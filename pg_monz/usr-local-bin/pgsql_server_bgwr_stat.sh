#!/bin/bash

PGSHELL_CONFDIR="$1"

GETROW="
select row_to_json(t) 
from 
	(	select 
		    buffers_alloc         as bufa
		,   buffers_backend       as bufb
		,   buffers_backend_fsync as bufbf
		,   buffers_checkpoint    as bufcp
		,   buffers_clean         as bufc
		,   checkpoints_req       as chkptr
		,   checkpoints_timed     as chkptt
		,   maxwritten_clean      as chkptc
		from 
			pg_catalog.pg_stat_bgwriter
	) t;"

# Load the psql connection option parameters.
source $PGSHELL_CONFDIR/pgsql_funcs.conf

result=$(psql -h $PGHOST -p $PGPORT -U $PGROLE -d $PGDATABASE -t -X -c "$GETROW" 2>&1)
echo "$result"