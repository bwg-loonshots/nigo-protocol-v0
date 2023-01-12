// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./MintableToken.sol";
import "./libs/SafeTransfer.sol";
import "./interfaces/IERC3156FlashBorrower.sol";


contract StakableToken is MintableToken {
    using SafeMath for uint;
    using SafeTransfer for address;

    address public token;

    uint public reserved;

    uint public flashFee = 3; // 1 == 0.01%

    constructor(address _token)
    MintableToken(
        string(abi.encodePacked("Nigo Staked ", StakableToken(token).name())),
        string(abi.encodePacked("st", StakableToken(token).symbol()))) {
        token = _token;
    }

    uint8 locked = 0;

    bool private unlocked = true;

    modifier lock() {
        require(unlocked == true, 'Nigo: LOCKED');
        unlocked = false;
        _;
        unlocked = true;
    }

    function _stakedBalance() private view returns(uint) {
        return IERC20(token).balanceOf(address(this));
    }

    function stake(address from) external returns(uint staked){
        // before staking, staker should transfer token to this contract
        uint balance = _stakedBalance();
        uint amount = balance.sub(reserved);

        require(amount > 0, "nigo: not found staked value");

        if(totalSupply == 0) {
            staked = amount;
        } else {
            staked = amount.mul(totalSupply) / reserved;
        }

        _mint(from, staked);

        reserved = balance;

    }

    function unstake(address from, uint staked) external returns(uint amount) {
        
        uint balance = _stakedBalance();
        amount = balance.mul(staked) / totalSupply;

        _burn(from, staked);

        token._transfer( from, amount);

        reserved = balance;

    }

    function erc3156(
        IERC3156FlashBorrower receiver,
        uint amount,
        bytes calldata data
    ) external returns(bool) {

        token._transfer(address(receiver), amount);

        require(
            receiver.onFlashLoan(address(receiver), token, amount, flashFee, data)
            == keccak256("ERC3156FlashBorrower.onFlashLoan"),
            "nigo: IERC3156 callback failed");

        uint balance = _stakedBalance();

        require(
            balance * 1000 > reserved  * 1000 + (amount * flashFee), 
            "nigo: not enough repayment");

        reserved = balance;

        return true;
        
    }


}