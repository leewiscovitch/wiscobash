detect_privileges() {
  if [[ $EUID -eq 0 ]]; then
    SUDO=""
  else
    command -v sudo >/dev/null || die "sudo required but not available"
    SUDO="sudo"
  fi
}

wiscobash_install() {
  detect_privileges

  local bashrc="/etc/bash.bashrc"

  local start_marker="# >>> WISCOBASH_MARKER >>>"
  local end_marker="# <<< WISCOBASH_MARKER <<<"

  # Remove existing block (if any)
  sed -i "/$start_marker/,/$end_marker/d" "$bashrc"

  # Append fresh block
tee -a "$bashrc" > /dev/null <<'EOF'

# >>> WISCOBASH_MARKER >>>
# Wiscobash system-wide initialization
if [ -f "$HOME/wiscobash/wiscobash.sh" ]; then
    source "$HOME/wiscobash/wiscobash.sh"
fi
# <<< WISCOBASH_MARKER <<<
EOF
}


# wiscobash_install() {
#   detect_privileges

#   # deletes everything between the code markers
#   sed -i "/# >>> WISCOBASH_MARKER >>>/,/# <<< WISCOBASH_MARKER <<</d" /etc/bash.bashrc

#   # appends the code block inbetween the code markers
#   tee -a /etc/bash.bashrc > /dev/null << 'EOF'
#   # >>> WISCOBASH_MARKER >>>
#   #configure /etc/bash.bashrc
#   for bashrc_file in /etc/bash.bashrc; do
#       if ! grep -qF "source ~/wiscobash/wiscobash.sh" $bashrc_file; then
#           echo "" >> $bashrc_file
#           echo "#wiscobash.sh" >> $bashrc_file
#           echo "source ~/wiscobash/wiscobash.sh" >> $bashrc_file
#       fi
#   done
#   # <<< WISCOBASH_MARKER <<<
#   EOF
# }