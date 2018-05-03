# Copyright (C) 2017 Philipp Holzinger
# Copyright (C) 2017 Martin Stumpf
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

set script_dir "[file dirname "[file normalize "[info script]"]"]"
source  "${script_dir}/../../../../board_config.tcl"

# cleanup previous mess if exists
close_project -quiet
file delete -force "$script_dir/build"


##################################
# General Project Settings 
#

# create project
set proj_obj [create_project "dualclock_bram" "$script_dir/build"]
set_property "target_language" "VHDL" $proj_obj

# set target board
set_property "part" "${PART_NAME}" $proj_obj

# enable xmp libraries (for virtex ultrascale)
set_property "XPM_LIBRARIES" {XPM_CDC XPM_MEMORY XPM_FIFO} $proj_obj


##################################
# Design 
#

set common_dir "../../common"

add_files "${common_dir}/mem_router/bram_tdp.vhd"
add_files "${common_dir}/mem_router/dualclock_bram.vhd"

# set toplevel entity
set_property "top" "dualclock_bram" [get_filesets sources_1]
update_compile_order -fileset sources_1


##################################
# Simulation 
#


##################################
# IP Creation
#

source "ip.tcl"
