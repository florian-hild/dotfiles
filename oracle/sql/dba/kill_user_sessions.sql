DECLARE
    v_username        VARCHAR2(50);
BEGIN
    -- Prompt the user for the username and client identifier
    DBMS_OUTPUT.PUT_LINE('Enter USERNAME:');
    v_username := '&USERNAME';

    -- Loop through sessions matching the criteria and kill them
    FOR rec IN (
        SELECT SID, SERIAL#
        FROM v$session
        WHERE username = UPPER(v_username)
    ) LOOP
        -- Dynamically kill each session
        EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION ''' || rec.SID || ',' || rec.SERIAL# || ''' IMMEDIATE';
        DBMS_OUTPUT.PUT_LINE('Session with SID = ' || LPAD(TO_CHAR(rec.SID), 4, ' ') || ' and SERIAL# = ' || LPAD(TO_CHAR(rec.SERIAL#), 5, ' ') || ' has been killed.');
    END LOOP;
END;
/
