// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.7.5;

import "../interfaces/IERC20.sol";
import "../interfaces/IOwnable.sol";
import "../types/Ownable.sol";
import "../libraries/SafeERC20.sol";

contract CrossChainMigrator is Ownable {
    using SafeERC20 for IERC20;

    IERC20 internal immutable wsGRT; // v1 token
    IERC20 internal immutable gGRT; // v2 token

    constructor(address _wsGRT, address _gGRT) {
        require(_wsGRT != address(0), "Zero address: wsGRT");
        wsGRT = IERC20(_wsGRT);
        require(_gGRT != address(0), "Zero address: gGRT");
        gGRT = IERC20(_gGRT);
    }

    // migrate wsGRT to gGRT - 1:1 like kind
    function migrate(uint256 amount) external {
        wsGRT.safeTransferFrom(msg.sender, address(this), amount);
        gGRT.safeTransfer(msg.sender, amount);
    }

    // withdraw wsGRT so it can be bridged on ETH and returned as more gGRT
    function replenish() external onlyOwner {
        wsGRT.safeTransfer(msg.sender, wsGRT.balanceOf(address(this)));
    }

    // withdraw migrated wsGRT and unmigrated gGRT
    function clear() external onlyOwner {
        wsGRT.safeTransfer(msg.sender, wsGRT.balanceOf(address(this)));
        gGRT.safeTransfer(msg.sender, gGRT.balanceOf(address(this)));
    }
}