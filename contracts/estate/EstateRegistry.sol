// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.5;

// import "./IEstateRegistry.sol";
// import "./EstateStorage.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

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

    // =========================================================================
    // **************************  Estate Storage   ****************************
    // =========================================================================

    // SPACERegistry address
    ISPACERegistry public registry;

    // Metadat of the Estate
    mapping(uint256 => string) internal estateData;

    // Array with all token ids, used for enumeration
    uint256[] internal allTokens;

    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) internal ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) internal ownedTokensIndex;


    // =========================================================================
    // ***************************  Estate Events   ****************************
    // =========================================================================

    event CreateEstate(address indexed _owner, uint256 indexed _estateId, string _data);

    event AddSpace(uint256 indexed _estateId, uint256 indexed _spaceId);

    event RemoveSpace(uint256 indexed _estateId, uint256 indexed _spaceId, address indexed _destinatary);

    event Update(uint256 indexed _assetId, address indexed _holder, address indexed _operator, string _data);

    event UpdateOperator(uint256 indexed _estateId, address indexed _operator);

    event UpdateManager(address indexed _owner, address indexed _operator, address indexed _caller, bool _approved);

    event SetSpaceRegistry(address indexed _registry);

    event SetEstateSpaceBalanceToken(address indexed _previousEstateLandBalance, address indexed _newEstateLandBalance);

    // =========================================================================
    // *************************  Estate Librareis   ***************************
    // =========================================================================

    using SafeMathUpgradeable for uint256;

    modifier onlyRegistry() {
        require(msg.sender == address(registry), "Only the registry can make this operation");
        _;
    }

    function initialize(string memory _name, string memory _symbol, address _registry) public initializer {
        require(_registry != address(0), "UNICIAL: The registry should be a valid SPACERegistry address");

        ERC721Upgradeable.__ERC721_init(_name, _symbol);
        OwnableUpgradeable.__Ownable_init();
        registry = ISPACERegistry(_registry);
    }

    // =========================================================================
    // ***********************  Estate Token functions   ***********************
    // =========================================================================
    
    function totalSupply() public view returns (uint256) {
        return allTokens.length;
    }

    /**
      * @dev Gets the token ID at a given index of the tokens list of the requested owner
      * @param _owner address owning the tokens list to be accessed
      * @param _index uint256 representing the index to be accessed of the requested tokens list
      * @return uint256 token ID at the given index of the tokens list owned by the requested address
    */
    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {
        require(_index < balanceOf(_owner));
        return ownedTokens[_owner][_index];
    }

    // =========================================================================
    // *************  Estate mint and Space transfer functions   ***************
    // =========================================================================

    /**
      * @notice Get the last index of the token ID
      * @return New token ID
     */
    function _getNewEstateId() internal view returns (uint256) {
        return totalSupply().add(1);
    }

    /**
      * @dev Internal function to update an Estate metadata
      * @param estateId Estate id to update
      * @param metadata The content of metadata
     */
    function _updateMetadata(uint256 estateId, string memory metadata) internal {
        estateData[estateId] = metadata;
    }

    /**
      * @notice Mint a new Estate with metadata (internal function)
      * @param to The address that will own the minted token
      * @param metadata This is the meta data of minted Estate token
      * @return Estate token ID that minted as new
     */
    function _mintEstate(address to, string memory metadata) internal returns (uint256) {
        require(to != address(0), "UNICIAL: You can not mint a token to an empty address");

        uint256 estateId = _getNewEstateId();
        _mint(to, estateId);
        _updateMetadata(estateId, metadata);

        allTokens.push(estateId);

        uint256 length = ownedTokens[to].length;
        ownedTokens[to].push(estateId);
        ownedTokensIndex[estateId] = length;

        emit CreateEstate(to, estateId, metadata);

        return estateId;
    }

    /**
      * @notice Mint a new Estate with metadata
      * @param to The address that will own the minted token
      * @param metadata This is the meta data of minted Estate token
      * @return Estate token ID that minted as new
     */
    function mint(address to, string memory metadata) external onlyRegistry returns (uint256) {
        return _mintEstate(to, metadata);
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