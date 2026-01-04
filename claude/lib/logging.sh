#!/usr/bin/env bash
WISCOBASH_LOG_FILE="${WISCOBASH_DIR}/wiscobash.log"
WISCOBASH_DEBUG_FLAG="${WISCOBASH_DIR}/.debug"
WISCOBASH_VERBOSE_FLAG="${WISCOBASH_DIR}/.verbose"
WISCOBASH_DEBUG=false
WISCOBASH_VERBOSE=false
[ -f "$WISCOBASH_DEBUG_FLAG" ] && WISCOBASH_DEBUG=true && WISCOBASH_VERBOSE=true
[ -f "$WISCOBASH_VERBOSE_FLAG" ] && WISCOBASH_VERBOSE=true
touch "$WISCOBASH_LOG_FILE" 2>/dev/null || WISCOBASH_LOG_FILE="/dev/null"
wb_rotate_log() {
    [ -f "$WISCOBASH_LOG_FILE" ] && [ "$WISCOBASH_LOG_FILE" != "/dev/null" ] || return
    local lines
    lines=$(wc -l < "$WISCOBASH_LOG_FILE" 2>/dev/null || echo 0)
    [ "$lines" -gt 1000 ] && tail -n 500 "$WISCOBASH_LOG_FILE" > "${WISCOBASH_LOG_FILE}.tmp" && mv "${WISCOBASH_LOG_FILE}.tmp" "$WISCOBASH_LOG_FILE"
}
wb_timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
wb_log() { echo "[$(wb_timestamp)] [$1] ${*:2}" >> "$WISCOBASH_LOG_FILE"; }
wb_log_info() { wb_log "INFO" "$*"; $WISCOBASH_VERBOSE && echo "[INFO] $*" >&2; }
wb_log_success() { wb_log "SUCCESS" "$*"; $WISCOBASH_VERBOSE && echo "[✓] $*" >&2; }
wb_log_warning() { wb_log "WARNING" "$*"; $WISCOBASH_VERBOSE && echo "[WARNING] $*" >&2; }
wb_log_error() { wb_log "ERROR" "$*"; echo "[ERROR] $*" >&2; }
wb_log_debug() { $WISCOBASH_DEBUG && wb_log "DEBUG" "$*" && echo "[DEBUG] $*" >&2; }
wb_log_section_start() { wb_log "SECTION" "START: $1"; wb_log_debug "Section: $1"; }
wb_log_section_end() { wb_log "SECTION" "END: $1 (${2:-success})"; }
wb_log_session_start() {
    wb_rotate_log
    echo "" >> "$WISCOBASH_LOG_FILE"
    wb_log "SESSION" "=== WiscoBash session started (PID: $$) ==="
    wb_log "INFO" "Distribution: $DISTRO ($DISTRO_FAMILY)"
    wb_log "INFO" "User: $USER, Shell: $SHELL"
    wb_log "INFO" "Debug: $WISCOBASH_DEBUG, Verbose: $WISCOBASH_VERBOSE"
}
wb_log_missing_file() { wb_log_warning "Missing file: $1"; }
wb_log_permission_error() { wb_log_error "Permission denied: $1"; }
wb_log_package_install() {
    [ "$2" = "success" ] && wb_log_success "Package installed: $1"
    [ "$2" = "skipped" ] && wb_log_info "Package skipped: $1"
    [ "$2" = "failed" ] && wb_log_error "Package failed: $1"
}
wb_source_with_log() {
    [ ! -f "$1" ] && wb_log_missing_file "$1" && return 1
    [ ! -r "$1" ] && wb_log_permission_error "$1" && return 1
    wb_log_debug "Sourcing: ${2:-$1}"
    # shellcheck disable=SC1090
    if source "$1" 2>/dev/null; then
        wb_log_debug "Sourced: ${2:-$1}"
    else
        wb_log_error "Failed: ${2:-$1}"
        return 1
    fi
}
wb_logs() { [ -f "$WISCOBASH_LOG_FILE" ] && tail -n "${1:-50}" "$WISCOBASH_LOG_FILE" || echo "No log"; }
wb_logs_errors() { wb_logs 100 | grep ERROR; }
wb_logs_warnings() { wb_logs 100 | grep -E "WARNING|ERROR"; }
wb_logs_clear() { true > "$WISCOBASH_LOG_FILE"; echo "Log cleared"; }
wb_debug_enable() { touch "$WISCOBASH_DEBUG_FLAG"; echo "Debug enabled. Restart shell."; }
wb_debug_disable() { rm -f "$WISCOBASH_DEBUG_FLAG"; echo "Debug disabled. Restart shell."; }
wb_verbose_enable() { touch "$WISCOBASH_VERBOSE_FLAG"; echo "Verbose enabled. Restart shell."; }
wb_verbose_disable() { rm -f "$WISCOBASH_VERBOSE_FLAG"; echo "Verbose disabled. Restart shell."; }
wb_log_status() {
    echo "=== WiscoBash Logging ==="
    echo "Log: $WISCOBASH_LOG_FILE"
    echo "Debug: $WISCOBASH_DEBUG | Verbose: $WISCOBASH_VERBOSE"
    [ -f "$WISCOBASH_LOG_FILE" ] && echo "Size: $(du -h "$WISCOBASH_LOG_FILE" | cut -f1) ($(wc -l < "$WISCOBASH_LOG_FILE") lines)"
}
