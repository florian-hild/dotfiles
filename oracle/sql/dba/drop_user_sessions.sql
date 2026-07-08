--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description: Generate kill statements for all sessions of a given user.
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col USERNAME format a16
col CNT      format 9999

SELECT count(*) AS CNT, USERNAME
  FROM v$session
  WHERE USERNAME IS NOT NULL
  GROUP BY USERNAME
  ORDER BY CNT DESC, USERNAME;

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
      WHERE USERNAME = UPPER(TRIM('&username'))
      ORDER BY PROGRAM,STATUS ASC;

BEGIN
  FOR session_record IN select_sessions
  LOOP
    dbms_output.put_line ('REM CLIENT_IDENTIFIER: "' || session_record.client_identifier || '" PROGRAM: "' || session_record.program || '" OSUSER: "' || session_record.osuser || '" PROCESS: "' || session_record.process || '"');
    dbms_output.put_line ('alter system kill session ''' || session_record.sid || ',' || session_record.serial# || ''';');
  END LOOP;
END;
/
