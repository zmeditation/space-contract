// SPDX-License-Identifier: Apache-1.0
pragma solidity ^0.8.5;

contract DelegateProxy {
    function delegateForward(address _dst) internal {
        require(isContract(_dst), "The destination address is not a contract");

        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _dst, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function isContract(address _addr) internal view returns (bool) {
        uint256 size;

        assembly {
            size := extcodesize(_addr)
        }

        return size > 0;
    }
}