// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.7.5;

import "../interfaces/IERC20.sol";
import "../types/Ownable.sol";

contract GrtFaucet is Ownable {
    IERC20 public grt;

    constructor(address _grt) {
        grt = IERC20(_grt);
    }

    function setGrt(address _grt) external onlyOwner {
        grt = IERC20(_grt);
    }

    function dispense() external {
        grt.transfer(msg.sender, 1e9);
    }
}
