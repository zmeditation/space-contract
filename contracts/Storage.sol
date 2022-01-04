// SPDX-License-Identifier: Apache-1.0
pragma solidity ^0.8.5;

import "./proxy/OwnableStorage.sol";
import "./proxy/ProxyStorage.sol";
import "./space/SPACEStorage.sol";

contract Storage is OwnableStorage, ProxyStorage, SPACEStorage {

}