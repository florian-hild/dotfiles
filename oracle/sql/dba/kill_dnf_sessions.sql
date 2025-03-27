--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 12-04-2025
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

accept dstuser char prompt 'Please enter db username to kill DNF/CNF sessions: '

col spoolname new_value spoolname
SELECT '$HOME/kill_dnf_sessions_' || NVL(UPPER('&dstuser'), 'ALL') || '_' || to_char(sysdate, 'yyyy-mm-dd_hh24-mi-ss') || '.sql' spoolname FROM dual;
SPOOL '&spoolname'

select 'alter system kill session ''' || SID || ',' || SERIAL# || ''';'
  from v$session
  where CLIENT_IDENTIFIER like 'DNF%'
  or CLIENT_IDENTIFIER like 'CNF%'
  and USERNAME = UPPER('&dstuser')
  ORDER BY USERNAME,OSUSER,PROCESS ASC;

SPOOL off;
select '&spoolname' from DUAL;
