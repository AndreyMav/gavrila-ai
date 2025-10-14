# Development Setup Guide

This guide covers the local development setup for contributing to Gavrila AI.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Initial Setup](#initial-setup)
- [Git Hooks Installation](#git-hooks-installation)
- [Development Workflow](#development-workflow)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before you begin, ensure you have the following installed on your development machine:

### Required Tools
- **Git** 2.0+ - Version control
- **jq** - Command-line JSON processor (required for git hooks)
  - macOS: `brew install jq`
  - Ubuntu/Debian: `sudo apt-get install jq`
  - Windows (WSL): `sudo apt-get install jq`
  - Windows (native): Download from https://stedolan.github.io/jq/download/

### Optional Tools (for full development)
- **Node.js** 16+ - For GitHub Actions local testing
- **Docker** 20+ - For running n8n locally
- **n8n** - Workflow automation platform (can be run via Docker)

## Initial Setup

### 1. Clone the Repository

```bash
git clone https://github.com/AndreyMav/gavrila-ai.git
cd gavrila-ai
```

### 2. Verify Prerequisites

Check that required tools are installed:

```bash
# Check Git version
git --version

# Check jq is installed
jq --version
```

If `jq` is not installed, install it using the commands in the [Prerequisites](#prerequisites) section.

### 3. Install Git Hooks

**IMPORTANT**: Git hooks are not tracked in version control and must be installed manually after cloning the repository.

Run the installation script:

```bash
./scripts/install-hooks.sh
```

This will install the pre-commit hook that automatically strips `pinData` from n8n workflow files before each commit.

#### Manual Hook Installation (if script fails)

If the installation script doesn't work, you can manually install the hook:

```bash
# Copy the hook template to .git/hooks/
cp scripts/hooks/pre-commit .git/hooks/pre-commit

# Make it executable
chmod +x .git/hooks/pre-commit

# Verify installation
ls -la .git/hooks/pre-commit
```

You should see output like:
```
-rwxrwxr-x 1 user user 2368 Oct 14 13:03 .git/hooks/pre-commit
```

## Git Hooks Installation

### What Hooks Are Installed?

#### pre-commit Hook
Automatically strips `pinData` from n8n workflow JSON files before each commit.

**Why is this needed?**
- n8n workflows can contain `pinData` - test/debug data pinned to nodes during development
- This data should not be committed because it:
  - May contain sensitive test data
  - Makes diffs harder to read
  - Is only relevant for local testing
  - Can become stale and misleading

**How it works:**
1. Runs automatically before every `git commit`
2. Checks all staged n8n workflow files (`.json` files in `n8n/` directory)
3. Strips any `pinData` from those files using `jq`
4. Re-stages the cleaned files
5. Allows the commit to proceed

### Testing the Hook

After installation, test that the hook works correctly:

```bash
# Stage an n8n file (even if unchanged)
git add n8n/Gavrila\ -\ Ask.json

# Run the hook manually
.git/hooks/pre-commit

# You should see output indicating whether pinData was found and removed
```

### Bypassing the Hook (Not Recommended)

If you need to temporarily bypass the hook:

```bash
git commit --no-verify -m "Your commit message"
```

**Warning**: This will allow `pinData` to be committed, which is not recommended.

## Development Workflow

### Working with n8n Workflows

1. **Edit workflows in n8n UI**
   - Make your changes in the n8n web interface
   - Test with sample data using pinData feature

2. **Export workflows**
   - Export the workflow as JSON from n8n
   - Save to the `n8n/` directory with appropriate naming

3. **Commit changes**
   - Stage the workflow file: `git add n8n/your-workflow.json`
   - Commit: `git commit -m "Description of changes"`
   - The pre-commit hook will automatically strip pinData

4. **Push to repository**
   - Push your changes: `git push origin your-branch`

### Manual pinData Cleanup

If you need to manually clean pinData from all n8n files:

```bash
./scripts/strip-n8n-pindata.sh
```

This script will:
- Find all `.json` files in the `n8n/` directory
- Check each file for `pinData`
- Remove any non-empty `pinData` sections
- Report which files were modified

After running, stage and commit the changes:

```bash
git add n8n/*.json
git commit -m "Remove pinData from n8n workflows"
```

## Additional Resources

- [Main README](README.md) - Project overview and setup
- [Scripts README](scripts/README.md) - Detailed script documentation
- [Git Hooks Documentation](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)
- [n8n Documentation](https://docs.n8n.io/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## Getting Help

If you encounter issues not covered in this guide:

1. Check the [Troubleshooting](#troubleshooting) section
2. Review existing [GitHub Issues](https://github.com/AndreyMav/gavrila-ai/issues)
3. Create a new issue with:
   - Description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - Your environment (OS, Git version, etc.)

---

**Happy coding! 🚀**

