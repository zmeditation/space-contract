// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.5;

abstract contract IEstateRegistry {
    function ownerOf(uint256 tokenId) public view virtual returns (address owner); // from ERC721
}