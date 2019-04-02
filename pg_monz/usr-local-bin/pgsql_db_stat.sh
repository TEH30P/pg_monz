#!/bin/bash

PGSHELL_CONFDIR="$1"
DBNAME="$2"

GETROW="\
select row_to_json(t) 
from ( \
	select 
			numbackends   as nbe
		,	xact_commit   as xactc
		,	xact_rollback as xactr
		,	deadlocks     as dlck
		,	temp_bytes    as tmpb
		,	tup_deleted   as tupd
		,	tup_fetched   as tupf
		,	tup_inserted  as tupi
		,	tup_returned  as tupr
		,	tup_updated   as tupu
		,	case when blks_hit+blks_read = 0 then 100 else round(blks_hit*100/(blks_hit+blks_read), 2) end as chitr
	from 
		pg_catalog.pg_stat_database
	where datname = '$DBNAME'
) t;"

# Load the psql connection option parameters.
source $PGSHELL_CONFDIR/pgsql_funcs.conf

result=$(psql -h $PGHOST -p $PGPORT -U $PGROLE -d $PGDATABASE -t -X -c "$GETROW" 2>&1)
echo "$result"