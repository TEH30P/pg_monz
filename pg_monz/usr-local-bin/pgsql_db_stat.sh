#!/bin/bash

PGSHELL_CONFDIR="$1"
DBNAME="$2"

GETROW="\
select row_to_json(t) 
from ( \
	select 
			numbackends
		,	xact_commit
		,	xact_rollback
		,	deadlocks
		,	temp_bytes
		,	tup_deleted
		,	tup_fetched
		,	tup_inserted
		,	tup_returned
		,	tup_updated
		,	CASE when blks_hit+blks_read = 0 THEN 100 ELSE round(blks_hit*100/(blks_hit+blks_read), 2) END AS cache_hit_ratio
	from 
		pg_stat_database
	where datname = '$DBNAME'
) t;"

# Load the psql connection option parameters.
source $PGSHELL_CONFDIR/pgsql_funcs.conf

psql -h $PGHOST -p $PGPORT -U $PGROLE -d $PGDATABASE -t -X -c "$GETROW"
