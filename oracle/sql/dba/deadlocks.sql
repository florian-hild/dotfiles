--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description: Show blocking/waiting sessions and locked objects.
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 300

col BLOCK_USER    format a40
col BLOCK_SID     format a12
col BLOCK_OS_USER format a15
col WAIT_USER     format a40
col WAIT_SID      format a12
col WAIT_OS_USER  format a15

SELECT s1.username || '@' || s1.machine AS block_user,
       s1.sid || ',' || s1.serial# AS block_sid,
       s1.osuser AS block_os_user,
       s2.username || '@' || s2.machine AS wait_user,
       s2.sid || ',' || s2.serial# AS wait_sid,
       s2.osuser AS wait_os_user
FROM v$lock l1
JOIN v$session s1 ON s1.sid = l1.sid
JOIN v$lock l2 ON l2.id1 = l1.id1 AND l2.id2 = l1.id2
JOIN v$session s2 ON s2.sid = l2.sid
WHERE l1.block = 1
  AND l2.request > 0;

col USERNAME    format a16
col OWNER       format a20
col OBJECT_NAME format a30
col LOCKED_MODE format a15

SELECT s.username,
       o.owner,
       o.object_name,
       DECODE(lo.locked_mode, 0, 'None',
                              1, 'Null (NULL)',
                              2, 'Row-S (SS)',
                              3, 'Row-X (SX)',
                              4, 'Share (S)',
                              5, 'S/Row-X (SSX)',
                              6, 'Exclusive (X)',
                              TO_CHAR(lo.locked_mode)) AS locked_mode
FROM v$locked_object lo
JOIN dba_objects o ON o.object_id = lo.object_id
JOIN v$session s ON s.sid = lo.session_id
ORDER BY s.username, o.owner, o.object_name;
