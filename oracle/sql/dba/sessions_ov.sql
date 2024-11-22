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

SELECT count(*) ctn,CLIENT_IDENTIFIER,PROGRAM,USERNAME,MACHINE
  FROM v$session
  WHERE USERNAME != ' '
  AND USERNAME != 'SYS'
  GROUP BY USERNAME,MACHINE,CLIENT_IDENTIFIER,PROGRAM
  ORDER BY ctn,USERNAME,CLIENT_IDENTIFIER,PROGRAM ASC;
