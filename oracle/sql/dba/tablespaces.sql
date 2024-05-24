--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

col TABLESPACE_NAME format a20
col STATUS format a7
col CONTENTS format a10
col ALLOCATION_TYPE format a10
col SEGMENT_SPACE_MANAGEMENT format a10
col BIGFILE format a5
col ENCRYPTED format a5

SELECT TABLESPACE_NAME,STATUS,CONTENTS,ALLOCATION_TYPE,SEGMENT_SPACE_MANAGEMENT,BIGFILE,LOGGING,force_logging,ENCRYPTED
  FROM DBA_TABLESPACES
  ORDER BY TABLESPACE_NAME,STATUS,CONTENTS ASC;
