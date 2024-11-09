import React from "react";
import Web3  from 'web3';
import { useState, useEffect } from "react";

var web3;
var signer;
var Connected;

async function createProvider() {
  if (window.ethereum) {
    await window.ethereum.request({ method: "eth_requestAccounts" });
    web3 = new Web3(window.ethereum);
    return true;
  } else {

    // Add provider (anvil)
    const wsProvider = new Web3.providers.WebsocketProvider('ws://localhost:8545');
    web3 = new Web3(wsProvider);
    let signers = await web3.eth.getAccounts();
    signer = signers[2];
    return true;
  }

  return false;
}

async function getBalance() {
  if (window.ethereum) {
    return null;
  } else {
    let wei = await web3.eth.getBalance(signer);
    return web3.utils.fromWei(wei, 'ether');
  }  
}

function Connect({ onConnected }) {

  const [connected, setConnected] = useState(false);
  const [balance, setBalance] = useState(null);

  useEffect(() => {
     Connected = connected;
     onConnected();
  }, [connected]);

  return <button className='connect-button' disabled={connected}
          onClick={ async () => { setConnected(await createProvider());
                                  setBalance(await getBalance())}}
         >{(connected == true)?
         `${signer.slice(0, 6)}::${signer.slice(36, 40)} bal:${balance}`
         :"Connect"}</button>
}

export {
  web3,
  signer,
  Connected,
  Connect
}