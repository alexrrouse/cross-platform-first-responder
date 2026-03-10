# Competitive Research: FirstDue MobileResponder

## Product Overview

FirstDue MobileResponder is a fire & EMS-focused mobile application (iOS, Android, and web) that provides first responders with critical incident data, real-time communication, and situational awareness tools during emergency response. It is part of FirstDue's broader fire/EMS software platform.

**Scope:** This document focuses exclusively on the **mobile app client**. Backend services, APIs, and server infrastructure are out of scope — we assume a backend exists and will provide the necessary data and endpoints.

**Sources:**
- [FirstDue MobileResponder Product Page](https://www.firstdue.com/products/mobileresponder)
- [FirstDue Best Practices: Mobile Response](https://www.firstdue.com/bestpractices/first-due-mobile-response)
- [How Mobile EMS Applications Are Changing Emergency Response](https://www.firstdue.com/news/how-mobile-ems-applications-are-changing-emergency-response)

---

## Feature Inventory

### 1. Multi-Platform Access
- Native iOS app
- Native Android app
- Web browser access (smartphones, tablets, laptops, MDTs)
- Offline mode with cached data (hydrants, occupancy details, pre-plans)

### 2. Dispatch & Incident Notifications
- Immediate push notifications upon dispatch
- Incident list view with detail drill-down
- Auto-population of live incident data from dispatch

### 3. Incident Detail View
- Building story information
- Incident notes from CAD
- Status logs for units and personnel
- Call history for the location
- Pre-plan data for the address/occupancy

### 4. Navigation & Routing
- Turn-by-turn directions to incident
- Traffic hazard visibility during navigation
- "Calculate Route" button within app
- Optimized routing

### 5. Status Management
- Single-tap status updates (en route, on scene, etc.)
- Real-time apparatus location tracking (truck-track map)
- Live arrival time updates
- Motion status indicators on unit icons
- Response dashboard

### 6. Secure Chat / Communication
- In-app encrypted messaging between responders
- Multi-agency communication
- Communication during active incidents
- Quick information exchange with mutual aid partners

### 7. Tactical Mapping
- Live tactical map with full operating picture
- Real-time unit location visualization
- Layer toggling for customizable map views
- Ruler/distance measurement tool (e.g., hose deployment calculations)
- Occupancy details overlay

### 8. Pre-Incident Planning
- View comprehensive pre-plans in the field
- Edit pre-plans from mobile device
- Share pre-plans across agencies and mutual aid partners
- Offline access to cached pre-plan data

### 9. Multi-Agency / Mutual Aid Support
- Account switching for users with multiple agency memberships
- Mutual aid partner data visibility
- Cross-agency pre-plan sharing
- Law enforcement data visibility

### 10. Fleet & Resource Tracking
- Live apparatus/vehicle location tracking on map
- Fleet activity monitoring
- Personnel tracking
- Asset and inventory overview

### 11. Offline Capabilities
- Cached hydrant information
- Cached occupancy details
- Cached pre-plan data
- Offline inspections (iPad)
- Sync queued changes when connectivity returns

### 12. User Management & Settings
- User profile management
- Email/account management
- Linked access to external websites
- One-tap deep links to companion web modules

---

## Feature Roadmap: Mobile App Parity Build Plan

### Phase 1: Core Foundation
**Goal:** Minimum viable incident response app

| Feature | Description |
|---------|-------------|
| Cross-platform app shell (iOS + Android) | App scaffolding, navigation structure, auth screens |
| Push notification dispatch alerts | Receive and display incoming incident notifications |
| Incident list & detail view | Browse active incidents with address, notes, unit status, building info |
| Turn-by-turn navigation | In-app routing to incident via mapping SDK (Mapbox / Google Maps) |
| Single-tap status updates | Tap to set status (en route, on scene, available) — posts to backend |
| User auth & profile | Login/logout, profile view, agency association |

### Phase 2: Communication & Situational Awareness
**Goal:** Real-time coordination between responders

| Feature | Description |
|---------|-------------|
| Secure in-app chat | Encrypted messaging per-incident and per-agency (consume real-time service) |
| Live map with unit locations | Display apparatus positions on map via location stream |
| Tactical map layers | Toggleable overlays — hydrants, occupancies, hazards |
| Live arrival time estimates | Display ETAs for responding units |
| Response dashboard | Summary view of all responding units, statuses, and ETAs |

### Phase 3: Pre-Planning & Data Access
**Goal:** Rich situational data at time of response

| Feature | Description |
|---------|-------------|
| Pre-incident plan viewer | Render pre-plans with floor plans, hazards, contacts, building details |
| Pre-plan editor (mobile) | Edit/update pre-plans from the field, submit changes to backend |
| Call history per location | Display historical incidents for the dispatched address |
| Building/occupancy details | Story count, construction type, occupancy classification |
| Distance measurement tool | Ruler overlay on map for hose deployment and distance calculations |

### Phase 4: Multi-Agency & Offline
**Goal:** Mutual aid coordination and offline resilience

| Feature | Description |
|---------|-------------|
| Multi-agency account switching | Switch between agency contexts within the app |
| Mutual aid data sharing | View pre-plans and incident data from partner agencies |
| Offline mode | Local cache of hydrants, occupancies, and pre-plans with background sync |
| Offline inspections | Conduct and queue inspections for upload when back online |
| Traffic hazard overlay | Display traffic incidents along navigation route |

### Phase 5: Polish & Extended Features
**Goal:** Full feature parity and platform completeness

| Feature | Description |
|---------|-------------|
| Web browser version | Responsive web app for MDTs and laptops |
| Fleet/asset tracking view | Monitor vehicle locations and equipment inventory |
| Deep links to web modules | One-tap navigation to companion web platform (RMS, scheduling, etc.) |
| Configurable external links | Agency-customizable resource links in the menu |
| Motion indicators on map | Show direction/speed indicators on unit map icons |

---

## Mobile App Technical Considerations

- **Cross-platform framework:** React Native or Flutter to target iOS + Android from a shared codebase.
- **Offline-first local storage:** SQLite, Realm, or WatermelonDB for caching pre-plans, hydrants, and occupancy data. Background sync when connectivity returns.
- **Mapping SDK:** Mapbox or Google Maps SDK — needs to support custom tile layers, real-time markers, routing, and measurement overlays.
- **Real-time data consumption:** WebSocket or SSE client for live unit locations, chat messages, and status updates.
- **Push notifications:** APNs (iOS) + FCM (Android) for dispatch alerts.
- **Secure messaging UI:** Chat interface consuming an encrypted messaging service; handle message persistence and offline queuing locally.
- **Background location:** Publish device GPS in the background for apparatus tracking (requires careful battery and permission management on both platforms).
- **Deep linking:** Universal links (iOS) / App Links (Android) for seamless handoff to/from the web platform.
