import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  
  console.log("🔍 Contract Verification\n");
  console.log("Deployer:", deployer.address);
  console.log("Balance:", ethers.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH\n");

  // Add your deployed contract addresses here
  const CORE_ADDRESS = process.env.CORE_ADDRESS || "";
  const ENCRYPTED_CHAT_ADDRESS = process.env.ENCRYPTED_CHAT_ADDRESS || "";
  const GIFTING_ADDRESS = process.env.GIFTING_ADDRESS || "";
  const SUBSCRIPTION_ADDRESS = process.env.SUBSCRIPTION_ADDRESS || "";

  if (!CORE_ADDRESS) {
    console.error("❌ CORE_ADDRESS not set");
    process.exit(1);
  }

  // Verify Core
  console.log("Verifying Core contract...");
  const core = await ethers.getContractAt("Core", CORE_ADDRESS);
  const owner = await core.owner();
  console.log(`✅ Core owner: ${owner}`);

  // Verify EncryptedChat
  if (ENCRYPTED_CHAT_ADDRESS) {
    console.log("\nVerifying EncryptedChat contract...");
    const encryptedChat = await ethers.getContractAt("EncryptedChat", ENCRYPTED_CHAT_ADDRESS);
    const chatCore = await encryptedChat.coreContract();
    console.log(`✅ EncryptedChat core: ${chatCore}`);
  }

  // Verify Gifting
  if (GIFTING_ADDRESS) {
    console.log("\nVerifying Gifting contract...");
    const gifting = await ethers.getContractAt("Gifting", GIFTING_ADDRESS);
    const giftingCore = await gifting.coreContract();
    console.log(`✅ Gifting core: ${giftingCore}`);
  }

  // Verify Subscription
  if (SUBSCRIPTION_ADDRESS) {
    console.log("\nVerifying Subscription contract...");
    const subscription = await ethers.getContractAt("Subscription", SUBSCRIPTION_ADDRESS);
    const subCore = await subscription.coreContract();
    console.log(`✅ Subscription core: ${subCore}`);
  }

  console.log("\n✅ All contracts verified!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
