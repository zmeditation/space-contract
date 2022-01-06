// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.5;

import "../Storage.sol";
import "../erc821/FullAssetRegistry.sol";
import "./ISPACERegistry.sol";
import "../proxy/Ownable.sol";

contract SPACERegistry is Storage, Ownable, FullAssetRegistry, ISPACERegistry {
    function initialize(bytes calldata) external {
        _name = "Unicial SPACE";
        _symbol = "UNIS";
        _description = "Contract that stores the Unicial Space registry";
    }

    modifier onlyProxyOwner() {
        require(msg.sender == proxyOwner, "UNICIAL: This function can only be called by the proxy owner");
        _;
    }

    modifier onlyDeployer() {
        require(
            msg.sender == proxyOwner || authorizedDeploy[msg.sender],
            "UNICIAL: This function can only be called by an authorized deployer"
        );
        _;
    }

    modifier onlyOwnerOf(uint256 assetId) {
        require(msg.sender == _ownerOf(assetId), "UNICIAL: This function can only be called by the owner of the asset");
        _;
    }

    // =========================================================================
    // *********************  SPACE creating modules  **************************
    // =========================================================================

    function assignNewRood(int x, int y, address beneficiary) external override onlyDeployer {
        _generate(_encodeTokenId(x, y), beneficiary);
        _updateSpaceBalance(address(0), beneficiary);
    }

    function assignMultipleRoods(int[] memory x, int[] memory y, address beneficiary) external override onlyDeployer {
        for (uint i = 0; i < x.length; i++) {
            _generate(_encodeTokenId(x[i], y[i]), beneficiary);
            _updateSpaceBalance(address(0), beneficiary);
        }
    }

    // ==========================================================================
    // *********************  SPACE getter functions  ***************************
    // ==========================================================================

    function encodeTokenId(int x, int y) external pure override returns (uint) {
        return _encodeTokenId(x, y);
    }

    function _encodeTokenId(int x, int y) internal pure returns (uint result) {
        require(
            -1000000 < x && x < 1000000 && -1000000 < y && y < 1000000,
            "UNICIAL: The coordinates should be inside bounds"
        );
        
        return ((uint(x) * factor) & clearLow) | (uint(y) & clearHigh);
    }

    function decodeTokenId(uint value) external pure override returns (int, int) {
        return _decodeTokenId(value);
    }

    function _decodeTokenId(uint value) internal pure returns (int x, int y) {
        x = expandNegative128BitCast((value & clearLow) >> 128);
        y = expandNegative128BitCast(value & clearHigh);

        require(
            -1000000 < x && x < 1000000 && -1000000 < y && y < 1000000,
            "UNICIAL: The coordinates should be inside bounds"
        );
    }

    function expandNegative128BitCast(uint value) internal pure returns (int) {
        if (value & (1<<127) != 0) {
            return int(value | clearLow);
        }
        return int(value);
    }

    function _exists(int x, int y) internal view returns (bool) {
        return _exists(_encodeTokenId(x, y));
    }

    function exists(int x, int y) external view override returns (bool) {
        return _exists(x, y);
    }

    function _ownerOfSpace(int x, int y) internal view returns (address) {
        return _ownerOf(_encodeTokenId(x, y));
    }

    function ownerOfSpace(int x, int y) external view override returns (address) {
        return _ownerOfSpace(x, y);
    }

    function ownerOfSpaceMany(int[] memory x, int[] memory y) external view override returns (address[] memory) {
        require(x.length > 0, "UNICIAL: You should supply at least one coordinate");
        require(x.length == y.length, "UNICIAL: The coordinates should have the same length");

        address[] memory addresses = new address[](x.length);

        for (uint i = 0; i < x.length; i++) {
            addresses[i] = _ownerOfSpace(x[i], y[i]);
        }

        return addresses;
    }

    function spaceOf(address owner) external view override returns (int[] memory, int[] memory) {
        uint256 length = _assetsOf[owner].length;
        int[] memory x = new int[](length);
        int[] memory y = new int[](length);

        for (uint i = 0; i < length; i++) {
            (x[i], y[i]) = _decodeTokenId(_assetsOf[owner][i]);
        }

        return (x, y);
    }

    // ==========================================================================
    // ***************************  SPACE Transfer  *****************************
    // ==========================================================================

    function transferFrom(address from, address to, uint256 assetId) external override {
        require(to != address(estateRegistry), "UNICIAL: EstateRegistry transfers are not allowed");

        return _doTransferFrom(from, to, assetId, "", false);
    }

    function transferSpace(int x, int y, address to) external {
        uint256 tokenId = _encodeTokenId(x, y);
        _doTransferFrom(_ownerOf(tokenId), to, tokenId, "", true);
    }

    function transferSpaceMany(int[] memory x, int[] memory y, address to) external {
        require(x.length > 0, "UNICIAL: You should supply at least one coordinate");
        require(x.length == y.length, "UNICIAL: The coordinates should have the same length");

        for (uint i = 0; i < x.length; i++) {
            uint256 tokenId = _encodeTokenId(x[i], y[i]);
            _doTransferFrom(_ownerOf(tokenId), to, tokenId, "", true);
        }
    }

    function transferSpaceToEstate(int x, int y, uint256 estateId) external {
        require(estateRegistry.ownerOf(estateId) == msg.sender, 
        "UNICIAL: You must own the estate you want to transfer to");

        uint256 tokenId = _encodeTokenId(x, y);
        _doTransferFrom(_ownerOf(tokenId), address(estateRegistry), tokenId, toBytes(estateId), true);
    }

    function transferSpaceManyToEstate(int[] memory x, int[] memory y, uint256 estateId) external {
        require(x.length > 0, "UNICIAL: You should supply at least one coordinate");
        require(x.length == y.length, "UNICIAL: The coordinates should have the same length");

        require(estateRegistry.ownerOf(estateId) == msg.sender, 
        "UNICIAL: You must own the estate you want to transfer to");

        for (uint i = 0; i < x.length; i++) {
            uint256 tokenId = _encodeTokenId(x[i], y[i]);
            _doTransferFrom(_ownerOf(tokenId), address(estateRegistry), tokenId, toBytes(estateId), true);
        }
    }

    function toBytes(uint256 x) internal pure returns (bytes memory b) {
        b = new bytes(32);
        assembly { 
            mstore(add(b, 32), x) 
        }
    }

    // ===========================================================================
    // *****************************  SPACE Update  ******************************
    // ===========================================================================

    function _updateSpaceData(int x, int y, string memory data) internal {
        uint256 assetId = _encodeTokenId(x, y);
        address owner = _holderOf[assetId];

        _update(assetId, data);

        emit Update(assetId, owner, msg.sender, data);
    }

    function updateSpaceData(int x, int y, string memory data) external {
        _updateSpaceData(x, y, data);
    }

    function updateManySpaceData(int[] memory x, int[] memory y, string memory data) external {
        require(x.length > 0, "UNICIAL: You should supply at least one coordinate");
        require(x.length == y.length, "UNICIAL: The coordinates should have the same length");

        for (uint i = 0; i < x.length; i++) {
            _updateSpaceData(x[i], y[i], data);
        }
    }

    // ===========================================================================
    // ************************  Proxy Manager Functions  ************************
    // ===========================================================================

    /**
     * @dev Set a new space balance minime token
     * @param _newSpaceBalance address of the new space balance token
     */
    function setSpaceBalanceToken(address _newSpaceBalance) onlyProxyOwner external {
        require(_newSpaceBalance != address(0), "UNICIAL: New spaceBalance should not be zero address");
        emit SetSpaceBalanceToken(address(spaceBalance), _newSpaceBalance);
        spaceBalance = IMiniMeToken(_newSpaceBalance);
    }

    // ===========================================================================
    // **************************  Proxy Authorization  **************************
    // ===========================================================================

    function _isUpdateAuthorized(address operator, uint256 assetId) internal view returns (bool) {
        address owner = _ownerOf(assetId);

        return owner == operator || updateOperator[assetId] == operator || updateManager[owner][operator];
    }

    function isUpdateAuthorized(address operator, uint256 assetId) external view returns (bool) {
        return _isUpdateAuthorized(operator, assetId);
    }

    function authorizeDeploy(address beneficiary) external onlyProxyOwner {
        require(beneficiary != address(0), "invalid address");
        require(authorizedDeploy[beneficiary] == false, "address is already authorized");

        authorizedDeploy[beneficiary] = true;
        emit DeployAuthorized(msg.sender, beneficiary);
    }

    function forbidDeploy(address beneficiary) external onlyProxyOwner {
        require(beneficiary != address(0), "invalid address");
        require(authorizedDeploy[beneficiary], "address is already forbidden");

        authorizedDeploy[beneficiary] = false;
        emit DeployForbidden(msg.sender, beneficiary);
    }

    // ===========================================================================
    // *************************  Proxy Other Functions  *************************
    // ===========================================================================

    function registerBalance() external {
        require(!registeredBalance[msg.sender], "UNICIAL: Register Balance::The user is already registered");

        // Get balance of the sender
        uint256 currentBalance = spaceBalance.balanceOf(msg.sender);
        if (currentBalance > 0) {
            require(spaceBalance.destroyTokens(msg.sender, currentBalance), 
            "UNICIAL: Register Balance::Could not destroy tokens");
        }

        // Set balance as registered
        registeredBalance[msg.sender] = true;

        // Get SPACE balance
        uint256 newBalance = _balanceOf(msg.sender);

        // Generate Tokens
        require(spaceBalance.generateTokens(msg.sender, newBalance),
            "UNICIAL: Register Balance::Could not generate tokens");
    }

    function unregisterBalance() external {
        require(registeredBalance[msg.sender], "UNICIAL: Unregister Balance::The user not registered");

        // Set balance as unregistered
        registeredBalance[msg.sender] = false;

        // Get balance
        uint256 currentBalance = spaceBalance.balanceOf(msg.sender);

        // Destroy Tokens
        require(spaceBalance.destroyTokens(msg.sender, currentBalance),
            "UNICIAL: Unregister Balance::Could not destroy tokens");
    }

    function _doTransferFrom(address from, address to, uint256 assetId, bytes memory userData, bool doCheck) internal override {
        updateOperator[assetId] = address(0);
        _updateSpaceBalance(from, to);

        super._doTransferFrom(from, to, assetId, userData, doCheck);
    }

    /**
     * @dev Update account balances
     * @param _from account
     * @param _to account
     */
    function _updateSpaceBalance(address _from, address _to) internal {
        if (registeredBalance[_from]) {
            spaceBalance.destroyTokens(_from, 1);
        }

        if (registeredBalance[_to]) {
            spaceBalance.generateTokens(_to, 1);
        }
    }
}