--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set linesize 250
set pagesize 1000

col RESOURCE_NAME format a20
col LIMIT_VALUE format a15

SELECT resource_name,current_utilization,max_utilization,limit_value
  FROM v$resource_limit
  WHERE resource_name in ('sessions', 'processes');

