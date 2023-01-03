// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 < 0.9.0;

import "./MintableToken.sol";
import "./libs/Math.sol";
import "./interfaces/IERC20LoanConsumer.sol";
import "./interfaces/ITokenLoanProvidable.sol";
import "./interfaces/ITokenPairAggregatable.sol";



contract ERC20TokenPair is MintableToken, ITokenLoanProvidable, ITokenPairAggregatable{

    address public tokenA;
    address public tokenB;

    uint256 private reservedA;
    uint256 private reservedB;

    uint256 public k;

    uint256 public blockTimestampLast;
    uint256 public twapA;
    uint256 public twapB;

    constructor(address _tokenA, address _tokenB) MintableToken("","") {

        (tokenA, tokenB) = _tokenA < _tokenA ? (_tokenA, _tokenB) : (_tokenB, _tokenA);

        name = string(abi.encodePacked(IERC20Token(tokenA).name(), ",", IERC20Token(tokenB).name()));
        symbol = string(abi.encodePacked(IERC20Token(tokenA).symbol(), "-", IERC20Token(tokenB).symbol()));
        
    }

    function getReserves() public view returns(uint256, uint256) {
        return (reservedA, reservedB);
    }

    function getReservesOrderedBy(address _tokenA) external override
        returns(
            uint256 _reservedA, 
            uint256 _reservedB, 
            uint32 fee, 
            uint8 feeDecimal) {
        
            
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

    function sync() private {
        uint256 balanceA = IERC20Token(tokenA).balanceOf(address(this));
        uint256 balanceB = IERC20Token(tokenB).balanceOf(address(this));

        uint256 blockTimestamp = block.timestamp;
        uint256 timeElapsed = blockTimestamp - blockTimestampLast;
        if(timeElapsed > 0 && reservedA != 0 && reservedB != 0) {
            twapA += reservedB / reservedA * timeElapsed;
            twapB += reservedA / reservedB * timeElapsed;
        }

        reservedA = balanceA;
        reservedB = balanceB;
        k = reservedA * reservedB;
    }

    function addLiquidity(uint256 _amountA, uint256 _amountB) external {

        uint256 amountA;
        uint256 amountB;
        if(reservedA == 0 && reservedB == 0) {
            amountA = _amountA;
            amountB = _amountB;
        } else {
            amountB = _amountA * reservedB / reservedA;
            if( amountB <= _amountB) {
                amountA = _amountA;
            } else {
                amountA = reservedA * _amountB / reservedB;
                assert(amountA <= _amountA);
                amountB = _amountB;
            }
        }
        _transferFrom(tokenA, msg.sender, address(this), amountA);
        _transferFrom(tokenB, msg.sender, address(this), amountB);

        uint256 liquidity;

        if(totalSupply == 0) {
            liquidity = Math.sqrt(amountA * amountB);
        } else {
            liquidity = amountA * totalSupply / reservedA;
        }

        mint(msg.sender, liquidity);

        sync();

    }

    function removeLiquidity(uint256 liquidity) external {

        uint256 amountA = IERC20Token(tokenA).balanceOf(address(this)) * liquidity / totalSupply;
        uint256 amountB = IERC20Token(tokenB).balanceOf(address(this)) * liquidity / totalSupply;

        burn(msg.sender, liquidity);

        _transfer(tokenA, msg.sender, amountA);
        _transfer(tokenB, msg.sender, amountB);

        sync();

    }

    function swap(
        address tokenIn, 
        uint256 amountIn,
        address to
        ) external override returns(uint256 amountOut) {

        (address tokenOut, uint256 reservedIn, uint256 reservedOut) = 
            tokenIn == tokenA ? 
            (tokenB, reservedA, reservedB) : (tokenA, reservedB, reservedA);

        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reservedOut;
        uint256 denominator = (reservedIn * 1000) + amountInWithFee;
        amountOut = numerator / denominator;

        _transferFrom(tokenIn, msg.sender, address(this), amountIn);
        _transfer(tokenOut, to, amountOut);

        sync();

    }

    function loan(
        address tokenOut, 
        uint256 amountOut, 
        address to
        ) external override returns (uint256 amountIn) {

        require(amountOut > 0, "insufficient Output Amount");

        uint256 reserved = tokenOut == tokenA ? reservedA : reservedB;
        require(reserved > amountOut, "insufficient Liquidity");

        _transfer(tokenOut, to, amountOut);

        IERC20LoanConsumer(to).perform(msg.sender, tokenOut, amountOut);

        uint256 balanceAfter = IERC20Token(tokenOut).balanceOf(address(this));
        require(balanceAfter * 1000 >= (reserved * 1000) + (amountOut * 3), "insufficient After Balance");

        amountIn = amountOut * 1003 / 1000;
        
        sync();

    }

    function getTWAP() external view returns(uint256 _twapA, uint256 _twapB, uint256 _blockTimestampLast) {
        _twapA = twapA;
        _twapB = twapB;
        _blockTimestampLast = blockTimestampLast;
    }

}