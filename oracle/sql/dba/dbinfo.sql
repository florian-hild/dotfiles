--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 38
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col NAME            format a10
col DBID            format 99999999999
col CREATED         format a20
col OPEN_MODE       format a11
col DB_UNIQUE_NAME  format a10
col PLATFORM_NAME   format a18
col CURRENT_SCN     format 9999999999999999
col STARTUP_TIME    format a20
col STATUS          format a6
col HOST_NAME       format a40
col VERSION         format a11
col DATABASE_STATUS format a7
col USER            format a10

SELECT D.NAME,USER,I.VERSION,I.HOST_NAME,I.DATABASE_STATUS,I.STATUS,D.OPEN_MODE,D.DBID
  FROM V$DATABASE D INNER JOIN V$INSTANCE I
  ON UPPER(D.NAME) = UPPER(I.INSTANCE_NAME)
  ORDER BY D.NAME ASC;

SELECT D.DB_UNIQUE_NAME,D.PLATFORM_NAME,D.CURRENT_SCN,I.STARTUP_TIME,D.CREATED
  FROM V$DATABASE D INNER JOIN V$INSTANCE I
  ON UPPER(D.NAME) = UPPER(I.INSTANCE_NAME)
  ORDER BY D.NAME ASC;

col COMMENT$ format a120
col VALUE$   format a33
col NAME     format a30

SELECT NAME,VALUE$
  FROM SYS.PROPS$
  WHERE NAME = 'DEFAULT_PERMANENT_TABLESPACE'
  OR NAME = 'DEFAULT_TBS_TYPE'
  OR NAME = 'NLS_LANGUAGE'
  OR NAME = 'NLS_CHARACTERSET'
  OR NAME = 'NLS_NCHAR_CHARACTERSET'
  OR NAME = 'NLS_RDBMS_VERSION'
  OR NAME = 'GLOBAL_DB_NAME'
  ORDER BY NAME ASC;
