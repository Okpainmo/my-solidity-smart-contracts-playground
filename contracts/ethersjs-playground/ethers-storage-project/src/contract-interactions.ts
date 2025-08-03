import fs from 'fs';
import { ethers } from 'ethers';
import dotenv from 'dotenv';

dotenv.config();

async function contractInteractions() {
  const RPC_URL = process.env.RPC_URL || 'http://127.0.0.1:7545';
  const PRIVATE_KEY = process.env.PRIVATE_KEY;

  let provider = new ethers.JsonRpcProvider(RPC_URL);
  console.log('block number', await provider.getBlockNumber());

  let signer = new ethers.Wallet(PRIVATE_KEY as string, provider);

  const abi = JSON.parse(
    fs.readFileSync(
      './contracts/compilation-details/_contracts_Storage_sol_SimpleStoragePracticeContract.abi',
      'utf8'
    )
  );
  // console.log('contract abi', abi);

  // const binary = fs
  //   .readFileSync(
  //     './contracts/compilation-details/_contracts_Storage_sol_SimpleStoragePracticeContract.bin',
  //     'utf8'
  //   )
  //   .trim();

  const contractInstance = new ethers.Contract(
    '0xA8c3047A5D661aB516C3266228ACAf2ADC365A99',
    abi,
    provider
  );

  const currentNumber = await contractInstance?.handleRetrieve();
  console.log(`currentNumber Number: ${currentNumber}`);

  // @ts-ignore
  await contractInstance?.connect(signer).handleStore(27);
  console.log('Updating number...');

  // @ts-ignore
  const newNumber = await contractInstance?.handleRetrieve();
  console.log(`New Number: ${newNumber}`);
}

contractInteractions();
