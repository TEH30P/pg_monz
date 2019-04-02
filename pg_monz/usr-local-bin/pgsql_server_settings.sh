#!/bin/bash

PGSHELL_CONFDIR="$1"
SETTING_NAME="$2"

# Load the psql connection option parameters.
source $PGSHELL_CONFDIR/pgsql_funcs.conf

result=$(psql -h $PGHOST -p $PGPORT -U $PGROLE -d $PGDATABASE -t -X -c "select setting from pg_catalog.pg_settings where name = '$SETTING_NAME'" 2>&1)
echo "$result"