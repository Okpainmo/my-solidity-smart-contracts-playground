"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const ethers_1 = require("ethers");
const fs_1 = __importDefault(require("fs"));
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
/*

Steps for encrypting private keys.
    
1. Add the private key to the .env file first, and then run this script to generate encrypted key - the json file.
2. Now remove the private key from the .env, and use the encrypted json for generating the private key in the code
whenever/wherever you need to.
3. Git ignore the encrypted json for the private key.
4. Also delete the private key password from the .env file. Only(STRICTLY) write the password directly to your terminal

*/
function handleKeyEncrypt() {
    return __awaiter(this, void 0, void 0, function* () {
        const wallet = new ethers_1.ethers.Wallet(process.env.PRIVATE_KEY);
        const encryptedJsonKey = yield wallet.encrypt(process.env.PRIVATE_KEY_PASSWORD);
        // In later version (^6.2.3 as of this commit) of etherjs, PRIVATE_KEY is inferred from wallet, so there is no need to
        // pass private key again.
        //     const encryptedJsonKey = await wallet.encrypt(
        //         process.env.PRIVATE_KEY_PASSWORD,
        //  )
        console.log(encryptedJsonKey);
        fs_1.default.writeFileSync("./.encryptedKey.json", encryptedJsonKey);
    });
}
handleKeyEncrypt()
    .then(() => process.exit(0))
    .catch((error) => {
    console.error(error);
    process.exit(1);
});
