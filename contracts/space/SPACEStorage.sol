// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.5;

import "../minimeToken/IMiniMeToken.sol";
import "../estate/IEstateRegistry.sol";

contract SPACEStorage {
    mapping (address => bool) public authorizedDeploy;

    // Registered balance accounts
    mapping(address => bool) public registeredBalance;

    // Space balance minime token
    IMiniMeToken public spaceBalance;

    uint256 constant clearLow = 0xffffffffffffffffffffffffffffffff00000000000000000000000000000000;
    uint256 constant clearHigh = 0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;
    uint256 constant factor = 0x100000000000000000000000000000000;

    // Estate registry contract
    IEstateRegistry public estateRegistry;

    mapping (uint256 => address) public updateOperator;
    mapping (address => mapping(address => bool)) public updateManager;
}