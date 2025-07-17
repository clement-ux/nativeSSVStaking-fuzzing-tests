// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import { MockBeaconChain } from "test/mocks/MockBeaconChain.sol";

contract MockBeaconProofs {
    MockBeaconChain public beaconChain;

    function setBeaconChain(
        MockBeaconChain _beaconChain
    ) external {
        beaconChain = _beaconChain;
    }

    enum BalanceProofLevel {
        Container,
        BeaconBlock
    }

    /// @notice Verifies the validator public key against the beacon block root
    /// BeaconBlock.state.validators[validatorIndex].pubkey
    /// @param beaconBlockRoot The root of the beacon block
    /// @param pubKeyHash The beacon chain hash of the validator public key
    // @param validatorPubKeyProof The merkle proof for the validator public key to the beacon block root.
    /// This is the witness hashes concatenated together starting from the leaf node.
    /// @param validatorIndex The validator index
    function verifyValidatorPubkey(
        bytes32 beaconBlockRoot,
        bytes32 pubKeyHash,
        bytes calldata,
        uint64 validatorIndex
    ) public view {
        require(beaconChain.getBlockByRoot(beaconBlockRoot).validatorPubKeyHashes[validatorIndex] == pubKeyHash);
    }

    /// @notice Verifies the balances container against the beacon block root
    /// BeaconBlock.state.balances
    /// @param beaconBlockRoot The root of the beacon block
    /// @param balancesContainerLeaf The leaf node containing the balances container
    /// @param balancesContainerProof The merkle proof for the balances container to the beacon block root.
    /// This is the witness hashes concatenated together starting from the leaf node.
    function verifyBalancesContainer(
        bytes32 beaconBlockRoot,
        bytes32 balancesContainerLeaf,
        bytes calldata balancesContainerProof
    ) public view { }

    /// @notice Verifies the validator balance against the root of the Balances container
    /// or the beacon block root
    /// @param root The root of the Balances container or the beacon block root
    // @param validatorBalanceLeaf The leaf node containing the validator balance with three other balances
    // @param balanceProof The merkle proof for the validator balance against the root.
    /// This is the witness hashes concatenated together starting from the leaf node.
    /// @param validatorIndex The validator index to verify the balance for
    // @param level The level of the balance proof, either Container or BeaconBlock
    function verifyValidatorBalance(
        bytes32 root,
        bytes32,
        bytes calldata,
        uint64 validatorIndex,
        BalanceProofLevel
    ) public view returns (uint256 validatorBalance) {
        return beaconChain.getBlockByRoot(root).validatorBalances[validatorIndex];
    }

    /// @notice Verifies the slot of the first pending deposit against the beacon block root
    /// BeaconBlock.state.PendingDeposits[0].slot
    /// @param beaconBlockRoot The root of the beacon block
    // @param slot The beacon chain slot to verify
    // @param firstPendingDepositSlotProof The merkle proof for the first pending deposit's slot
    /// against the beacon block root.
    /// This is the witness hashes concatenated together starting from the leaf node.
    function verifyFirstPendingDepositSlot(bytes32 beaconBlockRoot, uint64, bytes calldata) public view {
        require(beaconChain.getBlockByRoot(beaconBlockRoot).pendingDepositsLength == 0, "No pending deposits");
    }

    /// @notice Verifies the block number to the the beacon block root
    /// BeaconBlock.body.executionPayload.blockNumber
    /// @param beaconBlockRoot The root of the beacon block
    /// @param blockNumber The execution layer block number to verify
    // @param blockNumberProof The merkle proof for the block number against the beacon block
    /// This is the witness hashes concatenated together starting from the leaf node.
    function verifyBlockNumber(bytes32 beaconBlockRoot, uint256 blockNumber, bytes calldata) public view {
        require(
            beaconChain.getBlockByNumber(uint64(blockNumber)).data.beaconRoot == beaconBlockRoot,
            "MockBeaconProof: Invalid block number proof"
        );
    }

    /// @notice Verifies the slot number against the beacon block root.
    /// BeaconBlock.slot
    /// @param beaconBlockRoot The root of the beacon block
    /// @param slot The beacon chain slot to verify
    // @param  The merkle proof for the slot against the beacon block root.
    /// This is the witness hashes concatenated together starting from the leaf node.
    function verifySlot(bytes32 beaconBlockRoot, uint256 slot, bytes calldata) public view {
        require(
            beaconChain.getBlockBySlot(slot).data.beaconRoot == beaconBlockRoot, "MockBeaconProof: Invalid slot proof"
        );
    }
}
