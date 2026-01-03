this could be useful, it finds the markers and replaces everything inbetween it. would be inplace, so where it exists in the file

```shell
sed -i '/# >>> BASH_ALIASES_BLOCK >>>/,/# <<< BASH_ALIASES_BLOCK <<</d' your_script.sh

cat >> your_script.sh <<'EOF'
# >>> BASH_ALIASES_BLOCK >>>
if [ -d ~/.bash_aliases.d/ ]; then
    for alias_file in ~/.bash_aliases.d/*.sh; do
    if [ -f "$alias_file" ]; then
        . "$alias_file"
    fi
    done
fi
# <<< BASH_ALIASES_BLOCK <<<
EOF
```