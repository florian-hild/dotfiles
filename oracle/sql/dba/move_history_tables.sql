--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description: Generate ALTER TABLE MOVE script for %_H (history) tables not
--              yet in the target tablespace. MOVE ... UPDATE INDEXES keeps
--              the tables' indexes usable during the move.
--              Leave owner blank for current user.
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
accept tablespace char prompt 'Please enter tablespace for history tables: '

whenever sqlerror exit failure

col spoolname new_value spoolname
SELECT '$HOME/move_history_tables_' || to_char(sysdate, 'yyyy-mm-dd_hh24-mi-ss') || '.sql' spoolname FROM dual;

SPOOL '&spoolname'
PROMPT WHENEVER SQLERROR CONTINUE
SELECT 'ALTER TABLE "' || owner || '"."' || table_name || '" MOVE TABLESPACE ' || UPPER('&tablespace') || ' UPDATE INDEXES;'
  FROM dba_tables
  WHERE (('&owners' IS NULL AND owner = user)
         OR INSTR(',' || REPLACE(UPPER('&owners'), ' ') || ',',
                  ',' || owner || ',') > 0)
    AND table_name LIKE '%\_H' ESCAPE '\'
    AND tablespace_name != UPPER('&tablespace')
    AND partitioned = 'NO'   -- partitioned tables need MOVE PARTITION
    AND temporary = 'N'
    AND iot_type IS NULL     -- IOTs have no MOVE TABLESPACE
  ORDER BY owner, table_name;
PROMPT EXIT
SPOOL off

select '&spoolname' from DUAL;
