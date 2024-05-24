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

col spoolname_ena new_value spoolname_ena
SELECT '$HOME/constraints_enable_' || to_char(sysdate, 'yyyy-mm-dd_hh24-mi-ss') || '.sql' spoolname_ena FROM dual;

col spoolname new_value spoolname
SELECT '$HOME/constraints_disable_' || to_char(sysdate, 'yyyy-mm-dd_hh24-mi-ss') || '.sql' spoolname FROM dual;
SPOOL '&spoolname'

DECLARE
  CURSOR select_constraints
  IS
    SELECT constraint_name, table_name
      FROM dba_constraints
      WHERE owner = user
      AND constraint_type = 'R'
      AND status = 'ENABLED'
      ORDER BY table_name,constraint_name ASC;

BEGIN
  FOR constraint_record IN select_constraints
  LOOP
    dbms_output.put_line ('alter table ' || user || '.' || constraint_record.table_name || ' disable constraint ' || constraint_record.constraint_name || ';');
  END LOOP;
END;
/

SPOOL off;
!sed 's/disable/enable/g' &spoolname > &spoolname_ena

select '&spoolname' from DUAL;
select '&spoolname_ena' from DUAL;
