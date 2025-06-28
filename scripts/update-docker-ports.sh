# Docker Compose port updater function
update-docker-ports() {
    # Check if starting port is provided
    if [ $# -eq 0 ]; then
        echo "Usage: update-docker-ports <starting_port>"
        echo "Example: update-docker-ports 4000"
        return 1
    fi

    local starting_port=$1
    local compose_file="docker-compose.yml"

    # Check if docker-compose.yml exists
    if [ ! -f "$compose_file" ]; then
        echo "Error: $compose_file not found in current directory"
        return 1
    fi

    # Validate that starting port is a number
    if ! [[ "$starting_port" =~ ^[0-9]+$ ]]; then
        echo "Error: Starting port must be a number"
        return 1
    fi

    # Find all current port mappings first
    local port_mappings=()
    while IFS= read -r line; do
        port_mappings+=("$line")
    done < <(grep -E '^ *- *"[0-9]+:[0-9]+"' "$compose_file")

        # Now replace each port mapping
    local current_port=$starting_port
    for port_mapping in "${port_mappings[@]}"; do
        # Extract current host port and container port using extended regex
        local host_port=$(echo "$port_mapping" | sed -E 's/.*"([0-9]+):([0-9]+)".*/\1/')
        local container_port=$(echo "$port_mapping" | sed -E 's/.*"([0-9]+):([0-9]+)".*/\2/')

        # Replace the old mapping with new mapping
        sed -i.tmp "s/\"${host_port}:${container_port}\"/\"${current_port}:${container_port}\"/" "$compose_file"
        rm "${compose_file}.tmp" 2>/dev/null

        echo "Replaced port mapping: ${host_port}:${container_port} → ${current_port}:${container_port}"
        current_port=$((current_port + 1))
    done

    echo ""
    echo "Port replacement complete!"
    echo ""
    echo "New port mappings:"
    grep -E '^ *- *"[0-9]+:[0-9]+"' "$compose_file"
}