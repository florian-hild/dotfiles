--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 26-06-2024
-- Description: Show locked objects
--------------------------------------------------------------------------------

set pagesize 2000 linesize 1000

col OBJECT_OWNER      format a20
col OBJECT_NAME       format a30
col SID               format 99999
col SERIAL#           format 999999
col USERNAME          format a16
col CLIENT_IDENTIFIER format a17
col OS_USER_NAME      format a10
col locked_mode       format a15

SELECT o.owner AS object_owner,
       o.object_name,
       lo.session_id AS sid,
       s.serial#,
       NVL(lo.oracle_username, '(oracle)') AS username,
       s.CLIENT_IDENTIFIER,
       lo.os_user_name,
       Decode(lo.locked_mode, 0, 'None',
                              1, 'Null (NULL)',
                              2, 'Row-S (SS)',
                              3, 'Row-X (SX)',
                              4, 'Share (S)',
                              5, 'S/Row-X (SSX)',
                              6, 'Exclusive (X)',
                              lo.locked_mode) locked_mode
FROM   v$locked_object lo
       JOIN dba_objects o ON o.object_id = lo.object_id
       JOIN v$session s ON lo.session_id = s.sid
ORDER BY OBJECT_OWNER,OBJECT_NAME,CLIENT_IDENTIFIER ASC;


-- set wrap on
-- set long 1000000000

-- col OBJECT_NAME  format a25
-- col SID          format 99999
-- col SERIAL#      format 999999
-- col SPID         format a10
-- col PROGRAM      format a60
-- col USERNAME     format a16
-- col SQL_FULLTEXT format a300

-- SELECT O.OBJECT_NAME, S.SID, S.SERIAL#, P.SPID, S.PROGRAM, S.USERNAME, SQ.SQL_FULLTEXT
--   FROM V$LOCKED_OBJECT L, DBA_OBJECTS O, V$SESSION S, V$PROCESS P, V$SQL SQ
--   WHERE L.OBJECT_ID = O.OBJECT_ID
--   AND L.SESSION_ID = S.SID
--   AND S.PADDR = P.ADDR
--   AND S.SQL_ADDRESS = SQ.ADDRESS
--   ORDER BY S.USERNAME,O.OBJECT_NAME ASC;

