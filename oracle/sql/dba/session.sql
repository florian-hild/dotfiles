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
col PROCESS format a10
col USERNAME format a16
col STATUS format a8
col OSUSER format a10
col PROGRAM format a60
col CLIENT_IDENTIFIER format a17
col LOGON_TIME format a20

accept user char prompt 'Please enter db username: '

SELECT USERNAME,OSUSER,CLIENT_IDENTIFIER,PROCESS,STATUS,LOGON_TIME,SID,SERIAL#,PROGRAM
  FROM v$session
  WHERE USERNAME like UPPER('%&user%')
  ORDER BY USERNAME,OSUSER,PROCESS,CLIENT_IDENTIFIER,PROGRAM,STATUS,LOGON_TIME,SID ASC;
