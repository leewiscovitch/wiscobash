function tailx {
    local file="${1:-/var/log/messages}" 
    if [[ -f "$file" ]]; then
        sudo tail -F -n 1000 "$file"
    else
        echo "Error: File '$file' does not exist"
        return 1
    fi
}