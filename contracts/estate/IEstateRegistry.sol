// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.5;

interface IEstateRegistry {
    function ownerOf(uint256 _tokenId) external view returns (address _owner); // from ERC721
}