// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Core.sol";

/**
 * @title Subscription
 * @dev Manages user subscriptions for premium features.
 */
contract Subscription {
    // --- Events ---

    event Subscribed(address indexed user, uint256 tier, uint256 expiresAt);
    event SubscriptionTierCreated(uint256 indexed tierId, uint256 price, uint256 duration);

    // --- State Variables ---

    Core coreContract;
    address public paymentToken; // The ERC20 token used for payments

    // Struct to define a subscription tier
    struct SubscriptionTier {
        uint256 price; // Price in the smallest unit of the payment token
        uint256 duration; // Duration in seconds
        bool isActive;
    }

    // Mapping from a tier ID to the subscription tier (private for TEN encryption)
    mapping(uint256 => SubscriptionTier) private subscriptionTiers;

    // Mapping from a user to their subscription details (private for TEN encryption)
    mapping(address => UserSubscription) private userSubscriptions;

    struct UserSubscription {
        uint256 tier;
        uint256 expiresAt;
    }
    
    address owner;

    // --- Modifiers ---
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // --- Constructor ---

    constructor(address _coreAddress, address _paymentToken) {
        coreContract = Core(_coreAddress);
        paymentToken = _paymentToken;
        owner = msg.sender;
    }

    // --- Admin Functions ---

    /**
     * @dev Creates a new subscription tier.
     */
    function createSubscriptionTier(uint256 _tierId, uint256 _price, uint256 _duration) external onlyOwner {
        require(!subscriptionTiers[_tierId].isActive, "Tier already exists");
        subscriptionTiers[_tierId] = SubscriptionTier({
            price: _price,
            duration: _duration,
            isActive: true
        });
        emit SubscriptionTierCreated(_tierId, _price, _duration);
    }

    // --- Subscription Functions ---

    /**
     * @dev Subscribes a user to a specific tier.
     * The user must approve this contract to spend the payment token.
     */
    function subscribe(uint256 _tierId) external {
        require(coreContract.isUserRegistered(msg.sender), "User not registered");
        SubscriptionTier storage tier = subscriptionTiers[_tierId];
        require(tier.isActive, "Subscription tier not active");

        IERC20 token = IERC20(paymentToken);
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= tier.price, "Check token allowance for subscription");
        
        // Take payment
        bool success = token.transferFrom(msg.sender, owner, tier.price);
        require(success, "Payment transfer failed");

        uint256 newExpiry = block.timestamp + tier.duration;

        // If user already has an active subscription, extend it
        if (userSubscriptions[msg.sender].expiresAt > block.timestamp) {
            newExpiry = userSubscriptions[msg.sender].expiresAt + tier.duration;
        }

        userSubscriptions[msg.sender] = UserSubscription({
            tier: _tierId,
            expiresAt: newExpiry
        });

        emit Subscribed(msg.sender, _tierId, newExpiry);
    }

    /**
     * @dev Checks if a user's subscription is currently active.
     */
    function isSubscriptionActive(address _user) external view returns (bool) {
        return userSubscriptions[_user].expiresAt > block.timestamp;
    }

    /**
     * @dev Get subscription details for a user
     */
    function getSubscriptionDetails(address _user) external view returns (uint256 tier, uint256 expiresAt) {
        return (userSubscriptions[_user].tier, userSubscriptions[_user].expiresAt);
    }

    /**
     * @dev Get subscription tier details
     */
    function getSubscriptionTier(uint256 _tierId) external view returns (uint256 price, uint256 duration, bool isActive) {
        SubscriptionTier storage tier = subscriptionTiers[_tierId];
        return (tier.price, tier.duration, tier.isActive);
    }
}
