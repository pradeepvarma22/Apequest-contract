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
    fevm_ipc_mycelium: {
      url: "https://api.mycelium.calibration.node.glif.io/",
      accounts: [PRIVATE_KEY],
      chainId: 2120099022966061,
    },
    mantle: {
      chainId: 5001,
      accounts: [PRIVATE_KEY],
      url: "https://rpc.testnet.mantle.xyz",
    },
    scrollSepolia: {
      chainId: 534351,
      url: "https://sepolia-rpc.scroll.io",
      accounts: [PRIVATE_KEY],
      timeout: 60000000,
    },
    arbitrum: {
      chainId: 421613,
      url: "https://arbitrum-goerli.publicnode.com",
      accounts: [PRIVATE_KEY],
      timeout: 60000000,
    },
    mumbai: {
      chainId: 80001,
      url: "https://rpc-mumbai.maticvigil.com",
      accounts: [PRIVATE_KEY],
    }
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
