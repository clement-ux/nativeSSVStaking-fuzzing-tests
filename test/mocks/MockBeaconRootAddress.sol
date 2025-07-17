// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { MockBeaconChain } from "test/mocks/MockBeaconChain.sol";

contract MockBeaconRootAddress {
    MockBeaconChain public beaconChain;

    function setBeaconChain(
        address _beaconChain
    ) external {
        beaconChain = MockBeaconChain(_beaconChain);
    }

    fallback(
        bytes calldata data
    ) external returns (bytes memory) {
        return abi.encodePacked(beaconChain.getBlockByTimestamp(abi.decode(data, (uint64))).data.parentRoot);
    }
}
