// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Core.sol";

/**
 * @title Gifting
 * @dev Manages the sending of ERC20 token gifts between users.
 */
contract Gifting {
    // --- Events ---

    event GiftSent(
        address indexed from,
        address indexed to,
        address indexed token,
        uint256 amount
    );

    // --- State Variables ---

    Core coreContract;

    // Mapping from user addresses to their gift history (private for TEN encryption)
    mapping(address => Gift[]) private userGiftsSent;
    mapping(address => Gift[]) private userGiftsReceived;

    struct Gift {
        address from;
        address to;
        address token;
        uint256 amount;
        uint256 timestamp;
    }

    // --- Constructor ---

    constructor(address _coreAddress) {
        coreContract = Core(_coreAddress);
    }

    // --- Gifting Functions ---

    /**
     * @dev Sends an ERC20 token gift to another registered user.
     * The sender must have approved this contract to spend the tokens.
     * @param _to The recipient's address.
     * @param _tokenAddress The address of the ERC20 token contract.
     * @param _amount The amount of tokens to send.
     */
    function sendGift(address _to, address _tokenAddress, uint256 _amount) external {
        require(coreContract.isUserRegistered(msg.sender), "Sender not registered");
        require(coreContract.isUserRegistered(_to), "Recipient not registered");
        require(_amount > 0, "Gift amount must be greater than 0");

        IERC20 token = IERC20(_tokenAddress);
        
        // The user must have approved this contract to spend on their behalf
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Check token allowance");

        // Transfer the tokens from sender to recipient
        bool success = token.transferFrom(msg.sender, _to, _amount);
        require(success, "Token transfer failed");

        // Store gift history (private on TEN for privacy)
        Gift memory newGift = Gift({
            from: msg.sender,
            to: _to,
            token: _tokenAddress,
            amount: _amount,
            timestamp: block.timestamp
        });
        
        userGiftsSent[msg.sender].push(newGift);
        userGiftsReceived[_to].push(newGift);

        emit GiftSent(msg.sender, _to, _tokenAddress, _amount);
    }

    /**
     * @dev Gets the gift history sent by a user.
     */
    function getGiftsSent(address _user) external view returns (Gift[] memory) {
        require(msg.sender == _user, "Can only view your own gift history");
        return userGiftsSent[_user];
    }

    /**
     * @dev Gets the gift history received by a user.
     */
    function getGiftsReceived(address _user) external view returns (Gift[] memory) {
        require(msg.sender == _user, "Can only view your own gift history");
        return userGiftsReceived[_user];
    }
}
