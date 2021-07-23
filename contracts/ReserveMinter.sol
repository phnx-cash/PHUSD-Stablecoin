// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./PHUSD.sol";

contract ReserveMinter is Ownable, AccessControl {
    using SafeMath for uint256;

    /* ========== STATE VARIABLES ========== */

    address[] private collateralAddressesArray;
    mapping (address => bool) private collateralAddresses;
    mapping (address => uint256) private collateralBalances;
    PHUSDStablecoin private PHUSD;
    address private PHUSDTokenAddress;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    


    /* ========== MODIFIERS ========== */

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _;
    }
 
    /* ========== CONSTRUCTOR ========== */
    
    constructor(address _PHUSDTokenAddress) Ownable() {
        require(_PHUSDTokenAddress != address(0), "Zero address detected");
        PHUSD = PHUSDStablecoin(_PHUSDTokenAddress);
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    /* ========== VIEWS ========== */

    /* ========== PUBLIC FUNCTIONS ========== */

    function addCollateralToken(address tokenAddress) public onlyAdmin {
        require(!collateralAddresses[tokenAddress], "token address submitted already as collateral");
        collateralAddresses[tokenAddress] = true;
        collateralAddressesArray.push(tokenAddress);
    }

    // We separate out the 1t1, fractional and algorithmic minting functions for gas efficiency 
    function mint1t1PHUSD(address collateralAddress, uint256 collateralAmount) external onlyOwner {
        require(collateralAddresses[tokenAddress], "token address submitted is not a collateral");
//        uint256 collateral_amount_d18 = collateral_amount * (10 ** missing_decimals);


//        frax_amount_d18 = (frax_amount_d18.mul(uint(1e6).sub(minting_fee))).div(1e6); //remove precision at the end
//        require(FRAX_out_min <= frax_amount_d18, "Slippage limit reached");

//        TransferHelper.safeTransferFrom(address(collateral_token), msg.sender, address(this), collateral_amount);
        PHUSD.mint(msg.sender, collateralAmount);
    }

    /* ========== EVENTS ========== */

    event CollateralTokenWhitelisted(address collateralAddress);
    event CollateralBalanceAdded(address collateralAddress, uint256 collateralAmount);


}