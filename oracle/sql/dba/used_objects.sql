--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 01-07-2024
-- Description: Show current used objects
--------------------------------------------------------------------------------

set pagesize 2000 linesize 300
set wrap off
-- set long 100000000

col OBJECT_OWNER      format a15
col OBJECT_NAME       format a25
col SQL_FULLTEXT      format a60
col USERNAME          format a16
col CLIENT_IDENTIFIER format a17
col PROGRAM      format a40
col OSUSER       format a10

SELECT o.OWNER AS OBJECT_OWNER,
       o.OBJECT_NAME,
       sq.SQL_FULLTEXT,
       s.USERNAME,
       s.CLIENT_IDENTIFIER,
       s.PROGRAM,
       s.OSUSER
FROM V$LOCKED_OBJECT l,
     DBA_OBJECTS o,
     V$SESSION s,
     V$PROCESS p,
     V$SQL sq
WHERE l.OBJECT_ID = o.OBJECT_ID
  AND l.SESSION_ID = s.SID
  AND s.PADDR = p.ADDR
  AND s.SQL_ADDRESS = sq.ADDRESS
ORDER BY s.USERNAME,s.CLIENT_IDENTIFIER,s.PROGRAM,o.OBJECT_NAME ASC;

