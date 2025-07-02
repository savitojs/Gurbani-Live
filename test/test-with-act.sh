#!/bin/bash

# GitHub Actions Local Testing with act
# This script provides various ways to test GitHub Actions locally using act

set -e

echo "🎭 GitHub Actions Local Testing with act"
echo "========================================"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_usage() {
    echo "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  list              List all available workflows"
    echo "  test-dry         Run release workflow in dry-run mode"
    echo "  test-release     Run release workflow with actual release creation"
    echo "  release          Run main release workflow (tag-based)"
    echo "  check            Check workflow syntax only"
    echo "  events           List supported events"
    echo "  help             Show this help message"
    echo ""
}

list_workflows() {
    echo -e "${BLUE}📋 Available workflows:${NC}"
    # Set Podman socket environment variable
    export DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock"
    act -l
}

test_dry_run() {
    echo -e "${YELLOW}🧪 Running release workflow in dry-run mode...${NC}"
    echo -e "${BLUE}This will test the workflow without creating releases${NC}"
    echo ""
    
    # Set Podman socket environment variable
    export DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock"
    
    act workflow_dispatch \
        --workflows .github/workflows/release.yml \
        --input version="v0.9.0-test" \
        --dryrun
}

test_with_release() {
    echo -e "${YELLOW}🚀 Running release workflow with actual release creation...${NC}"
    echo -e "${RED}⚠️  This will create an actual release${NC}"
    echo ""
    
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Set Podman socket environment variable
        export DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock"
        
        act workflow_dispatch \
            --workflows .github/workflows/release.yml \
            --input version="v0.9.0-test" \
            --verbose
    else
        echo "Cancelled."
    fi
}

test_release_workflow() {
    echo -e "${YELLOW}🏷️  Running main release workflow...${NC}"
    echo -e "${RED}⚠️  This will simulate a tag-based release${NC}"
    echo ""
    
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Set Podman socket environment variable
        export DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock"
        
        act push \
            --workflows .github/workflows/release.yml \
            --eventpath .github/events/tag-push.json \
            --verbose
    else
        echo "Cancelled."
    fi
}

check_syntax() {
    echo -e "${BLUE}🔍 Checking workflow syntax...${NC}"
    
    for workflow in .github/workflows/*.yml; do
        echo "Checking: $workflow"
        act -n --workflows "$workflow" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "✅ ${GREEN}$workflow is valid${NC}"
        else
            echo -e "❌ ${RED}$workflow has syntax errors${NC}"
        fi
    done
}

show_events() {
    echo -e "${BLUE}📅 Supported events:${NC}"
    act --help | grep -A 20 "Events:"
}

# Create test event data if it doesn't exist
create_test_events() {
    mkdir -p .github/events
    
    if [ ! -f .github/events/tag-push.json ]; then
        cat > .github/events/tag-push.json << EOF
{
  "ref": "refs/tags/v0.9.0-test",
  "ref_type": "tag",
  "repository": {
    "name": "gurbani-live",
    "full_name": "savitojs/gurbani-live"
  }
}
EOF
        echo -e "${GREEN}Created test event: .github/events/tag-push.json${NC}"
    fi
}

# Main logic
case "${1:-help}" in
    "list")
        list_workflows
        ;;
    "test-dry")
        create_test_events
        test_dry_run
        ;;
    "test-release")
        create_test_events
        test_with_release
        ;;
    "release")
        create_test_events
        test_release_workflow
        ;;
    "check")
        check_syntax
        ;;
    "events")
        show_events
        ;;
    "help"|*)
        print_usage
        ;;
esac

echo ""
echo -e "${GREEN}💡 Tip: Use 'act --help' for more advanced options${NC}"
echo -e "${BLUE}📖 Documentation: https://github.com/nektos/act${NC}"
