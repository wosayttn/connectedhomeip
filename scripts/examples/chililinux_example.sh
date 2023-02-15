#!/usr/bin/env bash

#
#    Copyright (c) 2022 Project CHIP Authors
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

set -e
set -x
if [ "$#" != 2 && "$#" != 3 ]; then
    exit -1
fi

source "$(dirname "$0")/../../scripts/activate.sh"

#env

release_build=true
if [ "$3" = "debug" ]; then
    release_build=false
fi

PLATFORM_CFLAGS=''

gn gen --check --root="$1" "$2" --args="target_os=\"linux\" target_cpu=\"arm926ejs\"
treat_warnings_as_errors=false
import(\"//build_overrides/build.gni\")
target_cflags=[ \"$PLATFORM_CFLAGS\" ]
custom_toolchain=\"\${build_root}/toolchain/custom\"
target_cc=\"arm-linux-gcc\"
target_cxx=\"arm-linux-g++\"
target_ar=\"arm-linux-ar\"
is_clang=false
chip_config_network_layer_ble=false
chip_enable_wifi=false
chip_enable_openthread=false
$(if [ "$release_build" = "true" ]; then echo "is_debug=false"; else echo "optimize_debug=true"; fi)"

ninja -C "$2"
