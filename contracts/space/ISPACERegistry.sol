// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.5;

interface ISPACERegistry {
    // ======================================================
    // **********************  EVENTS  **********************
    // ======================================================

    event Update(uint256 indexed assetId, address indexed owner, address indexed operator, string data);
    event UpdateOperator(uint256 indexed assetId, address indexed operator);
    event SetSpaceBalanceToken(address indexed _previousSpaceBalance, address indexed _newSpaceBalance);
    event DeployAuthorized(address indexed _caller, address indexed _deployer);
    event DeployForbidden(address indexed _caller, address indexed _deployer);
    event EstateRegistrySet(address indexed registry);

    // ======================================================
    // ********************  FUNCTIONS  *********************
    // ======================================================

    // GETTERS
    function encodeTokenId(int x, int y) external pure returns (uint256);
    function decodeTokenId(uint value) external pure returns (int, int);
    function exists(int x, int y) external view returns (bool);
    function ownerOfSpace(int x, int y) external view returns (address);
    function ownerOfSpaceMany(int[] memory x, int[] memory y) external view returns (address[] memory);
    function spaceOf(address owner) external view returns (int[] memory, int[] memory);
    // function spaceData(int x, int y) external view returns (string memory);

    // CREATE SPACE
    function assignNewRood(int x, int y, address beneficiary) external;
    function assignMultipleRoods(int[] memory x, int[] memory y, address beneficiary) external;
}