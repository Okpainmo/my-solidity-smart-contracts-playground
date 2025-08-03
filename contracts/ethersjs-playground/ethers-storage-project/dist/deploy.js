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
exports.deploy = deploy;
const ethers_1 = require("ethers");
const fs_1 = __importDefault(require("fs"));
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
function deploy() {
    return __awaiter(this, void 0, void 0, function* () {
        var _a;
        try {
            const RPC_URL = process.env.RPC_URL || 'http://127.0.0.1:7545';
            let provider = new ethers_1.ethers.JsonRpcProvider(RPC_URL);
            console.log('block number', yield provider.getBlockNumber());
            let signer = new ethers_1.ethers.Wallet(process.env.PRIVATE_KEY, provider);
            const abi = JSON.parse(fs_1.default.readFileSync('./contracts/compilation-details/_contracts_Storage_sol_SimpleStoragePracticeContract.abi', 'utf8'));
            // console.log('contract abi', abi);
            const binary = fs_1.default
                .readFileSync('./contracts/compilation-details/_contracts_Storage_sol_SimpleStoragePracticeContract.bin', 'utf8')
                .trim();
            // console.log('contract binary', binary);
            const contractFactory = new ethers_1.ethers.ContractFactory(abi, binary, signer);
            console.log('Deploying, please wait...');
            const contract = yield contractFactory.deploy({
                gasLimit: 6000000,
                gasPrice: 100000000000, // 100 gwei
            });
            const deploymentReceipt = yield ((_a = contract === null || contract === void 0 ? void 0 : contract.deploymentTransaction()) === null || _a === void 0 ? void 0 : _a.wait(1));
            console.log('Deployment receipt:', deploymentReceipt);
            console.log(`Contract address: ${deploymentReceipt === null || deploymentReceipt === void 0 ? void 0 : deploymentReceipt.contractAddress}`);
            /* Difference between `deploymentReceipt` and `deploymentTransaction`,
            is that you get a receipt(a different kind of data set) when you wait for a txn.
            But deploymentTransaction contains more valuable data. */
            const deploymentTransaction = contract === null || contract === void 0 ? void 0 : contract.deploymentTransaction();
            console.log('Deployment transaction:', deploymentTransaction);
            return contract;
        }
        catch (error) {
            if (error instanceof Error) {
                console.error(error.message);
            }
            else {
                console.error(error);
            }
        }
    });
}
deploy();
