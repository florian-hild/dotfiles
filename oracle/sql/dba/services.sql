--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col SERVICE_ID format 99
col NAME format A20
col PDB format A10

SELECT SERVICE_ID,NAME,CREATION_DATE,PDB
  FROM V$SERVICES
  ORDER BY SERVICE_ID,CREATION_DATE,NAME ASC;
