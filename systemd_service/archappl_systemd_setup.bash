#!/bin/bash
#
#  Copyright (c) 2017 - Present Jeong Han Lee
#  Copyright (c) 2017 - Present European Spallation Source ERIC
#
#  The program is free software: you can redistribute
#  it and/or modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation, either version 2 of the
#  License, or any newer version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License along with
#  this program. If not, see https://www.gnu.org/licenses/gpl-2.0.txt
#
# Author : Jeong Han Lee
# email  : jeonghan.lee@gmail.com
# Date   : 
# version : 0.0.1
#

declare -gr SC_SCRIPT="$(realpath "$0")"
declare -gr SC_SCRIPTNAME=${0##*/}
declare -gr SC_TOP="$(dirname "$SC_SCRIPT")"


set -a
. ${SC_TOP}/archappl_systemd.conf
set +a

. ${SC_TOP}/../functions


declare -gr SUDO_CMD="sudo";


${SUDO_CMD} -v


pushd ${SC_TOP}

mkdir -p tmp

cat > ./tmp/${AA_SYSTEMD_UNIT_M4} <<EOF
include(\`${AA_SYSTEMD_CONF_M4}')
AA_SYSTEMD_UNIT(\`${SC_TOP}../')
EOF


m4 ./tmp/${AA_SYSTEMD_UNIT_M4}  > ./tmp/${AA_SYSTEMD_UNIT}

${SUDO_CMD} install -m 644 ./tmp/${AA_SYSTEMD_UNIT} ${SD_UNIT_PATH01}

popd

${SUDO_CMD} systemctl daemon-reload;

${SUDO_CMD} systemctl enable ${AA_SYSTEMD_UNIT};
${SUDO_CMD} systemctl start  ${AA_SYSTEMD_UNIT};
