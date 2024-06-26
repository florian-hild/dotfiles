--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col OWNER format a25;
col TABLE_NAME format a30
col OBJECT_TYPE format a15
col LAST_ANALYZED format a20
col STATTYPE_LOCKED format a5
col STALE_STATS format a5

SELECT OWNER,TABLE_NAME,OBJECT_TYPE,LAST_ANALYZED,STATTYPE_LOCKED,STALE_STATS
  FROM dba_tab_statistics
  WHERE STATTYPE_LOCKED!=' '
  AND OWNER not in ('SYS','WMSYS','GSMADMIN_INTERNAL')
  ORDER BY STALE_STATS,TABLE_NAME;

