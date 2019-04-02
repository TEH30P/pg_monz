#!/bin/bash

PGSHELL_CONFDIR="$1"

GETROW="
select row_to_json(t) 
from 
	(	select 
		    sum(xact_commit)      as xactc
		,   sum(xact_rollback)    as xactr
		from 
			pg_catalog.pg_stat_database
	) t;"

# Load the psql connection option parameters.
source $PGSHELL_CONFDIR/pgsql_funcs.conf

result=$(psql -h $PGHOST -p $PGPORT -U $PGROLE -d $PGDATABASE -t -X -c "$GETROW" 2>&1)
echo "$result"