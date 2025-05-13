--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 03-07-2024
-- Description: Show all dbms_alert package
--------------------------------------------------------------------------------

set pagesize 2000 linesize 250
SET WRAP OFF

col SID format 99999
col SERIAL# format 999999
col PROCESS format a15
col USERNAME format a16
col STATUS format a8
col OSUSER format a10
col PROGRAM format a15
col CLIENT_IDENTIFIER format a20
col MACHINE format a15
col sql_text format a100

SELECT s.username,
       s.osuser,
       s.machine,
       s.sid,
       s.serial#,
       s.client_identifier,
       s.status,
       s.program,
       q.sql_text
FROM   v$session s
JOIN   v$sql q ON s.sql_id = q.sql_id
WHERE  q.sql_text LIKE '%DBMS_ALERT%'
AND    q.sql_text not LIKE 'SELECT%'
ORDER BY s.username, s.osuser, s.process, s.client_identifier, s.program, s.status, s.logon_time, s.sid ASC;
