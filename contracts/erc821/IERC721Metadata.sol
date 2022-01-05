// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.5;

interface IERC721Metadata {

  /**
   * @notice A descriptive name for a collection of NFTs in this contract
   */
  function name() external view returns (string memory);

  /**
   * @notice An abbreviated name for NFTs in this contract
   */
  function symbol() external view returns (string memory);

  /**
   * @notice A description of what this DAR is used for
   */
  function description() external view returns (string memory);

  /**
   * Stores arbitrary info about a token
   */
  function tokenMetadata(uint256 assetId) external view returns (string memory);
}
