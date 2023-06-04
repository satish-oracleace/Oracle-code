################################################################################################
#!/bin/ksh
#
#       oracle_ocr_backup.ksh
#
#       Script used to backup OCR Disks
#       schedule the job in crontab
#
#       Author                     Date            Comments
#       Satishbabu Gunukula        01/20/2022      Created
#       Satishbabu Gunukula        06/04/2022      Modified Old dump deletion 30 to 45 days
#
################################################################################################
#----------------------------------------------
# Variable Initialization
#----------------------------------------------
init_variable()
{
HOSTNAME=`hostname |awk -F"." '{print $1}'`; export HOSTNAME
BACKUP_DIR=/backup/${HOSTNAME}; export BACKUP_DIR
BACKUP_DUMP=${BACKUP_DIR}/ocrvote
BACKUP_LOGS=${BACKUP_DIR}/ocrvote
V_DATE=`date +%m%d%y_%H%M`
V_LOGFILE=${BACKUP_LOGS}/ocr_backup_${V_DATE}.log
#
echo "***************************************************************************************" >> ${V_LOGFILE}
echo "                       OCR BACKUP on $HOSTNAME server                                  " >> ${V_LOGFILE}
echo "***************************************************************************************" >> ${V_LOGFILE}
}
#-------------------------------------------------
# Backup OCR Disks
#-------------------------------------------------
backup_ocr()
{
echo " " >> ${V_LOGFILE}
echo "Backing up OCR Disk..."  >> ${V_LOGFILE}
cp -p /oracle/crs/v1900/cdata/crs/backup01.ocr ${BACKUP_DUMP}/ocr_${V_DATE}
echo "OCR Backup file from OCR_HOME copied successfully!"  >> ${V_LOGFILE}
/oracle/crs/v1900/bin/ocrconfig -export ${BACKUP_DUMP}/ocr_export_${V_DATE}
echo "OCR export Backup Completed successfully!"  >> ${V_LOGFILE}
echo " " >> ${V_LOGFILE}
}
#-------------------------------------------------
# Send Mail
#-------------------------------------------------
send_mail()
{
(echo "From: BackupMonitor@oracleracexpert.com"
echo "To: user1@oracleracexpert.com"
echo "Subject: **ERROR**: OCR Backup Failed on ${HOSTNAME} server....!"
echo "Hi,

You are receiving this email because "OCR Backup" Failed with below Errors
`cat $V_LOGFILE | egrep "ORA-|RMAN-|Linux-|No"`

Please check the log file ${V_LOGFILE} for more information and take immediate action to fix the issue.

This is an automated message so please do not reply.

Thanks,
BackupMonitor
"
) | /usr/lib/sendmail -t
}
#-------------------------------------------------
# Main Program
#-------------------------------------------------
init_variable;
backup_ocr;
C_V_ERRORS=`cat $V_LOGFILE | egrep "ORA-|RMAN-|Linux-|No"| wc -l`
if [ $C_V_ERRORS -gt 0 ]; then
    send_mail;
else
        echo "***List OCR backup files older than 45 days***" >> ${V_LOGFILE}
        find ${BACKUP_DUMP} -mtime +45 -exec ls -lrt {} \; >> ${V_LOGFILE}
        echo " " >> ${V_LOGFILE}
        echo "Removing OCR backups files older than 45 days..." >> ${V_LOGFILE}
        find ${BACKUP_DUMP} -mtime +45 -exec rm -f {} \;
        echo "Done!" >> ${V_LOGFILE}
        echo " " >> ${V_LOGFILE}
fi
# End of Script
