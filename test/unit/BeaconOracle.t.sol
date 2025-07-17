// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

// Test imports
import { Modifiers } from "test/unit/Modifiers.sol";

/// @title BeaconOracleTest
/// @notice Unit tests for the BeaconOracle contract.
contract BeaconOracleTest is Modifiers {
    //////////////////////////////////////////////////////
    /// --- PASSING TESTS
    //////////////////////////////////////////////////////
    function test_BeaconOracle_VerifySlot_WhenSlotAndBlockAreSync() public {
        assertFalse(mockBeaconOracle.isBlockMapped(uint64(block.number - 2)), "Block should not be mapped");
        assertFalse(mockBeaconOracle.isSlotMapped(uint64(mockBeaconChain.slot() - 2)), "Slot should not be mapped");

        mockBeaconOracle.verifySlot(
            uint64(block.timestamp - 12),
            uint64(block.number - 2),
            uint64(mockBeaconChain.slot() - 2),
            new bytes(0),
            new bytes(0)
        );

        assertTrue(mockBeaconOracle.isBlockMapped(uint64(block.number - 2)), "Block should be mapped");
        assertTrue(mockBeaconOracle.isSlotMapped(uint64(mockBeaconChain.slot() - 2)), "Slot should be mapped");
        assertEq(
            mockBeaconOracle.blockToSlot(uint64(block.number - 2)),
            uint64(mockBeaconChain.slot() - 2),
            "Block to slot mapping mismatch"
        );
        assertEq(
            mockBeaconOracle.slotToBlock(uint64(mockBeaconChain.slot() - 2)),
            uint64(block.number - 2),
            "Slot to block mapping mismatch"
        );
        assertEq(
            mockBeaconOracle.slotToRoot(uint64(mockBeaconChain.slot() - 2)),
            mockBeaconChain.getBlockByTimestamp(uint64(block.timestamp - 12)).data.parentRoot,
            "Slot to root mapping mismatch"
        );
    }

    function test_BeaconOracle_VerifySlot_WhenSlotAndBlockAreNotSync() public {
        assertFalse(mockBeaconOracle.isBlockMapped(uint64(block.number - 2)), "Block should not be mapped");
        assertFalse(mockBeaconOracle.isSlotMapped(uint64(mockBeaconChain.slot() - 2)), "Slot should not be mapped");

        mockBeaconChain.processEmptySlot(); // Process an empty slot to simulate a slot without a block
        mockBeaconChain.mine(); // Mine a new block to create a new slot

        mockBeaconOracle.verifySlot(
            uint64(block.timestamp - 12),
            uint64(block.number - 2),
            uint64(mockBeaconChain.slot() - 3),
            new bytes(0),
            new bytes(0)
        );

        assertTrue(mockBeaconOracle.isBlockMapped(uint64(block.number - 2)), "Block should be mapped");
        assertTrue(mockBeaconOracle.isSlotMapped(uint64(mockBeaconChain.slot() - 3)), "Slot should be mapped");
        assertEq(
            mockBeaconOracle.blockToSlot(uint64(block.number - 2)),
            uint64(mockBeaconChain.slot() - 3),
            "Block to slot mapping mismatch"
        );
        assertEq(
            mockBeaconOracle.slotToBlock(uint64(mockBeaconChain.slot() - 3)),
            uint64(block.number - 2),
            "Slot to block mapping mismatch"
        );
        assertEq(
            mockBeaconOracle.slotToRoot(uint64(mockBeaconChain.slot() - 3)),
            mockBeaconChain.getBlockByTimestamp(uint64(block.timestamp - 12)).data.parentRoot,
            "Slot to root mapping mismatch"
        );
    }
}
