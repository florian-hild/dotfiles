--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

col owner format a25
col view_name format a30
col TEXT_VC format a50
col SYNONYM_NAME  format a45
col TABLE_OWNER   format a20
col TABLE_NAME    format a45
col DB_LINK       format a50

select owner,view_name,TEXT_VC
  from all_views
  where TEXT_VC like '%@%'
  and owner != 'SYS'
  order by owner,view_name;

select OWNER,SYNONYM_NAME,TABLE_OWNER,TABLE_NAME,DB_LINK
  from DBA_SYNONYMS
  where DB_LINK != ' '
  order by OWNER,SYNONYM_NAME;

