# Scripts

This directory contains utility scripts for the Gavrila AI project.

## strip-n8n-pindata.sh

Removes `pinData` from all n8n workflow JSON files in the `n8n/` directory.

### What is pinData?

In n8n, `pinData` is test/debug data that gets "pinned" to specific nodes during workflow development. This allows you to test workflows with known sample data without triggering actual executions. However, this data should not be committed to version control as it:

- Contains potentially sensitive test data
- Makes diffs harder to read
- Is only relevant for local testing
- Can become stale and misleading

### Usage

Run the script manually to clean all n8n workflow files:

```bash
./scripts/strip-n8n-pindata.sh
```

The script will:
1. Find all `.json` files in the `n8n/` directory
2. Check each file for `pinData`
3. Remove any non-empty `pinData` sections
4. Report which files were modified

After running, you'll need to stage and commit the changes:

```bash
git add n8n/*.json
git commit -m "Remove pinData from n8n workflows"
```

### Requirements

- `jq` - Command-line JSON processor
  - macOS: `brew install jq`
  - Ubuntu/Debian: `sudo apt-get install jq`
  - Other: https://stedolan.github.io/jq/download/

## Pre-commit Hook

A pre-commit hook is automatically installed at `.git/hooks/pre-commit` that strips `pinData` from n8n workflow files before each commit.

### How it works

The pre-commit hook:
1. Runs automatically before every `git commit`
2. Checks all staged n8n workflow files (`.json` files in `n8n/` directory)
3. Strips any `pinData` from those files
4. Re-stages the cleaned files
5. Allows the commit to proceed

This ensures that `pinData` never gets committed, even if you forget to run the manual script.

### Testing the hook

You can test the pre-commit hook manually:

```bash
# Stage an n8n file with pinData
git add n8n/Gavrila\ -\ Ask.json

# Run the hook manually
.git/hooks/pre-commit

# Check that pinData was removed
git diff --cached n8n/Gavrila\ -\ Ask.json
```

### Disabling the hook

If you need to temporarily disable the hook:

```bash
# Commit with --no-verify flag
git commit --no-verify -m "Your commit message"
```

**Note:** This is not recommended as it will allow `pinData` to be committed.

### Reinstalling the hook

If the hook gets deleted or you clone the repository fresh, you can recreate it by copying from the original location or re-running the setup script (if available).

## Troubleshooting

### "jq is not installed" error

Install `jq` using your package manager:
- macOS: `brew install jq`
- Ubuntu/Debian: `sudo apt-get install jq`
- Windows (WSL): `sudo apt-get install jq`
- Windows (native): Download from https://stedolan.github.io/jq/download/

### Pre-commit hook not running

1. Check that the hook is executable:
   ```bash
   ls -la .git/hooks/pre-commit
   chmod +x .git/hooks/pre-commit
   ```

2. Verify the hook file exists and is not a `.sample` file

3. Make sure you're committing n8n workflow files (`.json` files in `n8n/` directory)

### Files still have pinData after running script

1. Check that the script completed successfully (exit code 0)
2. Verify the files were actually modified (check the summary output)
3. Make sure you're looking at the working directory files, not staged files
4. Try running with verbose output: `bash -x ./scripts/strip-n8n-pindata.sh`

