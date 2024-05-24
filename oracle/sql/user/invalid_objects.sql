--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

col OWNER format a25;
col OBJECT_NAME format a40
col OBJECT_TYPE format a20

SELECT object_type,OBJECT_NAME,status,OWNER
  FROM all_objects
  WHERE status != 'VALID'
  ORDER BY object_type,OBJECT_NAME,status,OWNER ASC;

SELECT count(*), object_type
  FROM all_objects
  WHERE status != 'VALID'
  GROUP BY object_type;

-- Bei LBE_AUSLDATUM_VIEW compilieren
-- alter session set "_fix_control" = '8528517:off';
-- alter session set "_fix_control" = '7534027:off';

-- alter trigger NAME compile;
-- alter procedure NAME compile;

-- show error

-- Alle Objecte neu compilieren
-- set pagesize 0
-- spool recompile_objects.sql
-- select 'alter ' || object_type, OWNER || '.'|| OBJECT_NAME || ' compile;' from all_objects where status != 'VALID';
-- spool off;
