// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

// Test imports
import { Modifiers } from "test/unit/Modifiers.sol";

// Origin Dollar
import { BeaconRoots } from "@origin-dollar/beacon/BeaconRoots.sol";

/// @title BeaconOracleTest
/// @notice Unit tests for the BeaconOracle contract.
contract BeaconOracleTest is Modifiers {
    //////////////////////////////////////////////////////
    /// --- PASSING TESTS
    //////////////////////////////////////////////////////
    function test_ParentBlockRoot() public view {
        BeaconRoots.parentBlockRoot(uint64(block.timestamp) - 12);
    }

    //////////////////////////////////////////////////////
    /// --- REVERTING TESTS
    //////////////////////////////////////////////////////
}
