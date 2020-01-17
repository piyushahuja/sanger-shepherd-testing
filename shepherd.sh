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

# Our pet PostgreSQL instance
export PG_HOST="172.27.84.210"
export PG_DATABASE="postgres"
export PG_USERNAME="postgres"
export PG_PASSWORD="postgres"

# LSF configuration
export LSF_CONFIG="/usr/local/lsf/conf/lsbatch/${FARM}/configdir"
export LSF_GROUP="hgi-archive"

# Transfer options
export PREP_QUEUE="${PREP_QUEUE-normal}"
export TRANSFER_QUEUE="${TRANSFER_QUEUE-long}"
export IRODS_BASE="${IRODS_BASE-/humgen/archive}"

main() {
  local mode="$1"

  source .venv/bin/activate

  case "${mode}" in
    "submit")
      local subcollection="$2"
      local run_dir="$(pwd)/run/${subcollection}"
      local fofn="${run_dir}/fofn"
      local metadata="${run_dir}/metadata.json"
      export SHEPHERD_LOG="${run_dir}"

      shepherd/shepherd submit "${fofn}" "${subcollection}" "${metadata}"
      ;;

    "resume")
      local job_id="$2"
      export SHEPHERD_LOG="$(pwd)"

      # TODO Make this less shit
      if (( $# == 3 )) && [[ "$3" == "--force" ]]; then
        shepherd/shepherd resume "${job_id}" --force
      else
        shepherd/shepherd resume "${job_id}"
      fi
      ;;

    "status")
      local job_id="$2"
      export SHEPHERD_LOG="$(pwd)"

      shepherd/shepherd status "${job_id}"
      ;;

    *)
      >&2 echo "Usage: shepherd.sh ( submit RUN_DIR | resume JOB_ID [--force] | status JOB_ID )"
      exit 1
      ;;
  esac
}

main "$@"
