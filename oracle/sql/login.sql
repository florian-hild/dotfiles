set termout off
set linesize 250
set pagesize 2000
SET WRAP OFF
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';
COLUMN X NEW_VALUE Y
SELECT LOWER(USER || '@' || SYS_CONTEXT('userenv', 'instance_name')) X FROM dual;
SET SQLPROMPT '&Y SQL> '
set termout on
