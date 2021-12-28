// SPDX-License-Identifier: Apache-1.0
pragma solidity ^0.8.5;

contract DelegateProxy {
    function delegateForward(address _dst, bytes calldata _calldata) internal {
        require(isContract(_dst), "The destination address is not a contract");

        assembly {
            let result := delegatecall(sub(gas(), 10000), _dst, add(_calldata.offset, 0x20), mload(_calldata.offset), 0, 0)
            let size := returndatasize()

            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)

            switch result case 0 { revert(ptr, size) }
            default { return(ptr, size) }
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