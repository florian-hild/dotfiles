--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description: Report invalid objects (all owners) with summary per owner
--              and object type. Recompile with compile_invalid_objects.sql.
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250
set verify off

col OWNER format a25
col OBJECT_NAME format a40
col OBJECT_TYPE format a20

prompt === INVALID objects ===
SELECT owner, object_type, object_name, status
  FROM dba_objects
  WHERE status != 'VALID'
  ORDER BY owner, object_type, object_name;

prompt === summary per owner and object type ===
SELECT count(*) as "#", owner, object_type
  FROM dba_objects
  WHERE status != 'VALID'
  GROUP BY owner, object_type
  ORDER BY owner, object_type;
