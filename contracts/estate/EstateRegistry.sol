// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.5;

// import "./IEstateRegistry.sol";
// import "./EstateStorage.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";

interface ISPACERegistry {
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

contract EstateRegistry is Initializable, ERC721Upgradeable, IERC721ReceiverUpgradeable, OwnableUpgradeable {
    uint256 public x;
    bool private _initialized;
    ISPACERegistry public registry;

    modifier onlyRegistry() {
        require(msg.sender == address(registry), "Only the registry can make this operation");
        _;
    }

    function initialize(uint256 _x) public initializer {
        x = _x;
    }

    function increase() public {
        x += 1;
    }

    /**
      * @notice Handle the receipt of an NFT
      * @dev The ERC721 smart contract calls this function on the recipient
      * after a `safetransfer`. This function MAY throw to revert and reject the
      * transfer. Return of other than the magic value MUST result in the
      * transaction being reverted.
      * Note: the contract address is always the message sender.
      * @param _operator The address which called `safeTransferFrom` function
      * @param _from The address which previously owned the token
      * @param _tokenId The NFT identifier which is being transferred
      * @param _data Additional data with no specified format
      * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    */
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes memory _data
    )
        public
        override
        onlyRegistry
        returns (bytes4)
    {
        uint256 estateId = _bytesToUint(_data);
        // _pushLandId(estateId, _tokenId);
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    function _bytesToUint(bytes memory b) internal pure returns (uint256) {
        return uint256(_bytesToBytes32(b));
    }

    function _bytesToBytes32(bytes memory b) internal pure returns (bytes32) {
        bytes32 out;

        for (uint i = 0; i < b.length; i++) {
            out |= bytes32(b[i] & 0xFF) >> (i * 8);
        }

        return out;
    }
}