--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 13-08-2026
-- Description: Re-gather optimizer statistics per schema. Run after a
--              data/full import so the CBO has fresh stats.
--              Leave owner blank for current user.
--------------------------------------------------------------------------------

set serveroutput on size unlimited
set verify off
set feedback off

accept owners char prompt 'Enter owner(s) comma-separated (leave blank for current user): '

whenever sqlerror continue

DECLARE
  CURSOR c IS
    SELECT username
      FROM dba_users
      WHERE (('&owners' IS NULL AND username = user)
             OR INSTR(',' || REPLACE(UPPER('&owners'), ' ') || ',',
                      ',' || username || ',') > 0)
      ORDER BY username;
BEGIN
  FOR r IN c LOOP
    DBMS_OUTPUT.PUT_LINE('Gathering stats for ' || r.username || ' ...');
    DBMS_STATS.GATHER_SCHEMA_STATS(
      ownname          => r.username,
      estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,
      degree           => DBMS_STATS.AUTO_DEGREE,
      cascade          => TRUE);
    DBMS_OUTPUT.PUT_LINE('  done: ' || r.username);
  END LOOP;
END;
/

-- Verify freshness
set pagesize 200 linesize 200 feedback on heading on
col OWNER format a20
prompt === schemas with stale stats (should be empty) ===
SELECT owner, COUNT(*) AS stale_tables
  FROM dba_tab_statistics
  WHERE (('&owners' IS NULL AND owner = user)
         OR INSTR(',' || REPLACE(UPPER('&owners'), ' ') || ',',
                  ',' || owner || ',') > 0)
    AND stale_stats = 'YES'
  GROUP BY owner
  ORDER BY owner;
