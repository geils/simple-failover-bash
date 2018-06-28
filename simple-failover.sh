#!/bin/bash

NEXT_TRY_TIME=0
RCODE=999
PCOUNT=<process check command> #example: `ps -ef | grep <servicename> | wc -l`
LOGPATH=/path/to/logging/logfile.log


##### Def Functions


function check_code {
    RESULT=`curl -H 'Cache-Control: no-cache' -s -o /dev/null -w "%{http_code}\n" $1`
    echo $RESULT
    return $RESULT
}

function msg_error {
    echo -e [$1][`date +"%Y-%m-%d  %T"`][$2]@manager  2>&1 | ./slacktee/slacktee.sh -m link_names | tee -a ${LOGPATH}
    #curl -X POST -H 'Content-type: application/json' --data '{"text":"'$2'"}' https://hooks.slack.com/services/XXXXXXXX/ZZZZZZZZ/TOKENKEYS
    
}

function msg_okay {
    echo -e [$1][`date +"%Y-%m-%d  %T"`][$2] 2>&1 | tee -a ${LOGPATH}
}


##### Def Logics


if [ `check_code $1` -eq 200 ]; then
    msg_okay "OK" "Service 200 OK"
    RCODE=200
else
    while [[ $NEXT_TRY_TIME -ne 3 ]] && [[ $RCODE -ne 200 ]]
    do
        sleep 3
        if [ `check_code $1` -ne 200 ]; then
            RCODE=999
            msg_error "FAIL" "Service Unreachable, Try_again... $(( $NEXT_TRY_TIME+1 ))"
            NEXT_TRY_TIME=$(( $NEXT_TRY_TIME +1 ))
        elif [ `check_code $1` -eq 200 ]; then
            msg_error "OK" "Service_200_Recovered"
            RCODE=200
            break;
        fi
    done
fi


if [ $NEXT_TRY_TIME -eq 3 ]; then
    msg_error "RUN" "Standby_system_launch..."
    /path/to/application/start/script.sh 2>&1 | tee -a ${LOGPATH}
    sleep 10
elif [[ $NEXT_TRY_TIME -ne 3 ]] && [[ $RCODE -ne 200 ]]; then
    msg_error "ERR" "NOT_ENOUGH_COUNT_VALUE!!!"
else
    :
fi


if [ $PCOUNT -ne 0 ]; then
    msg_error "RUN" "Successfully_launch_standby_system!"
elif [[ $PCOUNT -eq 0 ]] && [[ $RCODE -ne 200 ]]; then
    msg_error "ERR" "No_Process_Found_!!!"
else
    :
fi
