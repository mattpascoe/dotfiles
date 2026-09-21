# AGENTS.md - Developer Guide for Dotfiles Repository

This repository contains shell scripts (bash/zsh) for system configuration using a Role/Profile pattern. It manages dotfiles, package installations, and desktop settings for Mac and Linux systems.

## Repository Structure
```
dotfiles/
├── dot.sh              # Main installer script
├── setup/
│   ├── platforms/       # OS-specific setup (Mac.sh, Linux.sh, unraid.sh)
│   ├── profiles/        # Individual installation profiles
│   ├── roles/           # Collections of profiles
│   ├── config.sh        # Configuration variables
│   └── setup_lib.sh     # Library functions
├── .zshrc, .vimrc, .shell-common
└── .config/            # Application configurations
```

## Build / Lint / Test Commands

### Linting
This project uses **ShellCheck** for linting bash/zsh scripts:
```bash
shellcheck dot.sh                              # Lint single script
shellcheck setup/profiles/starship.sh
shellcheck -S error dot.sh                     # Treat warnings as errors
```
Editor integration (nvim) should handle this automatically on save.

### Testing Changes
Since this is a shell script project without a formal test suite, testing is done manually:
```bash
./dot.sh -d                                    # Dry-run mode
./dot.sh -p starship                           # Run a specific profile
./dot.sh -r DEFAULT --dry-run                 # Run a specific role
./dot.sh -s                                    # Show status without changes
./dot.sh run                                   # Run the setup process
./dot.sh -l                                    # List available profiles
./dot.sh -L                                    # List available roles
./dot.sh -g                                    # Git pull the dotfiles repo
```

## Code Style Guidelines

### Shebang
Always use `#!/usr/bin/env bash` for maximum portability.

### File Header
Start profile and role scripts with a description on line 2:
```bash
#!/usr/bin/env bash
# Starship fancy prompts
```
This description is read by `dot.sh` for display during installation.

### Functions
- Use `function name()` syntax:
  ```bash
  function link_file() { ... }
  ```
- Always declare local variables:
  ```bash
  function example() {
    local VAR_NAME
    local OTHER_VAR="value"
  }
  ```

### Conditionals
- Use `[[ ]]` for extended test (not `[ ]`):
  ```bash
  if [[ "$VAR" == "value" ]]; then ... fi
  if [ ! -d "$HOME/bin" ]; then ... fi
  ```

### Variables
- Always quote variable expansions: `"$HOME/bin"`, `"${VAR}"`, `"${ARRAY[@]}"`
- Default values using `${VAR:-default}`: `USER="${USER:-$(whoami)}"`

### Arrays
- Declare with parentheses: `PROFILES=(starship fzf tmux)`
- Loop properly: `for PROFILE in "${PROFILES[@]}"; do ... done`

### Command Substitution
- Use `$(command)` instead of backticks: `CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)`

### Error Handling
- Redirect stderr: `if ! command -v "git" &> /dev/null; then ... fi`
- Critical paths: `cd "$DOTREPO" || exit`

### Disabling ShellCheck
Disable inline when rules don't apply:
```bash
# shellcheck disable=SC1090,SC1091
source "$PROFILE_DIR/$PROFILE.sh"
```
Common rules: `SC1090` (can't source non-constant), `SC1091` (not following sourced), `SC2086` (quote to prevent globbing)

### Indentation
Use 2 spaces for indentation.

### Logging/Output Functions
```bash
msg()     # Bold yellow message (info)
prompt()  # Bold green message with no newline (prompt)
msg "${BLU}Installing Starship prompt"
```

### Color Codes
Defined in dot.sh: `UL`, `UL_OFF`, `NC`, `YEL`, `BLU`, `RED`, `GRN`, `BOLD`

## Profile/Role Development

### Creating a New Profile
1. Create `setup/profiles/<name>.sh`
2. Add shebang and description on line 2
3. Use functions from dot.sh (sourced automatically)
4. Use `link_file` to create symlinks

### Creating a New Role
1. Create `setup/roles/<name>.sh`
2. Define `PROFILES` array
3. Call `run_profiles "${PROFILES[@]}"`

### Key Helper Functions
- `msg "text"` - Display info message
- `link_file ".config/file"` - Create symlink to dotfiles repo
- `run_profiles profile1 profile2` - Execute multiple profiles
- `command -v "name"` - Check if command exists

## Common Patterns

### Package Installation (Cross-platform)
```bash
case "$ID" in
  macos*)     brew install package ;;
  debian*|ubuntu*) sudo apt install -y package ;;
  arch*)     pacman -S --noconfirm package ;;
esac
```

### Checking Existing Installation
```bash
if ! command -v "starship" &> /dev/null; then
  msg "Installing Starship"
else
  msg "Starship already installed"
fi
```

### Dry-Run Support
```bash
if [[ "$DRY_RUN" == true ]]; then
  msg "[DRY_RUN] Would run: $COMMAND"
else
  eval "$COMMAND"
fi
```

## Editor Setup
The project is configured to work with Neovim. ShellCheck integration is likely set up in `.config/nvim/` for automatic linting on save.
