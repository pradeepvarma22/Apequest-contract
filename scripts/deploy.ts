import { ethers } from "hardhat";

async function main() {
  const network = await ethers.provider.getNetwork();
  console.log(
    `Deploying to network: ${network.name} (chainId: ${network.chainId})`
  );

  const apequestMultiSenderFactory = await ethers.getContractFactory(
    "ApequestMultiSender"
  );

  const apequestMultiSender = await apequestMultiSenderFactory.deploy();
  const address = await apequestMultiSender.getAddress();

  console.log(`ApequestMultiSender deployed to: ${address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
