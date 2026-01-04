#!/usr/bin/env bash
ESSENTIAL=(git curl wget vim htop tree unzip zip)
DEV=(tmux jq build-essential python3 python-pip)
install_essentials() {
    echo "=== Installing Essentials ==="
    local todo=()
    for p in "${ESSENTIAL[@]}"; do wb_package_installed "$p" && echo "✓ $p" || todo+=("$p"); done
    [ ${#todo[@]} -gt 0 ] && echo "Installing: ${todo[*]}" && wb_install_multi "${todo[@]}" || echo "All installed!"
}
install_dev() {
    echo "=== Installing Dev Tools ==="
    local todo=()
    for p in "${DEV[@]}"; do wb_package_installed "$p" && echo "✓ $p" || todo+=("$p"); done
    [ ${#todo[@]} -gt 0 ] && echo "Installing: ${todo[*]}" && wb_install_multi "${todo[@]}" || echo "All installed!"
}
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    source "$HOME/wiscobash/lib/logging.sh"
    source "$HOME/wiscobash/lib/distro_detect.sh"
    source "$HOME/wiscobash/lib/package_manager.sh"
    echo "1) Essentials  2) Dev tools  3) Both  4) Status  5) Exit"
    read -r -p "Choose: " c
    case $c in
        1) install_essentials ;;
        2) install_dev ;;
        3) install_essentials; install_dev ;;
        4) wb_list_installed ;;
        5) exit 0 ;;
    esac
fi
