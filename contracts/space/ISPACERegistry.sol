// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.5;

interface ISPACERegistry {
    // ======================================================
    // **********************  EVENTS  **********************
    // ======================================================

    event Update(uint256 indexed assetId, address indexed owner, address indexed operator, string data);
    event UpdateOperator(uint256 indexed assetId, address indexed operator);
}