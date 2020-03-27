#!/usr/bin/env bash

### WARNING!
### Do not use this unless you know what you're doing!

set -euo pipefail

# Quick-and-dirty restart
declare SHEPHERD_JOB="$1"

# Become mercury#humgen
export IRODS_ENVIRONMENT_FILE="/nfs/users/nfs_m/mercury/.irods/irods_environment.humgen.json"

# Our pet PostgreSQL instance
export PG_HOST="172.27.84.210"
export PG_DATABASE="postgres"
export PG_USERNAME="postgres"
export PG_PASSWORD="postgres"

# Set Postgre-recognised environment variables
export PGHOSTADDR="${PG_HOST}"
export PGPORT="5432"
export PGDATABASE="${PG_DATABASE}"
export PGUSER="${PG_USERNAME}"
export PGPASSWORD="${PG_PASSWORD}"

# Reset previously running task status on resumption
# WARNING SQL Injection: Dragons be here!
declare LOG_DIR="$(psql -tf <(cat <<-SQL
	with previously_running as (
	  select task
	  from   task_status
	  where  succeeded is null
	)
	update attempts
	set    start     = coalesce(start, now()),
	       finish    = now(),
	       exit_code = -3
	where  task in (select task from previously_running);
	
	select value
	from   job_metadata
	where  job = ${SHEPHERD_JOB}
	and    key = 'logs';
	SQL
) | sed -n "2{s/^[[:blank:]]*//;s/[[:blank:]]*$//;p}")"

# LSF configuration
export LSF_CONFIG="/usr/local/lsf/conf/lsbatch/farm5/configdir"
export LSF_GROUP="hgi-archive"

# Transfer options
export PREP_QUEUE="normal"
export TRANSFER_QUEUE="${TRANSFER_QUEUE-long}"
export IRODS_BASE="${IRODS_BASE-/humgen/archive}"

source .venv/bin/activate

bsub -n "4" -M "1000" \
     -q "${TRANSFER_QUEUE}" \
     -G "${LSF_GROUP}" \
     -R "span[hosts=1] select[mem>1000] rusage[mem=1000]" \
     -o "${LOG_DIR}/transfer.%I.log" \
     -e "${LOG_DIR}/transfer.%I.log" \
     -J "shepherd_worker[1-10]" \
     "/lustre/scratch119/realdata/mdt3/teams/hgi/shepherd-testing/shepherd/shepherd" __transfer "${SHEPHERD_JOB}"
