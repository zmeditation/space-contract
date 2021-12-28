// SPDX-License-Identifier: Apache-1.0
pragma solidity ^0.8.5;

import "../Storage.sol";
import "./Ownable.sol";
import "./DelegateProxy.sol";
import "./IApplication.sol";

contract Proxy is Storage, DelegateProxy, Ownable {
    
    event Upgrade(IApplication indexed newContract, bytes initializedWith);
    event OwnerUpdate(address _prevOwner, address _newOwner);

    constructor() {
        proxyOwner = msg.sender;
        _owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the proxy owner.
     */
    modifier onlyProxyOwner() {
        require(msg.sender == proxyOwner, "Proxy: Unauthorized user");
        _;
    }

    /**
     * @dev Throws if called by any account other than the proxy owner.
     * @param _newOwner new owner that will be owner of this proxy.
     */
    function transferOwnership(address _newOwner) public override onlyProxyOwner {
        require(_newOwner != address(0), "Proxy: Empty address");
        require(_newOwner != proxyOwner, "Proxy: Already authorized");

        emit OwnerUpdate(proxyOwner, _newOwner);
        proxyOwner = _newOwner;
    }

    /**
     * @dev Throws if called by any account other than the proxy owner.
     * @param newContract The address of the updated smart contract address.
     * @param data The initial data of parameter.
     */
    function upgrade(IApplication newContract, bytes calldata data) public onlyProxyOwner {
        currentContract = address(newContract);
        IApplication(newContract).initialize(data);

        emit Upgrade(newContract, data);
    }

    fallback() external payable {
        require(currentContract != address(0), "If app code has not been set yet, do not call");
        delegateForward(currentContract, msg.data);
    }
}