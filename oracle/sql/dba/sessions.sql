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
col MACHINE format a35

SELECT USERNAME,OSUSER,MACHINE,SID,SERIAL#,CLIENT_IDENTIFIER,PROGRAM,PROCESS,STATUS,LOGON_TIME
  FROM v$session
  WHERE USERNAME != ' '
  ORDER BY USERNAME,OSUSER,PROCESS,CLIENT_IDENTIFIER,PROGRAM,STATUS,LOGON_TIME,SID ASC;

-- alter system kill session 'SID,SERIAL#';
-- Wenn session gelocked ist immediate verwenden
-- alter system kill session 'SID,SERIAL#' immediate;

-- SELECT USERNAME,OSUSER,CLIENT_IDENTIFIER,PROCESS,STATUS,LOGON_TIME,SID,SERIAL#,PROGRAM,utl_inaddr.get_host_address(substr(machine,instr(machine,'\')+1)) IP
--   FROM v$session
--   ORDER BY USERNAME,OSUSER,PROCESS,CLIENT_IDENTIFIER,PROGRAM,STATUS,LOGON_TIME,SID ASC;

-- ss -utn "( sport = :1521 )"|awk '{print toupper($6)}'|cut -d':' -f 4 |sort|uniq

-- select 'alter system kill session ''' || SID || ',' || SERIAL# || ''';' from v$session;
