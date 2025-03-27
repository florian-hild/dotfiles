--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250
set wrap off

col CLIENT_IDENTIFIER format a25
col PROGRAM format a60
col USERNAME format a16
col MACHINE format a35

SELECT COUNT(*) AS ctn,
       CLIENT_IDENTIFIER,
       PROGRAM,
       USERNAME,
       MACHINE
FROM v$session
WHERE USERNAME IS NOT NULL
  AND USERNAME NOT IN (' ', 'SYS')
GROUP BY GROUPING SETS (
       (USERNAME, MACHINE, CLIENT_IDENTIFIER, PROGRAM),  -- Detailed breakdown
       ()  -- Grand total
)
ORDER BY 1,USERNAME, MACHINE, CLIENT_IDENTIFIER, PROGRAM;
