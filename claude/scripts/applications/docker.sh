#!/usr/bin/env bash
command -v docker >/dev/null 2>&1 || return
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs -f'
dstop() { docker stop "$@"; }
drm() { docker rm "$@"; }
drmi() { docker rmi "$@"; }
dstopall() { docker stop "$(docker ps -q)"; }
drmall() { docker rm "$(docker ps -aq)"; }
drmid() { docker rmi "$(docker images -f "dangling=true" -q)"; }
dcleanup() { docker system prune -af; }
denter() { [ -z "$1" ] && echo "Usage: denter <container>" && return 1; docker exec -it "$1" /bin/bash || docker exec -it "$1" /bin/sh; }
dstats() { docker stats --no-stream; }
