set pagesize 2000
set linesize 250

column FILE_ID          format 99
column FILE_NAME        format a70
column TABLESPACE_NAME  format a25
column STATUS           format a10
column AUTOEXTENSIBLE   format a5
column "Total MB"       format 99,999,999
column "Max extends MB" format 99,999,999

SELECT FILE_ID,TABLESPACE_NAME,FILE_NAME,STATUS,AUTOEXTENSIBLE,BYTES / 1024 / 1024 "Total MB",MAXBYTES / 1024 / 1024 "Max extends MB"
  FROM dba_data_files
  ORDER BY TABLESPACE_NAME,FILE_ID ASC;
