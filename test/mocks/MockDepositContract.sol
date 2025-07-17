// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { MockBeaconChain } from "test/mocks/MockBeaconChain.sol";

contract MockDepositContract {
    MockBeaconChain public beaconChain;

    constructor(
        MockBeaconChain _beaconChain
    ) {
        beaconChain = _beaconChain;
    }

    function deposit(bytes calldata pubkey, bytes calldata, bytes calldata, bytes32) external payable {
        beaconChain.queueDeposit(msg.value, sha256(abi.encodePacked(pubkey, bytes16(0))));
    }

    receive() external payable { }
}
