#!/bin/bash
#
# pgpool-II pcp wrapper
#
# Interfaces with pgpool's pcp command-line tools to provide access to common functions for managing
# load-balancing and failover.
#

PATH="/bin:/sbin:/usr/bin:/usr/sbin"

# PCP configuration
pcp_host="localhost"
pcp_port="{{ pgpool2_pcp_port }}"
pcp_username="{{ pgpool2_pcp_user_name }}"
pcp_password="{{ pgpool2_pcp_user_password }}"

# Health check uses psql to connect to each backend server. Specify options required to connect here
psql_healthcheck_opts="-U postgres"

# Default options to send to pcp commands
pcp_cmd_preamble="-h ${pcp_host} -p ${pcp_port} -U ${pcp_username} -w"

#
# Get the node ID of the first master
#
_get_master_node()
{
    # Get total number of nodes
    nodes=$(_get_node_count)

    if [ $? -gt 0 ]; then
        echo "ERROR: Failed getting node count: $nodes" >&2
        exit 1
    fi

    c=0

    # Loop through each node to check if it's the master
    while [ ${c} -lt ${nodes} ]; do
        if [ "$(_is_standby ${c})" == "0" ]; then
            echo ${c}
            return 0
        fi
        let c=c+1
    done

    echo "-1"
    return 1
}

#
# Checks if the node is in postgresql recovery mode (ie. if it is a slave)
#
_is_standby()
{
    if [ -z $1 ]; then
        echo "Usage: $0 _is_standby <node id>" >&2
        return 99
    fi

    # Get node connection information
    node_info=($(_get_node_info $1))

    if [ $? -gt 0 ]; then
        echo "ERROR: Failed getting node info for node $1" >&2
        return 1
    fi

    export PGCONNECT_TIMEOUT=2
    result=$(psql ${psql_healthcheck_opts} -h "${node_info[0]}" -p "${node_info[1]}" -Atc "SELECT pg_is_in_recovery();" 2>/dev/null)

    if [ "${result}" == "t" ]; then
        echo 1
        return 1
    else
        echo 0
        return 0
    fi
}

#
# Prints whether the postgresql service on the specified node is responding.
#
_is_node_alive()
{
    if [ -z $1 ]; then
        echo "Usage: $0 _is_node_alive <node id>" >&2
        return 99
    fi

    # Get node connection information
    node_info=($(_get_node_info $1))

    if [ $? -gt 0 ]; then
        echo "ERROR: Failed getting node info for node $1" >&2
        return 1
    fi

    export PGCONNECT_TIMEOUT=2
    result=$(psql ${psql_healthcheck_opts} -h "${node_info[0]}" -p "${node_info[1]}" -Atc "SELECT 1;" 2>/dev/null)

    if [ "$result" == "1" ]; then
        echo 1
        return 1
    else
        echo 0
        return 0
    fi
}

#
# Prints the status of the specified node in human readable format.
#
_get_node_status()
{
    if [ -z $1 ]; then
        echo "Usage: $0 _get_node_status <node id>" >&2
        return 99
    fi

    node_info=($(_get_node_info $1))

    if [ $? -gt 0 ]; then
        echo "ERROR: Failed getting node info for node $1" >&2
    else
        node_role=""
        node_alive=""
        case "$(_is_node_alive $1)" in
            1)
                node_alive="Up"
                ;;
            *)
                node_alive="Down"
                ;;
        esac
        if [ "$node_alive" == "Up" ]; then

            # Find out what role this node has
            if [ "$(_is_standby $1)" == "1" ]; then
                node_role="Slave"
            else
                node_role="Master"
            fi
        fi
        case "${node_info[2]}" in
            3)
                node_status="detached from pool"
                ;;
            2)
                node_status="in pool and connected"
                ;;
            1)
                node_status="in pool"
                ;;
            *)
                node_status="Unknown"
                ;;
        esac

        # Print status information about this node
        echo "Node: $1"
        echo "Host: ${node_info[0]}"
        echo "Port: ${node_info[1]}"
        echo "Weight: ${node_info[3]}"
        echo "Status: ${node_alive}, ${node_status} (${node_info[2]})"
        [ -n "${node_role}" ] && echo "Role: ${node_role}"
        echo ""
    fi
}

#
# Prints the total number of pgpool nodes.
#
_get_node_count() {
    pcp_node_count ${pcp_cmd_preamble}
}

#
# Prints out node information for the specified pgpool node
#
_get_node_info() {
    if [ -z $1 ]; then
        echo "Usage: $0 _get_node_info <node id>" >&2
        return 99
    fi
    pcp_node_info ${pcp_cmd_preamble} $1
}

#
# Attaches the specified node to the pool
#
attach() {
    if [ -z $1 ]; then
        echo "Usage: $0 attach <node id>" >&2
        return 99
    fi
    pcp_attach_node ${pcp_cmd_preamble} $1
}

#
# Detaches the specified node from the pool
#
detach() {
    if [ -z $1 ]; then
        echo "Usage: $0 detach <node id>" >&2
        return 99
    fi
    pcp_detach_node ${pcp_cmd_preamble} $1
}

#
# Recovers the specified node (restores it from current master and re-attaches)
#
recover() {
    if [ -z $1 ]; then
        echo "Usage: $0 recover <node id>" >&2
        return 99
    fi
    pcp_recovery_node ${pcp_cmd_preamble} $1
}

#
# Prints out the status of all pgpool nodes in human readable form.
#
status() {
    # Get total number of nodes
    nodes=$(_get_node_count)
    if [ $? -gt 0 ]; then
        echo "ERROR: Failed getting node count: $nodes" >&2
        exit 1
    fi
    c=0
    # Loop through each node to retrieve info
    while [ ${c} -lt ${nodes} ]; do
        _get_node_status ${c}
        let c=c+1
    done
}

main()
{
    if [ ! "$(type -t $1)" ]; then
        echo "Usage $0 <option>" >&2
        echo "" >&2
        echo "Available options:" >&2
        echo "$(compgen -A function | grep -Ev '^_|main')" >&2
        exit 99
    else
        cmd=$1
        shift
        $cmd $*
        exit $?
    fi
}

main $*
