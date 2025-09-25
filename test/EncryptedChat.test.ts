const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("EncryptedChat Contract", function () {
    let Core, core, EncryptedChat, chat, owner, sender, receiver, thirdParty;

    beforeEach(async function () {
        [owner, sender, receiver, thirdParty] = await ethers.getSigners();

        // Deploy a mock Core contract
        const CoreFactory = await ethers.getContractFactory("Core");
        core = await CoreFactory.deploy();

        // Register our test users in the mock Core contract
        await core.connect(sender).registerUser("Sender");
        await core.connect(receiver).registerUser("Receiver");
        // thirdParty remains unregistered for some tests

        // Deploy the EncryptedChat contract and link it to the mock Core
        const EncryptedChatFactory = await ethers.getContractFactory("EncryptedChat");
        chat = await EncryptedChatFactory.deploy(core.getAddress());
    });

    describe("Sending Messages", function () {
        it("Should allow a registered user to send a message to another registered user", async function () {
            const encryptedContent = ethers.toUtf8Bytes("This is a secret message");
            
            await expect(chat.connect(sender).sendMessage(receiver.address, encryptedContent))
                .to.emit(chat, "MessageSent");
            
            const message = await chat.getMessage(1);
            expect(message.from).to.equal(sender.address);
            expect(message.to).to.equal(receiver.address);
            expect(message.encryptedContent).to.equal(ethers.hexlify(encryptedContent));
        });

        it("Should prevent an unregistered user from sending a message", async function () {
            const encryptedContent = ethers.toUtf8Bytes("Test");
            await expect(chat.connect(thirdParty).sendMessage(receiver.address, encryptedContent))
                .to.be.revertedWith("Sender not registered");
        });

        it("Should prevent sending a message to an unregistered user", async function () {
            const encryptedContent = ethers.toUtf8Bytes("Test");
            await expect(chat.connect(sender).sendMessage(thirdParty.address, encryptedContent))
                .to.be.revertedWith("Recipient not registered");
        });

        it("Should prevent a user from sending a message to themselves", async function () {
            const encryptedContent = ethers.toUtf8Bytes("Test");
            await expect(chat.connect(sender).sendMessage(sender.address, encryptedContent))
                .to.be.revertedWith("Cannot send message to yourself");
        });
    });

    describe("Retrieving Messages", function () {
        it("Should allow the sender to retrieve a message they sent", async function () {
            const encryptedContent = ethers.toUtf8Bytes("Hello Receiver!");
            await chat.connect(sender).sendMessage(receiver.address, encryptedContent);
            
            const message = await chat.connect(sender).getMessage(1);
            expect(message.from).to.equal(sender.address);
            expect(message.encryptedContent).to.equal(ethers.hexlify(encryptedContent));
        });

        it("Should allow the receiver to retrieve a message they received", async function () {
            const encryptedContent = ethers.toUtf8Bytes("Hello Sender!");
            await chat.connect(sender).sendMessage(receiver.address, encryptedContent);

            const message = await chat.connect(receiver).getMessage(1);
            expect(message.to).to.equal(receiver.address);
             expect(message.encryptedContent).to.equal(ethers.hexlify(encryptedContent));
        });

        it("Should prevent a third party from retrieving a message", async function () {
            const encryptedContent = ethers.toUtf8Bytes("Private conversation");
            await chat.connect(sender).sendMessage(receiver.address, encryptedContent);
            
            await expect(chat.connect(thirdParty).getMessage(1))
                .to.be.revertedWith("You are not authorized to view this message");
        });

        it("Should revert when trying to retrieve a non-existent message", async function () {
            await expect(chat.getMessage(999))
                .to.be.revertedWith("Message does not exist");
        });
    });
});
