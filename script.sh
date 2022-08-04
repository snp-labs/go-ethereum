#!/bin/sh

help()
{
    cat << HELP
Usage:
    sh script.sh <command>

The commands are:

        clean       make clean
        make        make all geth
        make -j n   make all geth with n cores
        setup       init geth
        start       start geth
        console     attach to geth js console
        status      print the status of geth
        log         cat geth log
        gethhelp    view all geth option

Geth Default Options(If you want to change options, edit #OPTION(Line 52) in the script.sh):

           OPTION                |
                                 |   
        --allow-insecure-unlock  |   Use with --unlock, --password then unlock account
        --mine                   |   Enable mining(Use with --miner.threads)
        console                  |   Use geth console

           OPTION           |   VALUE
                            |
        --networkid         |  ${NETWORKID}                                              
                            |
        --http.port         |  ${HTTPPORT}             HTTP-RPC server listening port 
        --http.api          |  ${HTTPAPI}          
        --http.corsdomain   |  ${HTTPDOMAIN}              (*: All ip can access in rpc network)
        --http.addr         |  ${HTTPADDR}          (0.0.0.0: All ip can access in rpc interface)
                            |
        --ws.port           |  ${WSPORT}             WS-RPC server listening port
        --ws.api            |  ${WSAPI}            
        --ws.origins        |  ${WSDOMAIN}              (*: All ip's websockets requests are accept)
        --ws.addr           |  ${WSADDR}          (0.0.0.0: All ip can access in rpc interface)
                            |
        --verbosity         |  ${VERBOSITY}                0=no log, 1=error, 2=warn, 3=info, 4=debug, 5=detail
        --miner.threads     |  ${MINERTHREADS}     
        --password          |  ./password       Password file path
        --unlock            |  0                Comma separated list of accounts to unlock. 0,1,2...

HELP
exit 0
}
DIR=`dirname "$0"`
cd $DIR
#ARGUMENT ARRAY
IFS=$'\n'
ARGUMENT=($@)
IFS=$' '
#OPTION
GETHPWD="./build/bin/geth"      # geth.exe file path

PORT=30000
NETWORKID=2757      # --networkid
HTTPPORT=8545       # --http.port
HTTPADDR="127.0.0.1"  # --http.addr
HTTPDOMAIN="https://remix.ethereum.org"  # --http.corsdomain
HTTPAPI="admin,eth,debug,miner,net,txpool,personal,web3"    # --http.api
WSPORT=8546         # --ws.port
WSDOMAIN="https://remix.ethereum.org"    # --ws.origins
WSADDR="127.0.0.1"    # --ws.addr
WSAPI="admin,eth,debug,miner,net,txpool,personal,web3"      # --ws.api
VERBOSITY=3                 # --verbosity  If you want show geth's log, changed this value to 3
MINERTHREADS=1              # --miner.threads
DEFALTOPTION="--verbosity ${VERBOSITY} --allow-insecure-unlock --unlock 0 --password password --mine --miner.threads ${MINERTHREADS} --miner.gaslimit 3000000000"
            # |           LOG               unlock-account        (password file)  |               mine option

#COMMANDS
REMOVE="rm -rf home_geth/geth && rm -rf geth.log"
INIT="${GETHPWD} --datadir home_geth init genesis"
ACCOUNTGEN="${GETHPWD} --datadir home_geth account new --password password"
START="${GETHPWD} --datadir home_geth --networkid ${NETWORKID} --vmdebug --port 30000 --http --http.port ${HTTPPORT} --http.corsdomain ${HTTPDOMAIN} --http.api ${HTTPAPI} --http.addr ${HTTPADDR} --ws --ws.port ${WSPORT} --ws.origins ${WSDOMAIN} --ws.api ${WSAPI} --ws.addr ${WSADDR} ${DEFALTOPTION} --miner.gasprice 100000"
HELP="${GETHPWD} help"
[ -z "$1" ] && help


#FLAG
CLEAN_FLAG=0
MAKE_FLAG=0
CORE_FLAG=1
SETUP_FLAG=0
START_FLAG=0
GETHHELP_FLAG=0
CONSOLE_FLAG=0
END_FLAG=0
STATUS_FLAG=0
LOG_FLAG=0

loop_i=0
for e in ${ARGUMENT[@]}
do
    loop_i=$((loop_i + 1))
    if [ $e = "clean" ]; then
        CLEAN_FLAG=1
    elif [ $e = "make" ]; then
        MAKE_FLAG=1
    elif [[ $e =~ "-j" ]] && [ $loop_i -lt ${#ARGUMENT[@]} ]; then
        CORE_FLAG=${ARGUMENT[loop_i]}
    elif [ $e = "setup" ]; then
        SETUP_FLAG=1
    elif [ $e = "start" ]; then
        START_FLAG=1
    elif [ $e = "gethhelp" ]; then
        GETHHELP_FLAG=1
    elif [ $e = "console" ]; then
        CONSOLE_FLAG=1
    elif [ $e = "stop" ]; then
        END_FLAG=1
    elif [ $e = "status" ]; then
        STATUS_FLAG=1
    elif [ $e = "log" ]; then
        LOG_FLAG=1
    fi
done



#EXEC
if [ "$1" == "help" ] ; then
    help
elif [ $GETHHELP_FLAG = 1 ]; then
    echo "SHELL >>> ${HELP}"
    ${HELP}
elif [ $LOG_FLAG = 1 ]; then
    tail -f home_geth/geth.log
elif [ $STATUS_FLAG = 1 ]; then
    PIDS=`ps -ef | grep home_geth`
    if [[ "$PIDS" =~ "${START}" ]]; then
        echo "geth is running"
    else
        echo "geth is not running"
    fi
else
    if [ $CLEAN_FLAG = 1 ] ; then
        make clean
    fi
    if [ $MAKE_FLAG = 1 ] ; then
        echo "SHELL >>> make all -j $CORE_FLAG"
        make all -j $CORE_FLAG
    fi
    if [ $SETUP_FLAG = 1 ] ; then
        ${REMOVE}
        ${INIT}
    fi
    if  [ $START_FLAG = 1 ]; then
        PIDS=`ps -ef | grep home_geth`
        if [[ "$PIDS" =~ "${START}" ]]; then
            echo "geth is already running"
        else
            echo "SHELL >>> ${START}"
            nohup ${START} >> home_geth/geth.log 2>&1 &
            echo $! > home_geth/pid.txt
        fi
    fi
    if [ $END_FLAG = 1 ]; then
        PID=`cat home_geth/pid.txt`
        echo "stop geth"
        kill $PID
    fi
    if [ $CONSOLE_FLAG = 1 ]; then
        ${GETHPWD} attach "http://${HTTPADDR}:${HTTPPORT}"
    fi
fi