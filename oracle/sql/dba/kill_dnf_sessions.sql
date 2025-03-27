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

-- Save output to file
col USERNAME format a30
col DNF_count format 9999
col CNF_count format 9999

SELECT '-- USERNAME                       DNF_COUNT CNF_COUNT' FROM dual;
SELECT '-- ------------------------------ --------- ---------' FROM dual;
SELECT '-- ' || USERNAME AS USERNAME, COUNT(CASE WHEN CLIENT_IDENTIFIER LIKE 'DNF%' THEN 1 END) AS DNF_count, COUNT(CASE WHEN CLIENT_IDENTIFIER LIKE 'CNF%' THEN 1 END) AS CNF_count
  FROM v$session
  WHERE CLIENT_IDENTIFIER LIKE 'DNF%' OR CLIENT_IDENTIFIER LIKE 'CNF%'
  GROUP BY USERNAME
  ORDER BY DNF_count;

select 'alter system kill session ''' || SID || ',' || SERIAL# || ''';'
  from v$session
  where CLIENT_IDENTIFIER like 'DNF%'
  or CLIENT_IDENTIFIER like 'CNF%'
  and USERNAME = UPPER('&dstuser')
  ORDER BY USERNAME,OSUSER,PROCESS ASC;

SPOOL off;
select '&spoolname' from DUAL;
