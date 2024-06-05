--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

col OWNER format a25;
col STATUS format a10
col OBJECT_TYPE format a20

SELECT OWNER,count(*) as "Anzahl",OBJECT_TYPE
  FROM all_objects
  GROUP BY OWNER,OBJECT_TYPE
  ORDER BY OWNER,2;
