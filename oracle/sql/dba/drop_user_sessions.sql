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
col " " format 999

SELECT count(USERNAME) " ",USERNAME
  FROM v$session
  WHERE USERNAME != ' '
  GROUP BY USERNAME;

accept username char prompt 'Please enter username: ';
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

DECLARE
  CURSOR select_sessions
  IS
    SELECT OSUSER,SID,SERIAL#,CLIENT_IDENTIFIER,PROGRAM,PROCESS
      FROM v$session
      WHERE USERNAME = '&username'
      ORDER BY PROGRAM,STATUS ASC;

BEGIN
  FOR session_record IN select_sessions
  LOOP
    dbms_output.put_line ('REM CLIENT_IDENTIFIER: "' || session_record.client_identifier || '" PROGRAM: "' || session_record.program || '" OSUSER: "' || session_record.osuser || '" PROCESS: "' || session_record.process || '"');
    dbms_output.put_line ('alter system kill session ''' || session_record.sid || ',' || session_record.serial# || ''';');
  END LOOP;
END;
/