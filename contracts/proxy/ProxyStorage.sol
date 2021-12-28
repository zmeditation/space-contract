// SPDX-License-Identifier: Apache-1.0
pragma solidity ^0.8.5;

import "./IApplication.sol";

contract ProxyStorage {
    address public currentContract;
    address public proxyOwner;
}