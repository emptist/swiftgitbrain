# GitBrain Development Folder

This folder is used for AI-assisted collaborative development.

## Structure

- **Overseer/**: Working folder for OverseerAI (write access)
- **Memory/**: Shared persistent memory
- **Docs/**: Documentation for AIs

## Usage

### For CoderAI
Open Trae at project root:
```
trae .
```

CoderAI has access to all folders in the project.

### For OverseerAI
Open Trae at Overseer folder:
```
trae ./GitBrain/Overseer
```

OverseerAI has read access to the whole project and write access to GitBrain/Overseer/.

## Communication

CoderAI writes to GitBrain/Overseer/
OverseerAI writes to GitBrain/Memory/ (for CoderAI to read)

Messages are stored as JSON files with timestamps.

## Cleanup

After development is complete, you can safely remove this folder:
```
rm -rf GitBrain
```