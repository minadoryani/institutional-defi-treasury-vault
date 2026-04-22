const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TreasuryVault", function () {
  let owner;
  let user;
  let attacker;
  let other;

  let vault;
  let oracle;
  let token;
  let unsupportedToken;

  const ONE = ethers.utils.parseUnits("1", 18);
  const TEN = ethers.utils.parseUnits("10", 18);
  const HUNDRED = ethers.utils.parseUnits("100", 18);
  const THOUSAND = ethers.utils.parseUnits("1000", 18);

  describe("Core Vault Logic", function () {
    beforeEach(async function () {
      [owner, user, attacker, other] = await ethers.getSigners();

      const MockVaultPriceOracle = await ethers.getContractFactory("MockVaultPriceOracle");
      oracle = await MockVaultPriceOracle.deploy();
      await oracle.deployed();

      const MockERC20 = await ethers.getContractFactory("MockERC20");

      token = await MockERC20.deploy(
        "Mock USD",
        "mUSD",
        ethers.utils.parseUnits("1000000", 18),
        owner.address
      );
      await token.deployed();

      unsupportedToken = await MockERC20.deploy(
        "Unsupported Token",
        "uTOK",
        ethers.utils.parseUnits("1000000", 18),
        owner.address
      );
      await unsupportedToken.deployed();

      const TreasuryVault = await ethers.getContractFactory("TreasuryVault");
      vault = await TreasuryVault.deploy(owner.address, oracle.address);
      await vault.deployed();

      await oracle.setPrice(
        token.address,
        ethers.utils.parseUnits("1", 18),
        Math.floor(Date.now() / 1000),
        true
      );

      await vault.addSupportedAsset(token.address, TEN, THOUSAND);
      await vault.setWithdrawalCooldown(3600);

      await token.mint(user.address, ethers.utils.parseUnits("5000", 18));
      await unsupportedToken.mint(user.address, ethers.utils.parseUnits("5000", 18));
    });

    it("setzt den Admin korrekt beim Deployment", async function () {
      const DEFAULT_ADMIN_ROLE = await vault.DEFAULT_ADMIN_ROLE();
      expect(await vault.hasRole(DEFAULT_ADMIN_ROLE, owner.address)).to.equal(true);
    });

    it("fügt ein Asset korrekt als supported hinzu", async function () {
      expect(await vault.isAssetSupported(token.address)).to.equal(true);
    });

    it("lässt einen gültigen Deposit zu", async function () {
      const depositAmount = ethers.utils.parseUnits("100", 18);

      await token.connect(user).approve(vault.address, depositAmount);

      await expect(
        vault.connect(user).deposit(token.address, depositAmount)
      ).to.not.be.reverted;

      const storedBalance = await vault.getUserBalance(user.address, token.address);
      expect(storedBalance).to.equal(depositAmount);
    });

    it("blockiert Deposits unterhalb des Mindestbetrags", async function () {
      const tooSmallAmount = ONE;

      await token.connect(user).approve(vault.address, tooSmallAmount);

      await expect(
        vault.connect(user).deposit(token.address, tooSmallAmount)
      ).to.be.reverted;
    });

    it("blockiert Deposits oberhalb des Maximums", async function () {
      const tooLargeAmount = ethers.utils.parseUnits("5000", 18);

      await token.connect(user).approve(vault.address, tooLargeAmount);

      await expect(
        vault.connect(user).deposit(token.address, tooLargeAmount)
      ).to.be.reverted;
    });

    it("blockiert Withdraw, wenn der Cooldown noch aktiv ist", async function () {
      const depositAmount = HUNDRED;

      await token.connect(user).approve(vault.address, depositAmount);
      await vault.connect(user).deposit(token.address, depositAmount);

      await expect(
        vault.connect(user).withdraw(token.address, depositAmount)
      ).to.be.reverted;
    });

    it("erlaubt Withdraw nach Ablauf des Cooldowns", async function () {
      const depositAmount = HUNDRED;

      await token.connect(user).approve(vault.address, depositAmount);
      await vault.connect(user).deposit(token.address, depositAmount);

      await ethers.provider.send("evm_increaseTime", [3601]);
      await ethers.provider.send("evm_mine", []);

      await expect(
        vault.connect(user).withdraw(token.address, depositAmount)
      ).to.not.be.reverted;

      const storedBalance = await vault.getUserBalance(user.address, token.address);
      expect(storedBalance).to.equal(0);
    });

    it("blockiert Withdraws über dem verfügbaren Guthaben", async function () {
      await expect(
        vault.connect(user).withdraw(token.address, TEN)
      ).to.be.reverted;
    });

    it("pausiert und entpausiert den Vault korrekt", async function () {
      await expect(vault.pauseVault()).to.not.be.reverted;

      const depositAmount = HUNDRED;
      await token.connect(user).approve(vault.address, depositAmount);

      await expect(
        vault.connect(user).deposit(token.address, depositAmount)
      ).to.be.reverted;

      await expect(vault.unpauseVault()).to.not.be.reverted;

      await expect(
        vault.connect(user).deposit(token.address, depositAmount)
      ).to.not.be.reverted;
    });

    it("blockiert addSupportedAsset für Nicht-Risk-Manager", async function () {
      const MockERC20 = await ethers.getContractFactory("MockERC20");
      const token2 = await MockERC20.deploy(
        "Mock Two",
        "mTWO",
        ethers.utils.parseUnits("1000000", 18),
        owner.address
      );
      await token2.deployed();

      await expect(
        vault.connect(user).addSupportedAsset(token2.address, TEN, THOUSAND)
      ).to.be.reverted;
    });

    it("blockiert Deposit mit nicht unterstütztem Asset", async function () {
      const depositAmount = HUNDRED;

      await unsupportedToken.connect(user).approve(vault.address, depositAmount);

      await expect(
        vault.connect(user).deposit(unsupportedToken.address, depositAmount)
      ).to.be.reverted;
    });

    it("blockiert Deposit bei ungültigem Preis", async function () {
      const depositAmount = HUNDRED;

      await oracle.setPrice(
        token.address,
        ethers.utils.parseUnits("1", 18),
        Math.floor(Date.now() / 1000),
        false
      );

      await token.connect(user).approve(vault.address, depositAmount);

      await expect(
        vault.connect(user).deposit(token.address, depositAmount)
      ).to.be.reverted;
    });

    it("blockiert Deposit bei stale price", async function () {
      const depositAmount = HUNDRED;
      const oldTimestamp = Math.floor(Date.now() / 1000) - (2 * 24 * 60 * 60);

      await oracle.setPrice(
        token.address,
        ethers.utils.parseUnits("1", 18),
        oldTimestamp,
        true
      );

      await token.connect(user).approve(vault.address, depositAmount);

      await expect(
        vault.connect(user).deposit(token.address, depositAmount)
      ).to.be.reverted;
    });

    it("lässt nur den Risk Manager die Oracle-Adresse ändern", async function () {
      const MockVaultPriceOracle = await ethers.getContractFactory("MockVaultPriceOracle");
      const newOracle = await MockVaultPriceOracle.deploy();
      await newOracle.deployed();

      await expect(
        vault.connect(user).setOracle(newOracle.address)
      ).to.be.reverted;

      await expect(
        vault.connect(owner).setOracle(newOracle.address)
      ).to.not.be.reverted;

      expect(await vault.getOracleAddress()).to.equal(newOracle.address);
    });

    it("previewUsdValue liefert den erwarteten USD-Wert", async function () {
      const usdValue = await vault.previewUsdValue(token.address, HUNDRED);
      expect(usdValue).to.equal(HUNDRED);
    });
  });

  describe("Reentrancy Protection", function () {
    let reentrantToken;
    let attackerContract;

    beforeEach(async function () {
      [owner, user, attacker, other] = await ethers.getSigners();

      const MockVaultPriceOracle = await ethers.getContractFactory("MockVaultPriceOracle");
      oracle = await MockVaultPriceOracle.deploy();
      await oracle.deployed();

      const ReentrantToken = await ethers.getContractFactory("ReentrantCallbackToken");
      reentrantToken = await ReentrantToken.deploy(
        "Reentrant USD",
        "rUSD",
        ethers.utils.parseUnits("1000000", 18),
        owner.address
      );
      await reentrantToken.deployed();

      const TreasuryVault = await ethers.getContractFactory("TreasuryVault");
      vault = await TreasuryVault.deploy(owner.address, oracle.address);
      await vault.deployed();

      await oracle.setPrice(
        reentrantToken.address,
        ethers.utils.parseUnits("1", 18),
        Math.floor(Date.now() / 1000),
        true
      );

      await vault.addSupportedAsset(reentrantToken.address, HUNDRED, THOUSAND);
      await vault.setWithdrawalCooldown(0);

      await reentrantToken.mint(attacker.address, ethers.utils.parseUnits("1000", 18));

      const ReentrancyAttacker = await ethers.getContractFactory("ReentrancyAttacker");
      attackerContract = await ReentrancyAttacker.deploy(vault.address, reentrantToken.address);
      await attackerContract.deployed();

      await reentrantToken.connect(attacker).approve(attackerContract.address, HUNDRED);
      await attackerContract.connect(attacker).deposit(attacker.address, HUNDRED);
      await attackerContract.connect(attacker).prepare(HUNDRED);
    });

    it("blockiert einen echten Reentrancy-Angriff", async function () {
      await expect(
        attackerContract.connect(attacker).attackWithdraw(HUNDRED)
      ).to.be.reverted;
    });
  });
});