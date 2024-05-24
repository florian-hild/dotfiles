--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col DB_LINK  format a30
col USERNAME format a15
col HOST     format a55
col OWNER    format a10
col CREATED  format a10

SELECT DB_LINK,USERNAME,HOST,OWNER,To_char(CREATED, 'dd.mm.yyyy') CREATED
  FROM DBA_DB_LINKS
  ORDER BY DB_LINK,HOST,USERNAME,CREATED,OWNER ASC;
