#!/usr/bin/env zsh
# Docker daemon + Colima state

run_docker() {
  _header "🐳  DOCKER / COLIMA"

  docker info &>/dev/null \
      && _ok  "Docker daemon running" \
      || _fail "Docker daemon down"

  colima status 2>/dev/null | grep -qE 'UP|Running' \
      && _ok  "Colima running" \
      || _warn "Colima not running"
}