#/bin/zsh
rm -rf home_geth
./build/bin/geth --datadir home_geth init genesis
./build/bin/geth --datadir home_geth account new --password password
./build/bin/geth --datadir home_geth --networkid 2757 --http --http.port 8545 --http.corsdomain "*" --http.api "admin,eth,debug,miner,net,txpool,personal,web3" --ws --ws.port 8546 --ws.origins "*" --ws.api "admin,eth,debug,miner,net,txpool,personal,web3" console --allow-insecure-unlock --unlock 0 --password password --mine --miner.threads 1 --nodiscover