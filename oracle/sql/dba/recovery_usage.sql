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
  V$FLASH_RECOVERY_AREA_USAGE
order by FILE_TYPE ASC;

col "RecoveryArea: Size GB" format 99,999,999
col "Used GB"               format 99,999,999
col "Used %"                format 99,999,999
col "Reclaimable GB"        format 99,999,999

SELECT
  ROUND((A.SPACE_LIMIT / 1024 / 1024 / 1024), 2) "RecoveryArea: Size GB",
  ROUND((A.SPACE_USED / 1024 / 1024 / 1024), 2) "Used GB",
  SUM(B.PERCENT_SPACE_USED) "Used %",
  ROUND((A.SPACE_RECLAIMABLE / 1024 / 1024 / 1024), 2) "Reclaimable GB"
FROM
  V$RECOVERY_FILE_DEST A,
  V$FLASH_RECOVERY_AREA_USAGE B
GROUP BY
  A.SPACE_LIMIT,
  A.SPACE_USED ,
  A.SPACE_RECLAIMABLE;

-- Change Recovery size
-- ALTER SYSTEM SET DB_RECOVERY_FILE_DEST_SIZE = 30G SCOPE=BOTH SID='*';

-- Change Recovery directory destination
-- ALTER SYSTEM SET DB_RECOVERY_FILE_DEST = '/opt/oracle/fast_recovery_area' SCOPE=BOTH SID='*';
