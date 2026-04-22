const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with account:", deployer.address);

  const deployerBalance = await deployer.getBalance();
  console.log("Deployer balance:", ethers.utils.formatEther(deployerBalance), "ETH");

  const MockVaultPriceOracle = await ethers.getContractFactory("MockVaultPriceOracle");
  const oracle = await MockVaultPriceOracle.deploy();
  await oracle.deployed();

  console.log("MockVaultPriceOracle deployed to:", oracle.address);

  const TreasuryVault = await ethers.getContractFactory("TreasuryVault");
  const vault = await TreasuryVault.deploy(deployer.address, oracle.address);
  await vault.deployed();

  console.log("TreasuryVault deployed to:", vault.address);

  const MockERC20 = await ethers.getContractFactory("MockERC20");
  const token = await MockERC20.deploy(
    "Mock USD",
    "mUSD",
    ethers.utils.parseUnits("1000000", 18),
    deployer.address
  );
  await token.deployed();

  console.log("MockERC20 deployed to:", token.address);

  const currentTimestamp = Math.floor(Date.now() / 1000);

  await oracle.setPrice(
    token.address,
    ethers.utils.parseUnits("1", 18),
    currentTimestamp,
    true
  );
  console.log("Oracle price set for token");

  await vault.addSupportedAsset(
    token.address,
    ethers.utils.parseUnits("10", 18),
    ethers.utils.parseUnits("1000", 18)
  );
  console.log("Supported asset added to vault");

  await vault.setWithdrawalCooldown(3600);
  console.log("Withdrawal cooldown set to 3600 seconds");

  console.log("\nDeployment completed successfully");
  console.log("Oracle:", oracle.address);
  console.log("Vault:", vault.address);
  console.log("Token:", token.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});