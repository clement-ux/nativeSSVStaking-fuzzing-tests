// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

contract MockDepositContract {
    function deposit(
        bytes calldata pubkey,
        bytes calldata withdrawalCredentials,
        bytes calldata signature,
        bytes32 depositDataRoot
    ) external payable { }

    receive() external payable { }
}
