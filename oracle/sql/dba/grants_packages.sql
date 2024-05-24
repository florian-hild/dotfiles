--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 70
set linesize 250

col TABLE_NAME format a40
col OWNER format a20
col GRANTEE format a20
col PRIVILEGE format a25
col TYPE format a10
col GRANTOR format a20

SELECT TABLE_NAME,OWNER,GRANTEE,PRIVILEGE,TYPE,GRANTOR
  FROM dba_tab_privs
  where Type = 'PACKAGE'
  and GRANTEE = user
  ORDER BY OWNER,TABLE_NAME,GRANTEE,TYPE ASC;