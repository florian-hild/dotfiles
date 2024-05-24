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

alter session set "_fix_control" = '8528517:off';
alter session set "_fix_control" = '7534027:off';

accept dstuser char prompt 'Please enter db username for synonym destination: '

col spoolname new_value spoolname
SELECT '$HOME/create_synonyms_and_grants_' || to_char(sysdate, 'yyyy-mm-dd_hh24-mi-ss') || '.sql' spoolname FROM dual;
SPOOL '&spoolname'

DECLARE
  CURSOR all_objects
  IS
    SELECT OBJECT_NAME, OBJECT_TYPE
      FROM user_objects
      -- Nicht verwendete Objekte
      WHERE OBJECT_TYPE not in ('INDEX','TRIGGER','DATABASE LINK','LOB')
      AND  OBJECT_NAME NOT LIKE 'SYS_%$'
      ORDER BY OBJECT_NAME,OBJECT_TYPE ASC;
  synonym_tab VARCHAR2(100);
BEGIN
  FOR object_record IN all_objects
  LOOP
    IF object_record.object_type = 'SYNONYM' THEN
      -- Bei synonymen die orginal Tabelle verwenden.
      SELECT TABLE_NAME INTO synonym_tab FROM user_synonyms WHERE SYNONYM_NAME = object_record.object_name;
      dbms_output.put_line ('CREATE OR REPLACE SYNONYM ' || UPPER('&dstuser') || '.' || object_record.object_name || ' FOR ' || user || '.' || synonym_tab || ';');
    ELSE
      dbms_output.put_line ('CREATE OR REPLACE SYNONYM ' || UPPER('&dstuser') || '.' || object_record.object_name || ' FOR ' || user || '.' || object_record.object_name || ';');
    END IF;

    -- Unterschiedliche grants je nach Objekt typ
    CASE
     WHEN object_record.object_type in ('TABLE') THEN
      dbms_output.put_line('grant select,insert,update,delete on ' || user || '.' || object_record.object_name || ' to ' || UPPER('&dstuser') || ';');
     WHEN object_record.object_type in ('VIEW','SEQUENCE') THEN
      dbms_output.put_line('grant select on ' || user || '.' || object_record.object_name || ' to ' || UPPER('&dstuser') || ';');
     WHEN object_record.object_type in ('TYPE','PROCEDURE','FUNCTION','PACKAGE','PACKAGE BODY') THEN
      dbms_output.put_line('grant execute on ' || user || '.' || object_record.object_name || ' to ' || UPPER('&dstuser') || ';');
     WHEN object_record.object_type in ('SYNONYM') THEN
       null;
     ELSE
      dbms_output.put_line ('-- Object ' || user || '.' || object_record.object_type || ' not configured.');
    END CASE;
  END LOOP;
END;
/

SPOOL off;

select '&spoolname' from DUAL;
