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
    //////////////////////////////////////////////////////
    /// --- CONSTANTS
    //////////////////////////////////////////////////////
    Vm public vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    uint8 public constant TIME_BETWEEN_BLOCKS = 12; // seconds

    //////////////////////////////////////////////////////
    /// --- STRUCTS
    //////////////////////////////////////////////////////

    struct Block {
        // Data
        BlockData data;
        // Validators
        uint256[] validatorBalances; // Balances of registered validators
        bytes32[] validatorPubKeyHashes; // Public key hashes of registered validators
        // Deposits
        uint256 pendingDepositsLength; // Length of pending deposits
    }

    struct BlockData {
        uint64 timestamp;
        uint64 number;
        uint64 slot;
        bytes32 hash;
        bytes32 beaconRoot;
        bytes32 parentHash;
        bytes32 parentRoot;
    }

    struct PendingDeposit {
        bool isProcessed;
        uint64 blockNumber;
        uint256 amount;
        bytes32 pubKeyHash;
    }

    //////////////////////////////////////////////////////
    /// --- STATE VARIABLES
    //////////////////////////////////////////////////////

    // --- Beacon chain state --- //
    Block[] public blocks;
    PendingDeposit[] public pendingDeposits;
    uint64 public slot;

    // --- Mappings --- //
    mapping(uint64 => Block) public blockByNumber;
    mapping(uint64 => Block) public blockByTimestamp;
    mapping(bytes32 => Block) public blockByRoot;
    mapping(uint256 => Block) public blockBySlot;

    //////////////////////////////////////////////////////
    /// --- EVENTS
    //////////////////////////////////////////////////////
    event SlotProcessed(uint256 slot);
    event BlockRegistered(Block block);

    //////////////////////////////////////////////////////
    /// --- BEACON CHAIN FUNCTIONS
    //////////////////////////////////////////////////////
    function mine() public {
        // Create empty structs
        Block memory newBlock;
        BlockData memory newBlockData;

        // Fill the new block data
        if (blocks.length == 0) {
            // First block, no parent, so set parent hashes to a default value

            // Block data
            newBlockData.timestamp = uint64(block.timestamp);
            newBlockData.number = uint64(block.number);
            newBlockData.slot = 0; // Start at slot 0
            newBlockData.hash = keccak256(abi.encodePacked(block.number, block.timestamp));
            newBlockData.beaconRoot = keccak256(abi.encodePacked(newBlockData.slot, block.timestamp));
            newBlockData.parentHash = bytes32(bytes1(0x01)); // As there is no parent block
            newBlockData.parentRoot = bytes32(bytes1(0x01)); // As there is no parent block

            // Block
            newBlock.data = newBlockData;
        } else {
            // Fill the new block data based on the last block
            Block memory lastBlock = blocks[blocks.length - 1];

            // Block data
            newBlockData.timestamp = uint64(block.timestamp);
            newBlockData.number = uint64(block.number);
            newBlockData.slot = slot;
            newBlockData.hash = keccak256(abi.encodePacked(block.number, block.timestamp));
            newBlockData.beaconRoot = keccak256(abi.encodePacked(newBlockData.slot, block.timestamp));
            newBlockData.parentHash = lastBlock.data.hash; // Previous block's hash
            newBlockData.parentRoot = lastBlock.data.beaconRoot; // Previous block's root

            // Push all to the new block
            newBlock.data = newBlockData;

            // Validators
            // Todo: increase balance of validators to simulated validator rewards
            newBlock.validatorBalances = lastBlock.validatorBalances;
            newBlock.validatorPubKeyHashes = lastBlock.validatorPubKeyHashes;

            // Pending deposits
            newBlock.pendingDepositsLength = lastBlock.pendingDepositsLength;
        }
        blocks.push(newBlock);

        uint256 len = blocks.length;

        // Update mappings
        blockBySlot[uint256(slot)] = blocks[len - 1];
        blockByNumber[uint64(block.number)] = blocks[len - 1];
        blockByTimestamp[uint64(block.timestamp)] = blocks[len - 1];
        blockByRoot[blocks[len - 1].data.beaconRoot] = blocks[len - 1];

        emit BlockRegistered(blocks[len - 1]);

        // Increase block timestamp and number
        vm.warp(block.timestamp + TIME_BETWEEN_BLOCKS);
        vm.roll(block.number + 1);
        slot++;
        emit SlotProcessed(slot);
    }

    function processEmptySlot() external {
        // This function is used to process an empty slot, i.e. a slot where no block was proposed.
        // It simply increases the slot number without creating a new block.
        slot++;
        emit SlotProcessed(slot);
    }

    function queueDeposit(uint256 amount, bytes32 pubKeyHash) external {
        // Ensure the validator exist
        require(contains(blocks[blocks.length - 1].validatorPubKeyHashes, pubKeyHash), "Validator does not exist");

        // Queued deposit
        pendingDeposits.push(
            PendingDeposit({
                isProcessed: false,
                amount: amount,
                blockNumber: uint64(block.number),
                pubKeyHash: pubKeyHash
            })
        );
        blocks[blocks.length - 1].pendingDepositsLength++;
    }

    function processAllDeposits() external {
        for (uint256 i; i < pendingDeposits.length; i++) {
            Block storage lastBlock = blocks[blocks.length - 1];
            PendingDeposit storage deposit = pendingDeposits[i];
            uint256 index = indexOf(lastBlock.validatorPubKeyHashes, deposit.pubKeyHash);
            // Increase the balance of the validator
            deposit.isProcessed = true;
            lastBlock.validatorBalances[index] += deposit.amount;
        }
        delete pendingDeposits; // Clear the pending deposits
        delete blocks[blocks.length - 1].pendingDepositsLength; // Reset the pending deposits length
    }

    function addValidator(
        bytes32 pubKeyHash
    ) external {
        // Ensure the validator does not already exist
        require(!contains(blocks[blocks.length - 1].validatorPubKeyHashes, pubKeyHash), "Validator already exists");

        // Add the validator
        blocks[blocks.length - 1].validatorPubKeyHashes.push(pubKeyHash);
        blocks[blocks.length - 1].validatorBalances.push(0); // Initialize balance to 0
    }

    //////////////////////////////////////////////////////
    /// --- VIEWS FUNCTIONS
    //////////////////////////////////////////////////////
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

    function getBlockByRoot(
        bytes32 root
    ) external view returns (Block memory) {
        return blockByRoot[root];
    }

    function getBlockBySlot(
        uint256 slotNumber
    ) external view returns (Block memory) {
        return blockBySlot[slotNumber];
    }

    function getPendingDeposits() external view returns (PendingDeposit[] memory) {
        return pendingDeposits;
    }

    function getPendingDepositsLength() external view returns (uint256) {
        return pendingDeposits.length;
    }

    function getLatestBlock() external view returns (Block memory) {
        require(blocks.length > 0, "No blocks available");
        return blocks[blocks.length - 1];
    }

    //////////////////////////////////////////////////////
    /// --- HELPERS
    //////////////////////////////////////////////////////
    function indexOf(bytes32[] memory array, bytes32 value) internal pure returns (uint256) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == value) return i;
        }
        return type(uint256).max; // Return max value if not found
    }

    function contains(bytes32[] memory array, bytes32 value) internal pure returns (bool) {
        return indexOf(array, value) != type(uint256).max;
    }
}
