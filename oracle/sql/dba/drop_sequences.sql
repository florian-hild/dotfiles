--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
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
SET SERVEROUTPUT ON SIZE 1000000

col spoolname new_value spoolname
SELECT '$HOME/sequences_drop_' || to_char(sysdate, 'yyyy-mm-dd_hh24-mi-ss') || '.sql' spoolname FROM dual;
SPOOL '&spoolname'

-- Save output to file
col SEQUENCE_OWNER format a20
col SEQUENCE_NAME format a30
SELECT '-- SEQUENCE_OWNER       SEQUENCE_NAME                   MIN_VALUE  MAX_VALUE INCREMENT_BY LAST_NUMBER CACHE_SIZE' FROM dual;
SELECT '-- -------------------- ------------------------------ ---------- ---------- ------------ ----------- ----------' FROM dual;
SELECT '-- '|| SEQUENCE_OWNER as "SEQUENCE_OWNER",SEQUENCE_NAME,MIN_VALUE,MAX_VALUE,INCREMENT_BY,LAST_NUMBER,CACHE_SIZE
  FROM all_sequences
  WHERE SEQUENCE_OWNER = user
  ORDER BY SEQUENCE_OWNER,SEQUENCE_NAME ASC;

DECLARE
  CURSOR select_sequences
  IS
    SELECT OBJECT_NAME
      FROM all_objects
       WHERE OWNER = user
       AND OBJECT_TYPE = 'SEQUENCE'
       ORDER BY OBJECT_NAME ASC;

BEGIN
  FOR sequence_record IN select_sequences
  LOOP
    dbms_output.put_line ('drop sequence ' || user || '.' || sequence_record.OBJECT_NAME || ';');
  END LOOP;
END;
/

SPOOL off;

select '&spoolname' from DUAL;
