# Test Scripts

This directory contains test scripts for the Gurbani Live project.

## Scripts

### `test-with-act.sh`
Local GitHub Actions testing using [act](https://github.com/nektos/act) and Podman.

**Usage:**
```bash
# From project root
export DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock"
./test/test-with-act.sh [command]
```

**Commands:**
- `list` - List all available workflows
- `check` - Check workflow syntax
- `test-dry` - Run release workflow in dry-run mode
- `test-release` - Run release workflow with actual release creation
- `release` - Run main release workflow (tag-based)

**What it tests:**
- Script compilation to binary
- Binary functionality (--version, --help)
- Cleanup of temporary files

## Prerequisites

- **act**: For GitHub Actions testing
- **Podman**: Container runtime (with socket enabled)

## See Also

- [Testing Guide](../docs/TESTING.md) - Comprehensive testing documentation
