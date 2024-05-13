set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col ACCOUNT_STATUS format a20
col USERNAME format a30
col LOCK_DATE format a20
col EXPIRY_DATE format a20
col DEFAULT_TABLESPACE format a25
col LAST_LOGIN format a45
col PASSWORD_CHANGE_DATE format a20
col PROFILE format a20



-- DECLARE
--  sql_cmd  varchar2(250);

BEGIN
  CASE
    WHEN DBMS_DB_VERSION.VERSION >= '19' THEN
      EXECUTE IMMEDIATE '
        SELECT username,account_status,LOCK_DATE,EXPIRY_DATE,DEFAULT_TABLESPACE,LAST_LOGIN,PASSWORD_CHANGE_DATE,PROFILE
          FROM dba_users
          ORDER BY account_status,username,CREATED,DEFAULT_TABLESPACE ASC;
      ';
      -- sql_cmd := '
        -- SELECT username,account_status,LOCK_DATE,EXPIRY_DATE,DEFAULT_TABLESPACE,LAST_LOGIN,PASSWORD_CHANGE_DATE,PROFILE
         --  FROM dba_users
          -- ORDER BY account_status,username,CREATED,DEFAULT_TABLESPACE ASC;
      -- ';
    ELSE
      DBMS_OUTPUT.put_line('test');
      -- sql_cmd := '
      --   SELECT username,account_status,LOCK_DATE,EXPIRY_DATE,DEFAULT_TABLESPACE,PROFILE
       --    FROM dba_users
       --    ORDER BY account_status,username,CREATED,DEFAULT_TABLESPACE ASC;
     --  ';
  END CASE;

  -- DBMS_OUTPUT.put_line(sql_cmd);
   -- sql_cmd
END;
/

-- ALTER USER <USERNAME> IDENTIFIED BY <PWASSWORD> ACCOUNT UNLOCK;
-- ALTER PROFILE DEFAULT LIMIT PASSWORD_REUSE_TIME UNLIMITED;
-- ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;
-- ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED;
