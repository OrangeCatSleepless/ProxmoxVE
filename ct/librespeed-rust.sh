#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: Joseph Stubberfield (stubbers)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/librespeed/speedtest-rust

APP="Librespeed-Rust"
var_tags="${var_tags:-network}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-512}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-12}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -d /var/lib/librespeed-rs ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  
  RELEASE=$(curl -fsSL https://api.github.com/repos/librespeed/speedtest-rust/releases/latest | jq -r '.tag_name' | sed 's/^v//')
  if [[ "${RELEASE}" != "$(cat ~/.librespeed 2>/dev/null)" ]] || [[ ! -f ~/.librespeed ]]; then
    msg_info "Stopping Services"
    systemctl stop librespeed_rs
    msg_ok "Services Stopped"

    fetch_and_deploy_gh_release "librespeed-rust" "librespeed/speedtest-rust" "binary" "latest" "/opt/librespeed-rust" "librespeed-rs-x86_64-unknown-linux-gnu.deb"

    msg_info "Starting Service"
    systemctl start librespeed_rs
    msg_ok "Started Service"
  else
    msg_ok "No update required. ${APP} is already at v${RELEASE}"
  fi
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8080${CL}"
