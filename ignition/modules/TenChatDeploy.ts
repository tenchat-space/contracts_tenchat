import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const TenChatModule = buildModule("TenChatModule", (m) => {
  // Deploy Core contract (central registry and user management)
  const core = m.contract("Core");

  // Deploy EncryptedChat contract
  const encryptedChat = m.contract("EncryptedChat", [core]);

  // Deploy Gifting contract
  const gifting = m.contract("Gifting", [core]);

  // Deploy Subscription contract
  const subscription = m.contract("Subscription", [core]);

  // Register contracts in Core
  m.call(core, "setContractAddress", ["EncryptedChat", encryptedChat], {
    id: "register_encrypted_chat"
  });

  m.call(core, "setContractAddress", ["Gifting", gifting], {
    id: "register_gifting"
  });

  m.call(core, "setContractAddress", ["Subscription", subscription], {
    id: "register_subscription"
  });

  return { core, encryptedChat, gifting, subscription };
});

export default TenChatModule;
