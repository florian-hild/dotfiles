--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

COL PDB_ID           FORMAT 99
col PDB_NAME         format a20
col STATUS           format a10
col CREATION_SCN     format 99999999999999
col LAST_REFRESH_SCN format 99999999999999
col UNPLUG_SCN       format 99999999999999
col REFRESH_MODE     format a15
col REFRESH_INTERVAL format 999

select
  PDB_ID,
  PDB_NAME,
  STATUS,
  REFRESH_MODE,
  REFRESH_INTERVAL,
  UNPLUG_SCN,
  CREATION_SCN,
  LAST_REFRESH_SCN,
  CREATION_TIME
from
  dba_pdbs
order by PDB_ID;
