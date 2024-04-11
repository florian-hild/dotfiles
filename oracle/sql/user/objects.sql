alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';
set linesize 250
set pagesize 0

col OBJECT_NAME format a50
col OBJECT_TYPE format a15
col STATUS      format a7

SELECT OBJECT_NAME,OBJECT_TYPE,STATUS,CREATED
  FROM user_objects
  ORDER BY CREATED,OBJECT_NAME,OBJECT_TYPE;
