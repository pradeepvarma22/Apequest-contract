import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "dotenv/config";
const PRIVATE_KEY = process.env.PRIVATE_KEY!;

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    mantle: {
      chainId: 5001,
      accounts: [PRIVATE_KEY],
      url: "https://rpc.testnet.mantle.xyz",
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./temp/cache",
    artifacts: "./temp/artifacts",
  },
  typechain: {
    outDir: "./temp/types",
  },
};

export default config;
