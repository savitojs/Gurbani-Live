# GitHub Actions Testing Guide

This document explains how to test the GitHub Actions workflows for this project.

## Available Testing Methods

### 1. Local Testing with act (Recommended)

[act](https://github.com/nektos/act) is the standard tool for running GitHub Actions locally.

#### Setup act with Podman

```bash
# Install act
curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
sudo mv ./bin/act /usr/local/bin/

# Enable Podman socket service (rootless)
systemctl --user enable --now podman.socket

# Verify setup
export DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock"
act --version
```

#### Using the act test script

```bash
# Set environment for Podman
export DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock"

# List all workflows
./test/test-with-act.sh list

# Check workflow syntax
./test/test-with-act.sh check

# Run release workflow (dry run - no releases)
./test/test-with-act.sh test-dry

# Run release workflow (creates actual release)
./test/test-with-act.sh test-release

# Run main release workflow (tag-based)
./test/test-with-act.sh release
```

#### Manual act commands

```bash
# Set Podman socket
export DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock"

# List workflows
act -l

# Dry run a specific workflow
act -n workflow_dispatch --workflows .github/workflows/release.yml

# Run release workflow with inputs
act workflow_dispatch \
    --workflows .github/workflows/release.yml \
    --input version="v0.9.0-test"
```

### 2. GitHub Actions Manual Testing

#### Manual Workflow Dispatch

1. **Push changes to GitHub**
2. **Go to Actions tab** in your repository
3. **Select "Release"**
4. **Click "Run workflow"**
5. **Configure the test**:
   - Version: `v0.9.0-test` (or any test version)
6. **Click "Run workflow"** button

This will run the release workflow with your test version.

#### Test Release Creation

The release workflow has `workflow_dispatch` trigger, so you can test it manually:

1. **Follow steps 1-4 above**
2. **Enter version**: `v0.9.0-test`
3. **Click "Run workflow"**

⚠️ **Note**: This creates an actual release. Use test version numbers and clean up afterwards.

### 4. Tag-Based Testing

Create a test tag to trigger the release workflow:

```bash
# Create and push a test tag
git tag v0.9.0-test
git push origin v0.9.0-test

# Delete the tag locally and remotely after testing
git tag -d v0.9.0-test
git push origin --delete v0.9.0-test
```

## Testing Checklist

Before running tests, ensure:

- [ ] All files are renamed from old project name
- [ ] Script compiles without errors
- [ ] Script runs basic commands (--version, --help)
- [ ] Dependencies are properly handled
- [ ] Archive creation works
- [ ] Checksums are generated correctly
- [ ] Podman socket is running: `systemctl --user status podman.socket`

## Troubleshooting

### Common Issues

1. **act cannot connect to container runtime**:
   ```bash
   # Ensure Podman socket is running
   systemctl --user status podman.socket
   
   # Set the correct environment variable
   export DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock"
   ```

2. **Compilation fails**:
   - Check script syntax: `bash -n gurbani-live`

3. **Permission denied**:
   - Ensure GITHUB_TOKEN has proper permissions
   - Check repository settings for Actions permissions

4. **File not found errors**:
   - Verify all file references use the new script name
   - Check that files exist in the repository

### Debug Steps

1. **Check Action logs** in the GitHub Actions tab
2. **Run local test script** to isolate issues
3. **Use act dry run** to see what would happen: `act -n`
4. **Test individual commands** that are failing
5. **Verify file paths** and environment variables

## Best Practices

1. **Always test locally first** using `act` with `./test/test-with-act.sh`
2. **Use dry run mode** for initial testing
3. **Use test version numbers** (e.g., v0.9.0-test)
4. **Clean up test releases** after validation
5. **Test on a fork first** if making significant changes
6. **Use Podman for security** (rootless containers)

## Files Created During Testing

The test processes create these files:

- `gurbani-live` (compiled binary)
- `gurbani-live.sha256` (binary checksum)
- `gurbani-live-VERSION-linux-x86_64.tar.gz` (archive)
- `gurbani-live-VERSION-linux-x86_64.tar.gz.sha256` (archive checksum)

These are automatically cleaned up by the local test script but may remain in GitHub releases.

## act Configuration

The `.actrc` file configures act with:
- Ubuntu runner images for compatibility
- Environment variables for testing
- Podman-compatible settings

To override configuration, use command-line flags or environment variables.
