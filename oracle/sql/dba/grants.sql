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
  WHERE GRANTOR != 'XDB'
  AND GRANTOR != 'WMSYS'
  AND GRANTOR != 'SYS'
  AND GRANTOR != 'SYSTEM'
  AND GRANTOR != 'ORDSYS'
  AND GRANTOR != 'ORDDATA'
  AND GRANTOR != 'MDSYS'
  AND GRANTOR != 'GSMADMIN_INTERNAL'
  AND GRANTOR != 'APPQOSSYS'
  AND GRANTOR != 'AUDSYS'
  AND GRANTOR != 'CTXSYS'
  AND GRANTOR != 'DBSNMP'
  AND GRANTOR != 'ORDPLUGINS'
  AND GRANTOR != 'OUTLN'
  AND GRANTOR != 'XS$NULL'
  AND GRANTOR != 'GSMUSER'
  AND GRANTOR != 'GSMCATUSER'
  AND GRANTOR != 'PUBLIC'
  AND GRANTOR != 'C##CLONE_PDB'
  ORDER BY OWNER,TABLE_NAME,GRANTEE,TYPE ASC;
