// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.7.5;

import "../interfaces/IERC20.sol";
import "../interfaces/IsGRT.sol";
import "../interfaces/IwsGRT.sol";
import "../interfaces/IgGRT.sol";
import "../interfaces/ITreasury.sol";
import "../interfaces/IStaking.sol";
import "../interfaces/IOwnable.sol";
import "../interfaces/IUniswapV2Router.sol";
import "../interfaces/IStakingV1.sol";
import "../interfaces/ITreasuryV1.sol";

import "../types/GretaAccessControlled.sol";

import "../libraries/SafeMath.sol";
import "../libraries/SafeERC20.sol";


contract GretaTokenMigrator is GretaAccessControlled {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for IgGRT;
    using SafeERC20 for IsGRT;
    using SafeERC20 for IwsGRT;

    /* ========== MIGRATION ========== */

    event TimelockStarted(uint256 block, uint256 end);
    event Migrated(address staking, address treasury);
    event Funded(uint256 amount);
    event Defunded(uint256 amount);

    /* ========== STATE VARIABLES ========== */

    IERC20 public immutable oldGRT;
    IsGRT public immutable oldsGRT;
    IwsGRT public immutable oldwsGRT;
    ITreasuryV1 public immutable oldTreasury;
    IStakingV1 public immutable oldStaking;

    IUniswapV2Router public immutable sushiRouter;
    IUniswapV2Router public immutable uniRouter;

    IgGRT public gGRT;
    ITreasury public newTreasury;
    IStaking public newStaking;
    IERC20 public newGRT;

    bool public grtMigrated;
    bool public shutdown;

    uint256 public immutable timelockLength;
    uint256 public timelockEnd;

    uint256 public oldSupply;

    constructor(
        address _oldGRT,
        address _oldsGRT,
        address _oldTreasury,
        address _oldStaking,
        address _oldwsGRT,
        address _sushi,
        address _uni,
        uint256 _timelock,
        address _authority
    ) GretaAccessControlled(IGretaAuthority(_authority)) {
        require(_oldGRT != address(0), "Zero address: GRT");
        oldGRT = IERC20(_oldGRT);
        require(_oldsGRT != address(0), "Zero address: sGRT");
        oldsGRT = IsGRT(_oldsGRT);
        require(_oldTreasury != address(0), "Zero address: Treasury");
        oldTreasury = ITreasuryV1(_oldTreasury);
        require(_oldStaking != address(0), "Zero address: Staking");
        oldStaking = IStakingV1(_oldStaking);
        require(_oldwsGRT != address(0), "Zero address: wsGRT");
        oldwsGRT = IwsGRT(_oldwsGRT);
        require(_sushi != address(0), "Zero address: Sushi");
        sushiRouter = IUniswapV2Router(_sushi);
        require(_uni != address(0), "Zero address: Uni");
        uniRouter = IUniswapV2Router(_uni);
        timelockLength = _timelock;
    }

    /* ========== MIGRATION ========== */

    enum TYPE {
        UNSTAKED,
        STAKED,
        WRAPPED
    }

    // migrate GRTv1, sGRTv1, or wsGRT for GRTv2, sGRTv2, or gGRT
    function migrate(
        uint256 _amount,
        TYPE _from,
        TYPE _to
    ) external {
        require(!shutdown, "Shut down");

        uint256 wAmount = oldwsGRT.sGRTTowGRT(_amount);

        if (_from == TYPE.UNSTAKED) {
            require(grtMigrated, "Only staked until migration");
            oldGRT.safeTransferFrom(msg.sender, address(this), _amount);
        } else if (_from == TYPE.STAKED) {
            oldsGRT.safeTransferFrom(msg.sender, address(this), _amount);
        } else {
            oldwsGRT.safeTransferFrom(msg.sender, address(this), _amount);
            wAmount = _amount;
        }

        if (grtMigrated) {
            require(oldSupply >= oldGRT.totalSupply(), "GRTv1 minted");
            _send(wAmount, _to);
        } else {
            gGRT.mint(msg.sender, wAmount);
        }
    }

    // migrate all greta tokens held
    function migrateAll(TYPE _to) external {
        require(!shutdown, "Shut down");

        uint256 grtBal = 0;
        uint256 sGRTBal = oldsGRT.balanceOf(msg.sender);
        uint256 wsGRTBal = oldwsGRT.balanceOf(msg.sender);

        if (oldGRT.balanceOf(msg.sender) > 0 && grtMigrated) {
            grtBal = oldGRT.balanceOf(msg.sender);
            oldGRT.safeTransferFrom(msg.sender, address(this), grtBal);
        }
        if (sGRTBal > 0) {
            oldsGRT.safeTransferFrom(msg.sender, address(this), sGRTBal);
        }
        if (wsGRTBal > 0) {
            oldwsGRT.safeTransferFrom(msg.sender, address(this), wsGRTBal);
        }

        uint256 wAmount = wsGRTBal.add(oldwsGRT.sGRTTowGRT(grtBal.add(sGRTBal)));
        if (grtMigrated) {
            require(oldSupply >= oldGRT.totalSupply(), "GRTv1 minted");
            _send(wAmount, _to);
        } else {
            gGRT.mint(msg.sender, wAmount);
        }
    }

    // send preferred token
    function _send(uint256 wAmount, TYPE _to) internal {
        if (_to == TYPE.WRAPPED) {
            gGRT.safeTransfer(msg.sender, wAmount);
        } else if (_to == TYPE.STAKED) {
            newStaking.unwrap(msg.sender, wAmount);
        } else if (_to == TYPE.UNSTAKED) {
            newStaking.unstake(msg.sender, wAmount, false, false);
        }
    }

    // bridge back to GRT, sGRT, or wsGRT
    function bridgeBack(uint256 _amount, TYPE _to) external {
        if (!grtMigrated) {
            gGRT.burn(msg.sender, _amount);
        } else {
            gGRT.safeTransferFrom(msg.sender, address(this), _amount);
        }

        uint256 amount = oldwsGRT.wGRTTosGRT(_amount);
        // error throws if contract does not have enough of type to send
        if (_to == TYPE.UNSTAKED) {
            oldGRT.safeTransfer(msg.sender, amount);
        } else if (_to == TYPE.STAKED) {
            oldsGRT.safeTransfer(msg.sender, amount);
        } else if (_to == TYPE.WRAPPED) {
            oldwsGRT.safeTransfer(msg.sender, _amount);
        }
    }

    /* ========== OWNABLE ========== */

    // halt migrations (but not bridging back)
    function halt() external onlyPolicy {
        require(!grtMigrated, "Migration has occurred");
        shutdown = !shutdown;
    }

    // withdraw backing of migrated GRT
    function defund(address reserve) external onlyGovernor {
        require(grtMigrated, "Migration has not begun");
        require(timelockEnd < block.number && timelockEnd != 0, "Timelock not complete");

        oldwsGRT.unwrap(oldwsGRT.balanceOf(address(this)));

        uint256 amountToUnstake = oldsGRT.balanceOf(address(this));
        oldsGRT.approve(address(oldStaking), amountToUnstake);
        oldStaking.unstake(amountToUnstake, false);

        uint256 balance = oldGRT.balanceOf(address(this));

        if(balance > oldSupply) {
            oldSupply = 0;
        } else {
            oldSupply -= balance;
        }

        uint256 amountToWithdraw = balance.mul(1e9);
        oldGRT.approve(address(oldTreasury), amountToWithdraw);
        oldTreasury.withdraw(amountToWithdraw, reserve);
        IERC20(reserve).safeTransfer(address(newTreasury), IERC20(reserve).balanceOf(address(this)));

        emit Defunded(balance);
    }

    // start timelock to send backing to new treasury
    function startTimelock() external onlyGovernor {
        require(timelockEnd == 0, "Timelock set");
        timelockEnd = block.number.add(timelockLength);

        emit TimelockStarted(block.number, timelockEnd);
    }

    // set gGRT address
    function setgGRT(address _gGRT) external onlyGovernor {
        require(address(gGRT) == address(0), "Already set");
        require(_gGRT != address(0), "Zero address: gGRT");

        gGRT = IgGRT(_gGRT);
    }

    // call internal migrate token function
    function migrateToken(address token) external onlyGovernor {
        _migrateToken(token, false);
    }

    /**
     *   @notice Migrate LP and pair with new GRT
     */
    function migrateLP(
        address pair,
        bool sushi,
        address token,
        uint256 _minA,
        uint256 _minB
    ) external onlyGovernor {
        uint256 oldLPAmount = IERC20(pair).balanceOf(address(oldTreasury));
        oldTreasury.manage(pair, oldLPAmount);

        IUniswapV2Router router = sushiRouter;
        if (!sushi) {
            router = uniRouter;
        }

        IERC20(pair).approve(address(router), oldLPAmount);
        (uint256 amountA, uint256 amountB) = router.removeLiquidity(
            token, 
            address(oldGRT), 
            oldLPAmount,
            _minA, 
            _minB, 
            address(this), 
            block.timestamp
        );

        newTreasury.mint(address(this), amountB);

        IERC20(token).approve(address(router), amountA);
        newGRT.approve(address(router), amountB);

        router.addLiquidity(
            token, 
            address(newGRT), 
            amountA, 
            amountB, 
            amountA, 
            amountB, 
            address(newTreasury), 
            block.timestamp
        );
    }

    // Failsafe function to allow owner to withdraw funds sent directly to contract in case someone sends non-grt tokens to the contract
    function withdrawToken(
        address tokenAddress,
        uint256 amount,
        address recipient
    ) external onlyGovernor {
        require(tokenAddress != address(0), "Token address cannot be 0x0");
        require(tokenAddress != address(gGRT), "Cannot withdraw: gGRT");
        require(tokenAddress != address(oldGRT), "Cannot withdraw: old-GRT");
        require(tokenAddress != address(oldsGRT), "Cannot withdraw: old-sGRT");
        require(tokenAddress != address(oldwsGRT), "Cannot withdraw: old-wsGRT");
        require(amount > 0, "Withdraw value must be greater than 0");
        if (recipient == address(0)) {
            recipient = msg.sender; // if no address is specified the value will will be withdrawn to Owner
        }

        IERC20 tokenContract = IERC20(tokenAddress);
        uint256 contractBalance = tokenContract.balanceOf(address(this));
        if (amount > contractBalance) {
            amount = contractBalance; // set the withdrawal amount equal to balance within the account.
        }
        // transfer the token from address of this contract
        tokenContract.safeTransfer(recipient, amount);
    }

    // migrate contracts
    function migrateContracts(
        address _newTreasury,
        address _newStaking,
        address _newGRT,
        address _newsGRT,
        address _reserve
    ) external onlyGovernor {
        require(!grtMigrated, "Already migrated");
        grtMigrated = true;
        shutdown = false;

        require(_newTreasury != address(0), "Zero address: Treasury");
        newTreasury = ITreasury(_newTreasury);
        require(_newStaking != address(0), "Zero address: Staking");
        newStaking = IStaking(_newStaking);
        require(_newGRT != address(0), "Zero address: GRT");
        newGRT = IERC20(_newGRT);

        oldSupply = oldGRT.totalSupply(); // log total supply at time of migration

        gGRT.migrate(_newStaking, _newsGRT); // change gGRT minter

        _migrateToken(_reserve, true); // will deposit tokens into new treasury so reserves can be accounted for

        _fund(oldsGRT.circulatingSupply()); // fund with current staked supply for token migration

        emit Migrated(_newStaking, _newTreasury);
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    // fund contract with gGRT
    function _fund(uint256 _amount) internal {
        newTreasury.mint(address(this), _amount);
        newGRT.approve(address(newStaking), _amount);
        newStaking.stake(address(this), _amount, false, true); // stake and claim gGRT

        emit Funded(_amount);
    }

    /**
     *   @notice Migrate token from old treasury to new treasury
     */
    function _migrateToken(address token, bool deposit) internal {
        uint256 balance = IERC20(token).balanceOf(address(oldTreasury));

        uint256 excessReserves = oldTreasury.excessReserves();
        uint256 tokenValue = oldTreasury.valueOf(token, balance);

        if (tokenValue > excessReserves) {
            tokenValue = excessReserves;
            balance = excessReserves * 10**9;
        }

        oldTreasury.manage(token, balance);

        if (deposit) {
            IERC20(token).safeApprove(address(newTreasury), balance);
            newTreasury.deposit(balance, token, tokenValue);
        } else {
            IERC20(token).safeTransfer(address(newTreasury), balance);
        }
    }
}
