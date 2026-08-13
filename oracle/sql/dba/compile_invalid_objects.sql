--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description: Recompile invalid objects using UTL_RECOMP (handles dependency
--              order automatically). Leave owner blank to recompile all
--              non-Oracle-maintained schemas with invalid objects.
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250
set serveroutput on size unlimited
set verify off

col OWNER format a25
col OBJECT_NAME format a40
col OBJECT_TYPE format a20

prompt === INVALID objects before recompile ===
select count(*) as "#", owner, object_type
  from dba_objects
  where status != 'VALID'
  group by owner, object_type
  order by owner, object_type;

accept owners char prompt 'Enter owner(s) comma-separated (leave blank for ALL): '

whenever sqlerror continue

DECLARE
  CURSOR c IS
    SELECT DISTINCT o.owner
      FROM dba_objects o
      JOIN dba_users u ON u.username = o.owner
      WHERE o.status != 'VALID'
        AND u.oracle_maintained = 'N'
        AND ('&owners' IS NULL
             OR INSTR(',' || REPLACE(UPPER('&owners'), ' ') || ',',
                      ',' || o.owner || ',') > 0)
      ORDER BY o.owner;
BEGIN
  FOR r IN c LOOP
    DBMS_OUTPUT.put_line('Recompiling schema ' || r.owner || ' ...');
    UTL_RECOMP.RECOMP_PARALLEL(4, r.owner);
  END LOOP;
END;
/

prompt === still INVALID after recompile ===
select count(*) as "#", owner, object_type
  from dba_objects
  where status != 'VALID'
  group by owner, object_type
  order by owner, object_type;

select owner, object_type, object_name
  from dba_objects
  where status != 'VALID'
  order by owner, object_type, object_name;
