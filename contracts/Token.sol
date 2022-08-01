// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20 is ERC20, Ownable {

    constructor(address accountHolder,string memory name,string memory symbol ) ERC20( name, symbol) {
        _mint(accountHolder, 1000000 * 10 ** decimals());
    }
}
