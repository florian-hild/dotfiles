--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description: Generate MOVE/REBUILD script for NF_ tables and their indexes
--              into the target tablespace. move_indexe.sql excludes indexes
--              on NF_ tables, so the two steps don't fight over the same
--              objects. Leave owner blank for current user.
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
accept tablespace char prompt 'Please enter tablespace for nf tables: '

whenever sqlerror exit failure

col spoolname new_value spoolname
SELECT '$HOME/move_nf_objects_' || to_char(sysdate, 'yyyy-mm-dd_hh24-mi-ss') || '.sql' spoolname FROM dual;

SPOOL '&spoolname'
PROMPT WHENEVER SQLERROR CONTINUE
-- NF_ tables
SELECT 'ALTER TABLE "' || owner || '"."' || table_name || '" MOVE TABLESPACE ' || UPPER('&tablespace') || ' UPDATE INDEXES;'
  FROM dba_tables
  WHERE (('&owners' IS NULL AND owner = user)
         OR INSTR(',' || REPLACE(UPPER('&owners'), ' ') || ',',
                  ',' || owner || ',') > 0)
    AND table_name LIKE 'NF\_%' ESCAPE '\'
    AND tablespace_name != UPPER('&tablespace')
    AND partitioned = 'NO'   -- partitioned tables need MOVE PARTITION
    AND temporary = 'N'
    AND iot_type IS NULL     -- IOTs have no MOVE TABLESPACE
  ORDER BY owner, table_name;
-- Indexes on NF_ tables
SELECT 'ALTER INDEX "' || owner || '"."' || index_name || '" REBUILD TABLESPACE ' || UPPER('&tablespace') || ';'
  FROM dba_indexes
  WHERE (('&owners' IS NULL AND owner = user)
         OR INSTR(',' || REPLACE(UPPER('&owners'), ' ') || ',',
                  ',' || owner || ',') > 0)
    AND table_name LIKE 'NF\_%' ESCAPE '\'
    AND tablespace_name != UPPER('&tablespace')
    AND partitioned = 'NO'
    AND index_type NOT LIKE 'LOB%'
  ORDER BY owner, index_name;
PROMPT EXIT
SPOOL off

select '&spoolname' from DUAL;
