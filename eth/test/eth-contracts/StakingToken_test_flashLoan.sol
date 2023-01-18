// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./TokenTestable.sol";
import "../../contracts/StakingToken.sol";

contract StakingToken_test_flashLoan is TokenTestable, IERC3156FlashBorrower {
    
    enum Type {ORIGIN, STAKED}

    uint origin_token_balance;

    StakingToken stToken;

    function test() public {

        ERC20 token = newToken("T01", 100_000_000 * DEX18);
        stToken = new StakingToken(address(token));
        token.transfer(address(stToken), 1000_000);
        stToken.stake(address(this));

        // flash loan test
        origin_token_balance = token.balanceOf(address(this));
        assert(stToken.flashFee(1000) == 3);
        stToken.flashLoan(this, 1000, abi.encode(Type.ORIGIN));
        assert(stToken.reserved() == 1000_000 + 3);
        assert(origin_token_balance - 3 == token.balanceOf(address(this)));

        // unstake test
        stToken.transfer(address(stToken), 1000_000);
        stToken.unstake(address(this));
        assert(stToken.totalSupply() == 0);
        assert(stToken.balanceOf(address(this)) == 0);
        assert(token.balanceOf(address(this)) == 100_000_000 * DEX18);

    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external override returns (bytes32) {
        assert(msg.sender == address(stToken));
        assert(initiator == address(this));
        assert(abi.decode(data, (Type)) == Type.ORIGIN);
        assert(token == stToken.token());
        assert(origin_token_balance + amount == IERC20(token).balanceOf(address(this)));
        IERC20(token).approve(msg.sender, amount + fee);

        return keccak256("ERC3156FlashBorrower.onFlashLoan");

    }
}