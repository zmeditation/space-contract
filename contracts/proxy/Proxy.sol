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
    function upgradeDelegate(IApplication newContract, bytes calldata data) public onlyProxyOwner {
        currentContract = address(newContract);
        IApplication(newContract).initialize(data);

        emit Upgrade(newContract, data);
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _fallback() internal virtual {
        _beforeFallback();

        require(currentContract != address(0), "If app code has not been set yet, do not call");
        delegateForward(currentContract);
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     *
     * If overriden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {}

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive() external payable virtual {
        _fallback();
    }
}