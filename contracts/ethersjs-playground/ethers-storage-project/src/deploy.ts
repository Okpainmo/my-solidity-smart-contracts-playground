import { ethers } from "ethers";
import fs from "fs";
import dotenv from "dotenv";

dotenv.config();

export async function deploy() {
    try {
        const RPC_URL = process.env.RPC_URL || "http://127.0.0.1:7545";
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

        const binary = fs
            .readFileSync(
                "./contracts/compilation-details/_contracts_Storage_sol_SimpleStoragePracticeContract.bin",
                "utf8",
            )
            .trim();
        // console.log('contract binary', binary);

        const contractFactory = new ethers.ContractFactory(abi, binary, signer);

        console.log("Deploying, please wait...");

        // for local deployment
        // const contract = await contractFactory.deploy({
        //     gasLimit: 6_000_000,
        //     gasPrice: 100_000_000_000, // 100 gwei
        // });

        // for testnet/mainnet deployment
        const contract = await contractFactory.deploy();

        const deploymentReceipt = await contract
            ?.deploymentTransaction()
            ?.wait(1);
        console.log("Deployment receipt:", deploymentReceipt);

        console.log(`Contract address: ${deploymentReceipt?.contractAddress}`);

        /* Difference between `deploymentReceipt` and `deploymentTransaction`,
    is that you get a receipt(a different kind of data set) when you wait for a txn.
    But deploymentTransaction contains more valuable data. */
        const deploymentTransaction = contract?.deploymentTransaction();
        console.log("Deployment transaction:", deploymentTransaction);

        return contract;
    } catch (error) {
        if (error instanceof Error) {
            console.error(error.message);
        } else {
            console.error(error);
        }
    }
}

deploy();
