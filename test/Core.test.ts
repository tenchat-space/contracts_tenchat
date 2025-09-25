const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Core Contract", function () {
    let Core, core, owner, addr1, addr2;

    // Deploy the contract before each test
    beforeEach(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();
        const CoreFactory = await ethers.getContractFactory("Core");
        core = await CoreFactory.deploy();
    });

    describe("User Management", function () {
        it("Should allow a new user to register with a unique username", async function () {
            await expect(core.connect(addr1).registerUser("Alice"))
                .to.emit(core, "UserRegistered")
                .withArgs(addr1.address, "Alice");

            const userProfile = await core.userProfiles(addr1.address);
            expect(userProfile.username).to.equal("Alice");
            expect(userProfile.isRegistered).to.be.true;
        });

        it("Should prevent registration with an already taken username", async function () {
            await core.connect(addr1).registerUser("Alice");
            await expect(core.connect(addr2).registerUser("Alice"))
                .to.be.revertedWith("Username is taken");
        });

        it("Should prevent a user from registering twice", async function () {
            await core.connect(addr1).registerUser("Alice");
            await expect(core.connect(addr1).registerUser("AliceNew"))
                .to.be.revertedWith("User already registered");
        });

        it("Should allow a registered user to update their username", async function () {
            await core.connect(addr1).registerUser("Alice");
            await expect(core.connect(addr1).updateUsername("AliceV2"))
                .to.emit(core, "UserProfileUpdated")
                .withArgs(addr1.address, "AliceV2");
            
            const userProfile = await core.userProfiles(addr1.address);
            expect(userProfile.username).to.equal("AliceV2");
        });

        it("Should prevent updating to a username that is already taken", async function () {
            await core.connect(addr1).registerUser("Alice");
            await core.connect(addr2).registerUser("Bob");

            await expect(core.connect(addr1).updateUsername("Bob"))
                .to.be.revertedWith("New username is taken");
        });
    });

    describe("Contract Registry", function () {
        it("Should allow the owner to set a contract address", async function () {
            await expect(core.connect(owner).setContractAddress("Gifting", addr1.address))
                .to.emit(core, "ContractAddressUpdated")
                .withArgs("Gifting", addr1.address);

            const address = await core.getContractAddress("Gifting");
            expect(address).to.equal(addr1.address);
        });

        it("Should prevent a non-owner from setting a contract address", async function () {
            await expect(core.connect(addr1).setContractAddress("Gifting", addr2.address))
                .to.be.revertedWithCustomError(core, "OwnableUnauthorizedAccount");
        });

        it("Should return the correct address for a registered contract", async function () {
            await core.connect(owner).setContractAddress("EncryptedChat", addr2.address);
            expect(await core.getContractAddress("EncryptedChat")).to.equal(addr2.address);
        });

        it("Should return a zero address for an unregistered contract", async function () {
            expect(await core.getContractAddress("NonExistent")).to.equal(ethers.ZeroAddress);
        });
    });
});
