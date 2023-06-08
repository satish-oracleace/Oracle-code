SET PAGESIZE 1000
SET LINESIZE 600

COLUMN sid FORMAT A10
COLUMN status FORMAT A10
COLUMN owner FORMAT A20
COLUMN object_owner FORMAT A20
COLUMN object_name FORMAT A30
COLUMN object_type FORMAT A15
COLUMN oracle_username FORMAT A15
COLUMN locked_mode FORMAT A15
COLUMN os_user_name FORMAT A15

SELECT s.sid,
       s.serial#,
	   s.status, 
       do.owner, 
       do.object_name,
	   do.object_type,
	   lo.oracle_username,
       Decode(lo.locked_mode, 0, 'None',
                             1, 'Null (NULL)',
                             2, 'Row-S (SS)',
                             3, 'Row-X (SX)',
                             4, 'Share (S)',
                             5, 'S/Row-X (SSX)',
                             6, 'Exclusive (X)',
                             lo.locked_mode) locked_mode,
       lo.os_user_name
FROM   v$locked_object lo, dba_objects do, v$session s 
where  lo.session_id = s.sid
and do.object_id = lo.object_id
ORDER BY 1, 2, 3, 4;
