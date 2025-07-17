// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

// Test imports
import { Base } from "test/Base.sol";

// Origin Dollar
import { InitializableAbstractStrategy } from "@origin-dollar/utils/InitializableAbstractStrategy.sol";
import { CompoundingStakingSSVStrategy } from
    "@origin-dollar/strategies/NativeStaking/CompoundingStakingSSVStrategy.sol";
import { CompoundingStakingSSVStrategyProxy } from "@origin-dollar/proxies/Proxies.sol";

// ERC
import { WETH } from "@solmate/tokens/WETH.sol";

// Mocks
import { MockERC20 } from "@solmate/test/utils/mocks/MockERC20.sol";
import { MockBeaconChain } from "test/mocks/MockBeaconChain.sol";
import { MockSSVNetwork } from "test/mocks/MockSSVNetwork.sol";
import { MockBeaconOracle } from "test/mocks/MockBeaconOracle.sol";
import { MockBeaconProofs } from "test/mocks/MockBeaconProofs.sol";
import { MockDepositContract } from "test/mocks/MockDepositContract.sol";
import { MockBeaconRootAddress } from "test/mocks/MockBeaconRootAddress.sol";
import { MockWithdrawalRequest } from "test/mocks/MockWithdrawalRequest.sol";
import { MockConsolidationStrategy } from "test/mocks/MockConsolidationStrategy.sol";

/// @title Setup
/// @notice Abstract contract responsible for test environment initialization and contract deployment.
/// @dev    This contract orchestrates the complete test setup process in a structured manner:
///         1. Environment configuration (block timestamp, number)
///         2. User address generation and role assignment
///         3. External contract deployment (mocks, dependencies)
///         4. Main contract deployment
///         5. System initialization and configuration
///         No test logic should be implemented here, only setup procedures.
abstract contract Setup is Base {
    address public constant BEACON_ROOTS_ADDRESS = 0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02;
    //////////////////////////////////////////////////////
    /// --- SETUP
    //////////////////////////////////////////////////////

    function setUp() public virtual {
        // 1. Setup a realistic test environnement.
        _setUpRealisticEnvironnement();

        // 2. Create user.
        _createUsers();

        // 3. Deploy external contracts.
        _deployExternal();

        // 4. Deploy contracts.
        _deployContracts();

        // 5. Initialize users and contracts.
        _initalize();
    }

    //////////////////////////////////////////////////////
    /// --- ENVIRONMENT
    //////////////////////////////////////////////////////
    function _setUpRealisticEnvironnement() internal {
        vm.warp(1_800_000_000);
        vm.roll(23_000_000);
    }

    //////////////////////////////////////////////////////
    /// --- USERS
    //////////////////////////////////////////////////////
    function _createUsers() internal {
        // Random users
        alice = makeAddr("Alice");
        bobby = makeAddr("Bobby");

        // Permissionned users
        deployer = makeAddr("Deployer");
        governor = makeAddr("Governor");
    }

    //////////////////////////////////////////////////////
    /// --- EXTERNAL CONTRACTS
    //////////////////////////////////////////////////////
    function _deployExternal() internal {
        vm.startPrank(deployer);

        // Deploy WETH
        weth = new WETH();
        ssv = new MockERC20("SSV Network Token", "SSV", 18);

        // Deploy mocks
        mockSsvNetwork = new MockSSVNetwork();
        mockBeaconChain = new MockBeaconChain();
        mockBeaconProofs = new MockBeaconProofs();
        mockBeaconOracle = new MockBeaconOracle();
        mockDepositContract = new MockDepositContract(mockBeaconChain);
        mockBeaconRootAddress = new MockBeaconRootAddress();
        mockWithdrawalRequest = new MockWithdrawalRequest();
        mockConsolidationStrategy = new MockConsolidationStrategy();
        vm.etch(BEACON_ROOTS_ADDRESS, address(mockBeaconRootAddress).code);
        mockBeaconRootAddress = MockBeaconRootAddress(BEACON_ROOTS_ADDRESS);

        // Mock as addresses
        vault = makeAddr("Vault");

        vm.stopPrank();

        // Label all freshly deployed external contracts
        vm.label(address(weth), "WETH");
        vm.label(address(ssv), "SSV");
        vm.label(address(mockSsvNetwork), "Mock SSVNetwork");
        vm.label(address(mockBeaconChain), "Mock Beacon Chain");
        vm.label(address(mockBeaconProofs), "Mock Beacon Proofs");
        vm.label(address(mockDepositContract), "Mock Deposit Contract");
        vm.label(address(mockWithdrawalRequest), "Mock Withdrawal Request");
        vm.label(address(mockConsolidationStrategy), "Mock Consolidation Strategy");
        vm.label(vault, "Vault");
        vm.label(address(mockBeaconRootAddress), "Mock Beacon Root Address");
        vm.label(address(mockBeaconOracle), "Mock Beacon Oracle");
        vm.label(BEACON_ROOTS_ADDRESS, "Beacon Roots Address");
    }

    //////////////////////////////////////////////////////
    /// --- CONTRACTS
    //////////////////////////////////////////////////////
    function _deployContracts() internal {
        vm.startPrank(deployer);

        // Deploy the Compounding Staking SSV Strategy proxy
        proxy = new CompoundingStakingSSVStrategyProxy();

        // Deploy the Compounding Staking SSV Strategy implementation
        strategy = new CompoundingStakingSSVStrategy({
            _baseConfig: InitializableAbstractStrategy.BaseStrategyConfig(address(0), vault),
            _wethAddress: address(weth),
            _ssvToken: address(ssv),
            _ssvNetwork: address(mockSsvNetwork),
            _beaconChainDepositContract: address(mockDepositContract),
            _beaconOracle: address(mockBeaconOracle),
            _beaconProofs: address(mockBeaconProofs)
        });

        // Initialize the proxy with the implementation address
        address[] memory rewardsTokenAddresses = new address[](1);
        rewardsTokenAddresses[0] = address(weth);
        bytes memory data = abi.encodeWithSelector(
            CompoundingStakingSSVStrategy.initialize.selector, rewardsTokenAddresses, new address[](0), new address[](0)
        );
        proxy.initialize({ _logic: address(strategy), _initGovernor: governor, _data: data });

        vm.label(address(proxy), "Compounding Staking SSV Strategy Proxy");
        vm.label(address(strategy), "Compounding Staking SSV Strategy Implementation");

        strategy = CompoundingStakingSSVStrategy(payable(address(proxy)));

        vm.stopPrank();
    }

    //////////////////////////////////////////////////////
    /// --- INITIALIZATION
    //////////////////////////////////////////////////////
    function _initalize() internal {
        vm.startPrank(governor);

        strategy.setRegistrator(governor);
        strategy.addSourceStrategy(address(mockConsolidationStrategy));

        vm.stopPrank();

        vm.deal(address(weth), 1_000_000_000 ether);

        mockBeaconRootAddress.setBeaconChain(address(mockBeaconChain));
        mockBeaconOracle.setBeaconProofs(address(mockBeaconProofs));
        mockBeaconProofs.setBeaconChain(mockBeaconChain);
        for (uint256 i; i < 10; i++) {
            mockBeaconChain.mine(); // Mine a few blocks to initialize the mock beacon chain
        }
    }
}
