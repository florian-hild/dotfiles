--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

col COMPATIBLE_VERSION format a12
col SOFTWARE_VERSION format a12


select GROUP_NUMBER,DB_NAME,STATUS,INSTANCE_NAME,CLUSTER_NAME
  from v$asm_client
  order by CLUSTER_NAME,GROUP_NUMBER,DB_NAME;
