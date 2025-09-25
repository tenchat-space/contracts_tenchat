// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Core
 * @dev The central contract for TenChat, managing user profiles,
 * contract registry, and platform-wide settings.
 */
contract Core is Ownable {
    // --- Events ---

    event UserRegistered(address indexed userAddress, string username);
    event UserProfileUpdated(address indexed userAddress, string newUsername);
    event ContractAddressUpdated(string indexed name, address indexed newAddress);

    // --- State Variables ---

    // Mapping from user addresses to their profiles
    mapping(address => UserProfile) public userProfiles;
    // Mapping from usernames to user addresses for uniqueness
    mapping(string => address) private usernameToAddress;

    // Struct to hold user profile data
    struct UserProfile {
        string username;
        bool isRegistered;
    }

    // Registry for other contracts in the TenChat ecosystem
    mapping(bytes32 => address) private contractRegistry;

    // --- Constructor ---

    constructor() Ownable(msg.sender) {}

    // --- User Management Functions ---

    /**
     * @dev Registers a new user on the TenChat platform.
     * Usernames must be unique.
     */
    function registerUser(string calldata _username) external {
        require(!userProfiles[msg.sender].isRegistered, "User already registered");
        require(bytes(_username).length > 0, "Username cannot be empty");
        require(usernameToAddress[_username] == address(0), "Username is taken");

        userProfiles[msg.sender] = UserProfile({
            username: _username,
            isRegistered: true
        });
        usernameToAddress[_username] = msg.sender;

        emit UserRegistered(msg.sender, _username);
    }

    /**
     * @dev Updates the username for the calling user.
     * New username must be unique.
     */
    function updateUsername(string calldata _newUsername) external {
        require(userProfiles[msg.sender].isRegistered, "User not registered");
        require(bytes(_newUsername).length > 0, "New username cannot be empty");
        require(usernameToAddress[_newUsername] == address(0), "New username is taken");

        string memory oldUsername = userProfiles[msg.sender].username;
        usernameToAddress[oldUsername] = address(0); // Free up old username

        userProfiles[msg.sender].username = _newUsername;
        usernameToAddress[_newUsername] = msg.sender;

        emit UserProfileUpdated(msg.sender, _newUsername);
    }

    /**
     * @dev Checks if a user is registered.
     */
    function isUserRegistered(address _user) external view returns (bool) {
        return userProfiles[_user].isRegistered;
    }

    /**
     * @dev Gets a user's username by their address.
     */
    function getUsername(address _user) external view returns (string memory) {
        require(userProfiles[_user].isRegistered, "User not registered");
        return userProfiles[_user].username;
    }

    // --- Contract Registry Functions ---

    /**
     * @dev Sets the address of a core contract. Only callable by the owner.
     * @param _name The name of the contract (e.g., "EncryptedChat", "Gifting").
     * @param _address The address of the deployed contract.
     */
    function setContractAddress(string calldata _name, address _address) external onlyOwner {
        bytes32 contractName = keccak256(abi.encodePacked(_name));
        contractRegistry[contractName] = _address;
        emit ContractAddressUpdated(_name, _address);
    }

    /**
     * @dev Gets the address of a core contract by its name.
     */
    function getContractAddress(string calldata _name) external view returns (address) {
        bytes32 contractName = keccak256(abi.encodePacked(_name));
        return contractRegistry[contractName];
    }
}
