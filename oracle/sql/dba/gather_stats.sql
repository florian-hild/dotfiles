-- gather_stats.sql — re-gather optimizer statistics for the given owners.
-- Run after a data/full import so the CBO has fresh stats.
-- Usage:  @gather_stats.sql "<owners>"
--   &1 = owner in-list, already quoted, e.g. 'PUIG','PUIGDBA'
SET SERVEROUTPUT ON SIZE UNLIMITED VERIFY OFF FEEDBACK OFF
WHENEVER SQLERROR CONTINUE
DECLARE
  CURSOR c IS
    SELECT username FROM dba_users WHERE username IN (&1) ORDER BY username;
BEGIN
  FOR r IN c LOOP
    DBMS_OUTPUT.PUT_LINE('Gathering stats for '||r.username||' ...');
    DBMS_STATS.GATHER_SCHEMA_STATS(
      ownname          => r.username,
      estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,
      degree           => DBMS_STATS.AUTO_DEGREE,
      cascade          => TRUE);
    DBMS_OUTPUT.PUT_LINE('  done: '||r.username);
  END LOOP;
END;
/
-- Verify freshness
SET PAGESIZE 200 LINESIZE 200 FEEDBACK ON HEADING ON
COLUMN owner FORMAT A20
PROMPT === schemas with stale stats (should be empty) ===
SELECT owner, COUNT(*) AS stale_tables
FROM   dba_tab_statistics
WHERE  owner IN (&1) AND stale_stats = 'YES'
GROUP  BY owner
ORDER  BY owner;
