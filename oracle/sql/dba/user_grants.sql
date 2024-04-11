set pagesize 2000
set linesize 250

col TABLE_NAME format a40
col OWNER format a20
col GRANTEE format a20
col PRIVILEGE format a25
col TYPE format a10
col GRANTOR format a20

accept username char prompt 'Please enter username: ';

SELECT TABLE_NAME,OWNER,GRANTEE,PRIVILEGE,TYPE,GRANTOR
  FROM dba_tab_privs
  WHERE GRANTEE = '&username'
  ORDER BY OWNER,TABLE_NAME,GRANTEE,TYPE ASC;
