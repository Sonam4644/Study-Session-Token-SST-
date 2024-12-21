// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StudySessionToken {
    string public name = "StudyToken";
    string public symbol = "STT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public studySessionsHosted;
    mapping(address => uint256) public rewards;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event SessionHosted(address indexed host, uint256 rewardAmount);

    // Owner of the contract (could be an admin or the project team)
    address public owner;

    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        totalSupply = _initialSupply * 10 ** uint256(decimals);
        balanceOf[owner] = totalSupply;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can execute this");
        _;
    }

    modifier validSession() {
        require(msg.sender != address(0), "Invalid address");
        _;
    }

    // Host a study session and earn tokens
    function hostStudySession(uint256 rewardAmount) external validSession {
        require(rewardAmount > 0, "Reward must be greater than 0");

        // Increase the host's study sessions count and reward
        studySessionsHosted[msg.sender]++;
        rewards[msg.sender] += rewardAmount;

        // Transfer reward tokens to the host
        require(balanceOf[owner] >= rewardAmount, "Not enough tokens to distribute");
        balanceOf[owner] -= rewardAmount;
        balanceOf[msg.sender] += rewardAmount;

        emit SessionHosted(msg.sender, rewardAmount);
    }

    // Allow users to transfer tokens (standard ERC20 transfer logic)
    function transfer(address to, uint256 amount) external validSession returns (bool) {
        require(to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");

        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    // Return total balance of a user
    function getBalance(address user) external view returns (uint256) {
        return balanceOf[user];
    }

    // Allow the owner to mint new tokens if necessary
    function mintTokens(uint256 amount) external onlyOwner {
        totalSupply += amount;
        balanceOf[owner] += amount;
    }

    // Allow the owner to burn tokens (e.g., in case of excess minting)
    function burnTokens(uint256 amount) external onlyOwner {
        require(balanceOf[owner] >= amount, "Not enough tokens to burn");
        totalSupply -= amount;
        balanceOf[owner] -= amount;
    }
}
