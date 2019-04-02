#!/bin/bash

PGSHELL_CONFDIR="$1"
DBNAME="$2"
SCHEMANAME="$3"
TABLENAME="$4"

GETROW="
select row_to_json(t) 
from 
	(	select 
			case sio.heap_blks_hit + sio.heap_blks_read when 0 then 100 else round(sio.heap_blks_hit * 100 / (sio.heap_blks_hit + sio.heap_blks_read), 2) end                                             as hchitr,  -- heap_cachehit_ratio
			case when sio.idx_blks_read is null then 0 when sio.idx_blks_hit + sio.idx_blks_read = 0 then 100 else round(sio.idx_blks_hit * 100 / (sio.idx_blks_hit + sio.idx_blks_read + 0.0001), 2) end as ichitr,  -- idx_cachehit_ratio
			round(100 * (case (s.n_live_tup + s.n_dead_tup) when 0 then 0 else (s.n_dead_tup / (s.n_live_tup + s.n_dead_tup) :: numeric) end),2)                                                          as tgrbr,   -- table_garbage_ratio
			s.analyze_count              as anlc, 
			s.autoanalyze_count          as aanlc, 
			s.autovacuum_count           as avacc, 
			s.n_dead_tup                 as tupdd, 
			s.n_live_tup                 as tuplv, 
			s.n_tup_del                  as tupd, 
			s.n_tup_ins                  as tupi, 
			s.n_tup_upd                  as tupu, 
			s.n_tup_hot_upd              as tuphu, 
			coalesce(s.idx_scan, 0)      as isc, 
			coalesce(s.seq_tup_read, 0)  as tupsrd, 
			coalesce(s.idx_tup_fetch, 0) as tupif, 
			s.seq_scan                   as scs, 
			s.vacuum_count               as vacc, 
			pg_total_relation_size(s.relid) as sz
		from 
			pg_catalog.pg_stat_user_tables s 
		join 
			pg_catalog.pg_statio_user_tables sio 
		on s.relid = sio.relid 
		where s.schemaname = '$SCHEMANAME' and  s.relname = '$TABLENAME' 
	) t;"

# Load the psql connection option parameters.
source $PGSHELL_CONFDIR/pgsql_funcs.conf

result=$(psql -h $PGHOST -p $PGPORT -U $PGROLE -d $DBNAME -t -X -c "$GETROW" 2>&1)
echo "$result"