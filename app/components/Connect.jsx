import React from "react";
import Web3  from 'web3';
import { useState, useEffect } from "react";
import GameD from "../../out/Game.d.sol/GameD.json";

var web3;
var signer;
var Connected;
var GameContract;

function Connect({ onConnected, account }) {

  const [connected, setConnected] = useState(false);
  const [balance, setBalance] = useState(null);

  useEffect(() => {
     Connected = connected;
  }, [connected]);

  async function createProvider(account) {
    if (window.ethereum) {
      web3 = new Web3(window.ethereum);
      let signers = await window.ethereum.request({ method: "eth_requestAccounts" });
      signer = web3.utils.toChecksumAddress(signers[account]);
      return true;
    } else {

      // Add provider (anvil)
      const wsProvider = new Web3.providers.WebsocketProvider('ws://localhost:8545');
      web3 = new Web3(wsProvider);
      let signers = await web3.eth.getAccounts();
      signer = signers[account];
      return true;
    }

    return false;
  }

  async function getGameContract() {
    GameContract = new web3.eth.Contract(GameD.abi, 
      "0x4AE85136760964B0A2d87fF8CAB53014AE458237");
    onConnected();
  }

  async function getBalance() {
    if (window.ethereum) {
      let wei = await web3.eth.getBalance(signer)
      return Math.floor(web3.utils.fromWei(wei, 'ether'));
    } else {
      let wei = await web3.eth.getBalance(signer);
      return Math.floor(web3.utils.fromWei(wei, 'ether'));
    }  
  }

  return <button className='connect-button' disabled={connected}
          onClick={ async () => { setConnected(await createProvider(account));
                                  setBalance(await getBalance())
                                  getGameContract()}}
         >{(connected == true)?
           `${signer.slice(0, 6)}::${signer.slice(36, 40)} bal:${balance}`
            :"Connect"}</button>         
}

export {
  web3,
  signer,
  GameContract,
  Connected,
  Connect
}