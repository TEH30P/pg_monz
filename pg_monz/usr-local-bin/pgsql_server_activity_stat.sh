#!/bin/bash

PGSHELL_CONFDIR="$1"

# Load the psql connection option parameters.
source $PGSHELL_CONFDIR/pgsql_funcs.conf

PGVERSION=$(psql -A -t -X -h $PGHOST -p $PGPORT -U $PGROLE $PGDATABASE -c 'select * from version()' | cut -d ' ' -f 2 | sed -n 's/^\([0-9]\+\(\.[0-9]\+\)\?\).*$/\1/p')
if [ $? -ne 0 ]; then
	echo "$PGVERSION"
	exit
fi

if [ `echo "$PGVERSION >= 10.0" | bc` -eq 1 ] ; then
	GETROW="
	select row_to_json(t)
	from
		(	select
				sum(case when state = 'active' then 1 else 0 end)                as act
			,	sum(case when state = 'idle' then 1 else 0 end)                  as idl
			,	sum(case when state = 'idle in transaction' then 1 else 0 end)   as idlit
			,	sum(case when backend_type = 'client backend' then 1 else 0 end) as tot
			,	sum(case when backend_type = 'client backend' and wait_event_type like '%Lock%' then 1 else 0 end) as lckw
			from pg_catalog.pg_stat_activity
		) t;"
elif [ `echo "$PGVERSION >= 9.6" | bc` -eq 1 ] ; then
	GETROW="
	select row_to_json(t)
	from
		(	select
				sum(case when state = 'active' then 1 else 0 end)                as act
			,	sum(case when state = 'idle' then 1 else 0 end)                  as idl
			,	sum(case when state = 'idle in transaction' then 1 else 0 end)   as idlit
			,	count(*)                                                         as tot
			,	sum(case when wait_event_type like '%Lock%' then 1 else 0 end)   as lckw
			from pg_catalog.pg_stat_activity
		) t;"
else
	GETROW="
	select row_to_json(t)
	from
		(	select
				sum(case when state = 'active' then 1 else 0 end)                as act
			,	sum(case when state = 'idle' then 1 else 0 end)                  as idl
			,	sum(case when state = 'idle in transaction' then 1 else 0 end)   as idlit
			,	count(*)                                                         as tot
			,	sum(case when waiting = 'true' then 1 else 0 end)                as lckw
			from pg_catalog.pg_stat_activity
		) t;"
fi

result=$(psql -h $PGHOST -p $PGPORT -U $PGROLE -d $PGDATABASE -t -X -c "$GETROW" 2>&1)
echo "$result"