// SPDX-License-Identifier: Apache-1.0
pragma solidity ^0.8.5;

import "./IApplication.sol";

contract ProxyStorage {
    IApplication public currentContract;
    address public proxyOwner;
}