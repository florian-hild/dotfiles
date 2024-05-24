--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set linesize 250

col name format a20
col value format a100
col con_id format 99

SELECT con_id,name,value
  FROM v$system_parameter
  WHERE Name = 'local_listener';
