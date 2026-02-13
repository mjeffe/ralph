# Installation Guide

This guide covers installing Ralph into your project.

## Prerequisites

Before installing Ralph, ensure you have:

- **Git repository** - Your project must be a git repository (`git init`)
- **Cline CLI** - Install from [Cline documentation](https://docs.cline.bot/)
- **API Access** - API key for your chosen LLM provider (Anthropic, OpenAI, etc.)

## Installation Methods

### Method 1: curl (Recommended)

From your project root directory:

```bash
curl -fsSL https://raw.githubusercontent.com/mjeffe/ralph/main/install.sh | bash
```

### Method 2: wget

From your project root directory:

```bash
wget -qO- https://raw.githubusercontent.com/mjeffe/ralph/main/install.sh | bash
```

### Method 3: Manual Installation

```bash
# Clone Ralph repository
git clone https://github.com/mjeffe/ralph.git /tmp/ralph

# Copy .ralph/ directory to your project
cp -r /tmp/ralph/.ralph /path/to/your/project/

# Make scripts executable
chmod +x /path/to/your/project/.ralph/ralph
chmod +x /path/to/your/project/.ralph/loop.sh

# Clean up
rm -rf /tmp/ralph
```

## What Gets Installed

The installation creates a `.ralph/` directory in your project:

```
your-project/
├── .ralph/
│   ├── ralph                    # Entry point script
│   ├── loop.sh                  # Core loop implementation
│   ├── AGENTS.md.template       # Template for AGENTS.md
│   ├── IMPLEMENTATION_PLAN.md   # Placeholder (will be generated)
│   ├── PROGRESS.md              # Placeholder (will be generated)
│   ├── .ralph-version           # Version tracking
│   ├── .gitignore               # Ignores logs/
│   ├── prompts/                 # Agent instructions
│   ├── logs/                    # Execution logs (gitignored)
│   ├── docs/                    # Ralph documentation
│   └── validate.sh.example      # Optional validation template
```

## Post-Installation Setup

### 1. Initialize Ralph

Run the init command to set up your project:

```bash
.ralph/ralph init
```

This will:
- Create `specs/` directory
- Create `specs/README.md` with starter template
- Create `AGENTS.md` from template (if it doesn't exist)
- Display next steps

### 2. Optional: Create Convenience Symlink

For easier access, create a symlink in your project root:

```bash
ln -s .ralph/ralph ralph
```

Now you can run Ralph with:

```bash
./ralph
```

Instead of:

```bash
.ralph/ralph
```

The symlink works from anywhere inside your repository - Ralph automatically
resolves the project root regardless of your current working directory.

### 3. Configure Cline

Ensure cline CLI is configured with your API credentials:

```bash
cline auth
```

Follow the prompts to configure your LLM provider and API key.

## AGENTS.md Integration

Ralph requires an `AGENTS.md` file in your project root with a `## Specifications` section. This section directs agents to consult `specs/README.md` before implementing features, ensuring they work from specifications rather than assumptions.

### For New Projects

When you run `ralph init`, `AGENTS.md` will be created automatically from the template at `.ralph/AGENTS.md.template`.

The template includes:
- **Required section**: `## Specifications` (needed for Ralph to function)
- **Example sections**: Commit messages, code style (customize or remove as needed)

### For Existing Projects with AGENTS.md

If your project already has an `AGENTS.md` file, `ralph init` will NOT overwrite it. Instead, you need to manually add the `## Specifications` section.

**Add this section to your existing AGENTS.md:**

```markdown
## Specifications

IMPORTANT: Before implementing any feature, consult the specifications in specs/README.md.

- Make NO assumptions about implementation status. Many specs describe planned features that may not yet exist in the codebase.
- Always search the codebase first. Before concluding something is or isn't implemented, thoroughly search the actual code. Specs describe intent; code describes reality.
- Search for related functionality by feature name, file locations mentioned in specs, and logical places it would live.
- Use specs as guidance. When implementing a feature, follow the design patterns, types, and architecture defined in the relevant spec.
- Spec index: specs/README.md lists all specifications organized by category.
```

You can view the complete template at `.ralph/AGENTS.md.template` for reference.

### Why AGENTS.md is Required

The `## Specifications` section serves several critical purposes:

1. **Prevents Assumptions** - Agents must verify implementation status by searching code
2. **Enforces Spec-Driven Development** - Agents consult specs before implementing
3. **Improves Search Accuracy** - Agents know where to look for related functionality
4. **Maintains Consistency** - Agents follow patterns defined in specs

Without this section, agents may:
- Assume features exist when they don't
- Implement features without consulting requirements
- Miss existing implementations and duplicate code
- Ignore architectural patterns defined in specs

### Customizing AGENTS.md

The template includes example sections for:
- General guidelines (SOLID principles, simplicity, etc.)
- Commit message format
- Code style preferences

**These sections are suggestions** - modify or remove them to match your project's conventions. Only the `## Specifications` section is required for Ralph to function properly.

**Example customizations:**

```markdown
## Code Style

- **Language**: Python 3.11+
- **Formatting**: Black with 100 char line length
- **Type Hints**: Required for all functions
- **Docstrings**: Google style

## Testing

- Write pytest tests for all new features
- Maintain >80% code coverage
- Run `pytest` before committing

## Project-Specific Patterns

- Use dependency injection for services
- Follow repository pattern for data access
- Prefer composition over inheritance
```

### Verifying AGENTS.md

After setup, verify your `AGENTS.md` includes the required section:

```bash
grep -A 5 "## Specifications" AGENTS.md
```

You should see the specifications section content.

## Verification

After installation and setup, verify everything is working:

```bash
# Check Ralph is installed
.ralph/ralph --help

# Check directory structure
ls -la .ralph/

# Check AGENTS.md exists
cat AGENTS.md

# Check specs directory
ls -la specs/
```

## Next Steps

1. **Create your first specification** - See [writing-specs.md](writing-specs.md)
2. **Run Ralph** - See [quickstart.md](quickstart.md)
3. **Monitor progress** - Check `.ralph/logs/` for execution logs

## Troubleshooting

### Installation fails with "Not a git repository"

Ralph requires your project to be a git repository:

```bash
git init
git add .
git commit -m "Initial commit"
```

Then retry installation.

### Installation fails with ".ralph/ already exists"

Ralph is already installed. To reinstall:

```bash
# Backup existing .ralph/ if needed
mv .ralph .ralph.backup

# Reinstall
curl -fsSL https://raw.githubusercontent.com/mjeffe/ralph/main/install.sh | bash
```

### Permission denied when running .ralph/ralph

Make the script executable:

```bash
chmod +x .ralph/ralph
chmod +x .ralph/loop.sh
```

### Cline not found

Install Cline CLI:

```bash
npm install -g @cline/cli
```

Or follow [Cline installation instructions](https://docs.cline.bot/).

## Uninstallation

To remove Ralph from your project:

```bash
# Remove .ralph/ directory
rm -rf .ralph/

# Remove specs/ if no longer needed
rm -rf specs/

# Remove AGENTS.md if created by Ralph
# (Only if you don't have other agent guidelines)
rm AGENTS.md

# Remove convenience symlink if created
rm ralph
```

**Note**: This will not remove git history. If you want to remove Ralph from git history entirely, you'll need to rewrite history (not recommended if you've pushed commits).

## Updating Ralph

Currently, Ralph must be updated manually:

```bash
# Backup your state files
cp .ralph/IMPLEMENTATION_PLAN.md /tmp/
cp .ralph/PROGRESS.md /tmp/

# Remove old Ralph
rm -rf .ralph/

# Reinstall latest version
curl -fsSL https://raw.githubusercontent.com/mjeffe/ralph/main/install.sh | bash

# Restore state files
cp /tmp/IMPLEMENTATION_PLAN.md .ralph/
cp /tmp/PROGRESS.md .ralph/
```

**Future enhancement**: A `ralph update` command is planned for easier updates.

## Support

For issues, questions, or contributions:

- GitHub: https://github.com/mjeffe/ralph
- Documentation: `.ralph/docs/`
- Troubleshooting: [troubleshooting.md](troubleshooting.md)
