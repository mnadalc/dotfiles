#!/bin/bash

source './osx/utils.sh'

CMUX_APP_BIN="${CMUX_APP_BIN:-/Applications/cmux.app/Contents/Resources/bin/cmux}"
CMUX_CLI_LINK="${CMUX_CLI_LINK:-/usr/local/bin/cmux}"
CMUX_CLI_DIR="$(dirname "$CMUX_CLI_LINK")"
CMUX_SUDO_READY=0

ensure_sudo_session() {
  if [ "$CMUX_SUDO_READY" -eq 0 ]; then
    ask_for_sudo
    CMUX_SUDO_READY=1
  fi
}

ensure_cli_dir() {
  local writable_parent="$CMUX_CLI_DIR"

  if [ -d "$CMUX_CLI_DIR" ]; then
    return 0
  fi

  while [ ! -e "$writable_parent" ] && [ "$writable_parent" != "/" ]; do
    writable_parent="$(dirname "$writable_parent")"
  done

  if [ -w "$writable_parent" ]; then
    execute "mkdir -p \"$CMUX_CLI_DIR\""
  else
    ensure_sudo_session
    sudo mkdir -p "$CMUX_CLI_DIR"
    print_result $? "mkdir -p $CMUX_CLI_DIR"
  fi
}

link_cmux_cli() {
  if [ -w "$CMUX_CLI_DIR" ]; then
    execute "ln -sfn \"$CMUX_APP_BIN\" \"$CMUX_CLI_LINK\""
  else
    ensure_sudo_session
    sudo ln -sfn "$CMUX_APP_BIN" "$CMUX_CLI_LINK"
    print_result $? "ln -sfn $CMUX_APP_BIN $CMUX_CLI_LINK"
  fi
}

configure_cmux() {
  print_info "Configuring cmux CLI."

  if [ ! -x "$CMUX_APP_BIN" ]; then
    print_error "cmux app binary not found at $CMUX_APP_BIN"
    return 1
  fi

  if [ -L "$CMUX_CLI_LINK" ] && [ "$(readlink "$CMUX_CLI_LINK")" = "$CMUX_APP_BIN" ]; then
    print_success "cmux CLI already configured at $CMUX_CLI_LINK"
    return 0
  fi

  if [ -e "$CMUX_CLI_LINK" ] && [ ! -L "$CMUX_CLI_LINK" ]; then
    print_error "$CMUX_CLI_LINK already exists and is not a symlink."
    return 1
  fi

  ensure_cli_dir || return 1
  link_cmux_cli || return 1

  print_success "Configured cmux CLI at $CMUX_CLI_LINK"
}

configure_cmux
