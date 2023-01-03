// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 < 0.9.0;

import "./interfaces/ITokenPairAggregatable.sol";
import "./interfaces/IERC20Token.sol";
import "./interfaces/IERC20LoanConsumer.sol";
import "./interfaces/ITokenLoanProvidable.sol";



contract TokenPairAggregator is IERC20LoanConsumer{

    address tokenA;
    address tokenB;

    address pairA;

    address pairB;

    address loanC;

    address maxOutPair;
    address abiPair;

    constructor(
        address _tokenA,
        address _tokenB,
        address _pairA, 
        address _pairB, 
        address _loanC) {

        tokenA = _tokenA;
        tokenB = _tokenB;
        pairA = _pairA;
        pairB = _pairB;
        loanC = _loanC;

    }

    function _transfer(
        address token, 
        address to, 
        uint256 value) private {
        (bool success,) = token.call(
            abi.encodeWithSignature("transfer(address,uint256)", to, value)
        );
        require(success, "transfer Failed");
    }

    function _transferFrom(
        address token, 
        address from, 
        address to, 
        uint256 value) private {
        (bool success,) = token.call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, value)
        );
        require(success, "transfer from Failed");
    }

    function swap(
        address tokenIn, 
        uint256 amountIn,
        address to
        ) external returns(uint256 amountOut, uint256 discount) {

        (maxOutPair, abiPair) = calcAmountOut(tokenIn, amountIn, pairA) >=
                                calcAmountOut(tokenIn, amountIn, pairB) ?
                                (pairA, pairB) : (pairB, pairA);

        _transferFrom(tokenIn, msg.sender, address(this), amountIn);
        IERC20Token(tokenIn).approve(maxOutPair, amountIn);
        amountOut = ITokenPairAggregatable(maxOutPair).swap(tokenIn, amountIn, to);

        uint256 abiAmount = calcAbiAmount(amountIn);

        ITokenLoanProvidable(loanC).loan(tokenIn, abiAmount, address(this));

        discount = IERC20Token(address(tokenIn)).balanceOf(address(this));

        if(discount > 0) {
            _transfer(tokenIn, msg.sender, discount);
        }

    
    }

    function perform(address sender, address token, uint256 amount) external override {

        require(sender == address(this), "invalid loan caller");
        IERC20Token(token).approve(abiPair, amount);
        uint256 amountOutB = ITokenPairAggregatable(abiPair).swap(token, amount, address(this));

        address abiToken = token == tokenA ? tokenB : tokenA;
        IERC20Token(abiToken).approve(maxOutPair, amountOutB);
        uint256 amountOutA = ITokenPairAggregatable(maxOutPair).swap(abiToken, amountOutB, address(this));
        
        uint256 dept = amount * 1003 / 1000;
        require(amountOutA >= dept, "insufficient swapped amount for dept");

        _transfer(token, loanC, dept);

    }


    function calcAmountOut(
        address tokenIn, 
        uint256 amountIn, 
        address pair) private returns (uint256 amountOut) {
        
        (uint256 reservedIn, uint256 reservedOut, uint32 fee, uint8 feeDecimal) = 
            ITokenPairAggregatable(pair).getReservesOrderedBy(tokenIn);

        uint256 shift = 10 ** feeDecimal;
        uint256 amountInWithFee = amountIn * (shift - fee);
        uint256 numerator = amountInWithFee * reservedOut;
        uint256 denominator = (reservedIn * shift) + amountInWithFee;
        amountOut = numerator / denominator;
    }

    function calcAbiAmount(uint amount) private pure returns(uint256){
        return amount/2;
    }

}