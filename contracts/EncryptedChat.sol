// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Core.sol";

/**
 * @title EncryptedChat
 * @dev Handles the logic for sending and storing encrypted messages.
 * Actual encryption/decryption happens client-side.
 */
contract EncryptedChat {
    // --- Events ---

    event MessageSent(
        uint256 indexed chatId,
        address indexed from,
        address indexed to,
        uint256 timestamp,
        bytes encryptedContent
    );

    // --- State Variables ---

    Core coreContract;

    // A simple counter to create unique chat IDs
    uint256 private nextChatId;

    // Struct to represent a chat message
    struct Message {
        address from;
        address to;
        uint256 timestamp;
        bytes encryptedContent; // The client-side encrypted message
    }

    // Mapping from a chat ID to the message
    mapping(uint256 => Message) public messages;

    // --- Constructor ---

    constructor(address _coreAddress) {
        coreContract = Core(_coreAddress);
        nextChatId = 1;
    }

    // --- Chat Functions ---

    /**
     * @dev Sends an encrypted message to another user.
     * @param _to The recipient's address.
     * @param _encryptedContent The encrypted message payload from the client.
     */
    function sendMessage(address _to, bytes calldata _encryptedContent) external {
        require(coreContract.isUserRegistered(msg.sender), "Sender not registered");
        require(coreContract.isUserRegistered(_to), "Recipient not registered");
        require(_to != msg.sender, "Cannot send message to yourself");
        require(_encryptedContent.length > 0, "Encrypted content cannot be empty");

        uint256 chatId = nextChatId++;
        messages[chatId] = Message({
            from: msg.sender,
            to: _to,
            timestamp: block.timestamp,
            encryptedContent: _encryptedContent
        });

        emit MessageSent(chatId, msg.sender, _to, block.timestamp, _encryptedContent);
    }

    /**
     * @dev Retrieves a message by its chat ID.
     * The caller must be either the sender or the recipient.
     */
    function getMessage(uint256 _chatId)
        external
        view
        returns (address from, address to, uint256 timestamp, bytes memory encryptedContent)
    {
        Message storage message = messages[_chatId];
        require(message.timestamp != 0, "Message does not exist");
        require(
            msg.sender == message.from || msg.sender == message.to,
            "You are not authorized to view this message"
        );

        return (message.from, message.to, message.timestamp, message.encryptedContent);
    }
}
