#!/usr/bin/env bash

set -euo pipefail

# Setup
declare FARM="$(lsclusters | awk 'NR == 2 { print $1 }')"
case "${FARM}" in
  "farm3")
    # Add baton from HGI modules
    module add hgi/baton/latest
    ;;

  "farm4" | "farm5")
    # Add Singularity from ISG modules
    export MODULEPATH="/software/modules/ISG:${MODULEPATH}"
    module add singularity/3.2.0

    # Make containerised baton available
    export PATH="/software/hgi/containers/singularity-baton:${PATH}"
    ;;

  *)
    >&2 echo "I don't know anything about ${FARM}"
    exit 1
    ;;
esac

# Our dummy PostgreSQL instance
export PG_HOST="172.27.84.210"
export PG_DATABASE="postgres"
export PG_USERNAME="postgres"
export PG_PASSWORD="postgres"

# LSF configuration
export LSF_CONFIG="/usr/local/lsf/conf/lsbatch/${FARM}/configdir"
export LSF_GROUP="hgi-archive"

# Transfer options
export PREP_QUEUE="normal"
export TRANSFER_QUEUE="long"
export IRODS_BASE="/humgen/shepherd_testing"

# Let's go!
declare SUBCOLLECTION="$1"
declare RUN_DIR="$(pwd)/run/${SUBCOLLECTION}"
declare FOFN="${RUN_DIR}/fofn"
export SHEPHERD_LOG="${RUN_DIR}"

source .venv/bin/activate
shepherd/shepherd submit "${FOFN}" "${SUBCOLLECTION}"
