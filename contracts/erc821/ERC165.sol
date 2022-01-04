// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.5;

interface ERC165 {
  function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
