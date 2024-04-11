set pagesize 2000
set linesize 300

SELECT s1.username || '@' || s1.machine block_user,
       s1.sid || ',' || s1.serial# block_sid,
       s1.osuser block_os_user,
       s2.username || '@' || s2.machine wait_user,
       s2.sid || ',' || s2.serial# wait_sid,
       s2.osuser wait_os_user
FROM v$lock l1, v$session s1, v$lock l2, v$session s2
WHERE l1.sid = s1.sid
  AND l2.sid = s2.sid
  AND l1.id1 = l2.id1
  AND l2.id2 = l2.id2
  AND l1.block = 1
  AND l2.request > 0;

SELECT s.username, o.object_name, l.TYPE, l.id1, l.id2
  FROM v$locked_object l, dba_objects o, v$session s
  WHERE l.object_id = o.object_id
    AND l.session_id = s.sid;
