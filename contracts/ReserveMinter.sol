// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./PHUSD.sol";

contract ReserveMinter is Ownable, AccessControl {
    using SafeMath for uint256;

    /* ========== STATE VARIABLES ========== */

    address[] private collateralAddressesArray;
    mapping (address => bool) private collateralAddresses;
    PHUSDStablecoin private PHUSD;
    address private PHUSDTokenAddress;

    struct Collateral {
        address collateralAddress;
        uint balance;
    }

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");



    /* ========== MODIFIERS ========== */

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _;
    }

    modifier collateralGiven(address collateralAddress) {
        require(collateralAddresses[collateralAddress], "token address submitted is not a collateral");
        _;
    }

    /* ========== CONSTRUCTOR ========== */

    constructor(address _PHUSDTokenAddress) Ownable() {
        require(_PHUSDTokenAddress != address(0), "Zero address detected");
        PHUSD = PHUSDStablecoin(_PHUSDTokenAddress);
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    /* ========== VIEWS ========== */

    function getAllCollaterals() external view returns (address[] memory _collaterals) {
        _collaterals = collateralAddressesArray;
    }

    function getBalanceCollateral(address collateral) external view returns (uint256 _balance)  {
        _balance = ERC20(collateral).balanceOf(address(this));
    }

    /* ========== PUBLIC FUNCTIONS ========== */

    function addCollateralToken(address tokenAddress) public {
        require(!collateralAddresses[tokenAddress], "token address submitted already as collateral");
        collateralAddresses[tokenAddress] = true;
        collateralAddressesArray.push(tokenAddress);
        emit CollateralTokenWhitelisted(tokenAddress);
    }


    function mint1t1PHUSD(address collateralAddress, uint256 collateralAmount) external collateralGiven(collateralAddress) {


        SafeERC20.safeTransferFrom(ERC20(collateralAddress), msg.sender, address(this), collateralAmount);
        emit CollateralBalanceAdded(collateralAddress, collateralAmount);

        PHUSD.mint(msg.sender, collateralAmount);
    }

    function redeemCollateral(address collateralAddress, uint256 PHUSDAmount) external onlyAdmin collateralGiven(collateralAddress) {
        require(PHUSD.balanceOf(msg.sender) >= PHUSDAmount, "The PHUSD amount given exceed your balance");
        PHUSD.burn(msg.sender, PHUSDAmount);
        SafeERC20.safeTransfer(ERC20(collateralAddress), msg.sender, PHUSDAmount);

    }

    function giveAdminRights(address adminRequestAddress) external onlyAdmin {
        _setupRole(ADMIN_ROLE, adminRequestAddress);
    }

    /* ========== EVENTS ========== */

    event CollateralTokenWhitelisted(address collateralAddress);
    event CollateralBalanceAdded(address collateralAddress, uint256 collateralAmount);



}