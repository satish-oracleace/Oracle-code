------------------------------------
--Script : PROXY SESSIONS
--Author : oracleracexpert.com
------------------------------------
SET PAGESIZE 1000
SET LINESIZE 600

COLUMN username FORMAT A10
COLUMN osuser FORMAT A10
COLUMN spid FORMAT A10
COLUMN status FORMAT A10
COLUMN machine FORMAT A20
COLUMN program FORMAT A40
COLUMN module FORMAT A35
COLUMN action FORMAT A15
COLUMN logon_time FORMAT A20

select s.username,
       s.osuser,
       s.sid,
       s.serial#,
       p.spid,
       s.lockwait,
       s.status,
       s.machine,
       s.program,
       s.module,
       s.action,
       TO_CHAR(s.logon_Time,'MM-DD-YYYY HH24:MI:SS') AS logon_time,
	   s.blocking_session_status AS BlockStatus
from   v$session s, v$process p, v$session_connect_info sci
where  s.paddr = p.addr
and    s.sid = sci.sid
and    s.serial# = sci.serial#
and    sci.authentication_type = 'PROXY'
order by s.username, s.osuser;
