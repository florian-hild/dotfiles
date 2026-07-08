--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description: Kill all sessions matching a username and client identifier.
--------------------------------------------------------------------------------

set verify off
SET SERVEROUTPUT ON SIZE 1000000

accept username  char prompt 'Please enter username: '
accept client_id char prompt 'Please enter client identifier: '

DECLARE
    v_username  VARCHAR2(128) := UPPER(TRIM('&username'));
    v_client_id VARCHAR2(64)  := TRIM('&client_id');
    v_count     PLS_INTEGER := 0;
BEGIN
    FOR rec IN (
        SELECT SID, SERIAL#
        FROM v$session
        WHERE username = v_username
          AND client_identifier = v_client_id
    ) LOOP
        EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION ''' || rec.SID || ',' || rec.SERIAL# || ''' IMMEDIATE';
        DBMS_OUTPUT.PUT_LINE('Session with SID = ' || LPAD(TO_CHAR(rec.SID), 5) || ' and SERIAL# = ' || LPAD(TO_CHAR(rec.SERIAL#), 6) || ' has been killed.');
        v_count := v_count + 1;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(v_count || ' session(s) killed for user ' || v_username || ' / client identifier ' || v_client_id || '.');
END;
/
