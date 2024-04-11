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

accept tablespace char prompt 'Please enter tablespace for history tables: '

col spoolname new_value spoolname
SELECT '$HOME/move_history_tables_' || to_char(sysdate, 'yyyy-mm-dd_hh24-mi-ss') || '.sql' spoolname FROM dual;
SPOOL '&spoolname'

DECLARE
  CURSOR all_history_tables
  IS
    SELECT table_name
      FROM user_tables
      WHERE table_name LIKE '%\_H' ESCAPE'\'
      AND TABLESPACE_NAME != UPPER('&tablespace')
      ORDER BY TABLE_NAME;

BEGIN
  FOR table_record IN all_history_tables
  LOOP
    dbms_output.put_line ('ALTER TABLE ' || table_record.table_name || ' move tablespace ' || UPPER('&tablespace') || ';');
  END LOOP;
END;
/

SPOOL off;

select '&spoolname' from DUAL;
