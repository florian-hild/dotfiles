--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description: Generate REBUILD statements to relocate indexes into the target
--              tablespace. Non-partitioned indexes rebuild whole; partitioned
--              indexes rebuild per partition (a whole-index REBUILD raises
--              ORA-14086). LOB and system-generated (SYS_*) indexes are
--              skipped. Leave owner blank for current user.
--------------------------------------------------------------------------------

set echo off
set term on
set verify off
set feedback off
set heading off
set pagesize 0
set linesize 250
set trimspool on
set wrap off

accept owners char prompt 'Enter owner(s) comma-separated (leave blank for current user): '
accept tablespace char prompt 'Please enter tablespace for indexes: '

whenever sqlerror exit failure

col spoolname new_value spoolname
SELECT '$HOME/move_indexes_' || to_char(sysdate, 'yyyy-mm-dd_hh24-mi-ss') || '.sql' spoolname FROM dual;

SPOOL '&spoolname'
PROMPT WHENEVER SQLERROR CONTINUE
-- Non-partitioned indexes
SELECT 'ALTER INDEX "' || owner || '"."' || index_name || '" REBUILD TABLESPACE ' || UPPER('&tablespace') || ';'
  FROM dba_indexes
  WHERE (('&owners' IS NULL AND owner = user)
         OR INSTR(',' || REPLACE(UPPER('&owners'), ' ') || ',',
                  ',' || owner || ',') > 0)
    AND tablespace_name != UPPER('&tablespace')
    AND partitioned = 'NO'
    AND index_type NOT LIKE 'LOB%'
    AND index_name NOT LIKE 'SYS\_%' ESCAPE '\'
  ORDER BY owner, index_name;
-- Partitioned indexes: one REBUILD per partition
SELECT 'ALTER INDEX "' || ip.index_owner || '"."' || ip.index_name
       || '" REBUILD PARTITION "' || ip.partition_name || '" TABLESPACE ' || UPPER('&tablespace') || ';'
  FROM dba_ind_partitions ip
  JOIN dba_indexes i
    ON i.owner = ip.index_owner AND i.index_name = ip.index_name
  WHERE (('&owners' IS NULL AND i.owner = user)
         OR INSTR(',' || REPLACE(UPPER('&owners'), ' ') || ',',
                  ',' || i.owner || ',') > 0)
    AND i.partitioned = 'YES'
    AND i.index_type NOT LIKE 'LOB%'
    AND i.index_name NOT LIKE 'SYS\_%' ESCAPE '\'
    AND ip.tablespace_name != UPPER('&tablespace')
  ORDER BY ip.index_owner, ip.index_name, ip.partition_name;
PROMPT EXIT
SPOOL off

select '&spoolname' from DUAL;
