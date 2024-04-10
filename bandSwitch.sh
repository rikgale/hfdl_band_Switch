#!/bin/bash

# Function to print usage information
print_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -startdaytime <time>        Start time for daytime period (mandatory)"
    echo "  -enddaytime <time>          End time for daytime period (mandatory)"
    echo "  -startnighttime <time>      Start time for nighttime period (mandatory)"
    echo "  -endnighttime <time>        End time for nighttime period (mandatory)"
    echo "  -serviceday <service>       Service to run during daytime (mandatory)"
    echo "  -servicenight <service>     Service to run during nighttime (mandatory)"
    echo "  -bandday <description>      Description of band during daytime (optional, for example \"Band 17\")"
    echo "  -bandnight <description>    Description of band during nighttime (optional, for example \"Band 5-6\")"
    echo "  -h, --help                  Display this help message"
}

# Default values for optional variables
band_description_day=""
band_description_night=""

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -startdaytime) start_time_day="$2"; shift ;;
        -enddaytime) end_time_day="$2"; shift ;;
        -startnighttime) start_time_night="$2"; shift ;;
        -endnighttime) end_time_night="$2"; shift ;;
        -serviceday) service_day="$2"; shift ;;
        -servicenight) service_night="$2"; shift ;;
        -bandday) band_description_day="$2"; shift ;;
        -bandnight) band_description_night="$2"; shift ;;
        -h|--help) print_usage; exit 0 ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Check if mandatory options are provided
if [[ -z "${start_time_day}" || -z "${end_time_day}" || -z "${start_time_night}" || -z "${end_time_night}" || -z "${service_day}" || -z "${service_night}" ]]; then
    echo "Error: Mandatory options are missing."
    print_usage
    exit 1
fi

# Function to delete old log entries
delete_old_logs() {
  # Log file path
  log_file="/home/pi/bandSwitch.log"

  # Calculate 5 days ago timestamp
  five_days_ago=$(date -d "1 days ago" +%s)

  # Find and delete log entries older than 5 days 
  find "$log_file" -type f -mtime +1 -exec rm {} \;
}

# Log file
log_file="/home/pi/bandSwitch.log"

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") $1" >> "$log_file"
}

# Delete old log entries
delete_old_logs

# Get the current time in HH:MM format
current_time=$(date +"%H:%M")

# Check if current time is within the first time range
if [[ "$current_time" > "$start_time_day" && "$current_time" < "$end_time_day" ]]; then
    log_message "Current time is between $start_time_day and $end_time_day (daytime)"

    # Check if service_night is running
    if systemctl is-active --quiet "$service_night.service"; then
        log_message "$service_night is running. Stopping $service_night and starting $service_day."
        # Stop service_night
        sudo systemctl stop "$service_night.service"
        sleep 10
        # Start service_day
        sudo systemctl start "$service_day.service"
    else
        log_message "$service_day $band_description_day is running."
    fi

# Check if current time is within the second time range
elif [[ "$current_time" > "$start_time_night" || "$current_time" < "$end_time_night" ]]; then
    log_message "Current time is between $start_time_night and $end_time_night (nighttime)"

    # Check if service_day is running
    if systemctl is-active --quiet "$service_day.service"; then
        log_message "$service_day is running. Stopping $service_day and starting $service_night."
        # Stop service_day
        sudo systemctl stop "$service_day.service"
        sleep 10
        # Start service_night
        sudo systemctl start "$service_night.service"
    else
        log_message "$service_night $band_description_night is running."
    fi

else
    log_message "No action taken. Current time is outside the specified time ranges."
fi
