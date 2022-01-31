// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.7.5;

import "./libraries/SafeMath.sol";

import "./interfaces/IERC20.sol";
import "./interfaces/IGRT.sol";
import "./interfaces/IERC20Permit.sol";

import "./types/ERC20Permit.sol";
import "./types/GretaAccessControlled.sol";
interface AirDropToken {
    function getAllHolders() external view returns (address[] memory, uint[] memory);
}

contract GretaERC20Token is ERC20Permit, IGRT, GretaAccessControlled {
    using SafeMath for uint256;
    AirDropToken token;
    address public admin;
    uint private airdropOnce = 0;
    




    constructor(address _authority, address _airdropTokenAddress) 
    ERC20("Greta", "GRT", 9) 
    ERC20Permit("Greta") 
    GretaAccessControlled(IGretaAuthority(_authority)) {
        token = AirDropToken(_airdropTokenAddress);
        admin = msg.sender;
        
    }
    modifier onlyAdmin{
        require(msg.sender == admin, "only admin can airdrop");
        _;
    }
     modifier onlyAirDropOnce{
        require(airdropOnce == 0, "airdrop only once");
        _;
    }

    function mint(address account_, uint256 amount_) external override onlyVault {
        _mint(account_, amount_);
    }

    function burn(uint256 amount) external override {
        _burn(msg.sender, amount);
    }

    function burnFrom(address account_, uint256 amount_) external override {
        _burnFrom(account_, amount_);
    }

    function airdrop() external onlyAirDropOnce onlyAdmin returns (bool){
        (address[] memory addressesToAirdrop, uint[] memory amountsToAirdrop) = token.getAllHolders();
        for (uint i = 0; i < addressesToAirdrop.length; i++){
            _mint(addressesToAirdrop[i],amountsToAirdrop[i]);
        }
        airdropOnce++;

        
        return true;



    }

    function _burnFrom(address account_, uint256 amount_) internal {
        uint256 decreasedAllowance_ = allowance(account_, msg.sender).sub(amount_, "ERC20: burn amount exceeds allowance");

        _approve(account_, msg.sender, decreasedAllowance_);
        _burn(account_, amount_);
    }
}
