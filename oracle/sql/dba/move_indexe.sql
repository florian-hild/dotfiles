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

accept tablespace char prompt 'Please enter tablespace for indexes: '

col spoolname new_value spoolname
SELECT '$HOME/move_indexes_' || to_char(sysdate, 'yyyy-mm-dd_hh24-mi-ss') || '.sql' spoolname FROM dual;
SPOOL '&spoolname'

DECLARE
  CURSOR all_indexe
  IS
    SELECT INDEX_NAME
      FROM user_indexes
      WHERE TABLESPACE_NAME != UPPER('&tablespace')
      AND INDEX_NAME NOT LIKE 'SYS_%$'
      ORDER BY INDEX_NAME;

BEGIN
  FOR index_record IN all_indexe
  LOOP
    dbms_output.put_line ('ALTER INDEX ' || index_record.index_name || ' rebuild tablespace ' || UPPER('&tablespace') || ';');
  END LOOP;
END;
/

SPOOL off;

select '&spoolname' from DUAL;
