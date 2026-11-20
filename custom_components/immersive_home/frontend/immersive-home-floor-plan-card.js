/**
 * Immersive Home floor plan card: the rooms set up in the headset seen from above,
 * with the entities placed in them showing their live state.
 *
 * The floor plan is synced by the headsets (format: app/lib/utils/floor_plan.gd)
 * and served by the integration through `immersive_home/floor_plan/subscribe`.
 * Floor coordinates are [x, z] in meters; seen from above +X is right and +Z is
 * down, so they map straight onto SVG coordinates.
 *
 * type: custom:immersive-home-floor-plan-card
 * title: Home               # optional
 * north_up: false           # turn the plan so north is up (uses the heading set in the headset)
 * rotation: 0               # degrees clockwise, when north_up is off
 * show_compass: true
 * show_room_names: true
 * show_headsets: true       # highlight the rooms a headset is in
 * hide_entities: []         # entity ids not to show
 */

const CARD_TYPE = "immersive-home-floor-plan-card";
// Margin around the plan, in meters.
const PADDING = 0.4;

// States drawn in the domain's active color.
const ACTIVE_STATES = new Set([
  "on", "open", "opening", "closing", "playing", "buffering", "home", "unlocked",
  "unlocking", "heat", "cool", "heat_cool", "auto", "dry", "fan_only", "cleaning",
  "returning", "active", "triggered", "pending", "arming", "armed_away", "armed_home",
  "armed_night", "armed_vacation", "armed_custom_bypass",
]);

// Domains whose value is shown below the marker.
const VALUE_DOMAINS = new Set(["sensor", "number", "input_number"]);

const escapeHtml = (text) =>
  String(text).replace(/[&<>"']/g, (c) =>
    ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[c]);

/** Turns a floor point clockwise (as seen on screen) by `degrees`. */
const rotate = ([x, z], degrees) => {
  const r = (degrees * Math.PI) / 180;
  const c = Math.cos(r);
  const s = Math.sin(r);
  return [x * c - z * s, x * s + z * c];
};

/** Area centroid of a polygon, the vertex average for degenerate ones. */
const centroid = (points) => {
  let area = 0;
  let cx = 0;
  let cy = 0;
  points.forEach(([x0, y0], i) => {
    const [x1, y1] = points[(i + 1) % points.length];
    const cross = x0 * y1 - x1 * y0;
    area += cross;
    cx += (x0 + x1) * cross;
    cy += (y0 + y1) * cross;
  });
  if (Math.abs(area) < 1e-6) {
    const n = points.length;
    return [points.reduce((s, p) => s + p[0], 0) / n, points.reduce((s, p) => s + p[1], 0) / n];
  }
  return [cx / (3 * area), cy / (3 * area)];
};

const insidePolygon = ([x, y], points) => {
  let inside = false;
  points.forEach(([x0, y0], i) => {
    const [x1, y1] = points[(i + 1) % points.length];
    if (y0 > y !== y1 > y && x < ((x1 - x0) * (y - y0)) / (y1 - y0) + x0) inside = !inside;
  });
  return inside;
};

const distanceToSegment = ([x, y], [x0, y0], [x1, y1]) => {
  const dx = x1 - x0;
  const dy = y1 - y0;
  const length = dx * dx + dy * dy;
  const t = length === 0 ? 0 : Math.max(0, Math.min(1, ((x - x0) * dx + (y - y0) * dy) / length));
  return Math.hypot(x - (x0 + t * dx), y - (y0 + t * dy));
};

/**
 * Where to put a room's name: the point of the room furthest from its walls and the
 * markers in it, so the name is readable. Searched on a grid, near the centroid wins ties.
 */
const labelPosition = (points, obstacles) => {
  const center = centroid(points);
  const xs = points.map((p) => p[0]);
  const ys = points.map((p) => p[1]);
  const minX = Math.min(...xs);
  const minY = Math.min(...ys);
  const step = Math.max(Math.max(...xs) - minX, Math.max(...ys) - minY) / 24;

  let best = center;
  let bestScore = -Infinity;

  for (let x = minX + step / 2; x < minX + step * 24; x += step) {
    for (let y = minY + step / 2; y < minY + step * 24; y += step) {
      if (!insidePolygon([x, y], points)) continue;

      // Labels are wide: walls left and right count less than above and below.
      const walls = Math.min(...points.map((p, i) => distanceToSegment([x, y], p, points[(i + 1) % points.length])));
      const markers = Math.min(Infinity, ...obstacles.map((o) => Math.hypot((x - o[0]) * 0.6, y - o[1])));
      const score = Math.min(walls, markers * 0.8, 1.2) - Math.hypot(x - center[0], y - center[1]) * 0.05;

      if (score > bestScore) {
        bestScore = score;
        best = [x, y];
      }
    }
  }
  return best;
};

const isUnavailable = (stateObj) =>
  !stateObj || stateObj.state === "unavailable" || stateObj.state === "unknown";

const markerColor = (stateObj) => {
  if (isUnavailable(stateObj)) return "var(--disabled-text-color, #bdbdbd)";

  const domain = stateObj.entity_id.split(".")[0];
  const rgb = stateObj.attributes.rgb_color;

  if (domain === "light" && stateObj.state === "on" && Array.isArray(rgb)) {
    return `rgb(${rgb.join(",")})`;
  }
  if (ACTIVE_STATES.has(stateObj.state)) {
    return `var(--state-${domain}-active-color, var(--state-active-color, var(--amber-color, #ffc107)))`;
  }
  return "var(--state-icon-color, var(--secondary-text-color))";
};

class ImmersiveHomeFloorPlanCard extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: "open" });
    this._config = {};
    this._hass = null;
    this._data = null; // {floor_plan, device_id, updated_at}
    this._error = null;
    this._unsub = null;
    this._markers = []; // {entityId, element, icon, value, stateObj}
    this._roomLabels = new Map(); // room name -> label element
  }

  static getStubConfig() {
    return {};
  }

  setConfig(config) {
    if (config.hide_entities && !Array.isArray(config.hide_entities)) {
      throw new Error("hide_entities must be a list of entity ids");
    }
    this._config = { ...config };
    this._render();
  }

  set hass(hass) {
    const first = !this._hass;
    this._hass = hass;
    if (first) this._subscribe();
    this._updateStates();
  }

  connectedCallback() {
    this._subscribe();
  }

  disconnectedCallback() {
    this._unsubscribe();
  }

  getCardSize() {
    return 6;
  }

  getGridOptions() {
    return { columns: 12, min_columns: 6, min_rows: 4 };
  }

  _subscribe() {
    if (this._unsub || !this._hass || !this.isConnected) return;

    this._unsub = this._hass.connection.subscribeMessage(
      (data) => {
        this._data = data;
        this._error = null;
        this._render();
      },
      { type: "immersive_home/floor_plan/subscribe" },
    );

    this._unsub.catch((err) => {
      this._unsub = null;
      this._error =
        err && err.code === "unknown_command"
          ? "The Immersive Home integration is not installed or needs to be updated."
          : `Could not load the floor plan: ${(err && (err.message || err.code)) || err}`;
      this._render();
    });
  }

  _unsubscribe() {
    if (!this._unsub) return;
    this._unsub.then((unsub) => unsub()).catch(() => {});
    this._unsub = null;
  }

  /** Room names a headset is in, from the room sensors of the integration. */
  _headsetRooms() {
    const rooms = new Map();
    if (!this._hass || this._config.show_headsets === false) return rooms;

    for (const entry of Object.values(this._hass.entities || {})) {
      if (entry.platform !== "immersive_home" || !entry.entity_id.startsWith("sensor.")) continue;
      const room = this._hass.states[entry.entity_id]?.state;
      if (room && !isUnavailable(this._hass.states[entry.entity_id])) {
        rooms.set(room, (rooms.get(room) || 0) + 1);
      }
    }
    return rooms;
  }

  _render() {
    const root = this.shadowRoot;
    const plan = this._data?.floor_plan;
    const title = this._config.title;

    this._markers = [];
    this._roomLabels = new Map();
    this._container = null;
    this._headsetKey = null;

    let body;
    if (this._error) {
      body = `<div class="message">${escapeHtml(this._error)}</div>`;
    } else if (!this._data) {
      body = `<div class="message">Loading floor plan…</div>`;
    } else if (!plan || !plan.rooms || plan.rooms.length === 0) {
      body = `<div class="message">No floor plan yet. Set up your rooms in Immersive Home while it is connected to Home Assistant.</div>`;
    } else {
      body = `<div class="plan"></div>`;
    }

    root.innerHTML = `
      <style>${STYLES}</style>
      <ha-card ${title ? `header="${escapeHtml(title)}"` : ""}>
        <div class="content">${body}</div>
      </ha-card>`;

    if (plan && plan.rooms && plan.rooms.length > 0 && !this._error) {
      this._renderPlan(root.querySelector(".plan"), plan);
      this._updateStates(true);
    }
  }

  _renderPlan(container, plan) {
    const heading = Number(plan.heading) || 0;
    const angle = this._config.north_up ? heading : Number(this._config.rotation) || 0;
    const hidden = new Set(this._config.hide_entities || []);

    const rooms = plan.rooms.map((room) => {
      const points = room.polygon.map((p) => rotate(p, angle));
      return { name: room.name, points };
    });

    const doors = (plan.doors || []).flatMap((door) =>
      [door.room1, door.room2]
        .filter((side) => Array.isArray(side) && side.length === 2)
        .map((side) => side.map((p) => rotate([p[0], p[2]], angle))),
    );

    const entities = (plan.entities || [])
      .filter((entity) => !hidden.has(entity.id))
      .map((entity) => ({
        id: entity.id,
        point: rotate([entity.position[0], entity.position[2]], angle),
      }));

    // Bounds of everything drawn
    const all = [...rooms.flatMap((r) => r.points), ...entities.map((e) => e.point)];
    const minX = Math.min(...all.map((p) => p[0])) - PADDING;
    const minY = Math.min(...all.map((p) => p[1])) - PADDING;
    const width = Math.max(...all.map((p) => p[0])) + PADDING - minX;
    const height = Math.max(...all.map((p) => p[1])) + PADDING - minY;

    const left = (p) => `${(((p[0] - minX) / width) * 100).toFixed(3)}%`;
    const top = (p) => `${(((p[1] - minY) / height) * 100).toFixed(3)}%`;
    const svgPoints = (points) => points.map((p) => `${p[0]},${p[1]}`).join(" ");

    container.style.aspectRatio = `${width} / ${height}`;

    const showCompass = this._config.show_compass !== false;
    // Bearing of screen-up is heading - angle, so north points angle - heading clockwise from up.
    const north = angle - heading;

    container.innerHTML = `
      <svg viewBox="${minX} ${minY} ${width} ${height}" preserveAspectRatio="xMidYMid meet" aria-hidden="true">
        ${rooms
          .map((room) => `<polygon class="room" data-room="${escapeHtml(room.name)}" points="${svgPoints(room.points)}"></polygon>`)
          .join("")}
        ${doors
          .map(([a, b]) => `<line class="door" x1="${a[0]}" y1="${a[1]}" x2="${b[0]}" y2="${b[1]}"></line>`)
          .join("")}
      </svg>
      ${showCompass
        ? `<div class="compass" title="North" style="transform: rotate(${north}deg)"><ha-icon icon="mdi:navigation"></ha-icon><span>N</span></div>`
        : ""}`;

    if (this._config.show_room_names !== false) {
      const markerPoints = entities.map((e) => e.point);

      for (const room of rooms) {
        const position = labelPosition(room.points, markerPoints);
        const label = document.createElement("div");
        label.className = "room-label";
        label.style.left = left(position);
        label.style.top = top(position);
        label.innerHTML = `<ha-icon class="headset" icon="mdi:virtual-reality"></ha-icon><span>${escapeHtml(room.name)}</span>`;
        container.appendChild(label);
        this._roomLabels.set(room.name, label);
      }
    }

    for (const entity of entities) {
      const element = document.createElement("button");
      element.className = "marker";
      element.style.left = left(entity.point);
      element.style.top = top(entity.point);
      element.addEventListener("click", () => this._moreInfo(entity.id));

      const icon = document.createElement("ha-state-icon");
      const value = document.createElement("span");
      value.className = "value";

      const bubble = document.createElement("div");
      bubble.className = "bubble";
      bubble.appendChild(icon);
      element.append(bubble, value);
      container.appendChild(element);

      this._markers.push({ entityId: entity.id, element, icon, value, stateObj: undefined });
    }

    this._container = container;
  }

  /** Applies the current states to the markers and room highlights, only where they changed. */
  _updateStates(force = false) {
    if (!this._hass || !this._container) return;
    const hass = this._hass;

    for (const marker of this._markers) {
      const stateObj = hass.states[marker.entityId];
      if (!force && stateObj === marker.stateObj) continue;
      marker.stateObj = stateObj;

      const color = markerColor(stateObj);
      const name = stateObj?.attributes.friendly_name || marker.entityId;
      const state = stateObj
        ? hass.formatEntityState ? hass.formatEntityState(stateObj) : stateObj.state
        : "not found";
      const domain = marker.entityId.split(".")[0];

      marker.element.style.setProperty("--marker-color", color);
      marker.element.classList.toggle("active", !isUnavailable(stateObj) && ACTIVE_STATES.has(stateObj.state));
      marker.element.classList.toggle("unavailable", isUnavailable(stateObj));
      marker.element.title = `${name}: ${state}`;
      marker.element.setAttribute("aria-label", `${name}: ${state}`);

      marker.icon.hass = hass;
      marker.icon.stateObj = stateObj;
      if (!stateObj) marker.icon.icon = "mdi:help-circle-outline";

      marker.value.textContent = stateObj && VALUE_DOMAINS.has(domain) && !isUnavailable(stateObj) ? state : "";
    }

    const headsetRooms = this._headsetRooms();
    const key = JSON.stringify([...headsetRooms]);
    if (!force && key === this._headsetKey) return;
    this._headsetKey = key;

    for (const polygon of this._container.querySelectorAll("polygon.room")) {
      polygon.classList.toggle("occupied", headsetRooms.has(polygon.dataset.room));
    }
    for (const [room, label] of this._roomLabels) {
      label.classList.toggle("occupied", headsetRooms.has(room));
    }
  }

  _moreInfo(entityId) {
    this.dispatchEvent(
      new CustomEvent("hass-more-info", { bubbles: true, composed: true, detail: { entityId } }),
    );
  }
}

const STYLES = `
  :host { display: block; }
  .content { padding: 12px 16px 16px; }
  ha-card:not([header]) .content { padding-top: 16px; }
  .message {
    color: var(--secondary-text-color);
    text-align: center;
    padding: 24px 8px;
  }
  .plan { position: relative; width: 100%; }
  svg { position: absolute; inset: 0; width: 100%; height: 100%; overflow: visible; }
  .room {
    fill: var(--secondary-background-color, #f5f5f5);
    stroke: var(--primary-text-color);
    stroke-width: 2.5px;
    stroke-linejoin: round;
    vector-effect: non-scaling-stroke;
    transition: fill 0.3s;
  }
  .room.occupied {
    fill: color-mix(in srgb, var(--primary-color) 18%, var(--secondary-background-color, #f5f5f5));
  }
  /* Cuts the doorway out of the wall */
  .door {
    stroke: var(--secondary-background-color, #f5f5f5);
    stroke-width: 5px;
    vector-effect: non-scaling-stroke;
  }
  .room-label {
    position: absolute;
    transform: translate(-50%, -50%);
    display: flex;
    align-items: center;
    gap: 2px;
    font-size: 12px;
    font-weight: 500;
    color: var(--secondary-text-color);
    white-space: nowrap;
    pointer-events: none;
  }
  .room-label.occupied { color: var(--primary-color); }
  .room-label .headset { --mdc-icon-size: 16px; display: none; }
  .room-label.occupied .headset { display: inline-flex; }
  .marker {
    position: absolute;
    transform: translate(-50%, -50%);
    display: flex;
    flex-direction: column;
    align-items: center;
    background: none;
    border: none;
    padding: 0;
    cursor: pointer;
    font: inherit;
    color: inherit;
    z-index: 1;
  }
  .marker:focus-visible { outline: none; }
  .marker:focus-visible .bubble { box-shadow: 0 0 0 3px var(--primary-color); }
  .bubble {
    width: 30px;
    height: 30px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    background: var(--card-background-color, #fff);
    border: 2px solid var(--marker-color);
    color: var(--marker-color);
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.25);
    transition: transform 0.15s, background 0.3s;
    --mdc-icon-size: 18px;
  }
  .marker.active .bubble {
    background: color-mix(in srgb, var(--marker-color) 22%, var(--card-background-color, #fff));
  }
  .marker.unavailable .bubble { border-style: dashed; }
  .marker:hover .bubble { transform: scale(1.12); }
  .value {
    margin-top: 2px;
    font-size: 11px;
    line-height: 1.2;
    padding: 0 4px;
    border-radius: 4px;
    color: var(--primary-text-color);
    background: color-mix(in srgb, var(--card-background-color, #fff) 85%, transparent);
    white-space: nowrap;
  }
  .value:empty { display: none; }
  .compass {
    position: absolute;
    top: 0;
    right: 0;
    display: flex;
    flex-direction: column;
    align-items: center;
    color: var(--secondary-text-color);
    font-size: 10px;
    font-weight: 600;
    --mdc-icon-size: 20px;
    pointer-events: none;
  }
`;

if (!customElements.get(CARD_TYPE)) {
  customElements.define(CARD_TYPE, ImmersiveHomeFloorPlanCard);

  window.customCards = window.customCards || [];
  window.customCards.push({
    type: CARD_TYPE,
    name: "Immersive Home Floor Plan",
    description: "The rooms set up in Immersive Home with the live state of the entities placed in them.",
    preview: false,
  });
}
