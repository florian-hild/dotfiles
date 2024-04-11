set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col USERNAME format a25
col CREATED format a20
col USER_ID format 9999999999999

SELECT USER_ID,USERNAME,CREATED
  FROM ALL_USERS
  ORDER BY USER_ID,USERNAME,CREATED ASC;
