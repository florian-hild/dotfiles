--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col OBJECT_NAME format a30
col ORIGINAL_NAME format a50
col OPERATION format a10
col TYPE format a10
col DROPTIME format a20
col DROPSCN format 9999999999999999999999

SELECT OBJECT_NAME,ORIGINAL_NAME,OPERATION,TYPE,DROPTIME,DROPSCN
  FROM USER_RECYCLEBIN
  ORDER BY DROPTIME;
