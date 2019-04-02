#!/bin/bash

PGSHELL_CONFDIR="$1"
PARAM1="$2"

GETROW="
select row_to_json(t)
from
	(	select
			count(*) as tot
		,	coalesce(sum(case when query ~* '^(insert|update|delete)' then 1 else 0 end), 0) as wr
		,	coalesce(sum(case when query ilike 'select%' then 1 else 0 end), 0) as rd
		from pg_catalog.pg_stat_activity
		where
			state = 'active'
		and	query_start + interval '$PARAM1 sec' <= now()
	) t;"

# Load the psql connection option parameters.
source $PGSHELL_CONFDIR/pgsql_funcs.conf

result=$(psql -h $PGHOST -p $PGPORT -U $PGROLE -d $PGDATABASE -t -X -c "$GETROW" 2>&1)
echo "$result"