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
 *   overlay: none             # map shown at first: none, temperature or humidity
 *   hide_entities: []         # entity ids not to show
 *
 * The temperature and humidity maps color each room by the temperature or humidity
 * sensors (and climate entities) placed in it, blended by distance between them.
 * Hidden entities still count. Rooms without one stay uncolored. Below the plan are
 * buttons to switch between the maps and the legend of the one shown.
 *
 * 3D, a dollhouse to turn by dragging (or the arrow keys), to zoom by scrolling or
 * pinching (or + and -) and to move by dragging with the right mouse button, shift
 * held or two fingers. All options above plus:
 *   type: custom:immersive-home-floor-plan-3d-card
 *   pitch: 55                 # degrees the view looks down, 15 (side) to 90 (top)
 *   aspect_ratio: 1.333       # width / height of the view
 *   show_lighting: true       # lights that are on light up their room in their color
 *
 * Markers that would overlap are moved apart, with a line to where their entity is.
 *
 * Both cards have a visual editor built on Home Assistant's ha-form. Options set
 * to their default are left out of the configuration.
 *
 * The 3D view is drawn in SVG with the painter's algorithm: floors first, then
 * the walls back to front. Walls facing the viewer are drawn see-through so the
 * rooms stay visible. That is plenty for extruded rooms and needs no WebGL library.
 * Light is drawn as radial gradients over the floor and far walls of a light's room.
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

/** Approximate color of black-body light, for lights set by color temperature. */
const kelvinToRgb = (kelvin) => {
  const t = clamp(kelvin, 1000, 40000) / 100;
  const r = t <= 66 ? 255 : 329.698727446 * Math.pow(t - 60, -0.1332047592);
  const g = t <= 66 ? 99.4708025861 * Math.log(t) - 161.1195681661 : 288.1221695283 * Math.pow(t - 60, -0.0755148492);
  const b = t >= 66 ? 255 : t <= 19 ? 0 : 138.5177312231 * Math.log(t - 10) - 305.0447927307;
  return [r, g, b].map((v) => Math.round(clamp(v, 0, 255)));
};

/** The light a light entity gives off: {rgb, strength 0..1}, null when it is off. */
const lightGlow = (stateObj) => {
  if (!stateObj || !stateObj.entity_id.startsWith("light.") || stateObj.state !== "on") return null;
  const { rgb_color: rgb, color_temp_kelvin: kelvin, brightness } = stateObj.attributes;

  let color = [255, 190, 110]; // a warm white for lights without a color
  if (Array.isArray(rgb) && rgb.length === 3) color = rgb;
  else if (Number(kelvin) > 0) color = kelvinToRgb(Number(kelvin));

  const strength = typeof brightness === "number" ? 0.3 + 0.7 * clamp(brightness / 255, 0, 1) : 1;
  return { rgb: color, strength };
};

/**
 * Maps colored by the readings of the sensors placed in the rooms. Stops are
 * [value, rgb], temperatures in °C. The headset's Map View uses the same scales
 * (app/content/system/miniature: temp_gradient.tres, humid_gradient.tres and
 * default_scale in miniature.gd), keep them in step.
 */
const OVERLAYS = {
  temperature: {
    label: "Temperature",
    icon: "mdi:thermometer",
    stops: [[16, [49, 110, 206]], [19, [64, 176, 206]], [21.5, [92, 190, 110]], [24, [240, 200, 60]], [27, [240, 120, 50]], [30, [214, 48, 49]]],
  },
  humidity: {
    label: "Humidity",
    icon: "mdi:water-percent",
    stops: [[20, [214, 130, 50]], [35, [236, 200, 100]], [45, [110, 190, 120]], [60, [70, 165, 215]], [80, [40, 80, 200]]],
  },
};

const toCelsius = (value, unit) => (unit === "°F" ? ((value - 32) * 5) / 9 : value);

/** The temperature (°C) or humidity (%) an entity reads, null when it has none. */
const sensorReading = (stateObj, kind, systemUnit) => {
  if (isUnavailable(stateObj)) return null;
  const domain = stateObj.entity_id.split(".")[0];
  const attributes = stateObj.attributes;
  let value = null;

  if (domain === "climate") {
    value = Number(attributes[kind === "temperature" ? "current_temperature" : "current_humidity"]);
    if (kind === "temperature") value = toCelsius(value, systemUnit);
  } else if (domain === "sensor" && attributes.device_class === kind) {
    value = Number(stateObj.state);
    if (kind === "temperature") value = toCelsius(value, attributes.unit_of_measurement);
  }
  return Number.isFinite(value) ? value : null;
};

/** The color of `value` on a scale of OVERLAYS. */
const scaleColor = (stops, value) => {
  if (value <= stops[0][0]) return stops[0][1];
  for (let i = 1; i < stops.length; i++) {
    const [v1, c1] = stops[i];
    if (value > v1) continue;
    const [v0, c0] = stops[i - 1];
    const t = (value - v0) / (v1 - v0);
    return c0.map((c, k) => Math.round(c + (c1[k] - c) * t));
  }
  return stops[stops.length - 1][1];
};

/**
 * The readings blended over a room's floor, by inverse distance weighting, as an
 * image covering the room's bounds in floor coordinates.
 */
const fieldImage = (polygon, readings, stops) => {
  const xs = polygon.map((p) => p[0]);
  const zs = polygon.map((p) => p[1]);
  const minX = Math.min(...xs);
  const minZ = Math.min(...zs);
  const width = Math.max(Math.max(...xs) - minX, 0.01);
  const height = Math.max(Math.max(...zs) - minZ, 0.01);

  // About 10 cm a pixel, the browser smooths it when scaling up.
  const scale = Math.min(10, 96 / Math.max(width, height));
  const canvas = document.createElement("canvas");
  canvas.width = Math.max(2, Math.ceil(width * scale));
  canvas.height = Math.max(2, Math.ceil(height * scale));
  const context = canvas.getContext("2d");
  const image = context.createImageData(canvas.width, canvas.height);

  for (let py = 0; py < canvas.height; py++) {
    const z = minZ + ((py + 0.5) / canvas.height) * height;
    for (let px = 0; px < canvas.width; px++) {
      const x = minX + ((px + 0.5) / canvas.width) * width;
      let sum = 0;
      let weights = 0;
      for (const r of readings) {
        const weight = 1 / ((x - r.x) ** 2 + (z - r.z) ** 2 + 0.04);
        sum += r.value * weight;
        weights += weight;
      }
      const [red, green, blue] = scaleColor(stops, sum / weights);
      const i = (py * canvas.width + px) * 4;
      image.data[i] = red;
      image.data[i + 1] = green;
      image.data[i + 2] = blue;
      image.data[i + 3] = 255;
    }
  }
  context.putImageData(image, 0, 0);
  return { href: canvas.toDataURL(), x: minX, y: minZ, width, height };
};

/**
 * Pushes overlapping markers apart. Nodes are {x, y, r, ax, ay} in pixels, (ax, ay)
 * the true position. Markers whose true position is in the view are kept in it.
 */
const spreadOut = (nodes, width, height) => {
  for (let iteration = 0; iteration < 60; iteration++) {
    let overlap = false;

    for (let i = 0; i < nodes.length; i++) {
      for (let j = i + 1; j < nodes.length; j++) {
        const a = nodes[i];
        const b = nodes[j];
        const dx = b.x - a.x;
        const dy = b.y - a.y;
        const min = a.r + b.r + 2;
        if (Math.abs(dx) >= min || Math.abs(dy) >= min) continue;
        const distance = Math.hypot(dx, dy);
        if (distance >= min) continue;
        overlap = true;

        let ux = dx / distance;
        let uy = dy / distance;
        if (distance < 0.01) {
          // Same spot: fan them out, the golden angle keeps the directions apart.
          const angle = (i + j) * 2.39996;
          ux = Math.cos(angle);
          uy = Math.sin(angle);
        }
        const push = (min - distance) / 2;
        a.x -= ux * push;
        a.y -= uy * push;
        b.x += ux * push;
        b.y += uy * push;
      }
    }

    for (const n of nodes) {
      if (n.ax < 0 || n.ax > width || n.ay < 0 || n.ay > height) continue;
      n.x = clamp(n.x, Math.min(n.r, n.ax), Math.max(width - n.r, n.ax));
      n.y = clamp(n.y, Math.min(n.r, n.ay), Math.max(height - n.r, n.ay));
    }
    if (!overlap) break;
  }
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
    if (config.overlay && config.overlay !== "none" && !OVERLAYS[config.overlay]) {
      throw new Error(`overlay must be one of none, ${Object.keys(OVERLAYS).join(", ")}`);
    }
    this._config = { ...config };
    this._overlay = OVERLAYS[config.overlay] ? config.overlay : null;
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
    this._leaders = null;
    this._headsetKey = null;
    this._plan = plan;
    this._readings = null; // {temperature: [{room, x, z, value}], humidity: [...]}
    this._readingsKey = null;
    this._overlayLayers = new Map(); // overlay -> SVG in floor coordinates
    this._overlayBar = null;
    this._resizeObserver?.disconnect();
    this._resizeObserver = null;
    this._teardown();

    let body;
    if (this._error) {
      body = `<div class="message">${escapeHtml(this._error)}</div>`;
    } else if (!this._data) {
      body = `<div class="message">Loading floor plan…</div>`;
    } else if (!plan || !plan.rooms || plan.rooms.length === 0) {
      body = `<div class="message">No floor plan yet. Set up your rooms in Immersive Home while it is connected to Home Assistant.</div>`;
    } else {
      body = `<div class="plan"></div><div class="overlay-bar" hidden></div>`;
    }

    root.innerHTML = `
      <style>${BASE_STYLES}${this.constructor.styles || ""}</style>
      <ha-card ${title ? `header="${escapeHtml(title)}"` : ""}>
        <div class="content">${body}</div>
      </ha-card>`;

    if (plan && plan.rooms && plan.rooms.length > 0 && !this._error) {
      this._container = root.querySelector(".plan");
      this._overlayBar = root.querySelector(".overlay-bar");
      this._renderPlan(this._container, plan);
      this._updateStates(true);

      // Marker spacing is in pixels, it is redone when the card changes size.
      if (window.ResizeObserver) {
        this._resizeObserver = new ResizeObserver(() => this._resized());
        this._resizeObserver.observe(this._container);
      }
    }
  }

  /** Draws the plan into `container`, implemented by the cards. */
  _renderPlan(_container, _plan) {}

  /** The card changed size, implemented by the cards. */
  _resized() {}

  /** Marker states changed, `layout` when a marker changed size. Implemented by the cards. */
  _markersChanged(_layout) {}

  /**
   * Places the markers at their points (in the units of `box`, the viewBox), moving
   * apart the ones that would overlap and linking those to their true position.
   * Returns where each marker ended up, in the units of `box`.
   */
  _spreadMarkers(placed, box) {
    const container = this._container;
    const width = container.clientWidth;
    const height = container.clientHeight;
    const sx = width / box.width;
    const sy = height / box.height;

    const nodes = placed.map(({ marker, point }) => {
      const x = (point[0] - box.minX) * sx;
      const y = (point[1] - box.minY) * sy;
      // Markers with a value below are taller.
      return { marker, point, ax: x, ay: y, x, y, r: marker.value.textContent ? 23 : 17 };
    });
    if (width > 0 && height > 0) spreadOut(nodes, width, height);

    const lines = [];
    for (const n of nodes) {
      const element = n.marker.element;
      element.style.left = `${(((n.point[0] - box.minX) / box.width) * 100).toFixed(3)}%`;
      element.style.top = `${(((n.point[1] - box.minY) / box.height) * 100).toFixed(3)}%`;
      const dx = n.x - n.ax;
      const dy = n.y - n.ay;
      element.style.setProperty("--dx", `${dx.toFixed(1)}px`);
      element.style.setProperty("--dy", `${dy.toFixed(1)}px`);

      if (Math.hypot(dx, dy) > 4) {
        lines.push(
          `<line class="leader" x1="${n.ax.toFixed(1)}" y1="${n.ay.toFixed(1)}" x2="${n.x.toFixed(1)}" y2="${n.y.toFixed(1)}"></line>`,
          `<circle class="anchor" cx="${n.ax.toFixed(1)}" cy="${n.ay.toFixed(1)}" r="2.5"></circle>`,
        );
      }
    }
    if (this._leaders) this._leaders.innerHTML = lines.join("");

    return nodes.map((n) => (width > 0 && height > 0 ? [box.minX + n.x / sx, box.minY + n.y / sy] : n.point));
  }

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
    let changed = false;
    let layout = false;

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

      const glow = lightGlow(stateObj);
      marker.element.classList.toggle("lit", !!glow);
      if (glow) marker.element.style.setProperty("--glow-rgb", glow.rgb.join(", "));

      const value = stateObj && VALUE_DOMAINS.has(domain) && !isUnavailable(stateObj) ? state : "";
      if (!value !== !marker.value.textContent) layout = true;
      marker.value.textContent = value;
      changed = true;
    }
    if (changed) this._markersChanged(layout);
    this._updateReadings();

    const headsetRooms = this._headsetRooms();
    const key = JSON.stringify([...headsetRooms]);
    if (!force && key === this._headsetKey) return;
    this._headsetKey = key;

    for (const [room, label] of this._roomLabels) {
      label.classList.toggle("occupied", headsetRooms.has(room));
    }
    this._applyHeadsets(headsetRooms);
  }

  /**
   * Collects the temperatures and humidities of the entities placed in the plan,
   * hidden ones too, and redraws the map when they changed.
   */
  _updateReadings() {
    const plan = this._plan;
    if (!plan || !this._hass) return;
    const systemUnit = this._hass.config?.unit_system?.temperature;

    const readings = Object.fromEntries(Object.keys(OVERLAYS).map((kind) => [kind, []]));
    for (const entity of plan.entities || []) {
      const stateObj = this._hass.states[entity.id];
      if (!stateObj || !Array.isArray(entity.position)) continue;
      const [x, , z] = entity.position;

      let room = plan.rooms.findIndex((r) => insidePolygon([x, z], r.polygon));
      if (room < 0) room = plan.rooms.findIndex((r) => r.name === entity.room);
      if (room < 0) continue;

      for (const kind of Object.keys(OVERLAYS)) {
        const value = sensorReading(stateObj, kind, systemUnit);
        if (value !== null) readings[kind].push({ room, x, z, value: Math.round(value * 10) / 10 });
      }
    }

    const key = JSON.stringify(readings);
    if (key === this._readingsKey) return;
    this._readingsKey = key;
    this._readings = readings;
    this._overlayLayers = new Map();
    this._renderOverlayBar();
    this._overlayChanged();
  }

  /** The map that is shown, null for none. */
  _activeOverlay() {
    return this._overlay && this._readings?.[this._overlay]?.length ? this._overlay : null;
  }

  /**
   * The map shown, as SVG in floor coordinates: rooms with one reading in its
   * color, rooms with more blended between them. Rooms without one are left out.
   */
  _overlaySvg() {
    const kind = this._activeOverlay();
    if (!kind) return "";
    if (this._overlayLayers.has(kind)) return this._overlayLayers.get(kind);

    const { stops } = OVERLAYS[kind];
    const id = `${kind}-${Math.random().toString(36).slice(2, 8)}`;
    const parts = this._plan.rooms.map((room, i) => {
      const readings = this._readings[kind].filter((r) => r.room === i);
      if (readings.length === 0) return "";
      const points = room.polygon.map((p) => p.join(",")).join(" ");

      if (readings.length === 1) {
        return `<polygon points="${points}" fill="rgb(${scaleColor(stops, readings[0].value).join(",")})"></polygon>`;
      }
      const image = fieldImage(room.polygon, readings, stops);
      return `
        <clipPath id="clip-${id}-${i}"><polygon points="${points}"></polygon></clipPath>
        <image href="${image.href}" x="${image.x}" y="${image.y}" width="${image.width}" height="${image.height}"
          preserveAspectRatio="none" clip-path="url(#clip-${id}-${i})"></image>`;
    });

    const svg = parts.join("");
    this._overlayLayers.set(kind, svg);
    return svg;
  }

  /** The switches between the maps below the plan, with the legend of the shown one. */
  _renderOverlayBar() {
    const bar = this._overlayBar;
    if (!bar) return;

    const kinds = Object.keys(OVERLAYS).filter((kind) => this._readings?.[kind]?.length);
    bar.hidden = kinds.length === 0;
    if (bar.hidden) return;

    const active = this._activeOverlay();
    const fahrenheit = this._hass?.config?.unit_system?.temperature === "°F";
    const format = (kind, value) =>
      kind === "temperature"
        ? `${Math.round(fahrenheit ? (value * 9) / 5 + 32 : value)}${fahrenheit ? "°F" : "°C"}`
        : `${value}%`;

    let legend = "";
    if (active) {
      const { stops } = OVERLAYS[active];
      const min = stops[0][0];
      const max = stops[stops.length - 1][0];
      const gradient = stops
        .map(([value, rgb]) => `rgb(${rgb.join(",")}) ${(((value - min) / (max - min)) * 100).toFixed(1)}%`)
        .join(", ");
      legend = `
        <div class="legend">
          <span>${format(active, min)}</span>
          <div class="scale" style="background: linear-gradient(to right, ${gradient})"></div>
          <span>${format(active, max)}</span>
        </div>`;
    }

    bar.innerHTML = `
      ${kinds
        .map(
          (kind) => `
        <button class="chip${kind === active ? " active" : ""}" data-overlay="${kind}" aria-pressed="${kind === active}">
          <ha-icon icon="${OVERLAYS[kind].icon}"></ha-icon><span>${OVERLAYS[kind].label}</span>
        </button>`,
        )
        .join("")}
      ${legend}`;

    for (const button of bar.querySelectorAll("[data-overlay]")) {
      button.addEventListener("click", () => {
        // A second click on the shown map hides it.
        this._overlay = this._overlay === button.dataset.overlay ? null : button.dataset.overlay;
        this._renderOverlayBar();
        this._overlayChanged();
      });
    }
  }

  /** The map to show changed, implemented by the cards. */
  _overlayChanged() {}

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
        <g class="heat" transform="rotate(${angle})"></g>
        ${rooms.map((room) => `<polygon class="outline" points="${svgPoints(room.points)}"></polygon>`).join("")}
        ${doors
          .map(([a, b]) => `<line class="door" x1="${a[0]}" y1="${a[1]}" x2="${b[0]}" y2="${b[1]}"></line>`)
          .join("")}
      </svg>
      <svg class="leaders" aria-hidden="true"></svg>
      ${this._config.show_compass !== false ? compassHtml(north) : ""}`;
    this._leaders = container.querySelector(".leaders");

    if (this._config.show_room_names !== false) {
      const markerPoints = entities.map((e) => e.point);
      for (const room of rooms) {
        place(this._addRoomLabel(container, room.name), labelPosition(room.points, markerPoints));
      }
    }

    this._layout = {
      box: { minX, minY, width, height },
      placed: entities.map((entity) => ({ marker: this._addMarker(container, entity.id), point: entity.point })),
    };
    this._spreadMarkers(this._layout.placed, this._layout.box);
  }

  _resized() {
    if (this._layout) this._spreadMarkers(this._layout.placed, this._layout.box);
  }

  _markersChanged(layout) {
    if (layout) this._resized();
  }

  _overlayChanged() {
    const layer = this._container?.querySelector(".heat");
    if (layer) layer.innerHTML = this._overlaySvg();
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

// How far the 3D view zooms in.
const MAX_ZOOM = 8;

/** The color stops of a light's glow, [offset, opacity] scaled by `strength`. */
const glowStops = (color, strength, stops) =>
  stops
    .map(([offset, opacity]) => `<stop offset="${offset}" stop-color="${color}" stop-opacity="${(opacity * strength).toFixed(3)}"></stop>`)
    .join("");

/** The floor plan as a dollhouse that can be turned around and zoomed into. */
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
    rooms.forEach((room, roomIndex) => {
      const ccw = signedArea(room.points) > 0;
      room.points.forEach((a, i) => {
        const b = room.points[(i + 1) % room.points.length];
        const length = Math.hypot(b[0] - a[0], b[1] - a[1]);
        if (length < 1e-6) return;

        const dx = (b[0] - a[0]) / length;
        const dz = (b[1] - a[1]) / length;
        const normal = ccw ? [dz, -dx] : [-dz, dx];

        for (const corners of wallPieces(a, b, room.height, wallOpenings(room, a, b, doors))) {
          walls.push({ corners, normal, room: roomIndex });
        }
      });
    });

    const entities = (plan.entities || [])
      .filter((entity) => !hidden.has(entity.id))
      .map((entity) => ({ id: entity.id, position: entity.position }));

    // The view turns around the middle of the plan.
    const floor = [...rooms.flatMap((r) => r.points), ...entities.map((e) => [e.position[0], e.position[2]])];
    const xs = floor.map((p) => p[0]);
    const zs = floor.map((p) => p[1]);
    const maxHeight = Math.max(...rooms.map((r) => r.height), ...entities.map((e) => e.position[1]));
    const center = [(Math.min(...xs) + Math.max(...xs)) / 2, maxHeight / 2, (Math.min(...zs) + Math.max(...zs)) / 2];
    // How far the view can move from the middle when zoomed all the way in.
    const reach = [(Math.max(...xs) - Math.min(...xs)) / 2, (Math.max(...zs) - Math.min(...zs)) / 2];
    // What has to fit into the view: the room corners at floor and ceiling, and the entities.
    const fitPoints = [
      ...rooms.flatMap((r) => r.points.flatMap(([x, z]) => [[x, 0, z], [x, r.height, z]])),
      ...entities.map((e) => e.position),
    ];
    const extent = Math.max(...floor.map((p) => Math.hypot(p[0] - center[0], p[1] - center[2])));

    this._geometry = { rooms, walls, entities, center, reach, fitPoints, extent, heading, fits: new Map() };

    const aspect = clamp(Number(this._config.aspect_ratio) || 4 / 3, 0.5, 3);
    this._aspect = aspect;
    this._initialView = {
      // Turned a bit by default: straight on, the walls facing the viewer are just lines.
      yaw: this._config.north_up ? heading : Number(this._config.rotation ?? 30) || 0,
      pitch: clamp(Number(this._config.pitch ?? 55), 15, 90),
      zoom: 1,
      target: [center[0], center[2]],
    };
    this._view = this._view && this._viewKept ? { ...this._initialView, ...this._view } : { ...this._initialView };
    this._viewKept = true;
    this._occupied = new Set();
    this._lightsKey = null;

    container.classList.add("stage");
    container.tabIndex = 0;
    container.setAttribute("role", "application");
    container.setAttribute(
      "aria-label",
      "3D floor plan. Drag or use the arrow keys to turn it, scroll, pinch or use plus and minus to zoom, " +
        "drag with the right mouse button or shift held to move it, Home to reset.",
    );
    container.style.aspectRatio = `${aspect}`;
    container.innerHTML = `
      <svg class="scene" preserveAspectRatio="xMidYMid meet" aria-hidden="true">
        <g class="floors"></g><g class="heat"></g><g class="above"></g>
      </svg>
      <svg class="leaders" aria-hidden="true"></svg>
      ${this._config.show_compass !== false ? compassHtml(0) : ""}
      <button class="reset" title="Reset view" aria-label="Reset view"><ha-icon icon="mdi:restore"></ha-icon></button>`;

    this._svg = container.querySelector(".scene");
    this._floorsLayer = container.querySelector(".floors");
    this._heatLayer = container.querySelector(".heat");
    this._aboveLayer = container.querySelector(".above");
    this._leaders = container.querySelector(".leaders");
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
    const pointers = new Map(); // pointer id -> {x, y}, of the pointers pressed on the card
    let drag = null;

    const capture = (id) => {
      try {
        // Keeps the drag going when the pointer leaves the card
        container.setPointerCapture(id);
      } catch {
        // The pointer is already gone, the drag still works while over the card
      }
    };

    const begin = (id, x, y, mode, moved = false) => {
      drag = {
        mode, // "turn", "pan" or "pinch"
        id,
        x,
        y,
        view: { ...this._view },
        box: this._box(this._view),
        rect: container.getBoundingClientRect(),
        moved,
        turn: mode === "turn" ? this._turnDirection(container, y) : 1,
      };
    };

    container.addEventListener("pointerdown", (event) => {
      if (event.button > 2 || event.target.closest(".reset")) return;
      // The middle button would start the browser's autoscroll.
      if (event.button === 1) event.preventDefault();
      pointers.set(event.pointerId, { x: event.clientX, y: event.clientY });

      if (pointers.size === 2) {
        // Two fingers: pinch to zoom, move both to pan.
        const [a, b] = [...pointers.values()];
        begin(event.pointerId, 0, 0, "pinch", true);
        drag.mid = [(a.x + b.x) / 2, (a.y + b.y) / 2];
        drag.distance = Math.max(1, Math.hypot(a.x - b.x, a.y - b.y));
        for (const id of pointers.keys()) capture(id);
        container.classList.add("dragging");
      } else if (pointers.size === 1) {
        const pan = event.button !== 0 || event.shiftKey || event.ctrlKey;
        begin(event.pointerId, event.clientX, event.clientY, pan ? "pan" : "turn");
        this._suppressClick = false;
      }
    });

    container.addEventListener("pointermove", (event) => {
      const pointer = pointers.get(event.pointerId);
      if (!pointer || !drag) return;
      pointer.x = event.clientX;
      pointer.y = event.clientY;

      if (drag.mode === "pinch") {
        this._pinch(drag, [...pointers.values()]);
        return;
      }
      if (event.pointerId !== drag.id) return;

      const dx = event.clientX - drag.x;
      const dy = event.clientY - drag.y;

      if (!drag.moved && Math.hypot(dx, dy) < 4) return;
      if (!drag.moved) {
        drag.moved = true;
        capture(event.pointerId);
        container.classList.add("dragging");
      }

      if (drag.mode === "pan") {
        // The plan follows the pointer.
        const scale = drag.box.width / drag.rect.width;
        this._setView({ ...drag.view, target: this._moveTarget(drag.view, -dx * scale, -dy * scale) });
      } else {
        this._setView({
          ...drag.view,
          yaw: drag.view.yaw + dx * 0.5 * drag.turn,
          pitch: clamp(drag.view.pitch + dy * 0.4, 15, 90),
        });
      }
    });

    const end = (event) => {
      if (!pointers.delete(event.pointerId) || !drag) return;
      if (drag.mode !== "pinch" && event.pointerId !== drag.id) return;

      // A drag that ends on a marker isn't a click on it. The click follows in the
      // same task, after that keyboard activation works again.
      if (drag.moved) {
        this._suppressClick = true;
        setTimeout(() => (this._suppressClick = false), 0);
      }

      // One finger of a pinch lifted: the other one turns the plan from here on.
      const [rest] = pointers.entries();
      if (drag.mode === "pinch" && rest) {
        begin(rest[0], rest[1].x, rest[1].y, "turn", true);
        return;
      }
      container.classList.remove("dragging");
      drag = null;
    };
    container.addEventListener("pointerup", end);
    container.addEventListener("pointercancel", end);
    container.addEventListener("contextmenu", (event) => event.preventDefault());

    container.addEventListener("dblclick", (event) => {
      if (!event.target.closest(".marker, .reset")) this._setView({ ...this._initialView });
    });

    container.addEventListener(
      "wheel",
      (event) => {
        const pixels = event.deltaY * (event.deltaMode === 1 ? 16 : event.deltaMode === 2 ? 400 : 1);
        // A trackpad pinch arrives as a wheel event with ctrl held and small deltas.
        const factor = Math.exp(-pixels * (event.ctrlKey ? 0.01 : 0.002));
        // Zoomed all the way out, scrolling down scrolls the page.
        if (factor < 1 && this._view.zoom <= 1) return;
        event.preventDefault();
        this._zoomAt(factor, event.clientX, event.clientY);
      },
      { passive: false },
    );

    container.addEventListener("keydown", (event) => {
      const view = this._view;
      const { yaw, pitch } = view;
      const zoom = { "+": 1.25, "=": 1.25, "-": 0.8, _: 0.8 }[event.key];
      if (zoom) {
        event.preventDefault();
        this._zoomAt(zoom);
        return;
      }

      const views = {
        ArrowLeft: { ...view, yaw: yaw - 15 },
        ArrowRight: { ...view, yaw: yaw + 15 },
        ArrowUp: { ...view, pitch: clamp(pitch + 10, 15, 90) },
        ArrowDown: { ...view, pitch: clamp(pitch - 10, 15, 90) },
        Home: { ...this._initialView },
      };
      if (!views[event.key]) return;
      event.preventDefault();
      this._setView(views[event.key]);
    });
  }

  /** Zooms by `factor`, keeping the point under the pointer where it is. */
  _zoomAt(factor, clientX, clientY) {
    const view = this._view;
    const zoom = clamp(view.zoom * factor, 1, MAX_ZOOM);
    if (Math.abs(zoom - view.zoom) < 1e-4) return;

    let offset = [0, 0];
    const rect = this._container?.getBoundingClientRect();
    if (clientX !== undefined && rect && rect.width > 0) {
      const box = this._box(view);
      const k = 1 - view.zoom / zoom;
      offset = [
        (box.minX + ((clientX - rect.left) / rect.width) * box.width) * k,
        (box.minY + ((clientY - rect.top) / rect.height) * box.height) * k,
      ];
    }
    this._setView({ ...view, zoom, target: this._moveTarget({ ...view, zoom }, ...offset) });
  }

  /** Two fingers: zoom by their spread around their midpoint, which also pans. */
  _pinch(drag, [a, b]) {
    if (!b) return;
    const view = drag.view;
    const zoom = clamp((view.zoom * Math.hypot(a.x - b.x, a.y - b.y)) / drag.distance, 1, MAX_ZOOM);
    const k = 1 - view.zoom / zoom;
    const mid = [(a.x + b.x) / 2, (a.y + b.y) / 2];
    const scale = drag.box.width / drag.rect.width;

    // Panned with the midpoint, then zoomed around where the midpoint is now.
    const dx = -(mid[0] - drag.mid[0]) * scale + (drag.box.minX + (mid[0] - drag.rect.left) * scale) * k;
    const dy = -(mid[1] - drag.mid[1]) * scale + (drag.box.minY + (mid[1] - drag.rect.top) * scale) * k;
    this._setView({ ...view, zoom, target: this._moveTarget({ ...view, zoom }, dx, dy) });
  }

  /**
   * The target of `view` moved so the plan moves by (-dx, -dy) on screen, in view
   * units. Kept so the plan doesn't leave the view: the less zoomed, the less it moves.
   */
  _moveTarget(view, dx, dy) {
    const cy = Math.cos(view.yaw * DEG);
    const sy = Math.sin(view.yaw * DEG);
    // Screen x runs along the floor, screen y along the floor shortened by the tilt.
    const depth = dy / Math.max(Math.sin(view.pitch * DEG), 0.2);
    return this._clampTarget([view.target[0] + dx * cy + depth * sy, view.target[1] - dx * sy + depth * cy], view.zoom);
  }

  _clampTarget(target, zoom) {
    const { center, reach } = this._geometry;
    const free = 1 - 1 / zoom;
    return [
      clamp(target[0], center[0] - reach[0] * free, center[0] + reach[0] * free),
      clamp(target[1], center[2] - reach[1] * free, center[2] + reach[1] * free),
    ];
  }

  /**
   * Which way a horizontal drag turns the plan, so the part that was grabbed follows
   * the pointer like on a turntable: increasing the yaw turns the plan clockwise,
   * which moves its far half (above the middle of the floor) right and its near half
   * left. Grabbed below the middle of the floor the turn is reversed.
   */
  _turnDirection(container, clientY) {
    if (!this._geometry) return 1;
    const box = this._box(this._view);

    // The middle of the floor: the view's target on the floor, on screen.
    const floorY = this._geometry.center[1] * Math.cos(this._view.pitch * DEG);
    const rect = container.getBoundingClientRect();
    const screenY = rect.top + ((floorY - box.minY) / box.height) * rect.height;

    return clientY > screenY ? -1 : 1;
  }

  _setView(view) {
    this._view = view;
    this._scheduleDraw();
  }

  _scheduleDraw() {
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

  _resized() {
    this._scheduleDraw();
  }

  /** The map is kept in its own layer, drawing only moves it. */
  _overlayChanged() {
    if (this._heatLayer) this._heatLayer.innerHTML = this._overlaySvg();
  }

  /** Redrawn when a light changes, as it lights up its room. */
  _markersChanged(layout) {
    const key = JSON.stringify(this._markers.map((marker) => lightGlow(marker.stateObj)));
    if (!layout && key === this._lightsKey) return;
    this._lightsKey = key;
    this._scheduleDraw();
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

  /** The viewBox of `view`, centered on its target. Big enough for the plan at every yaw, so turning doesn't zoom. */
  _box({ pitch, zoom }) {
    const [halfWidth, halfHeight] = this._fit(pitch);
    let width = 2 * (halfWidth + PADDING);
    let height = 2 * (halfHeight + PADDING);
    if (width / height < this._aspect) width = height * this._aspect;
    else height = width / this._aspect;
    width /= zoom;
    height /= zoom;
    return { minX: -width / 2, minY: -height / 2, width, height };
  }

  _draw() {
    const g = this._geometry;
    if (!g || !this._svg) return;

    const { yaw, pitch, zoom } = this._view;
    const target = this._clampTarget(this._view.target, zoom);
    const cy = Math.cos(yaw * DEG);
    const sy = Math.sin(yaw * DEG);
    const sp = Math.sin(pitch * DEG);

    const project = makeProjection([target[0], g.center[1], target[1]], yaw, pitch);
    const box = this._box(this._view);
    const { minX, minY, width, height } = box;

    const svgPoints = (points) => points.map((p) => `${p[0].toFixed(4)},${p[1].toFixed(4)}`).join(" ");
    const f = (n) => n.toFixed(4);
    const parts = [];

    // Lights that are on light up the floor and walls of their room, fading with distance.
    const lights =
      this._config.show_lighting === false
        ? []
        : this._markers.flatMap((marker) => {
            const glow = lightGlow(marker.stateObj);
            if (!glow) return [];
            const [x, y, z] = marker.position;
            return [{
              glow,
              room: g.rooms.findIndex((room) => insidePolygon([x, z], room.points)),
              top: project([x, y, z]),
              foot: project([x, 0, z]),
              radius: (1.6 + 0.35 * Math.max(0, y)) * (0.55 + 0.45 * glow.strength),
            }];
          });

    const defs = [
      // Walls darken towards the floor.
      `<linearGradient id="occlusion" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0.5" stop-color="#000" stop-opacity="0"></stop>
        <stop offset="1" stop-color="#000" stop-opacity="0.18"></stop>
      </linearGradient>`,
    ];
    lights.forEach(({ glow, top, foot, radius }, i) => {
      const color = `rgb(${glow.rgb.join(",")})`;
      const [fx, fy] = foot;
      // A circle on the floor is an ellipse on screen, flattened by the tilt.
      defs.push(
        `<radialGradient id="glow-floor-${i}" gradientUnits="userSpaceOnUse" cx="${f(fx)}" cy="${f(fy)}" r="${f(radius)}"
          gradientTransform="translate(${f(fx)} ${f(fy)}) scale(1 ${f(sp)}) translate(${f(-fx)} ${f(-fy)})">
          ${glowStops(color, glow.strength, [[0, 0.65], [0.3, 0.35], [0.65, 0.1], [1, 0]])}
        </radialGradient>`,
        `<radialGradient id="glow-wall-${i}" gradientUnits="userSpaceOnUse" cx="${f(top[0])}" cy="${f(top[1])}" r="${f(radius)}">
          ${glowStops(color, glow.strength, [[0, 0.5], [0.45, 0.2], [1, 0]])}
        </radialGradient>`,
      );
    });
    parts.push(`<defs>${defs.join("")}</defs>`);

    const floors = g.rooms.map((room) => room.points.map(([x, z]) => project([x, 0, z])));
    g.rooms.forEach((room, i) => {
      const occupied = this._occupied.has(room.name) ? " occupied" : "";
      parts.push(`<polygon class="floor${occupied}" points="${svgPoints(floors[i])}"></polygon>`);
    });
    this._floorsLayer.innerHTML = parts.join("");
    parts.length = 0;

    // The floor seen through the orthographic camera is an affine map of floor [x, z],
    // see makeProjection: the map is drawn in floor coordinates and transformed.
    const [ox, oy, oz] = [target[0], g.center[1], target[1]];
    const cp = Math.cos(pitch * DEG);
    this._heatLayer.setAttribute(
      "transform",
      `matrix(${[cy, sy * sp, -sy, cy * sp, -ox * cy + oz * sy, (-ox * sy - oz * cy) * sp + oy * cp].map(f).join(" ")})`,
    );

    // On the floor of the light's room, so it doesn't shine through the walls.
    lights.forEach((light, i) => {
      if (light.room >= 0) {
        parts.push(`<polygon class="glow" fill="url(#glow-floor-${i})" points="${svgPoints(floors[light.room])}"></polygon>`);
      } else {
        parts.push(
          `<ellipse class="glow" fill="url(#glow-floor-${i})" cx="${f(light.foot[0])}" cy="${f(light.foot[1])}" rx="${f(light.radius)}" ry="${f(light.radius * sp)}"></ellipse>`,
        );
      }
    });

    const walls = g.walls.map((wall) => {
      const points = wall.corners.map(project);
      const depth = points.reduce((sum, p) => sum + p[2], 0) / points.length;
      // The normal turned into the view: +z faces the viewer, x tells the side it faces.
      const [nx, nz] = wall.normal;
      const facing = nx * sy + nz * cy;
      const side = nx * cy - nz * sy;
      return { points, depth, room: wall.room, near: facing > 0.05, shade: Math.round(16 + 8 * side) };
    });
    walls.sort((a, b) => a.depth - b.depth);

    for (const wall of walls) {
      const points = svgPoints(wall.points);
      parts.push(`<polygon class="wall${wall.near ? " near" : ""}" style="--shade: ${wall.shade}%" points="${points}"></polygon>`);
      // Walls facing the viewer are see-through, only the inside of the far walls is lit.
      if (wall.near) continue;
      parts.push(`<polygon class="glow" fill="url(#occlusion)" points="${points}"></polygon>`);
      lights.forEach((light, i) => {
        if (light.room === wall.room) parts.push(`<polygon class="glow" fill="url(#glow-wall-${i})" points="${points}"></polygon>`);
      });
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
      return { marker, point: top };
    });

    this._svg.setAttribute("viewBox", `${minX} ${minY} ${width} ${height}`);
    this._aboveLayer.innerHTML = parts.join("");
    this._container.classList.toggle("zoomed", zoom > 1.001);

    // Nearer markers on top of further ones.
    const depths = placed.map((p) => p.point[2]).sort((a, b) => a - b);
    for (const { marker, point } of placed) {
      marker.element.style.zIndex = String(2 + depths.indexOf(point[2]));
    }
    const spread = this._spreadMarkers(placed, box);

    // On the room's floor where no marker hangs in front of it, in this view.
    if (this._roomLabels.size > 0) {
      g.rooms.forEach((room, i) => {
        const label = this._roomLabels.get(room.name);
        if (!label) return;
        const p = labelPosition(floors[i], spread);
        label.style.left = `${(((p[0] - minX) / width) * 100).toFixed(3)}%`;
        label.style.top = `${(((p[1] - minY) / height) * 100).toFixed(3)}%`;
      });
    }

    if (this._compass) {
      this._compass.style.transform = `rotate(${yaw - g.heading}deg)`;
    }

    const initial = this._initialView;
    const changed = Math.abs(yaw - initial.yaw) > 0.5 || Math.abs(pitch - initial.pitch) > 0.5 || zoom > 1.001;
    this._reset.classList.toggle("shown", changed);
  }
}

FloorPlanCard.styles = `
  .room {
    fill: var(--secondary-background-color, #f5f5f5);
    transition: fill 0.3s;
  }
  /* The walls, over the temperature or humidity map */
  .outline {
    fill: none;
    stroke: var(--primary-text-color);
    stroke-width: 2.5px;
    stroke-linejoin: round;
    vector-effect: non-scaling-stroke;
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
  /* Zoomed in, what is outside the view is cut off and one finger pans no page */
  .stage.zoomed { overflow: hidden; touch-action: none; }
  .glow { pointer-events: none; }
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
  /* Temperature or humidity map, see-through so the floor still reads as floor */
  .heat { opacity: 0.55; pointer-events: none; }
  .overlay-bar {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 8px;
    margin-top: 12px;
  }
  .overlay-bar[hidden] { display: none; }
  .chip {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    height: 28px;
    padding: 0 10px 0 8px;
    border-radius: 14px;
    border: 1px solid var(--divider-color, rgba(0, 0, 0, 0.12));
    background: none;
    color: var(--primary-text-color);
    font: inherit;
    font-size: 12px;
    cursor: pointer;
    --mdc-icon-size: 16px;
  }
  .chip.active {
    border-color: var(--primary-color);
    background: color-mix(in srgb, var(--primary-color) 15%, transparent);
    color: var(--primary-color);
  }
  .chip:focus-visible { outline: 2px solid var(--primary-color); outline-offset: 1px; }
  .legend {
    display: flex;
    align-items: center;
    gap: 6px;
    flex: 1 1 140px;
    min-width: 140px;
    font-size: 11px;
    color: var(--secondary-text-color);
  }
  .legend .scale { flex: 1; height: 8px; border-radius: 4px; opacity: 0.8; }
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
  /* Lines from markers moved apart to where their entity is */
  .leaders { z-index: 1; pointer-events: none; }
  .leader {
    stroke: var(--secondary-text-color);
    stroke-opacity: 0.7;
    stroke-width: 1px;
  }
  .anchor { fill: var(--secondary-text-color); fill-opacity: 0.8; }
  .marker {
    position: absolute;
    /* --dx/--dy move markers apart that would overlap */
    transform: translate(calc(-50% + var(--dx, 0px)), calc(-50% + var(--dy, 0px)));
    display: flex;
    flex-direction: column;
    align-items: center;
    background: none;
    border: none;
    padding: 0;
    cursor: pointer;
    font: inherit;
    color: inherit;
    z-index: 2;
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
  /* Lights that are on glow in their color */
  .marker.lit .bubble {
    box-shadow: 0 0 10px 3px rgba(var(--glow-rgb), 0.55), 0 1px 3px rgba(0, 0, 0, 0.25);
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

/**
 * Home Assistant loads ha-form only once something needs it. Opening the editor of
 * a built-in card loads it, that is the documented way for custom cards to get it.
 */
const loadHaForm = async () => {
  if (customElements.get("ha-form")) return true;

  try {
    const helpers = await window.loadCardHelpers?.();
    const card = await helpers?.createCardElement({ type: "entities", entities: [] });
    await card?.constructor?.getConfigElement?.();
  } catch {
    // Waited for below, it may still arrive another way
  }

  const timeout = new Promise((resolve) => setTimeout(() => resolve(false), 5000));
  return Promise.race([customElements.whenDefined("ha-form").then(() => true), timeout]);
};

// Option defaults, an option set to its default is left out of the configuration.
const DEFAULTS_2D = {
  north_up: false,
  rotation: 0,
  show_compass: true,
  show_room_names: true,
  show_headsets: true,
  overlay: "none",
};
const DEFAULTS_3D = { ...DEFAULTS_2D, rotation: 30, pitch: 55, aspect_ratio: 1.333, show_lighting: true };

const EDITOR_LABELS = {
  title: "Title",
  north_up: "North up",
  rotation: "Rotation",
  pitch: "Tilt",
  aspect_ratio: "Aspect ratio",
  show_compass: "Compass",
  show_room_names: "Room names",
  show_headsets: "Headsets",
  show_lighting: "Lighting",
  overlay: "Map",
  hide_entities: "Hide entities",
};

const EDITOR_HELPERS = {
  north_up: "Turn the plan so north is up, using the heading set in the headset.",
  rotation: "Turns the plan clockwise.",
  rotation_3d: "Starting turn of the view, drag the card to turn it further.",
  pitch: "How steeply the view looks down, 90° is straight from above.",
  aspect_ratio: "Width divided by height of the view.",
  show_headsets: "Highlight the rooms a headset is in.",
  show_lighting: "Lights that are on light up their room in their color.",
  overlay: "Map shown at first, from the temperature and humidity sensors placed in the rooms. It can be switched below the plan.",
  hide_entities: "Entities placed in the headset not to show on the plan.",
};

/** Visual editor of both cards, built on Home Assistant's ha-form. */
class FloorPlanCardEditorBase extends HTMLElement {
  constructor() {
    super();
    this._config = null;
    this._hass = null;
    this._form = null;
    this._planEntities = null; // entity ids placed in the floor plan, null until known
    this._planRequested = false;
  }

  get _is3d() {
    return false;
  }

  get _defaults() {
    return this._is3d ? DEFAULTS_3D : DEFAULTS_2D;
  }

  setConfig(config) {
    this._config = config;
    this._update();
  }

  set hass(hass) {
    this._hass = hass;
    this._loadPlanEntities();
    this._update();
  }

  connectedCallback() {
    this._init();
  }

  async _init() {
    if (this._form || this._loading) return;
    this._loading = true;

    if (!(await loadHaForm())) {
      this.innerHTML = `<p>The visual editor could not be loaded, use the code editor instead.</p>`;
      return;
    }

    this._form = document.createElement("ha-form");
    this._form.computeLabel = (schema) => EDITOR_LABELS[schema.name] ?? schema.name;
    this._form.computeHelper = (schema) =>
      EDITOR_HELPERS[this._is3d && schema.name === "rotation" ? "rotation_3d" : schema.name];
    this._form.addEventListener("value-changed", (event) => this._changed(event));
    this.appendChild(this._form);
    this._update();
  }

  /** The hide picker offers only the entities placed in the floor plan. */
  async _loadPlanEntities() {
    if (this._planRequested || !this._hass) return;
    this._planRequested = true;

    try {
      const data = await this._hass.callWS({ type: "immersive_home/floor_plan/get" });
      const ids = (data?.floor_plan?.entities || []).map((entity) => entity.id);
      this._planEntities = [...new Set(ids)];
    } catch {
      // No integration or no floor plan yet: any entity can be picked
      this._planEntities = null;
    }
    this._update();
  }

  _schema(data) {
    const view = [{ name: "north_up", selector: { boolean: {} } }];

    if (!data.north_up) {
      view.push({
        name: "rotation",
        selector: { number: { min: 0, max: 359, step: 1, mode: "slider", unit_of_measurement: "°" } },
      });
    }
    if (this._is3d) {
      view.push(
        { name: "pitch", selector: { number: { min: 15, max: 90, step: 1, mode: "slider", unit_of_measurement: "°" } } },
        { name: "aspect_ratio", selector: { number: { min: 0.5, max: 3, step: 0.05, mode: "box" } } },
      );
    }

    const entities = this._planEntities?.length
      ? { multiple: true, include_entities: [...new Set([...this._planEntities, ...(data.hide_entities || [])])] }
      : { multiple: true };

    return [
      { name: "title", selector: { text: {} } },
      ...view,
      {
        name: "overlay",
        selector: {
          select: {
            mode: "dropdown",
            options: [
              { value: "none", label: "None" },
              ...Object.entries(OVERLAYS).map(([value, { label }]) => ({ value, label })),
            ],
          },
        },
      },
      {
        type: "grid",
        name: "",
        schema: [
          { name: "show_compass", selector: { boolean: {} } },
          { name: "show_room_names", selector: { boolean: {} } },
          { name: "show_headsets", selector: { boolean: {} } },
          ...(this._is3d ? [{ name: "show_lighting", selector: { boolean: {} } }] : []),
        ],
      },
      { name: "hide_entities", selector: { entity: entities } },
    ];
  }

  _update() {
    if (!this._form || !this._config) return;

    const data = { ...this._defaults, ...this._config };
    this._form.hass = this._hass;
    this._form.data = data;
    this._form.schema = this._schema(data);
  }

  _changed(event) {
    event.stopPropagation();
    if (!this._config) return;

    const merged = { ...this._config, ...event.detail.value };
    const config = { type: this._config.type };

    for (const [key, value] of Object.entries(merged)) {
      if (key === "type") continue;
      if (value === undefined || value === null || value === "") continue;
      if (Array.isArray(value) && value.length === 0) continue;
      if (key in this._defaults && value === this._defaults[key]) continue;
      config[key] = value;
    }

    this._config = config;
    this._update();
    this.dispatchEvent(new CustomEvent("config-changed", { detail: { config }, bubbles: true, composed: true }));
  }
}

class FloorPlanCardEditor extends FloorPlanCardEditorBase {}

class FloorPlan3DCardEditor extends FloorPlanCardEditorBase {
  get _is3d() {
    return true;
  }
}

FloorPlanCard.getConfigElement = () => document.createElement(`${CARD_2D}-editor`);
FloorPlan3DCard.getConfigElement = () => document.createElement(`${CARD_3D}-editor`);

const register = (type, element, editor, name, description) => {
  if (customElements.get(type)) return;
  customElements.define(type, element);
  customElements.define(`${type}-editor`, editor);
  window.customCards = window.customCards || [];
  window.customCards.push({ type, name, description, preview: false });
};

register(
  CARD_2D,
  FloorPlanCard,
  FloorPlanCardEditor,
  "Immersive Home Floor Plan",
  "The rooms set up in Immersive Home with the live state of the entities placed in them.",
);
register(
  CARD_3D,
  FloorPlan3DCard,
  FloorPlan3DCardEditor,
  "Immersive Home 3D Floor Plan",
  "The rooms set up in Immersive Home as a dollhouse to turn around, with the live state of the entities in them.",
);
