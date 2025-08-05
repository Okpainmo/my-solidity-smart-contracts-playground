import fs from "fs";
import { ethers } from "ethers";
import dotenv from "dotenv";

dotenv.config();

async function contractInteractions() {
    const RPC_URL = process.env.RPC_URL || "http://127.0.0.1:7545";
    const PRIVATE_KEY = process.env.PRIVATE_KEY;

    let provider = new ethers.JsonRpcProvider(RPC_URL);
    console.log("block number", await provider.getBlockNumber());

    // let signer = new ethers.Wallet(PRIVATE_KEY as string, provider);
    const encryptedJson = fs.readFileSync("./.encryptedKey.json", "utf8");
    let signer = ethers.Wallet.fromEncryptedJsonSync(
        encryptedJson,
        process.env.PRIVATE_KEY_PASSWORD as string,
    ).connect(provider);

    const abi = JSON.parse(
        fs.readFileSync(
            "./contracts/compilation-details/_contracts_Storage_sol_SimpleStoragePracticeContract.abi",
            "utf8",
        ),
    );
    // console.log('contract abi', abi);

    // const binary = fs
    //   .readFileSync(
    //     './contracts/compilation-details/_contracts_Storage_sol_SimpleStoragePracticeContract.bin',
    //     'utf8'
    //   )
    //   .trim();

    const contractInstance = new ethers.Contract(
        "0x163b46dc1f27AAeD8Ba6C87Bfb31595c1493f9DE",
        abi,
        provider,
    );

    /* the below contract interactions might work differently on a testnet as it would on a mainnet - if called together like was done below.
      Call the contracts separately instead - in different functions/processes*/
    const currentNumber = await contractInstance?.handleRetrieve();
    console.log(`currentNumber Number: ${currentNumber}`);

    // @ts-ignore
    await contractInstance?.connect(signer).handleStore(90);
    console.log("Updating number...");

    // @ts-ignore
    const newNumber = await contractInstance?.handleRetrieve();
    console.log(`New Number: ${newNumber}`);
}

contractInteractions();
