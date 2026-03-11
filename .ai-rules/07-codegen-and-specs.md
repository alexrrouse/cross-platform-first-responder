# Code Generation & Specs

## Code Generation
- Data models are generated from `specs/api/` definitions
- Run `tools/codegen/generate.sh` after modifying any spec in `specs/api/`
- Never hand-edit generated model files — modify the spec and regenerate

## Spec Workflow
- Feature specs in `specs/features/` define behavior, states, and edge cases
- Test contracts in `specs/test-contracts/` define platform-agnostic test cases
- Both must be read BEFORE implementing any feature
- Modifying a spec requires updating both platform implementations
