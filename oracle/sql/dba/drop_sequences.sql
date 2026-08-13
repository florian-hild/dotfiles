--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description: Generate a drop script plus a DDL backup (safety net) for all
--              sequences. Sequences are dropped so a later import
--              (INCLUDE=SEQUENCE) recreates them with the source values; the
--              backup lets you restore them if the sequence import is skipped.
--              Leave owner blank for current user.
--------------------------------------------------------------------------------

set echo off
set term on
set verify off
set feedback off
set heading off
set pagesize 0
set linesize 32767
set long 200000
set trimspool on
set wrap off

accept owners char prompt 'Enter owner(s) comma-separated (leave blank for current user): '

whenever sqlerror exit failure

col spoolname new_value spoolname
SELECT '$HOME/sequences_drop_' || to_char(sysdate, 'yyyy-mm-dd_hh24-mi-ss') || '.sql' spoolname FROM dual;

col spoolname_bak new_value spoolname_bak
SELECT '$HOME/sequences_recreate_' || to_char(sysdate, 'yyyy-mm-dd_hh24-mi-ss') || '.sql' spoolname_bak FROM dual;

-- DROP all sequences (current values documented as comment)
SPOOL '&spoolname'
PROMPT WHENEVER SQLERROR CONTINUE
SELECT '-- SEQUENCE_OWNER       SEQUENCE_NAME                   MIN_VALUE  MAX_VALUE INCREMENT_BY LAST_NUMBER CACHE_SIZE' FROM dual;
SELECT '-- -------------------- ------------------------------ ---------- ---------- ------------ ----------- ----------' FROM dual;
SELECT '-- ' || RPAD(sequence_owner, 21) || RPAD(sequence_name, 31)
       || LPAD(min_value, 10) || LPAD(max_value, 11) || LPAD(increment_by, 13)
       || LPAD(last_number, 12) || LPAD(cache_size, 11)
  FROM dba_sequences
  WHERE (('&owners' IS NULL AND sequence_owner = user)
         OR INSTR(',' || REPLACE(UPPER('&owners'), ' ') || ',',
                  ',' || sequence_owner || ',') > 0)
  ORDER BY sequence_owner, sequence_name;
SELECT 'DROP SEQUENCE "' || sequence_owner || '"."' || sequence_name || '";'
  FROM dba_sequences
  WHERE (('&owners' IS NULL AND sequence_owner = user)
         OR INSTR(',' || REPLACE(UPPER('&owners'), ' ') || ',',
                  ',' || sequence_owner || ',') > 0)
  ORDER BY sequence_owner, sequence_name;
PROMPT EXIT
SPOOL off

-- DDL backup of the current sequences (recreate fallback)
BEGIN
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', TRUE);
END;
/
SPOOL '&spoolname_bak'
SELECT DBMS_METADATA.GET_DDL('SEQUENCE', sequence_name, sequence_owner)
  FROM dba_sequences
  WHERE (('&owners' IS NULL AND sequence_owner = user)
         OR INSTR(',' || REPLACE(UPPER('&owners'), ' ') || ',',
                  ',' || sequence_owner || ',') > 0)
  ORDER BY sequence_owner, sequence_name;
SPOOL off

select '&spoolname' from DUAL;
select '&spoolname_bak' from DUAL;
