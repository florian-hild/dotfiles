--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set linesize 200
set pagesize 2000
col TABLE_NAME format a20
col OWNER format a20
col select_priv format a6
col insert_priv format a6
col delete_priv format a6
col update_priv format a6
col references_priv format a10
col alter_priv format a5
col index_priv format a5

DEFINE user = &user
DEFINE table = &table

SELECT owner, table_name, select_priv, insert_priv, delete_priv, update_priv, references_priv, alter_priv, index_priv
  FROM table_privileges
  WHERE grantee like UPPER('%&user%') and table_name like UPPER('%&table%')
  ORDER BY owner, table_name;

select * from dba_tab_privs;

select * from dba_tab_privs where GRANTEE = 'HOST';

exit

