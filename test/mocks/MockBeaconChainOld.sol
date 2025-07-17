// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

// Foundry imports
import { Vm } from "@forge-std/Vm.sol";

/// @title BeaconChain
/// @notice This contract aims to replicate the behavior of the Beacon chain (i.e. validator management etc.)
/// @dev The goal is to update this contract every time we mint a new block on the execution layer.
/// ** ** ** ** ** **
/// Quick recap for slot and blocks:
/// - A slot is a period of time in which a validator can propose a block.
/// - A block is a collection of transactions that are processed and added to the blockchain.
/// - The slot is incremented every 12 seconds, which is the time it takes to produce a new block on the Beacon chain.
/// - The block number is incremented every time a new block is mined on the execution layer.
/// - Block number are consecutive and start at 0.
/// - Slots are not consecutive, they can be skipped if no block is proposed in a slot
contract MockBeaconChain {
    Vm public vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    uint8 public constant TIME_BETWEEN_BLOCKS = 12; // seconds

    uint64 public slot;

    struct Block {
        uint64 timestamp;
        uint64 number;
        uint64 slot;
        bytes32 hash;
        bytes32 stateRoot;
        bytes32 parentHash;
        bytes32 parentRoot;
        bytes32[] pubKeyHashes;
        uint256[] validatorBalances;
    }

    Block[] public blocks;

    mapping(uint64 => Block) public blockByNumber;
    mapping(uint64 => Block) public blockByTimestamp;
    mapping(uint256 => Block) public blockBySlot;
    mapping(bytes32 => Block) public blockByRoot;

    function mine() public {
        // Create a new block
        Block memory newBlock = Block({
            timestamp: uint64(block.timestamp),
            number: uint64(block.number),
            slot: slot,
            hash: keccak256(abi.encodePacked(block.number, block.timestamp)),
            stateRoot: keccak256(abi.encodePacked(slot, block.timestamp)), // Placeholder for state root
            parentHash: blocks.length > 0 ? blocks[blocks.length - 1].hash : bytes32(bytes1(0x01)),
            parentRoot: blocks.length > 0 ? blocks[blocks.length - 1].hash : bytes32(bytes1(0x01)),
            pubKeyHashes: new bytes32[](0), // Placeholder for pubKeyHashes
            validatorBalances: new uint256[](0) // Placeholder for validatorBalances
         });

        // Push an empty block, then fill it
        blocks.push(newBlock);

        // Update mappings
        blockByNumber[uint64(block.number)] = blocks[blocks.length - 1];
        blockByTimestamp[uint64(block.timestamp)] = blocks[blocks.length - 1];
        blockBySlot[0] = blocks[blocks.length - 1]; // Placeholder for slot
        blockByRoot[blocks[blocks.length - 1].hash] = blocks[blocks.length - 1];

        // Increase block timestamp and number
        vm.warp(block.timestamp + TIME_BETWEEN_BLOCKS);
        vm.roll(block.number + 1);
        slot++;
    }

    function mineSlot() external {
        slot++;
    }

    function getBlockByNumber(
        uint64 number
    ) external view returns (Block memory) {
        return blockByNumber[number];
    }

    function getBlockByTimestamp(
        uint64 timestamp
    ) external view returns (Block memory) {
        return blockByTimestamp[timestamp];
    }

    function getBlockBySlot(
        uint256 slotNumber
    ) external view returns (Block memory) {
        return blockBySlot[slotNumber];
    }

    function getBlockByRoot(
        bytes32 root
    ) external view returns (Block memory) {
        return blockByRoot[root];
    }

    function contains(bytes32[] memory array, bytes32 value) internal pure returns (bool) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == value) return true;
        }
        return false;
    }

    function indexOf(bytes32[] memory array, bytes32 value) internal pure returns (uint256) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == value) return i;
        }
        revert("Value not found in array");
    }
}
