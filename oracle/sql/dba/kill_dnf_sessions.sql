--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 12-04-2025
-- Description: Kill DNF/CNF sessions for a given Oracle user
--------------------------------------------------------------------------------

set echo     off
set term     on
set verify   off
set feedback off
set heading  off
set pagesize 0
set linesize 250
set trimspool on
set wrap     off
SET SERVEROUTPUT ON SIZE 1000000

PROMPT
PROMPT ============================================================
PROMPT  Kill DNF / CNF Sessions
PROMPT ============================================================
PROMPT

PROMPT -- ── Active DNF / CNF Sessions (all users) ───────────────
PROMPT

col USERNAME  format a30
col DNF_COUNT format 9999 heading "DNF"
col CNF_COUNT format 9999 heading "CNF"
set heading on
set pagesize 50

SELECT USERNAME,
       COUNT(CASE WHEN CLIENT_IDENTIFIER LIKE 'DNF%' THEN 1 END) AS DNF_COUNT,
       COUNT(CASE WHEN CLIENT_IDENTIFIER LIKE 'CNF%' THEN 1 END) AS CNF_COUNT
  FROM v$session
  WHERE CLIENT_IDENTIFIER LIKE 'DNF%' OR CLIENT_IDENTIFIER LIKE 'CNF%'
  GROUP BY USERNAME
  ORDER BY DNF_COUNT DESC;

set heading off
set pagesize 0

PROMPT
accept dstuser char prompt 'Enter username to filter (leave blank for ALL): '

PROMPT

col spoolname new_value spoolname noprint
SELECT '$HOME/kill_dnf_sessions_'
    || to_char(sysdate, 'yyyy-mm-dd_hh24-mi-ss')
    || '_' || NVL(UPPER('&dstuser'), 'ALL')
    || '.sql' AS spoolname
  FROM dual;

SPOOL '&spoolname'

SELECT '-- Generated : ' || to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS') FROM dual;
SELECT '-- Filter    : ' || NVL(UPPER('&dstuser'), 'ALL users')         FROM dual;
SELECT '-- DB        : ' || sys_context('USERENV', 'DB_NAME')           FROM dual;

PROMPT
PROMPT -- ── Session Summary ─────────────────────────────────────
PROMPT

SELECT '-- ' || RPAD('USERNAME', 30) || LPAD('DNF', 6) || LPAD('CNF', 6) FROM dual;
SELECT '-- ' || RPAD('-', 30, '-') || LPAD('-----', 6) || LPAD('-----', 6) FROM dual;
SELECT '-- ' || RPAD(USERNAME, 30)
       || LPAD(COUNT(CASE WHEN CLIENT_IDENTIFIER LIKE 'DNF%' THEN 1 END), 6)
       || LPAD(COUNT(CASE WHEN CLIENT_IDENTIFIER LIKE 'CNF%' THEN 1 END), 6)
  FROM v$session
  WHERE (CLIENT_IDENTIFIER LIKE 'DNF%' OR CLIENT_IDENTIFIER LIKE 'CNF%')
    AND ('&dstuser' IS NULL OR USERNAME = UPPER('&dstuser'))
  GROUP BY USERNAME
  ORDER BY COUNT(CASE WHEN CLIENT_IDENTIFIER LIKE 'DNF%' THEN 1 END) DESC;

SELECT CASE COUNT(*)
         WHEN 0 THEN '-- No DNF/CNF sessions found for filter: '
                      || NVL(UPPER('&dstuser'), 'ALL')
         ELSE        '-- Total sessions to kill: ' || COUNT(*)
       END
  FROM v$session
  WHERE (CLIENT_IDENTIFIER LIKE 'DNF%' OR CLIENT_IDENTIFIER LIKE 'CNF%')
    AND ('&dstuser' IS NULL OR USERNAME = UPPER('&dstuser'));

PROMPT
PROMPT -- ── Kill Commands ────────────────────────────────────────
PROMPT

SELECT 'alter system kill session ''' || SID || ',' || SERIAL# || ''' immediate;'
  FROM v$session
  WHERE (CLIENT_IDENTIFIER LIKE 'DNF%' OR CLIENT_IDENTIFIER LIKE 'CNF%')
    AND ('&dstuser' IS NULL OR USERNAME = UPPER('&dstuser'))
  ORDER BY USERNAME, OSUSER, PROCESS ASC;

SPOOL off;

PROMPT
PROMPT ============================================================
PROMPT  Run the generated file to execute:
SELECT '    @&spoolname' FROM dual;
PROMPT ============================================================
PROMPT
