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

accept tablespace char prompt 'Please enter tablespace for nf objects: '

col spoolname new_value spoolname
SELECT '$HOME/move_nf_' || to_char(sysdate, 'yyyy-mm-dd_hh24-mi-ss') || '.sql' spoolname FROM dual;
SPOOL '&spoolname'

DECLARE
  CURSOR all_nf_objects
  IS
    SELECT SEGMENT_NAME,SEGMENT_TYPE
      FROM dba_segments
      WHERE TABLESPACE_NAME != UPPER('&tablespace')
      AND OWNER = UPPER(user)
      AND SEGMENT_NAME like 'NF\_%' ESCAPE '\'
      ORDER BY SEGMENT_NAME,SEGMENT_TYPE;

BEGIN
  FOR nf_record IN all_nf_objects
  LOOP
    CASE
     WHEN nf_record.segment_type in ('TABLE') THEN
      dbms_output.put_line ('ALTER TABLE ' || nf_record.segment_name || ' move tablespace ' || UPPER('&tablespace') || ';');
     WHEN nf_record.segment_type in ('INDEX') THEN
      dbms_output.put_line ('ALTER INDEX ' || nf_record.segment_name || ' rebuild tablespace ' || UPPER('&tablespace') || ';');
     ELSE
      dbms_output.put_line ('-- Object ' || user || '.' || nf_record.segment_name || ' from type ' || nf_record.segment_type || ' not configured.');
    END CASE;
  END LOOP;
END;
/

SPOOL off;

select '&spoolname' from DUAL;
