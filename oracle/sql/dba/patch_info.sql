--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 18-06-2025
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col patch_id format 99999999999
col patch_type format a10
col action_time format a30
col action format a10
col status format a10
col description format a60

SELECT
  patch_id,
  patch_type,
  action,
  action_time,
  status,
  description
FROM dba_registry_sqlpatch
ORDER BY action_time DESC;

col COMP_ID format a15
col NAMESPACE format a10
col VERSION format a15
col VERSION_FULL format a15
col STATUS format a10
col MODIFIED format a30

SELECT
  NAMESPACE,
  COMP_ID,
  VERSION,
  VERSION_FULL,
  STATUS,
  MODIFIED
FROM dba_registry_hierarchy
ORDER BY MODIFIED DESC;
