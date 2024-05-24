--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

col SYNONYM_NAME  format a45
col TABLE_OWNER   format a20
col TABLE_NAME    format a45
col DB_LINK       format a50
col ORIGIN_CON_ID format 9999

SELECT SYNONYM_NAME,TABLE_OWNER,TABLE_NAME,DB_LINK,ORIGIN_CON_ID
  FROM user_synonyms
  ORDER BY TABLE_OWNER,SYNONYM_NAME,TABLE_NAME ASC;
