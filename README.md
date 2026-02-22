# DockerStackBack
Simple script to keep multiple daily versions of your docker stack files and then retain daily versions for a period of time. I created this simple script to keep copies of my docker compose files that I may edit throughout the day. I don't keep the compose files up on Gitgub and wanted a way to keep simple copies to revert back to if needed. I have mounts to my NAS and keep them there where they are also synced to a second NAS as an extra copy. 

Keep in mind this wont backup or version your docker volumes or data within your docker containers. It will only keep copies of the compose.yaml, .env and Dockerfile files in folders that have a .tobackup file in them. It will scan all the folders (only one folder deep) within a set location.

Feel free to use and modify as you see fit, please be careful and ensure your not deleting/pruning files you wish to keep.

1) make sure to chmod +x docker-backstack.sh to make the script executable.
2) edit top of script to set your stack/compose, backup locations and retention days
3) create .tobackup files in the folders you wish the script to maintain version backups for
4) run the script with --dry-run option to verify the outcome is desired (backup loction etc)
5) create crontab entry if you wish to run it on a schedule. make sure to create two entries one running the backup command and the other running the prune command

USAGE:
  ./docker-stackback.sh backup
  will run a backup of compose.yaml, .env and Dockerfile files in folders where your stacks are located.

  ./docker-stackback prune
  will run the pruining job which will remove all the previous daily version except one (all current today backups will remain). it will then prune of any days exceeding the retantion days ie. 30.

  adding --dry-run will only run the script in test mode and not backup or prune any files.


Happy Versioning/Backup-ing!
GewGaw4U
  
