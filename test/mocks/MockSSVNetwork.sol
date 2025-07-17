// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { MockBeaconChain } from "test/mocks/MockBeaconChain.sol";

contract MockSSVNetwork {
    mapping(bytes => bool) public isRegisteredValidator;

    MockBeaconChain public beaconChain;

    struct Cluster {
        uint32 validatorCount;
        uint64 networkFeeIndex;
        uint64 index;
        bool active;
        uint256 balance;
    }

    function setBeaconChain(
        address _beaconChain
    ) external {
        beaconChain = MockBeaconChain(_beaconChain);
    }

    function registerValidator(
        bytes calldata publicKey,
        uint64[] calldata operatorIds,
        bytes calldata sharesData,
        uint256 amount,
        Cluster memory cluster
    ) external {
        isRegisteredValidator[publicKey] = true;

        // Register the validator in the mock beacon chain
        beaconChain.addValidator(sha256(abi.encodePacked(publicKey, bytes16(0))));
        // Mine a new block to simulate the registration
        beaconChain.mine(); // Simulate a block to register the validator

        // Silent unused variable warnings
        operatorIds;
        sharesData;
        amount;
        cluster;
    }

    function removeValidator(bytes memory publicKey, uint64[] memory operatorIds, Cluster memory cluster) external {
        // Todo: Implement the logic for removing a validator
    }

    function withdraw(uint64[] memory operatorIds, uint256 amount, Cluster memory cluster) external {
        // Todo: Implement the logic for withdrawing SSV tokens
    }
}
