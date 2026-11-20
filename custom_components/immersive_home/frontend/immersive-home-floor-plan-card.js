/**
 * Immersive Home floor plan cards: the rooms set up in the headset, with the
 * entities placed in them showing their live state.
 *
 * The floor plan is synced by the headsets (format: app/lib/utils/floor_plan.gd)
 * and served by the integration through `immersive_home/floor_plan/subscribe`.
 * Coordinates are meters, +Y up. Seen from above +X is right and +Z is down, so
 * floor coordinates [x, z] map straight onto SVG coordinates.
 *
 * 2D, seen from above:
 *   type: custom:immersive-home-floor-plan-card
 *   title: Home               # optional
 *   north_up: false           # turn the plan so north is up (uses the heading set in the headset)
 *   rotation: 0               # degrees clockwise, when north_up is off
 *   show_compass: true
 *   show_room_names: true
 *   show_headsets: true       # highlight the rooms a headset is in
 *   hide_entities: []         # entity ids not to show
 *
 * 3D, a dollhouse to turn by dragging (or the arrow keys), all options above plus:
 *   type: custom:immersive-home-floor-plan-3d-card
 *   pitch: 55                 # degrees the view looks down, 15 (side) to 90 (top)
 *   aspect_ratio: 1.333       # width / height of the view
 *
 * The 3D view is drawn in SVG with the painter's algorithm: floors first, then
 * the walls back to front. Walls facing the viewer are drawn see-through so the
 * rooms stay visible. That is plenty for extruded rooms and needs no WebGL library.
 */

const CARD_2D = "immersive-home-floor-plan-card";
const CARD_3D = "immersive-home-floor-plan-3d-card";
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

const clamp = (value, min, max) => Math.min(max, Math.max(min, value));
const DEG = Math.PI / 180;

/** Turns a floor point clockwise (as seen on screen) by `degrees`. */
const rotate = ([x, z], degrees) => {
  const c = Math.cos(degrees * DEG);
  const s = Math.sin(degrees * DEG);
  return [x * c - z * s, x * s + z * c];
};

/** Twice the signed area of a polygon, positive for counter-clockwise in a y-up frame. */
const signedArea = (points) =>
  points.reduce((sum, [x0, y0], i) => {
    const [x1, y1] = points[(i + 1) % points.length];
    return sum + x0 * y1 - x1 * y0;
  }, 0);

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

/** Subscription, messages, entity markers and headsets, shared by the 2D and 3D card. */
class FloorPlanCardBase extends HTMLElement {
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
    this._container = null;
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
    const rooms = new Set();
    if (!this._hass || this._config.show_headsets === false) return rooms;

    for (const entry of Object.values(this._hass.entities || {})) {
      if (entry.platform !== "immersive_home" || !entry.entity_id.startsWith("sensor.")) continue;
      const stateObj = this._hass.states[entry.entity_id];
      if (!isUnavailable(stateObj)) rooms.add(stateObj.state);
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
    this._teardown();

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
      <style>${BASE_STYLES}${this.constructor.styles || ""}</style>
      <ha-card ${title ? `header="${escapeHtml(title)}"` : ""}>
        <div class="content">${body}</div>
      </ha-card>`;

    if (plan && plan.rooms && plan.rooms.length > 0 && !this._error) {
      this._container = root.querySelector(".plan");
      this._renderPlan(this._container, plan);
      this._updateStates(true);
    }
  }

  /** Draws the plan into `container`, implemented by the cards. */
  _renderPlan(_container, _plan) {}

  /** Highlights the rooms headsets are in, implemented by the cards. */
  _applyHeadsets(_rooms) {}

  /** Releases what _renderPlan set up outside of the shadow DOM. */
  _teardown() {}

  _hiddenEntities() {
    return new Set(this._config.hide_entities || []);
  }

  _addRoomLabel(container, name) {
    const label = document.createElement("div");
    label.className = "room-label";
    label.innerHTML = `<ha-icon class="headset" icon="mdi:virtual-reality"></ha-icon><span>${escapeHtml(name)}</span>`;
    container.appendChild(label);
    this._roomLabels.set(name, label);
    return label;
  }

  _addMarker(container, entityId) {
    const element = document.createElement("button");
    element.className = "marker";
    element.addEventListener("click", () => {
      if (!this._suppressClick) this._moreInfo(entityId);
    });

    const icon = document.createElement("ha-state-icon");
    const value = document.createElement("span");
    value.className = "value";

    const bubble = document.createElement("div");
    bubble.className = "bubble";
    bubble.appendChild(icon);
    element.append(bubble, value);
    container.appendChild(element);

    const marker = { entityId, element, icon, value, stateObj: undefined };
    this._markers.push(marker);
    return marker;
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

    for (const [room, label] of this._roomLabels) {
      label.classList.toggle("occupied", headsetRooms.has(room));
    }
    this._applyHeadsets(headsetRooms);
  }

  _moreInfo(entityId) {
    this.dispatchEvent(
      new CustomEvent("hass-more-info", { bubbles: true, composed: true, detail: { entityId } }),
    );
  }
}

/** The floor plan seen from above. */
class FloorPlanCard extends FloorPlanCardBase {
  _renderPlan(container, plan) {
    const heading = Number(plan.heading) || 0;
    const angle = this._config.north_up ? heading : Number(this._config.rotation) || 0;
    const hidden = this._hiddenEntities();

    const rooms = plan.rooms.map((room) => ({
      name: room.name,
      points: room.polygon.map((p) => rotate(p, angle)),
    }));

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

    const place = (element, p) => {
      element.style.left = `${(((p[0] - minX) / width) * 100).toFixed(3)}%`;
      element.style.top = `${(((p[1] - minY) / height) * 100).toFixed(3)}%`;
    };
    const svgPoints = (points) => points.map((p) => `${p[0]},${p[1]}`).join(" ");

    container.style.aspectRatio = `${width} / ${height}`;

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
      ${this._config.show_compass !== false ? compassHtml(north) : ""}`;

    if (this._config.show_room_names !== false) {
      const markerPoints = entities.map((e) => e.point);
      for (const room of rooms) {
        place(this._addRoomLabel(container, room.name), labelPosition(room.points, markerPoints));
      }
    }

    for (const entity of entities) {
      place(this._addMarker(container, entity.id).element, entity.point);
    }
  }

  _applyHeadsets(rooms) {
    for (const polygon of this._container.querySelectorAll("polygon.room")) {
      polygon.classList.toggle("occupied", rooms.has(polygon.dataset.room));
    }
  }
}

const compassHtml = (degrees) =>
  `<div class="compass" title="North" style="transform: rotate(${degrees}deg)"><ha-icon icon="mdi:navigation"></ha-icon><span>N</span></div>`;

/**
 * Splits the wall from `a` to `b` around its door openings into quads
 * [t0, t1, y0, y1]: t along the wall from 0 to 1, y the height.
 */
const wallPieces = (a, b, height, openings) => {
  const pieces = [];
  let cursor = 0;

  for (const o of [...openings].sort((p, q) => p.t0 - q.t0)) {
    if (o.t0 > cursor) pieces.push([cursor, o.t0, 0, height]);
    const t0 = Math.max(o.t0, cursor);
    if (o.t1 > t0) {
      if (o.bottom > 0.02) pieces.push([t0, o.t1, 0, o.bottom]);
      if (o.top < height - 0.02) pieces.push([t0, o.t1, o.top, height]);
    }
    cursor = Math.max(cursor, o.t1);
  }
  if (cursor < 1) pieces.push([cursor, 1, 0, height]);

  return pieces.map(([t0, t1, y0, y1]) => {
    const p0 = [a[0] + (b[0] - a[0]) * t0, a[1] + (b[1] - a[1]) * t0];
    const p1 = [a[0] + (b[0] - a[0]) * t1, a[1] + (b[1] - a[1]) * t1];
    return [[p0[0], y0, p0[1]], [p1[0], y0, p1[1]], [p1[0], y1, p1[1]], [p0[0], y1, p0[1]]];
  });
};

/** Door openings of a room's wall from `a` to `b`, see wallPieces. */
const wallOpenings = (room, a, b, doors) => {
  const length = Math.hypot(b[0] - a[0], b[1] - a[1]);
  if (length < 1e-6) return [];

  const openings = [];
  for (const door of doors) {
    (door.rooms || []).forEach((name, side) => {
      const points = side === 0 ? door.room1 : door.room2;
      if (name !== room.name || !Array.isArray(points) || points.length !== 2) return;

      const floor = points.map((p) => [p[0], p[2]]);
      // The corners are placed on the wall, allow for the hand tracking being off a bit.
      if (floor.some((p) => distanceToSegment(p, a, b) > 0.3)) return;

      const ts = floor.map((p) => clamp(((p[0] - a[0]) * (b[0] - a[0]) + (p[1] - a[1]) * (b[1] - a[1])) / (length * length), 0, 1));
      let bottom = Math.max(0, Math.min(points[0][1], points[1][1]));
      let top = Math.min(room.height, Math.max(points[0][1], points[1][1]));
      // Both corners on the floor: an opening of regular door height.
      if (top - bottom < 0.1) {
        bottom = 0;
        top = Math.min(room.height, 2.0);
      }
      if (Math.abs(ts[1] - ts[0]) * length < 0.05) return;

      openings.push({ t0: Math.min(...ts), t1: Math.max(...ts), bottom, top });
    });
  }
  return openings;
};

/**
 * Orthographic camera around `center`: turned by `yaw` around Y (clockwise on
 * screen, like the 2D card), then tilted to look down by `pitch`. Returns
 * [screen x, screen y, depth], larger depth is nearer.
 */
const makeProjection = ([ox, oy, oz], yaw, pitch) => {
  const cy = Math.cos(yaw * DEG);
  const sy = Math.sin(yaw * DEG);
  const cp = Math.cos(pitch * DEG);
  const sp = Math.sin(pitch * DEG);

  return ([x, y, z]) => {
    const px = x - ox;
    const py = y - oy;
    const pz = z - oz;
    const x1 = px * cy - pz * sy;
    const z1 = px * sy + pz * cy;
    return [x1, z1 * sp - py * cp, z1 * cp + py * sp];
  };
};

/** The floor plan as a dollhouse that can be turned around. */
class FloorPlan3DCard extends FloorPlanCardBase {
  getCardSize() {
    return 7;
  }

  _renderPlan(container, plan) {
    const heading = Number(plan.heading) || 0;
    const hidden = this._hiddenEntities();
    const doors = plan.doors || [];

    const rooms = plan.rooms.map((room) => ({
      name: room.name,
      height: Math.max(0.1, Number(room.height) || 2.5),
      points: room.polygon,
    }));

    // Wall quads with their outward normal, which decides shading and see-through.
    const walls = [];
    for (const room of rooms) {
      const ccw = signedArea(room.points) > 0;
      room.points.forEach((a, i) => {
        const b = room.points[(i + 1) % room.points.length];
        const length = Math.hypot(b[0] - a[0], b[1] - a[1]);
        if (length < 1e-6) return;

        const dx = (b[0] - a[0]) / length;
        const dz = (b[1] - a[1]) / length;
        const normal = ccw ? [dz, -dx] : [-dz, dx];

        for (const corners of wallPieces(a, b, room.height, wallOpenings(room, a, b, doors))) {
          walls.push({ corners, normal });
        }
      });
    }

    const entities = (plan.entities || [])
      .filter((entity) => !hidden.has(entity.id))
      .map((entity) => ({ id: entity.id, position: entity.position }));

    // The view turns around the middle of the plan.
    const floor = [...rooms.flatMap((r) => r.points), ...entities.map((e) => [e.position[0], e.position[2]])];
    const xs = floor.map((p) => p[0]);
    const zs = floor.map((p) => p[1]);
    const maxHeight = Math.max(...rooms.map((r) => r.height), ...entities.map((e) => e.position[1]));
    const center = [(Math.min(...xs) + Math.max(...xs)) / 2, maxHeight / 2, (Math.min(...zs) + Math.max(...zs)) / 2];
    // What has to fit into the view: the room corners at floor and ceiling, and the entities.
    const fitPoints = [
      ...rooms.flatMap((r) => r.points.flatMap(([x, z]) => [[x, 0, z], [x, r.height, z]])),
      ...entities.map((e) => e.position),
    ];
    const extent = Math.max(...floor.map((p) => Math.hypot(p[0] - center[0], p[1] - center[2])));

    this._geometry = { rooms, walls, entities, center, fitPoints, extent, heading, fits: new Map() };

    const aspect = clamp(Number(this._config.aspect_ratio) || 4 / 3, 0.5, 3);
    this._aspect = aspect;
    this._initialView = {
      // Turned a bit by default: straight on, the walls facing the viewer are just lines.
      yaw: this._config.north_up ? heading : Number(this._config.rotation ?? 30) || 0,
      pitch: clamp(Number(this._config.pitch ?? 55), 15, 90),
    };
    this._view = this._view && this._viewKept ? this._view : { ...this._initialView };
    this._viewKept = true;
    this._occupied = new Set();

    container.classList.add("stage");
    container.tabIndex = 0;
    container.setAttribute("role", "application");
    container.setAttribute("aria-label", "3D floor plan. Drag or use the arrow keys to turn it, Home to reset.");
    container.style.aspectRatio = `${aspect}`;
    container.innerHTML = `
      <svg preserveAspectRatio="xMidYMid meet" aria-hidden="true"></svg>
      ${this._config.show_compass !== false ? compassHtml(0) : ""}
      <button class="reset" title="Reset view" aria-label="Reset view"><ha-icon icon="mdi:restore"></ha-icon></button>`;

    this._svg = container.querySelector("svg");
    this._compass = container.querySelector(".compass");
    this._reset = container.querySelector(".reset");
    this._reset.addEventListener("click", () => this._setView({ ...this._initialView }));

    if (this._config.show_room_names !== false) {
      for (const room of rooms) this._addRoomLabel(container, room.name);
    }

    for (const entity of entities) {
      this._addMarker(container, entity.id).position = entity.position;
    }

    this._listen(container);
    this._draw();
  }

  _listen(container) {
    let drag = null;

    container.addEventListener("pointerdown", (event) => {
      if (event.button !== 0 || event.target.closest(".reset")) return;
      drag = { x: event.clientX, y: event.clientY, view: { ...this._view }, moved: false, id: event.pointerId };
      this._suppressClick = false;
    });

    container.addEventListener("pointermove", (event) => {
      if (!drag || event.pointerId !== drag.id) return;
      const dx = event.clientX - drag.x;
      const dy = event.clientY - drag.y;

      if (!drag.moved && Math.hypot(dx, dy) < 4) return;
      if (!drag.moved) {
        drag.moved = true;
        try {
          // Keeps the drag going when the pointer leaves the card
          container.setPointerCapture(event.pointerId);
        } catch {
          // The pointer is already gone, the drag still works while over the card
        }
        container.classList.add("dragging");
      }

      this._setView({
        yaw: drag.view.yaw + dx * 0.5,
        pitch: clamp(drag.view.pitch + dy * 0.4, 15, 90),
      });
    });

    const end = (event) => {
      if (!drag || event.pointerId !== drag.id) return;
      // A drag that ends on a marker isn't a click on it. The click follows in the
      // same task, after that keyboard activation works again.
      if (drag.moved) {
        this._suppressClick = true;
        setTimeout(() => (this._suppressClick = false), 0);
      }
      container.classList.remove("dragging");
      drag = null;
    };
    container.addEventListener("pointerup", end);
    container.addEventListener("pointercancel", end);

    container.addEventListener("dblclick", (event) => {
      if (!event.target.closest(".marker, .reset")) this._setView({ ...this._initialView });
    });

    container.addEventListener("keydown", (event) => {
      const { yaw, pitch } = this._view;
      const views = {
        ArrowLeft: { yaw: yaw - 15, pitch },
        ArrowRight: { yaw: yaw + 15, pitch },
        ArrowUp: { yaw, pitch: clamp(pitch + 10, 15, 90) },
        ArrowDown: { yaw, pitch: clamp(pitch - 10, 15, 90) },
        Home: { ...this._initialView },
      };
      if (!views[event.key]) return;
      event.preventDefault();
      this._setView(views[event.key]);
    });
  }

  _setView(view) {
    this._view = view;
    if (this._frame) return;
    this._frame = requestAnimationFrame(() => {
      this._frame = null;
      this._draw();
    });
  }

  _teardown() {
    if (this._frame) cancelAnimationFrame(this._frame);
    this._frame = null;
  }

  setConfig(config) {
    // A changed configuration starts from its own view again.
    this._viewKept = false;
    super.setConfig(config);
  }

  _applyHeadsets(rooms) {
    this._occupied = rooms;
    this._draw();
  }

  /**
   * Half the width and height the plan needs at `pitch`, whichever way it is turned.
   * Sampled every 10 degrees of yaw, the last digit of the pitch is cached.
   */
  _fit(pitch) {
    const g = this._geometry;
    const key = Math.round(pitch);
    if (g.fits.has(key)) return g.fits.get(key);

    let halfWidth = 0;
    let halfHeight = 0;
    for (let yaw = 0; yaw < 360; yaw += 10) {
      const project = makeProjection(g.center, yaw, key);
      for (const point of g.fitPoints) {
        const [x, y] = project(point);
        halfWidth = Math.max(halfWidth, Math.abs(x));
        halfHeight = Math.max(halfHeight, Math.abs(y));
      }
    }
    // Between the samples the plan can reach a little further.
    const fit = [Math.min(halfWidth * 1.02, g.extent), halfHeight * 1.02];
    g.fits.set(key, fit);
    return fit;
  }

  _draw() {
    const g = this._geometry;
    if (!g || !this._svg) return;

    const { yaw, pitch } = this._view;
    const cy = Math.cos(yaw * DEG);
    const sy = Math.sin(yaw * DEG);

    const project = makeProjection(g.center, yaw, pitch);

    // Big enough for the plan at every yaw, so turning doesn't zoom.
    const [halfWidth, halfHeight] = this._fit(pitch);
    let width = 2 * (halfWidth + PADDING);
    let height = 2 * (halfHeight + PADDING);
    if (width / height < this._aspect) width = height * this._aspect;
    else height = width / this._aspect;
    const minX = -width / 2;
    const minY = -height / 2;

    const svgPoints = (points) => points.map((p) => `${p[0].toFixed(4)},${p[1].toFixed(4)}`).join(" ");
    const parts = [];

    const floors = g.rooms.map((room) => room.points.map(([x, z]) => project([x, 0, z])));
    g.rooms.forEach((room, i) => {
      const occupied = this._occupied.has(room.name) ? " occupied" : "";
      parts.push(`<polygon class="floor${occupied}" points="${svgPoints(floors[i])}"></polygon>`);
    });

    const walls = g.walls.map((wall) => {
      const points = wall.corners.map(project);
      const depth = points.reduce((sum, p) => sum + p[2], 0) / points.length;
      // The normal turned into the view: +z faces the viewer, x tells the side it faces.
      const [nx, nz] = wall.normal;
      const facing = nx * sy + nz * cy;
      const side = nx * cy - nz * sy;
      return { points, depth, near: facing > 0.05, shade: Math.round(16 + 8 * side) };
    });
    walls.sort((a, b) => a.depth - b.depth);

    for (const wall of walls) {
      parts.push(
        `<polygon class="wall${wall.near ? " near" : ""}" style="--shade: ${wall.shade}%" points="${svgPoints(wall.points)}"></polygon>`,
      );
    }

    // Stems show how high an entity hangs above the floor.
    const placed = this._markers.map((marker) => {
      const [x, y, z] = marker.position;
      const top = project([x, y, z]);
      const foot = project([x, 0, z]);
      parts.push(
        `<line class="stem" x1="${foot[0]}" y1="${foot[1]}" x2="${top[0]}" y2="${top[1]}"></line>`,
        `<circle class="foot" cx="${foot[0]}" cy="${foot[1]}" r="${(width / 200).toFixed(4)}"></circle>`,
      );
      return { marker, top };
    });

    this._svg.setAttribute("viewBox", `${minX} ${minY} ${width} ${height}`);
    this._svg.innerHTML = parts.join("");

    const place = (element, p) => {
      element.style.left = `${(((p[0] - minX) / width) * 100).toFixed(3)}%`;
      element.style.top = `${(((p[1] - minY) / height) * 100).toFixed(3)}%`;
    };

    // Nearer markers on top of further ones.
    const depths = placed.map((p) => p.top[2]).sort((a, b) => a - b);
    for (const { marker, top } of placed) {
      place(marker.element, top);
      marker.element.style.zIndex = String(2 + depths.indexOf(top[2]));
    }

    // On the room's floor where no marker hangs in front of it, in this view.
    if (this._roomLabels.size > 0) {
      const obstacles = placed.map((p) => p.top);
      g.rooms.forEach((room, i) => {
        const label = this._roomLabels.get(room.name);
        if (label) place(label, labelPosition(floors[i], obstacles));
      });
    }

    if (this._compass) {
      this._compass.style.transform = `rotate(${yaw - g.heading}deg)`;
    }

    const changed = Math.abs(yaw - this._initialView.yaw) > 0.5 || Math.abs(pitch - this._initialView.pitch) > 0.5;
    this._reset.classList.toggle("shown", changed);
  }
}

FloorPlanCard.styles = `
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
`;

FloorPlan3DCard.styles = `
  .stage {
    cursor: grab;
    touch-action: pan-y;
    user-select: none;
    -webkit-user-select: none;
    outline: none;
    border-radius: 8px;
  }
  .stage:focus-visible { box-shadow: 0 0 0 2px var(--primary-color); }
  .stage.dragging { cursor: grabbing; }
  .stage.dragging .marker { pointer-events: none; }
  .floor {
    fill: var(--secondary-background-color, #f5f5f5);
    stroke: var(--divider-color, rgba(0, 0, 0, 0.12));
    stroke-width: 1px;
    vector-effect: non-scaling-stroke;
  }
  .floor.occupied {
    fill: color-mix(in srgb, var(--primary-color) 18%, var(--secondary-background-color, #f5f5f5));
  }
  .wall {
    fill: color-mix(in srgb, var(--primary-text-color) var(--shade), var(--card-background-color, #fff));
    fill-opacity: 0.92;
    stroke: var(--primary-text-color);
    stroke-opacity: 0.55;
    stroke-width: 1.2px;
    stroke-linejoin: round;
    vector-effect: non-scaling-stroke;
  }
  /* Walls facing the viewer: just their outline, so the rooms stay visible */
  .wall.near {
    fill-opacity: 0.06;
    stroke-opacity: 0.22;
  }
  .stem {
    stroke: var(--secondary-text-color);
    stroke-opacity: 0.6;
    stroke-width: 1px;
    stroke-dasharray: 3 2;
    vector-effect: non-scaling-stroke;
  }
  .foot { fill: var(--secondary-text-color); fill-opacity: 0.5; }
  .room-label { z-index: 1; }
  .reset {
    position: absolute;
    right: 0;
    bottom: 0;
    z-index: 1000;
    display: none;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    border-radius: 50%;
    border: none;
    cursor: pointer;
    color: var(--primary-text-color);
    background: var(--secondary-background-color, #f5f5f5);
    --mdc-icon-size: 18px;
  }
  .reset.shown { display: flex; }
`;

const BASE_STYLES = `
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
    z-index: 1000;
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

const register = (type, element, name, description) => {
  if (customElements.get(type)) return;
  customElements.define(type, element);
  window.customCards = window.customCards || [];
  window.customCards.push({ type, name, description, preview: false });
};

register(
  CARD_2D,
  FloorPlanCard,
  "Immersive Home Floor Plan",
  "The rooms set up in Immersive Home with the live state of the entities placed in them.",
);
register(
  CARD_3D,
  FloorPlan3DCard,
  "Immersive Home 3D Floor Plan",
  "The rooms set up in Immersive Home as a dollhouse to turn around, with the live state of the entities in them.",
);
