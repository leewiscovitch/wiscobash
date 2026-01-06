#!/usr/bin/env bash
command -v docker >/dev/null 2>&1 || return 0
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
dstopall() {
    local containers
    containers=$(docker ps -q)
    [ -z "$containers" ] && echo "No running containers" && return 0
    docker stop $containers
}
drmall() {
    local containers
    containers=$(docker ps -aq)
    [ -z "$containers" ] && echo "No containers to remove" && return 0
    docker rm $containers
}
drmid() {
    local images
    images=$(docker images -f "dangling=true" -q)
    [ -z "$images" ] && echo "No dangling images" && return 0
    docker rmi $images
}
dcleanup() { docker system prune -af; }
denter() {
    [ -z "$1" ] && echo "Usage: denter <container>" && return 1
    docker exec -it "$1" /bin/bash || docker exec -it "$1" /bin/sh
}
dstats() { docker stats --no-stream; }
