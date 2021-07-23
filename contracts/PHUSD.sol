// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract PHUSDStablecoin is ERC20, Ownable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    address private minter;


    /* ========== MODIFIERS ========== */

    modifier onlyMinter() {
        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");
        _;
    }


    /* ========== CONSTRUCTOR ========== */

    constructor(string name, string symbol) ERC20(name, symbol) {}



    /* ========== PUBLIC FUNCTIONS ========== */

    function setMinter(address minter) onlyOwner {
        _setupRole(MINTER_ROLE, minter);
    }

    function mint(address to, uint256 amount) onlyMinter public {
        _mint(to, amount);
    }

    /* ========== VIEWS ========== */

    function getMinter() public view returns (address memory _minter) {
        _minter = minter;
    }

}
