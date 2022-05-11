#!/bin/sh

help()
{
    cat << HELP
Usage:
    sh script.sh <command>

The commands are:

        setup       Init geth
        start       Start geth
        gethhelp    View all geth option

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

#ARGUMENT ARRAY
ARGUMENT=$@

#OPTION
GETHPWD="./build/bin/geth"      # geth.exe file path

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
DEFALTOPTION="--verbosity ${VERBOSITY} --allow-insecure-unlock --unlock 0 --password password --mine --miner.threads ${MINERTHREADS}"
            # |           LOG               unlock-account        (password file)  |               mine option

#COMMANDS
REMOVE="rm -rf home_geth/geth && rm -rf geth.log"
INIT="${GETHPWD} --datadir home_geth init genesis"
ACCOUNTGEN="${GETHPWD} --datadir home_geth account new --password password"
SETUP="${GETHPWD} --datadir home_geth --networkid ${NETWORKID} --vmdebug --http --http.port ${HTTPPORT} --http.corsdomain ${HTTPDOMAIN} --http.api ${HTTPAPI} --http.addr ${HTTPADDR} --ws --ws.port ${WSPORT} --ws.origins ${WSDOMAIN} --ws.api ${WSAPI} --ws.addr ${WSADDR} ${DEFALTOPTION}"
START="${SETUP} --dev console"
HELP="${GETHPWD} help"
[ -z "$1" ] && help

function in_array {
    ARRAY=$2
    
    for e in ${ARRAY[*]}
    do
        if [[ "$e" == "$1" ]]
        then
            return 0
        fi
    done

    return 1
}
function option_return {
    ARRAY=$2
    index=0
    one=1
    for e in ${ARRAY[*]}
    do
        if [[ "$e" == "$1" ]]
        then
            return $(expr $index + $one)
        fi
        index=$(expr $index + $one)
    done

    return -1
}



if [ "$1" == "help" ] ; then
    help
else
    if in_array "setup" "${ARGUMENT[*]}" ; then
        ${REMOVE}
        ${INIT}
        ${SETUP} 2>> geth.log &
        PID=$!
        sleep 3
        kill $PID
        sleep 4
    fi
    if in_array "start" "${ARGUMENT[*]}" ; then
        echo "SHELL >>> ${START}"
        ${START} 2>> geth.log
    fi
    if in_array "gethhelp" "${ARGUMENT[*]}" ; then
        echo "SHELL >>> ${HELP}"
        ${HELP}
    fi
fi