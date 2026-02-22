# DockerStackBack
Simple script to keep multiple daily versions of your docker stack files and then retain daily versions for a period of time

1) make sure to chmod +x docker-backstack.sh to make the script executable.
2) edit top of script to set your stack/compose, backup locations and retention days
3) create .tobackup files in the folders you wish the script to maintain version backups for
4) run the script with --dry-run option to verify the outcome is desired (backup loction etc)
5) create crontab entry if you wish to run it on a schedule. make sure to create two entries one running the backup command and the other running the prune command

USAGE:
  ./docker-stackback.sh backup
  will run a backup of compose.yaml, .env and Dockerfile files in foolders where your stacks are located.

  ./docker-stackback prune
  will run the pruining job which will remove all the previous daily version except one (all current today backups will remain). it will then prune of any days exceeding the retantion days ie. 30.

  adding --dry-run will only run the script in test mode and not backup or prune any files.

  Happy Versioning/Backup-ing!

  GewGaw4U
  
