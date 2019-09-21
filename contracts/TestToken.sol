pragma solidity ^0.5.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract ERC20Mintable is ERC20 {


    function mint(address account, uint256 amount) public returns (bool) {
        _mint(account, amount);
        return true;
    }
}


contract ERC20MintableA is ERC20Mintable {
    string public name = 'TEST Wrapped ETH';
    string public symbol = 'WETH';
        uint8 public decimals = 18;
}


contract ERC20MintableB is ERC20Mintable {
    string public name = 'TEST Wrapped BTC';
    string public symbol = 'WBTC';
        uint8 public decimals = 18;
}
