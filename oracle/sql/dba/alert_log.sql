--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description: Show alert log errors of the last 24 hours.
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

col OCCUR_DATE format a20
col MESSAGE_TEXT format a210

SELECT
  TO_CHAR (ORIGINATING_TIMESTAMP, 'DD-MON-YYYY HH24:MI:SS') Occur_date,
  SUBSTR (MESSAGE_TEXT, 1, 300) MESSAGE_TEXT
FROM V$DIAG_ALERT_EXT
WHERE ORIGINATING_TIMESTAMP > SYSTIMESTAMP - INTERVAL '1' DAY
  AND (MESSAGE_TEXT LIKE '%ORA-%'
  OR UPPER (MESSAGE_TEXT) LIKE '%ERROR%'
  OR UPPER (MESSAGE_TEXT) LIKE '%ALTER SYSTEM%'
  OR UPPER (MESSAGE_TEXT) LIKE '%ALTER DATABASE%')
ORDER BY ORIGINATING_TIMESTAMP;;
