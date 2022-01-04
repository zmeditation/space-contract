// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.5;

interface IERC721Receiver {
  function onERC721Received(
    address _operator,
    address _from,
    uint256 _tokenId,
    bytes calldata   _userData
  ) external returns (bytes4);
}
