#!/usr/bin/env bash

# Hide the terminal cursor
tput civis
# Restore cursor when the script exits
trap 'tput cnorm; exit' INT TERM EXIT

declare -A prev_idle prev_total
SECONDS=0

while true; do
  # Check if 10 seconds have passed
  if ((SECONDS >= 10)); then
    exit 0
  fi

  cores_output=""
  declare -A phys_core_temps

  # 1. Grab temperatures
  for d in /sys/class/hwmon/hwmon*; do
    if [[ -f "$d/name" ]] && [[ "$(cat "$d/name")" == "coretemp" ]]; then
      for label_file in "$d"/temp*_label; do
        if [[ -f "$label_file" ]]; then
          label=$(cat "$label_file")
          if [[ "$label" == Core* ]]; then
            phys_id="${label#Core }"
            input_file="${label_file%_label}_input"
            if [[ -f "$input_file" ]]; then
              temp_milli=$(cat "$input_file")
              phys_core_temps["$phys_id"]=$((temp_milli / 1000))
            fi
          fi
        fi
      done
      break
    fi
  done

  # 2. Read CPU data
  while read -r line; do
    if [[ "$line" == cpu[0-9]* ]]; then
      read -r -a cpu_data <<<"$line"
      cpu_name="${cpu_data[0]}"
      user="${cpu_data[1]}"
      nice="${cpu_data[2]}"
      system="${cpu_data[3]}"
      idle="${cpu_data[4]}"
      iowait="${cpu_data[5]}"
      irq="${cpu_data[6]}"
      softirq="${cpu_data[7]}"

      idle_time=$((idle + iowait))
      total_time=$((user + nice + system + idle + iowait + irq + softirq))

      if [[ -n "${prev_total[$cpu_name]}" ]]; then
        diff_idle=$((idle_time - prev_idle[$cpu_name]))
        diff_total=$((total_time - prev_total[$cpu_name]))

        if [[ "$diff_total" -ne 0 ]]; then
          usage=$((100 * (diff_total - diff_idle) / diff_total))
          logical_core="${cpu_name#cpu}"
          phys_id=$(cat "/sys/devices/system/cpu/cpu${logical_core}/topology/core_id" 2>/dev/null)
          temp="${phys_core_temps[$phys_id]:---}"

          printf -v formatted_usage "%3s%%" "$usage"
          printf -v formatted_temp "%2s°C" "$temp"
          cores_output="${cores_output}     core-${logical_core}: ${formatted_usage}   |    ${formatted_temp}\n"
        fi
      fi

      prev_idle[$cpu_name]=$idle_time
      prev_total[$cpu_name]=$total_time
    fi
  done </proc/stat

  tput clear
  echo -e "\n  ╭────────── CPU Cores ──────────╮\n"
  echo -e "${cores_output%\\n}"
  echo -e "\n  ╰───────────────────────────────╯"

  time_left=$((10 - SECONDS))
  echo -e " (Closing in ${time_left}s or press 'q' to quit)"

  # --- THE KEYPRESS LOGIC ---
  # -t 1: Wait for 1 second (replaces sleep 1)
  # -n 1: Read only 1 character
  # -s: Silent (don't echo the key pressed)
  read -t 1 -n 1 -s key
  if [[ $key == "q" ]]; then
    exit 0
  fi
done
