const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

describe("Subscription Contract", function () {
    let Core, core, Subscription, subscription, MockERC20, paymentToken, owner, user1;

    const TIER_1_ID = 1;
    const TIER_1_PRICE = ethers.parseUnits("50", 18);
    const TIER_1_DURATION = 30 * 24 * 60 * 60; // 30 days in seconds

    beforeEach(async function () {
        [owner, user1] = await ethers.getSigners();

        // Deploy Mock Core and register user
        const CoreFactory = await ethers.getContractFactory("Core");
        core = await CoreFactory.deploy();
        await core.connect(user1).registerUser("User1");

        // Deploy Mock ERC20 and mint tokens to user
        const MockERC20Factory = await ethers.getContractFactory("MockERC20");
        paymentToken = await MockERC20Factory.deploy("Payment Token", "PAY");
        await paymentToken.mint(user1.address, ethers.parseUnits("1000", 18));

        // Deploy Subscription contract
        const SubscriptionFactory = await ethers.getContractFactory("Subscription");
        subscription = await SubscriptionFactory.deploy(core.getAddress(), paymentToken.getAddress());

        // Create a subscription tier as the owner
        await subscription.connect(owner).createSubscriptionTier(TIER_1_ID, TIER_1_PRICE, TIER_1_DURATION);
    });

    it("Should allow a user to subscribe to a tier", async function () {
        // User approves the subscription contract to spend their payment tokens
        await paymentToken.connect(user1).approve(subscription.getAddress(), TIER_1_PRICE);
        
        const ownerInitialBalance = await paymentToken.balanceOf(owner.address);
        
        await expect(subscription.connect(user1).subscribe(TIER_1_ID)).to.emit(subscription, "Subscribed");
        
        const latestBlock = await ethers.provider.getBlock("latest");
        const expectedExpiry = latestBlock.timestamp + TIER_1_DURATION;

        const subDetails = await subscription.getSubscriptionDetails(user1.address);
        expect(subDetails.tier).to.equal(TIER_1_ID);
        expect(subDetails.expiresAt).to.equal(expectedExpiry);

        // Check if payment was transferred to the owner
        const ownerFinalBalance = await paymentToken.balanceOf(owner.address);
        expect(ownerFinalBalance).to.equal(ownerInitialBalance + TIER_1_PRICE);
    });

    it("Should allow a user to extend their existing subscription", async function () {
        // First subscription
        await paymentToken.connect(user1).approve(subscription.getAddress(), TIER_1_PRICE * BigInt(2));
        await subscription.connect(user1).subscribe(TIER_1_ID);
        const firstSubDetails = await subscription.getSubscriptionDetails(user1.address);
        const firstExpiry = firstSubDetails.expiresAt;

        // Move time forward, but not past expiry
        await time.increase(TIER_1_DURATION / 2);

        // Second subscription (renewal)
        await subscription.connect(user1).subscribe(TIER_1_ID);
        const secondSubDetails = await subscription.getSubscriptionDetails(user1.address);
        
        // Expiry should be extended from the *previous* expiry date, not the new block.timestamp
        const expectedNewExpiry = firstExpiry + BigInt(TIER_1_DURATION);
        expect(secondSubDetails.expiresAt).to.equal(expectedNewExpiry);
    });

    it("Should fail if the user has not approved enough tokens", async function () {
        await paymentToken.connect(user1).approve(subscription.getAddress(), ethers.parseUnits("10", 18)); // Not enough
        await expect(subscription.connect(user1).subscribe(TIER_1_ID)).to.be.revertedWith("Check token allowance for subscription");
    });
    
    it("Should correctly report an active subscription", async function () {
        await paymentToken.connect(user1).approve(subscription.getAddress(), TIER_1_PRICE);
        await subscription.connect(user1).subscribe(TIER_1_ID);

        expect(await subscription.isSubscriptionActive(user1.address)).to.be.true;

        // Move time past the expiry date
        await time.increase(TIER_1_DURATION + 60); // 60 seconds buffer

        expect(await subscription.isSubscriptionActive(user1.address)).to.be.false;
    });
});
