# Testing Guide

How to test the GitHub Actions release workflow locally and on GitHub.

## Local Testing with act

[act](https://github.com/nektos/act) runs GitHub Actions locally using Podman.

### Setup

```bash
# Install act
curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
sudo mv ./bin/act /usr/local/bin/

# Enable Podman socket (rootless)
systemctl --user enable --now podman.socket

# Verify
export DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock"
act --version
```

### Using the test script

```bash
export DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock"

./test/test-with-act.sh list          # List workflows
./test/test-with-act.sh check         # Check syntax
./test/test-with-act.sh test-dry      # Dry run (no release created)
./test/test-with-act.sh test-release  # Creates an actual release
./test/test-with-act.sh release       # Tag-based release
```

### Manual act commands

```bash
export DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock"

act -l                                                              # List workflows
act -n workflow_dispatch --workflows .github/workflows/release.yml  # Dry run
act workflow_dispatch \
    --workflows .github/workflows/release.yml \
    --input version="v0.9.0-test"                                   # Run with input
```

## GitHub Actions Manual Testing

1. Push changes to GitHub
2. Go to **Actions** tab > **Release** workflow
3. Click **Run workflow**
4. Enter a test version like `v0.9.0-test`
5. Click **Run workflow**

This creates an actual release. Clean up test releases afterward.

## Tag-Based Testing

```bash
# Create and push a test tag
git tag v0.9.0-test
git push origin v0.9.0-test

# Clean up after testing
git tag -d v0.9.0-test
git push origin --delete v0.9.0-test
```

## Pre-Test Checklist

- [ ] Script passes syntax check: `bash -n gurbani-live`
- [ ] `--version` and `--help` work
- [ ] Dependencies are handled correctly
- [ ] Archive and checksums generate properly
- [ ] Podman socket is running: `systemctl --user status podman.socket`

## Troubleshooting

**act cannot connect to container runtime:**
```bash
systemctl --user status podman.socket
export DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock"
```

**Syntax errors:** Run `bash -n gurbani-live`.

**Permission denied:** Check that `GITHUB_TOKEN` has the right permissions in repo settings.

## Build Artifacts

The release workflow produces:

- `gurbani-live` (script)
- `gurbani-live.sha256` (checksum)
- `gurbani-live-VERSION.tar.gz` (archive)
- `gurbani-live-VERSION.tar.gz.sha256` (archive checksum)

The local test script cleans these up. GitHub releases keep them.
