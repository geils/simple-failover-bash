# simple-failover-bash

* Pre-install script
Slack Notification : https://github.com/course-hero/slacktee

* Configuration
1. Edit PCOUNT variable to check service process alive or not (LINE 5)
2. Edit Logfile path (LINE 6)
2. Edit @manager to your manager slack username (LINE 19)
3. Edit service launch command (LINE 54)

* Usage
Simple, just execute this script with 'Active' server's IP address.

    ./simple-failover 100.10.0.2

1. Download failover sciprt on 'Standby' system.
2. Add cron job every 5minute/10minute (whenever you want) this command.
3. If 'Active' server response is not 200, will check 3 more time (with Slack notification to manager)
4. 3 time is passed, and still 'Active' server response is not 200, will launch 'Standby' service automatically.
