#!/usr/bin/env bash

declare -Agr B=(
  [B]=$(echo -e "\e[44m")
  [C]=$(echo -e "\e[46m")
  [G]=$(echo -e "\e[42m")
  [K]=$(echo -e "\e[40m")
  [M]=$(echo -e "\e[45m")
  [R]=$(echo -e "\e[41m")
  [W]=$(echo -e "\e[47m")
  [Y]=$(echo -e "\e[43m")
)
declare -Agr F=(
  [B]=$(echo -e "\e[0;34m")
  [C]=$(echo -e "\e[0;36m")
  [G]=$(echo -e "\e[0;32m")
  [K]=$(echo -e "\e[0;30m")
  [M]=$(echo -e "\e[0;35m")
  [R]=$(echo -e "\e[0;31m")
  [W]=$(echo -e "\e[0;37m")
  [Y]=$(echo -e "\e[0;33m")
)
readonly NC=$(echo -e "\e[0m")

export B
export F
export NC
