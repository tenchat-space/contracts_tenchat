import { ethers } from "hardhat";

async function main() {
  console.log("🚀 Deploying TenChat contracts...\n");

  // Deploy Core contract
  console.log("📝 Deploying Core contract...");
  const Core = await ethers.getContractFactory("Core");
  const core = await Core.deploy();
  await core.waitForDeployment();
  const coreAddress = await core.getAddress();
  console.log(`✅ Core deployed to: ${coreAddress}`);

  // Deploy EncryptedChat
  console.log("\n📝 Deploying EncryptedChat contract...");
  const EncryptedChat = await ethers.getContractFactory("EncryptedChat");
  const encryptedChat = await EncryptedChat.deploy(coreAddress);
  await encryptedChat.waitForDeployment();
  const encryptedChatAddress = await encryptedChat.getAddress();
  console.log(`✅ EncryptedChat deployed to: ${encryptedChatAddress}`);

  // Deploy Gifting
  console.log("\n📝 Deploying Gifting contract...");
  const Gifting = await ethers.getContractFactory("Gifting");
  const gifting = await Gifting.deploy(coreAddress);
  await gifting.waitForDeployment();
  const giftingAddress = await gifting.getAddress();
  console.log(`✅ Gifting deployed to: ${giftingAddress}`);

  // Deploy Subscription
  console.log("\n📝 Deploying Subscription contract...");
  const Subscription = await ethers.getContractFactory("Subscription");
  const subscription = await Subscription.deploy(coreAddress);
  await subscription.waitForDeployment();
  const subscriptionAddress = await subscription.getAddress();
  console.log(`✅ Subscription deployed to: ${subscriptionAddress}`);

  // Register contracts in Core
  console.log("\n📝 Registering contracts in Core...");
  await core.setContractAddress("EncryptedChat", encryptedChatAddress);
  console.log("✅ Registered EncryptedChat");
  
  await core.setContractAddress("Gifting", giftingAddress);
  console.log("✅ Registered Gifting");
  
  await core.setContractAddress("Subscription", subscriptionAddress);
  console.log("✅ Registered Subscription");

  console.log("\n🎉 Deployment Complete!\n");
  console.log("Contract Addresses:");
  console.log("===================");
  console.log(`Core:           ${coreAddress}`);
  console.log(`EncryptedChat:  ${encryptedChatAddress}`);
  console.log(`Gifting:        ${giftingAddress}`);
  console.log(`Subscription:   ${subscriptionAddress}`);
  console.log("\n💡 Save these addresses for frontend integration!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
