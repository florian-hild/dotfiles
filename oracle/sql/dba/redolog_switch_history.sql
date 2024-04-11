set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col day format a10
col 00 format a4
col 01 format a4
col 02 format a4
col 03 format a4
col 04 format a4
col 05 format a4
col 06 format a4
col 07 format a4
col 08 format a4
col 09 format a4
col 10 format a4
col 11 format a4
col 12 format a4
col 13 format a4
col 14 format a4
col 15 format a4
col 16 format a4
col 17 format a4
col 18 format a4
col 19 format a4
col 20 format a4
col 21 format a4
col 22 format a4
col 23 format a4

SELECT
  to_char(first_time,'YYYY-MM-DD') day,
  to_char(sum(decode(to_char(first_time,'HH24'),'00',1,0)),'999') "00",
  to_char(sum(decode(to_char(first_time,'HH24'),'01',1,0)),'999') "01",
  to_char(sum(decode(to_char(first_time,'HH24'),'02',1,0)),'999') "02",
  to_char(sum(decode(to_char(first_time,'HH24'),'03',1,0)),'999') "03",
  to_char(sum(decode(to_char(first_time,'HH24'),'04',1,0)),'999') "04",
  to_char(sum(decode(to_char(first_time,'HH24'),'05',1,0)),'999') "05",
  to_char(sum(decode(to_char(first_time,'HH24'),'06',1,0)),'999') "06",
  to_char(sum(decode(to_char(first_time,'HH24'),'07',1,0)),'999') "07",
  to_char(sum(decode(to_char(first_time,'HH24'),'08',1,0)),'999') "08",
  to_char(sum(decode(to_char(first_time,'HH24'),'09',1,0)),'999') "09",
  to_char(sum(decode(to_char(first_time,'HH24'),'10',1,0)),'999') "10",
  to_char(sum(decode(to_char(first_time,'HH24'),'11',1,0)),'999') "11",
  to_char(sum(decode(to_char(first_time,'HH24'),'12',1,0)),'999') "12",
  to_char(sum(decode(to_char(first_time,'HH24'),'13',1,0)),'999') "13",
  to_char(sum(decode(to_char(first_time,'HH24'),'14',1,0)),'999') "14",
  to_char(sum(decode(to_char(first_time,'HH24'),'15',1,0)),'999') "15",
  to_char(sum(decode(to_char(first_time,'HH24'),'16',1,0)),'999') "16",
  to_char(sum(decode(to_char(first_time,'HH24'),'17',1,0)),'999') "17",
  to_char(sum(decode(to_char(first_time,'HH24'),'18',1,0)),'999') "18",
  to_char(sum(decode(to_char(first_time,'HH24'),'19',1,0)),'999') "19",
  to_char(sum(decode(to_char(first_time,'HH24'),'20',1,0)),'999') "20",
  to_char(sum(decode(to_char(first_time,'HH24'),'21',1,0)),'999') "21",
  to_char(sum(decode(to_char(first_time,'HH24'),'22',1,0)),'999') "22",
  to_char(sum(decode(to_char(first_time,'HH24'),'23',1,0)),'999') "23"
FROM v$log_history
GROUP BY to_char(first_time,'YYYY-MM-DD')
ORDER BY 1 ASC;