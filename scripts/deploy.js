import hre from "hardhat";

async function main() {
  const ESGStorage = await hre.ethers.getContractFactory("ESGStorage");
  const contract = await ESGStorage.deploy();
  await contract.waitForDeployment();
  console.log("ESGStorage deployed to:", await contract.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});