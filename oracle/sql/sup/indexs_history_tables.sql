--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

col INDEX_NAME format a40
col INDEX_TYPE format a20
col TABLE_OWNER format a20
col TABLE_NAME format a30

SELECT i.index_name,
       i.table_name,
       i.table_owner,
       i.INDEX_TYPE,
       CASE
           WHEN c.constraint_name IS NOT NULL THEN 'Constraint Index'
           ELSE 'Regular Index'
       END AS index_type
FROM all_indexes i
LEFT JOIN user_constraints c
    ON i.index_name = c.constraint_name
    AND i.table_name = c.table_name
WHERE i.table_owner = user
AND i.table_name like '%\_H' ESCAPE '\'
ORDER BY i.table_name, i.index_name;
