// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.5;

import './IERC721Metadata.sol';
import './AssetRegistryStorage.sol';

contract ERC721Metadata is AssetRegistryStorage, IERC721Metadata {
  function name() external view override returns (string memory) {
    return _name;
  }
  function symbol() external view override returns (string memory) {
    return _symbol;
  }
  function description() external view override returns (string memory) {
    return _description;
  }
  function tokenMetadata(uint256 assetId) external view override returns (string memory) {
    return _assetData[assetId];
  }
  function _update(uint256 assetId, string memory data) internal {
    _assetData[assetId] = data;
  }
}
