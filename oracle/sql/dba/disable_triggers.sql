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

col trigger_name format a60

col spoolname_ena new_value spoolname_ena
SELECT '$HOME/triggers_enable_' || to_char(sysdate, 'yyyy-mm-dd_hh24-mi-ss') || '.sql' spoolname_ena FROM dual;

col spoolname new_value spoolname
SELECT '$HOME/triggers_disable_' || to_char(sysdate, 'yyyy-mm-dd_hh24-mi-ss') || '.sql' spoolname FROM dual;
SPOOL '&spoolname'

DECLARE
  CURSOR select_triggers
  IS
    SELECT trigger_name
      FROM dba_triggers
       WHERE owner = user
       AND status = 'ENABLED'
       ORDER BY trigger_name ASC;

BEGIN
  FOR trigger_record IN select_triggers
  LOOP
    dbms_output.put_line ('alter trigger ' || user || '.' || trigger_record.trigger_name || ' disable;');
  END LOOP;
END;
/

SPOOL off;
!sed 's/disable/enable/g' &spoolname > &spoolname_ena

select '&spoolname' from DUAL;
select '&spoolname_ena' from DUAL;
