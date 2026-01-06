# Contributing to WiscoBash

Thank you for your interest in contributing to WiscoBash! This guide will help you understand the project structure and development conventions.

## Project Structure

```
wiscobash/
├── install.sh              # Installation script
├── uninstall.sh           # Uninstallation script
├── config/
│   └── bashrc_additions   # Main entry point (sourced by .bashrc)
├── lib/                   # Core library modules
│   ├── distro_detect.sh   # Distribution detection
│   ├── logging.sh         # Logging framework
│   └── package_manager.sh # Cross-distro package management
└── scripts/
    ├── alias/             # Shell aliases
    ├── functions/         # Shell functions
    ├── applications/      # Application-specific configs
    └── setup/             # Setup utilities
```

## Coding Conventions

### Naming

- **All functions** must be prefixed with `wb_` (WiscoBash)
  - Example: `wb_install()`, `wb_log_info()`
  - Exception: User-facing convenience functions (like `mkcd`, `extract`, etc.)

- **File naming**: Use lowercase with underscores
  - Example: `package_manager.sh`, `distro_detect.sh`

### File Headers

All scripts should start with a shebang and module description:

```bash
#!/usr/bin/env bash
# Module description
# Additional context about what this module does
```

### Function Documentation

Document all public functions with:
- Brief description of what the function does
- Parameters (Args)
- Return values
- Usage examples (when helpful)

```bash
# wb_example_function - Brief description
# Args: $1 = parameter description
# Returns: 0 on success, 1 on failure
# Example: wb_example_function "value"
wb_example_function() {
    # implementation
}
```

### Error Handling

- Always validate user input for user-facing functions
- Check for required parameters
- Use meaningful error messages
- Return appropriate exit codes (0 = success, 1 = failure)

```bash
my_function() {
    [ -z "$1" ] && echo "Usage: my_function <arg>" && return 1
    [ ! -f "$1" ] && echo "File not found: $1" && return 1
    # implementation
}
```

### Shell Best Practices

1. Use `#!/usr/bin/env bash` instead of `#!/bin/bash`
2. Quote variables: `"$var"` not `$var`
3. Use `[[` instead of `[` for conditionals when possible
4. Run `shellcheck` on all scripts before committing
5. Use local variables in functions: `local var="value"`

## Adding New Features

### Adding a New Package to Package Manager

Edit `lib/package_manager.sh` and add a case to `wb_get_package_name()`:

```bash
yourpackage)
    case "$DISTRO_FAMILY" in
        debian) name="debian-pkg-name" ;;
        rhel) name="rhel-pkg-name" ;;
        arch) name="arch-pkg-name" ;;
    esac ;;
```

Don't forget to update `wb_packages_list()`.

### Adding New Aliases

Create or edit a file in `scripts/alias/`:

```bash
#!/usr/bin/env bash
alias myalias='command'
```

### Adding New Functions

Create or edit a file in `scripts/functions/`:

```bash
#!/usr/bin/env bash
my_function() {
    [ -z "$1" ] && echo "Usage: my_function <arg>" && return 1
    # implementation
}
```

### Adding Application-Specific Config

Create a new file in `scripts/applications/`:

```bash
#!/usr/bin/env bash
# Only load if application is installed
command -v myapp >/dev/null 2>&1 || return

alias myapp-alias='myapp --flag'
```

## Module System

### Load Order

The initialization order in `config/bashrc_additions` is important:

1. `lib/distro_detect.sh` - Must load first (exports `$DISTRO`, `$DISTRO_FAMILY`)
2. `lib/logging.sh` - Depends on distro detection
3. `lib/package_manager.sh` - Depends on logging
4. `scripts/alias/*.sh` - Aliases loaded next
5. `scripts/functions/*.sh` - Functions loaded next
6. `scripts/applications/*.sh` - App configs loaded last

### Logging

Use the logging functions throughout your code:

```bash
wb_log_info "Informational message"
wb_log_success "Success message"
wb_log_warning "Warning message"
wb_log_error "Error message"
wb_log_debug "Debug message"
```

Debug messages only show when debug mode is enabled via `wb_debug_enable`.

## Testing

Before submitting changes:

1. Test on your distribution
2. Run `shellcheck` on modified scripts:
   ```bash
   shellcheck lib/*.sh scripts/**/*.sh
   ```
3. Test installation from scratch:
   ```bash
   ./uninstall.sh
   ./install.sh
   ```
4. Verify no errors in a new shell session

## Supported Distributions

WiscoBash supports three distribution families:

- **Debian family**: Debian, Ubuntu, Linux Mint, Pop!_OS
- **RHEL family**: RHEL, CentOS, Fedora, Rocky Linux, AlmaLinux
- **Arch family**: Arch Linux, Manjaro, EndeavourOS

When adding features, ensure they work across all families or gracefully degrade.

## Pull Request Guidelines

1. Create a descriptive branch name (e.g., `feature/new-aliases`, `fix/logging-bug`)
2. Write clear commit messages
3. Update documentation if needed
4. Ensure all scripts pass `shellcheck`
5. Test your changes on at least one distribution

## Questions?

If you have questions about contributing, please open an issue on GitHub.

## License

By contributing to WiscoBash, you agree that your contributions will be licensed under the same license as the project.
