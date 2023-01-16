// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 < 0.9.0;

import "./ERC20TokenPair.sol";

contract InterSwap {

    mapping (address => address) tokenPair;

    address public keyToken;

    event AddPair(address indexed _token, address indexed _pair);

    constructor(address _keyToken ) {
        keyToken = _keyToken;
    }

    function _transferFrom(address token, address from, address to, uint256 value) private {
        (bool success,) = token.call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, value)
        );
        require(success, "transfer from Failed");
    }
    
    function _approve(address token, address spender, uint256 value) private {
        (bool success,) = token.call(
            abi.encodeWithSignature("approve(address,uint256)", spender, value)
        );
        require(success, "approve Failed");
    }
    function bytesToUint(bytes memory b) internal pure returns (uint256){
        uint256 number;
        for(uint i=0;i<b.length;i++){
            number = number + uint(uint8(b[i]))*(2**(8*(b.length-(i+1))));
        }
        return number;
    }

    function addTokenPair(address _pair) external { //keyToken을 사용하는 기존 pair 등록
        address checkToken = ERC20TokenPair(_pair).tokenA();
        address matchedToken;
        if(checkToken == keyToken){
            matchedToken = ERC20TokenPair(_pair).tokenB();
        }else{
            matchedToken = checkToken;
            checkToken = ERC20TokenPair(_pair).tokenB();
        }
        require(checkToken == keyToken,"there isn't keyToken");

        tokenPair[matchedToken] = _pair;

        emit AddPair(matchedToken,_pair);
    }

    //function createTokenPair(address _token) //keyToken과 기존 token을 사용하는 신규 pair생성

    function _swap(address token, uint256 amount, address to)internal returns(uint256 value){
        (bool success, bytes memory result) = tokenPair[token].call(
            abi.encodeWithSignature(
                "swap(address,uint256,address)",
                token, amount, to
            )
        );
        require(success,"pair fail");

        value = bytesToUint(result);
    }

    function interSwap(address tokenIn, address tokenOut, uint256 amountIn, address to) external returns(uint256 amountOut) {
        
        // (bool success,) = tokenIn.delegatecall(
        //     abi.encodeWithSignature("approve(address,uint256)", address(this), amountIn)
        // );
        // require(success, "approve Failed");

        _transferFrom(tokenIn, msg.sender, address(this), amountIn); //m->s

        _approve(tokenIn, tokenPair[tokenIn], amountIn);    //s->pairIn

        uint256 interAmount = _swap(tokenIn, amountIn, address(this)) * 997 / 1000;

        _approve(tokenOut,tokenPair[tokenOut],interAmount); //s->pairOut

        amountOut = _swap(keyToken, interAmount, to); //s -> pairOut / pairOut -> m
    }
}