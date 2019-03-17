#!/bin/bash

PGSHELL_CONFDIR="$1"
DBNAME="$2"
SCHEMANAME="$3"
TABLENAME="$4"

GETROW="
select row_to_json(t) 
from 
	(	select 
			case sio.heap_blks_hit + sio.heap_blks_read when 0 then 100 else round(sio.heap_blks_hit * 100 / (sio.heap_blks_hit + sio.heap_blks_read), 2) end as heap_cachehit_ratio, 
			case when sio.idx_blks_read is null then 0 when sio.idx_blks_hit + sio.idx_blks_read = 0 then 100 else round(sio.idx_blks_hit * 100 / (sio.idx_blks_hit + sio.idx_blks_read + 0.0001), 2) end as idx_cachehit_ratio, 
			s.analyze_count, 
			s.autoanalyze_count, 
			s.autovacuum_count, 
			s.n_dead_tup, 
			s.n_tup_del, 
			s.n_tup_hot_upd, 
			coalesce(s.idx_scan, 0) as idx_scan, 
			coalesce(s.seq_tup_read, 0) as seq_tup_read, 
			coalesce(s.idx_tup_fetch, 0) as idx_tup_fetch, 
			s.n_tup_ins, 
			s.n_live_tup, 
			s.seq_scan, 
			s.n_tup_upd, 
			s.vacuum_count, 
			round(100 * (case (s.n_live_tup + s.n_dead_tup) when 0 then 0 else (s.n_dead_tup / (s.n_live_tup + s.n_dead_tup) :: numeric) end),2) as table_garbage_ratio, 
			pg_total_relation_size(s.relid) as table_size_tot 
		from 
			pg_catalog.pg_stat_user_tables s 
		join 
			pg_catalog.pg_statio_user_tables sio 
		on s.relid = sio.relid 
		where s.schemaname = '$SCHEMANAME' and  s.relname = '$TABLENAME' 
	) t;"

# Load the psql connection option parameters.
source $PGSHELL_CONFDIR/pgsql_funcs.conf

psql -h $PGHOST -p $PGPORT -U $PGROLE -d $DBNAME -t -X -c "$GETROW"

