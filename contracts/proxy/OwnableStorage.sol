// SPDX-License-Identifier: Apache-1.0
pragma solidity ^0.8.5;

contract OwnableStorage {
    address public _owner;
    
    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = msg.sender;
    }
}