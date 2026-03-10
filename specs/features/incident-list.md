# Feature: Incident List

## Overview
The primary screen responders see after login. Displays active incidents dispatched
to the user's agency with real-time updates. Tapping an incident navigates to its
detail view.

## User Stories
- As a responder, I want to see all active incidents so I can understand what's happening
- As a responder, I want to tap an incident to see its details and navigate to it
- As a responder, I want incidents to update in real-time so I always have current info

## State Definition
```
State {
  isLoading: Boolean
  incidents: List<IncidentSummary>
  error: String?
  filterStatus: FilterStatus     // all, active, my_assigned
  lastUpdated: Timestamp?
}

Event {
  OnScreenAppear                 // Initial load
  OnRefresh                      // Pull-to-refresh
  OnFilterChanged(FilterStatus)  // User changes filter
  OnIncidentTapped(incidentId)   // User taps an incident
  OnIncidentUpdated(incident)    // Real-time update from websocket
}

Effect {
  NavigateToIncidentDetail(incidentId)
  ShowError(message)
}
```

## Data Model
```
IncidentSummary {
  id: String
  caseNumber: String
  type: IncidentType             // fire, ems, hazmat, etc.
  priority: Priority             // high, medium, low
  address: String
  dispatchTime: Timestamp
  status: IncidentStatus         // dispatched, en_route, on_scene, cleared
  assignedUnits: List<UnitSummary>
  coordinates: LatLng
}
```

## Screens
### Incident List Screen
- **Route**: Main tab → Incidents (default/first tab)
- **Layout**:
  - Top: Filter chips (All, Active, My Assigned)
  - Content: Scrollable list of incident cards
  - Each card: Case number, type icon, address, time, status badge, unit count
- **States**:
  - Loading: Skeleton/shimmer cards
  - Empty: Illustration + "No active incidents" message
  - Content: List of incident cards
  - Error: Error message + retry button
- **Interactions**:
  - Pull-to-refresh
  - Tap filter chip to change filter
  - Tap incident card → navigate to detail
  - Long press (future): quick actions

## Business Logic
- Incidents are sorted by dispatch time (newest first)
- High priority incidents have a visual emphasis (color/icon)
- Real-time updates merge into the list without disrupting scroll position
- Filter state persists across screen re-entries within the same session

## API Dependencies
- `GET /api/v1/incidents` — List incidents for user's agency
- WebSocket `/ws/incidents` — Real-time incident updates

## Edge Cases
- Offline: Show last cached incidents with a banner "Offline — data may be outdated"
- Empty agency: Show empty state with explanation
- Rapid updates: Batch websocket updates to avoid excessive re-renders
- Incident removed while viewing list: Animate removal gracefully

## Accessibility
- Incident cards must be fully accessible via VoiceOver/TalkBack
- Status badges need accessible labels (not just color)
- Filter chips must announce selected state
- Pull-to-refresh must be accessible via accessibility actions

## Platform-Specific Notes
- iOS: Use `List` with `.refreshable` modifier for pull-to-refresh
- Android: Use `LazyColumn` with `pullRefresh` modifier
- Both: Native platform navigation patterns (NavigationStack vs NavHost)
