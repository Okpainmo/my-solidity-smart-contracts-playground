import { ethers, ProgressCallback } from "ethers";
import fs from "fs";
import dotenv from "dotenv";

dotenv.config();

/* 

Steps for encrypting private keys.
    
1. Add the private key to the .env file first, and then run this script to generate encrypted key - the json file.
2. Now remove the private key from the .env, and use the encrypted json for generating the private key in the code 
whenever/wherever you need to.
3. Git ignore the encrypted json for the private key. 
4. Also delete the private key password from the .env file. Only(STRICTLY) write the password directly to your terminal

*/

async function handleKeyEncrypt() {
    const wallet = new ethers.Wallet(process.env.PRIVATE_KEY as string);

    const encryptedJsonKey = await wallet.encrypt(
        process.env.PRIVATE_KEY_PASSWORD as string,
    );
    // In later version (^6.2.3 as of this commit) of etherjs, PRIVATE_KEY is inferred from wallet, so there is no need to
    // pass private key again.
    //     const encryptedJsonKey = await wallet.encrypt(
    //         process.env.PRIVATE_KEY_PASSWORD,
    //  )
    console.log(encryptedJsonKey);
    fs.writeFileSync("./.encryptedKey.json", encryptedJsonKey);
}

handleKeyEncrypt()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
