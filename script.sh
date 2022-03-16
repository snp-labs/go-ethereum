#!/bin/sh

help()
{
    cat << HELP
Usage:
    sh script.sh <command>

The commands are:

        rm          Remove datadir
        setup       Init geth
        reset       Execute rm and setup
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
HTTPADDR="0.0.0.0"  # --http.addr
HTTPDOMAIN="\"*\""  # --http.corsdomain
HTTPAPI="\"admin,eth,debug,miner,net,txpool,personal,web3\""    # --http.api
WSPORT=8546         # --ws.port
WSDOMAIN="\"*\""    # --ws.origins
WSADDR="0.0.0.0"    # --ws.addr
WSAPI="\"admin,eth,debug,miner,net,txpool,personal,web3\""      # --ws.api
VERBOSITY=0                 # --verbosity  If you want show geth's log, changed this value to 3
MINERTHREADS=1              # --miner.threads
DEFALTOPTION="--verbosity ${VERBOSITY} console --allow-insecure-unlock --unlock 0 --password password --mine --miner.threads ${MINERTHREADS}"
            # |           LOG         |console|               unlock-account        (password file)  |               mine option          

#COMMANDS
REMOVE="rm -rf home_geth/geth"
INIT="${GETHPWD} --datadir home_geth init genesis"
ACCOUNTGEN="${GETHPWD} --datadir home_geth account new --password password"
START="${GETHPWD} --datadir home_geth --networkid ${NETWORKID} --http --http.port ${HTTPPORT} --http.corsdomain ${HTTPDOMAIN} --http.api ${HTTPAPI} --http.addr ${HTTPADDR} --ws --ws.port ${WSPORT} --ws.origins ${WSDOMAIN} --ws.api ${WSAPI} --ws.addr ${WSADDR} ${DEFALTOPTION}"
#START=./build/bin/geth --datadir home_geth --networkid 2757 --http --http.port 8545 --http.corsdomain "*" --http.api "admin,eth,debug,miner,net,txpool,personal,web3" --ws --ws.port 8546 --ws.origins "*" --ws.api "admin,eth,debug,miner,net,txpool,personal,web3" --ws.api "0.0.0.0" --verbosity 0 console --allow-insecure-unlock --unlock 0 --password password --mine --miner.threads 1 --nodiscover
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
    if in_array "rm" "${ARGUMENT[*]}"; then
        echo "SHELL >>> ${REMOVE}"
        ${REMOVE}
        
    fi

    if in_array "setup" "${ARGUMENT[*]}" ; then
        echo "SHELL >>> ${INIT}"
        ${INIT}
    fi

    if in_array "reset" "${ARGUMENT[*]}" ; then
            echo "SHELL >>> ${REMOVE}"
            ${REMOVE}
            echo "SHELL >>> ${INIT}"
            ${INIT}
    fi

    if in_array "start" "${ARGUMENT[*]}" ; then
            echo "SHELL >>> ${START}"
            ${START}
    fi
    if in_array "gethhelp" "${ARGUMENT[*]}" ; then
            echo "SHELL >>> ${HELP}"
            ${HELP}
    fi
fi