#!/bin/bash

APP_NAME="$1"
PGSHELL_CONFDIR="$2"
DBNAME="$3"

# Load the psql connection option parameters.
source $PGSHELL_CONFDIR/pgsql_funcs.conf

case "$APP_NAME" in
	size)
		result=$(psql -h $PGHOST -p $PGPORT -U $PGROLE -d $PGDATABASE -t -X -c "\
		select pg_database_size('$DBNAME');" 2>&1)
		;;
	garbage_r)
		result=$(psql -h $PGHOST -p $PGPORT -U $PGROLE -d $DBNAME -t -X -c "
		select
			round(100 * sum(
				case (a.n_live_tup + a.n_dead_tup)
					when 0 then 0
					else c.relpages * (a.n_dead_tup / (a.n_live_tup + a.n_dead_tup)::numeric)
				end)
			/ sum(c.relpages), 2)
		from
			pg_catalog.pg_class as c
		join
			pg_catalog.pg_stat_all_tables as a
		on (c.oid = a.relid)
		where c.relpages > 0;" 2>&1)
		;;
	*)
		echo "'$APP_NAME' did not match anything."
		exit
		;;
esac

echo "$result"