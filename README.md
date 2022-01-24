## Go Ethereum

Official Golang implementation of the Ethereum protocol.

[![API Reference](
https://camo.githubusercontent.com/915b7be44ada53c290eb157634330494ebe3e30a/68747470733a2f2f676f646f632e6f72672f6769746875622e636f6d2f676f6c616e672f6764646f3f7374617475732e737667
)](https://pkg.go.dev/github.com/ethereum/go-ethereum?tab=doc)
[![Go Report Card](https://goreportcard.com/badge/github.com/ethereum/go-ethereum)](https://goreportcard.com/report/github.com/ethereum/go-ethereum)
[![Travis](https://travis-ci.com/ethereum/go-ethereum.svg?branch=master)](https://travis-ci.com/ethereum/go-ethereum)
[![Discord](https://img.shields.io/badge/discord-join%20chat-blue.svg)](https://discord.gg/nthXNEv)

Automated builds are available for stable releases and the unstable master branch. Binary
archives are published at https://geth.ethereum.org/downloads/.

## Building the source

For prerequisites and detailed build instructions please read the [Installation Instructions](https://geth.ethereum.org/docs/install-and-build/installing-geth).

Building `geth` requires both a Go (version 1.14 or later) and a C compiler. You can install
them using your favourite package manager. Once the dependencies are installed, run

```shell
make geth
```

or, to build the full suite of utilities:

```shell
make all
```

## Running geth

To do so:

```shell
sh script.sh
```
## Geth Option

If modify Geth's options, change go-ethereum/genesis & go-ethereum/script.sh files.

The default options are:  

|    Command    | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| :-----------: | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|   `chainId`    | 2757  |
|   `http.corsdomain`    | 127.0.0.1  |
|   `http.port`    | 8545  |
|   `http.api`    | `admin,eth,debug,miner,net,txpool,personal,web3`  |
|   `ws.corsdomain`    | 127.0.0.1  |
|   `ws.port`    | 8545  |
|   `ws.api`    | `admin,eth,debug,miner,net,txpool,personal,web3`  |
## How to Use PreCompiled Contract MiMC7 in Solidity
```
function callmimc(bytes memory data) public returns (bytes32) {
  uint256 len = data.length;
  bytes32[1] memory out;
  assembly {
      let success := call(0x186A0, 0x13, 0, add(data,0x20), len, out, 0x20)
  }
  emit showbytes32(out[0]);
  return out[0];
}
```