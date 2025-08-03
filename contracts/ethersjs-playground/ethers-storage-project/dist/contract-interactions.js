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
const fs_1 = __importDefault(require("fs"));
const ethers_1 = require("ethers");
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
function contractInteractions() {
    return __awaiter(this, void 0, void 0, function* () {
        const RPC_URL = process.env.RPC_URL || 'http://127.0.0.1:7545';
        const PRIVATE_KEY = process.env.PRIVATE_KEY;
        let provider = new ethers_1.ethers.JsonRpcProvider(RPC_URL);
        console.log('block number', yield provider.getBlockNumber());
        let signer = new ethers_1.ethers.Wallet(PRIVATE_KEY, provider);
        const abi = JSON.parse(fs_1.default.readFileSync('./contracts/compilation-details/_contracts_Storage_sol_SimpleStoragePracticeContract.abi', 'utf8'));
        // console.log('contract abi', abi);
        // const binary = fs
        //   .readFileSync(
        //     './contracts/compilation-details/_contracts_Storage_sol_SimpleStoragePracticeContract.bin',
        //     'utf8'
        //   )
        //   .trim();
        const contractInstance = new ethers_1.ethers.Contract('0xA8c3047A5D661aB516C3266228ACAf2ADC365A99', abi, provider);
        const currentNumber = yield (contractInstance === null || contractInstance === void 0 ? void 0 : contractInstance.handleRetrieve());
        console.log(`currentNumber Number: ${currentNumber}`);
        // @ts-ignore
        yield (contractInstance === null || contractInstance === void 0 ? void 0 : contractInstance.connect(signer).handleStore(27));
        console.log('Updating number...');
        // @ts-ignore
        const newNumber = yield (contractInstance === null || contractInstance === void 0 ? void 0 : contractInstance.handleRetrieve());
        console.log(`New Number: ${newNumber}`);
    });
}
contractInteractions();
