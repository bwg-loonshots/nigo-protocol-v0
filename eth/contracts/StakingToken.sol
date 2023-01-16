// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./MintableToken.sol";
import "./libs/SafeTransfer.sol";
import "./interfaces/IERC3156FlashBorrower.sol";
import "./interfaces/IERC20Stakeable.sol";



contract StakingToken is MintableToken, IERC20Stakeable {
    using SafeMath for uint;
    using SafeTransfer for address;

    bytes32 constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");

    address public token;

    uint public reserved;

    uint public fee = 30; // 1 == 0.01%, 0.3 default

    constructor(address _token)
    MintableToken(
        string(abi.encodePacked("Nigo Staked ", IERC20(token).name())),
        string(abi.encodePacked("st", IERC20(token).symbol()))) {
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

    function stake(address from) external lock returns(uint staked) {
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

    // TODO if another one transfered st token to contract before unstake?
    function unstake(address from) external lock returns(uint amount) {

        uint staked = balances[address(this)];

        _burn(address(this), staked);

        uint balance = _stakedBalance();
        
        amount = balance.mul(staked) / totalSupply;

        token._transfer(from, amount);

        reserved = balance;

    }

    function _flashFee(uint amount) internal view returns(uint256) {
        return amount.mul(fee) / 10000;
    }

    function flashFee(uint amount) external view returns(uint256) {
        return _flashFee(amount);
    }

    function flashLoan(
        IERC3156FlashBorrower receiver,
        uint amount,
        bytes calldata data
    ) external lock returns(bool) {

        token._transfer(address(receiver), amount);

        uint _fee = _flashFee(amount);

        require(
            receiver.onFlashLoan(address(receiver), token, amount, _fee, data)
            == CALLBACK_SUCCESS,
            "nigo: IERC3156 callback failed");

        require(
            token._transferFrom(address(receiver), address(this), amount.add(_fee)),
            "nigo: repay failed"
            );


        reserved = _stakedBalance();

        return true;

    }

    function flashMint(
        IERC3156FlashBorrower receiver,
        uint amount,
        bytes calldata data
    ) external lock returns(bool) {

        _mint(address(receiver), amount);

        uint _fee = _flashFee(amount);

        require(
            receiver.onFlashLoan(address(receiver), token, amount, _fee, data)
            == CALLBACK_SUCCESS,
            "nigo: IERC3156 callback failed");
        
        uint repay = amount.add(_fee);
        uint _allowed = allowed[address(receiver)][address(this)];

        require(
            _allowed > repay,
            "nigo: repay not approved");

        allowed[address(receiver)][address(this)] = _allowed - repay;
        _burn(address(receiver), repay);

        return true;

    }

}