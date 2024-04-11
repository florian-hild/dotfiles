set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col SID format 99999
col SERIAL# format 999999
col PROCESS format a15
col USERNAME format a16
col STATUS format a8
col OSUSER format a15
col PROGRAM format a60
col CLIENT_IDENTIFIER format a17
col LOGON_TIME format a20
col IP format a15
col MACHINE format a30

SELECT count(*) ctn,CLIENT_IDENTIFIER,PROGRAM,USERNAME,MACHINE
  FROM v$session
  WHERE USERNAME != ' '
  AND USERNAME != 'SYS'
  GROUP BY USERNAME,MACHINE,CLIENT_IDENTIFIER,PROGRAM
  ORDER BY ctn,USERNAME,CLIENT_IDENTIFIER,PROGRAM ASC;
