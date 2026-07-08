--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description: Show fast recovery area usage.
--------------------------------------------------------------------------------

set linesize 250
set pagesize 2000

show parameter db_recovery_file_dest

col "FILE_TYPE"                 format a30
col "PERCENT_SPACE_USED"        format 999
col "PERCENT_SPACE_RECLAIMABLE" format 999
col "NUMBER_OF_FILES"           format 99999

SELECT
  FILE_TYPE,
  PERCENT_SPACE_USED,
  PERCENT_SPACE_RECLAIMABLE,
  NUMBER_OF_FILES
FROM
  V$RECOVERY_AREA_USAGE
order by FILE_TYPE ASC;

col "RecoveryArea: Size GB" format 99,999,999.99
col "Used GB"               format 99,999,999.99
col "Used %"                format 999.99
col "Reclaimable GB"        format 99,999,999.99

SELECT
  ROUND(SPACE_LIMIT / 1024 / 1024 / 1024, 2) "RecoveryArea: Size GB",
  ROUND(SPACE_USED / 1024 / 1024 / 1024, 2) "Used GB",
  ROUND(SPACE_USED / NULLIF(SPACE_LIMIT, 0) * 100, 2) "Used %",
  ROUND(SPACE_RECLAIMABLE / 1024 / 1024 / 1024, 2) "Reclaimable GB"
FROM
  V$RECOVERY_FILE_DEST;

-- Change Recovery size
-- ALTER SYSTEM SET DB_RECOVERY_FILE_DEST_SIZE = 30G SCOPE=BOTH SID='*';

-- Change Recovery directory destination
-- ALTER SYSTEM SET DB_RECOVERY_FILE_DEST = '/opt/oracle/fast_recovery_area' SCOPE=BOTH SID='*';
