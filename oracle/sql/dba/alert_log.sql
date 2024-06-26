--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

col OCCUR_DATE format a20
col MESSAGE_TEXT format a210

SELECT
  TO_CHAR (ORIGINATING_TIMESTAMP, 'DD-MON-YYYY HH24:MI:SS') Occur_date,
  SUBSTR (MESSAGE_TEXT, 1, 300) MESSAGE_TEXT
FROM X$DBGALERTEXT
WHERE CAST (ORIGINATING_TIMESTAMP AS DATE) > SYSDATE - 1
  AND (MESSAGE_TEXT LIKE '%ORA-%'
  OR UPPER (MESSAGE_TEXT) LIKE '%ERROR%'
  OR UPPER (MESSAGE_TEXT) LIKE '%ALTER SYSTEM%'
  OR UPPER (MESSAGE_TEXT) LIKE '%ALTER DATABASE%');
