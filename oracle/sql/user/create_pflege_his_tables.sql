--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 0
set linesize 250
set echo off
set term on
set verify off
set feedback off
set heading off
set wrap off
SET SERVEROUTPUT ON SIZE 1000000
-- To print newline
set serveroutput on format wrapped

DECLARE
  CURSOR history_tables
  IS
    SELECT TABLE_NAME,COLUMN_NAME 
      FROM user_tab_columns
      WHERE column_name like '%MODDAT'
      AND table_name like '%\_H' ESCAPE '\'
      ORDER BY TABLE_NAME ASC;
BEGIN
  FOR object_record IN history_tables 
  LOOP
      dbms_output.new_line;
      dbms_output.put_line ('select sysdate ' || object_record.table_name || ' from dual;');
      dbms_output.put_line ('delete from ' || user || '.' || object_record.table_name || ' where ' || object_record.column_name || ' < to_date(''' || chr(38) || 'today'') - ' || chr(38) || 'DEFAULT_KEEP_DAYS;');
      dbms_output.put_line ('commit;');
  END LOOP;
END;
/

