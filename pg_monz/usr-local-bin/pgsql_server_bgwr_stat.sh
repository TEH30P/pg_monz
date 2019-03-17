#!/bin/bash

PGSHELL_CONFDIR="$1"

GETROW="
select row_to_json(t) 
from 
	(	select 
		    buffers_alloc
		,   buffers_backend
		,   buffers_backend_fsync
		,   buffers_checkpoint
		,   buffers_clean
		,   checkpoints_req
		,   checkpoints_timed
		,   maxwritten_clean
		from 
			pg_catalog.pg_stat_bgwriter
	) t;"

# Load the psql connection option parameters.
source $PGSHELL_CONFDIR/pgsql_funcs.conf

psql -h $PGHOST -p $PGPORT -U $PGROLE -d postgres -t -X -c "$GETROW"

