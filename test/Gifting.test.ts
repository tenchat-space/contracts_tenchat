const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Gifting Contract", function () {
    let Core, core, Gifting, gifting, MockERC20, token, owner, sender, receiver;
    const giftAmount = ethers.parseUnits("100", 18); // 100 tokens

    beforeEach(async function () {
        [owner, sender, receiver] = await ethers.getSigners();

        // Deploy Mock Core and register users
        const CoreFactory = await ethers.getContractFactory("Core");
        core = await CoreFactory.deploy();
        await core.connect(sender).registerUser("Sender");
        await core.connect(receiver).registerUser("Receiver");

        // Deploy Mock ERC20 Token and mint tokens to the sender
        const MockERC20Factory = await ethers.getContractFactory("MockERC20");
        token = await MockERC20Factory.deploy("Mock Token", "MTK");
        await token.mint(sender.address, ethers.parseUnits("1000", 18)); // Mint 1000 tokens

        // Deploy Gifting contract
        const GiftingFactory = await ethers.getContractFactory("Gifting");
        gifting = await GiftingFactory.deploy(core.getAddress());
    });

    it("Should allow a registered user to send a gift to another registered user", async function () {
        // Sender must first approve the Gifting contract to spend their tokens
        await token.connect(sender).approve(gifting.getAddress(), giftAmount);

        // Check initial balances
        const senderInitialBalance = await token.balanceOf(sender.address);
        const receiverInitialBalance = await token.balanceOf(receiver.address);

        // Send the gift
        await expect(gifting.connect(sender).sendGift(receiver.address, token.getAddress(), giftAmount))
            .to.emit(gifting, "GiftSent")
            .withArgs(sender.address, receiver.address, await token.getAddress(), giftAmount);

        // Check final balances
        const senderFinalBalance = await token.balanceOf(sender.address);
        const receiverFinalBalance = await token.balanceOf(receiver.address);

        expect(senderFinalBalance).to.equal(senderInitialBalance - giftAmount);
        expect(receiverFinalBalance).to.equal(receiverInitialBalance + giftAmount);
    });

    it("Should fail if the sender has not approved the contract to spend tokens", async function () {
        await expect(gifting.connect(sender).sendGift(receiver.address, token.getAddress(), giftAmount))
            .to.be.revertedWith("Check token allowance");
    });
    
    it("Should fail if the sender has an insufficient token balance", async function () {
        const excessiveAmount = ethers.parseUnits("2000", 18); // More than sender has
        await token.connect(sender).approve(gifting.getAddress(), excessiveAmount);

        await expect(gifting.connect(sender).sendGift(receiver.address, token.getAddress(), excessiveAmount))
            .to.be.reverted; // ERC20 will revert with "transfer amount exceeds balance"
    });

    it("Should fail if the sender is not a registered user", async function () {
        const unregisteredSender = (await ethers.getSigners())[3];
        await expect(gifting.connect(unregisteredSender).sendGift(receiver.address, token.getAddress(), giftAmount))
            .to.be.revertedWith("Sender not registered");
    });
});

// A simple Mock ERC20 contract for testing purposes
// In a real project, you might use a more robust mock from a library like OpenZeppelin.
// For brevity, I'm creating a minimal version here. You'll need to create a `contracts/mocks/MockERC20.sol` file for this.
//
// File: contracts/mocks/MockERC20.sol
/*
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
*/
