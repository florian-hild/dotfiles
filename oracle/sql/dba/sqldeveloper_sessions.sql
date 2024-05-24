--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col SID format 99999
col SERIAL# format 999999
col PROCESS format a15
col USERNAME format a16
col STATUS format a8
col OSUSER format a10
col PROGRAM format a60
col CLIENT_IDENTIFIER format a17
col LOGON_TIME format a20
col IP format a15

SELECT USERNAME,OSUSER,SID,SERIAL#,CLIENT_IDENTIFIER,PROGRAM,PROCESS,STATUS,LOGON_TIME
  FROM v$session
  WHERE PROGRAM = 'SQL Developer'
  ORDER BY USERNAME,OSUSER,PROCESS,CLIENT_IDENTIFIER,PROGRAM,STATUS,LOGON_TIME,SID ASC;

-- alter system kill session 'SID,SERIAL#';
