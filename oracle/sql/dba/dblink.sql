--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col OWNER    format a10
col DB_LINK  format a25
col USERNAME format a18
col HOST     format a58
col CREATED  format a20

accept name char prompt 'Please enter a name: '

SELECT DB_LINK,USERNAME,HOST,OWNER,CREATED
  FROM DBA_DB_LINKS
  WHERE USERNAME like UPPER('%&name%')
  OR DB_LINK like UPPER('%&name%')
  OR HOST like UPPER('%&name%')
  ORDER BY DB_LINK,HOST,USERNAME,CREATED,OWNER ASC;
