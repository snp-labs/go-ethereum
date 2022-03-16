## Go Ethereum + Precompiled Contract(MiMC7, Poseidon)

Official Golang implementation of the Ethereum protocol.

[![API Reference](
https://camo.githubusercontent.com/915b7be44ada53c290eb157634330494ebe3e30a/68747470733a2f2f676f646f632e6f72672f6769746875622e636f6d2f676f6c616e672f6764646f3f7374617475732e737667
)](https://pkg.go.dev/github.com/ethereum/go-ethereum?tab=doc)
[![Go Report Card](https://goreportcard.com/badge/github.com/ethereum/go-ethereum)](https://goreportcard.com/report/github.com/ethereum/go-ethereum)
[![Travis](https://travis-ci.com/ethereum/go-ethereum.svg?branch=master)](https://travis-ci.com/ethereum/go-ethereum)
[![Discord](https://img.shields.io/badge/discord-join%20chat-blue.svg)](https://discord.gg/nthXNEv)

## MiMC
MiMC7 is mapped to Opcode 0x13.  
Detail MiMC protocol : https://eprint.iacr.org/2016/492.pdf  
Detail MiMC7 protocol : https://iden3-docs.readthedocs.io/en/latest/_downloads/a04267077fb3fdbf2b608e014706e004/Ed-DSA.pdf  
MiMC7 algorithm :  
```
SEED = keccak256("mimc7_seed")
ORDER = 21888242871839275222246405745257275088548364400416034343698204186575808495617

function MiMC7(inputs)
  if len(inputs) <= 1 then
    output = mimc7round(inputs[0], inputsinputs[0])
  else
    output = input[0]
    for i = 1 to i < len(inputs) do
      output = mimc7round(output, input[i])
    endfor
  endif
  return output

function mimc7round(m, key)
  rc = keccak256(SEED)
  c = (m + key)^7 mod ORDER // round 1
  for i = 2 to i < 92 do    // round 2 ~ 91
    c = (c + key + rc)^7 mod ORDER
    rc = keccak256(rc)
  endfor
  output = (c + key + m + key) mod ORDER
  return output
```
## Poseidon
Poseidon is mapped to Opcode 0x14.  
The Poseidon protocol referred to https://github.com/iden3/go-iden3-crypto/tree/master/poseidon  

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

To do  
First setup & start :
```
bash script.sh setup start
```
Restart Geth :
```
bash script.sh start
```
Remove all chaindata :
```
bash script.sh rm
```
Re-setup all chaindata :
```
bash script.sh reset
```
Same as
```
bash script.sh rm setup
```
## Geth Option

If modify Geth's options, change go-ethereum/genesis & go-ethereum/script.sh files.  
The default options are:  

|    Command    | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| :-----------: | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|   `chainId`    | 2757  |
|   `http.corsdomain`    | *  |
|   `http.port`    | 8545  |
|   `http.addr`   | 0.0.0.0 |
|   `http.api`    | admin,eth,debug,miner,net,txpool,personal,web3  |
|   `ws.corsdomain`    | *  |
|   `ws.addr`   | 0.0.0.0 |
|   `ws.port`    | 8545  |
|   `ws.api`    | admin,eth,debug,miner,net,txpool,personal,web3  |

## How to Use PreCompiled Contract MiMC7 in Solidity
The input data must padded the remaining left side of 32bytes to "0". (ex 0x01 -> 0x0000000000000000000000000000000000000000000000000000000000000001)  
If solidity version order than v0.5.0, use "gas" instead of "gas()" as the first factor in the call function.

```
pragma solidity >=0.5.0
function callmimc(bytes32[] memory data) public returns (bytes32 result) {
  uint256 len = data.length*32;
  assembly {
    let memPtr := mload(0x40)
      let success := call(gas(), 0x13, 0, add(data, 0x20), len, memPtr, 0x20)
      //solc -v < 0.5.0    let success := call(gas, 0x13, 0, add(data, 0x20), len, memPtr, 0x20)
      switch success
      case 0 {
        revert(0,0)
      } default {
        result := mload(memPtr)
      }
  }
}
```

## How to Use PreCompiled Contract Poseidon in Solidity
The input data must padded the remaining left side of 32bytes to "0". (ex 0x01 -> 0x0000000000000000000000000000000000000000000000000000000000000001)  
If solidity version order than v0.5.0, use "gas" instead of "gas()" as the first factor in the call function.
```
pragma solidity >=0.5.0
function callposeidon(bytes32[] memory data) public returns (bytes32 result) {
  uint256 len = data.length*32;
  assembly {
    let memPtr := mload(0x40)
      let success := call(gas(), 0x14, 0, add(data, 0x20), len, memPtr, 0x20)
      //let success := call(gas, 0x14, 0, add(data, 0x20), len, memPtr, 0x20)
      switch success
      case 0 {
        revert(0,0)
      } default {
        result := mload(memPtr)
      }
  }
}
```