// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

// Foundry
import { Test } from "@forge-std/Test.sol";

// ERC
import { WETH } from "@solmate/tokens/WETH.sol";
import { ERC20 } from "@solmate/tokens/ERC20.sol";

// Origin Dollar
import { CompoundingStakingSSVStrategy } from
    "@origin-dollar/strategies/NativeStaking/CompoundingStakingSSVStrategy.sol";
import { CompoundingStakingSSVStrategyProxy } from "@origin-dollar/proxies/Proxies.sol";

// Mocks
import { MockSSVNetwork } from "test/mocks/MockSSVNetwork.sol";
import { MockBeaconChain } from "test/mocks/MockBeaconChain.sol";
import { MockBeaconOracle } from "test/mocks/MockBeaconOracle.sol";
import { MockBeaconProofs } from "test/mocks/MockBeaconProofs.sol";
import { MockDepositContract } from "test/mocks/MockDepositContract.sol";
import { MockBeaconRootAddress } from "test/mocks/MockBeaconRootAddress.sol";
import { MockWithdrawalRequest } from "test/mocks/MockWithdrawalRequest.sol";
import { MockConsolidationStrategy } from "test/mocks/MockConsolidationStrategy.sol";

/// @title Base
/// @notice Abstract base contract defining shared state variables and contract instances for the test suite.
/// @dev    This contract serves as the foundation for all test contracts, providing:
///         - Contract instances (tokens, external dependencies)
///         - Address definitions (users, governance, deployers)
///         - No logic or setup should be included here, only state variable declarations
abstract contract Base is Test {
    //////////////////////////////////////////////////////
    /// --- CONTRACTS
    //////////////////////////////////////////////////////
    // ERC20 tokens
    WETH public weth;
    ERC20 public ssv;

    // Origin Dollar contracts
    CompoundingStakingSSVStrategy public strategy;
    CompoundingStakingSSVStrategyProxy public proxy;

    // Mocks
    MockSSVNetwork public mockSsvNetwork;
    MockBeaconChain public mockBeaconChain;
    MockBeaconOracle public mockBeaconOracle;
    MockBeaconProofs public mockBeaconProofs;
    MockDepositContract public mockDepositContract;
    MockBeaconRootAddress public mockBeaconRootAddress;
    MockWithdrawalRequest public mockWithdrawalRequest;
    MockConsolidationStrategy public mockConsolidationStrategy;

    address public vault;

    //////////////////////////////////////////////////////
    /// --- Governance, multisigs and EOAs
    //////////////////////////////////////////////////////
    address public alice;
    address public bobby;

    address public deployer;
    address public governor;
}
