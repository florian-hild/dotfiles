--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set linesize 250

col Group             format 99
col Thread            format 99
col Sequence          format 999999
col ARCHIVED          format a10
col STATUS            format a10
col TYPE              format a10
col REDOLOG_FILE_NAME format a80
col SIZE_MB           format 9999

SELECT
    a.GROUP# "Group",
    a.THREAD# "Thread",
    a.SEQUENCE# "Sequence",
    a.ARCHIVED,
    a.STATUS,
    b.TYPE,
    b.MEMBER AS REDOLOG_FILE_NAME,
    (a.BYTES/1024/1024) AS SIZE_MB
  FROM v$log a
  JOIN v$logfile b ON a.Group#=b.Group#
  ORDER BY a.GROUP#;

-- ALTER SYSTEM SWITCH LOGFILE;
-- ALTER SYSTEM ARCHIVE LOG CURRENT;
