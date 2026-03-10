# Feature: {Feature Name}

## Overview
Brief description of what this feature does and why it exists.

## User Stories
- As a [responder/dispatcher/admin], I want to [action] so that [benefit]

## State Definition
```
State {
  // Define the complete state for this feature
}

Event {
  // Define all user/system events
}

Effect {
  // Define all side effects (navigation, alerts, etc.)
}
```

## Screens
### {Screen Name}
- **Route/Path**: How the user gets here
- **Layout**: Description of UI elements and their arrangement
- **States**: Loading, Empty, Content, Error
- **Interactions**: What the user can tap/swipe/input

## Business Logic
- State transition rules
- Validation rules
- Data transformation logic

## API Dependencies
- List endpoints used (reference specs/api/ definitions)

## Edge Cases
- Offline behavior
- Empty states
- Error states
- Permission denied states

## Accessibility
- VoiceOver/TalkBack requirements
- Minimum tap target sizes
- Dynamic type / font scaling support

## Platform-Specific Notes
Document any cases where platform behavior intentionally diverges:
- iOS: {any iOS-specific behavior}
- Android: {any Android-specific behavior}
