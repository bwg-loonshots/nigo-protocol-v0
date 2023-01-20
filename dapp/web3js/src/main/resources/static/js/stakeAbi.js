const stakingPoolAbi=[
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_tokenRecipe",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "_tokenPairRecipe",
				"type": "address"
			}
		],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "tokenA",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "tokenB",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amountA",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "amountB",
				"type": "uint256"
			}
		],
		"name": "addLiquidity",
		"outputs": [
			{
				"internalType": "address",
				"name": "pair",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "liquidity",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "token",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "flashFee",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "contract IERC3156FlashBorrower",
				"name": "receiver",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "token",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			},
			{
				"internalType": "bytes",
				"name": "data",
				"type": "bytes"
			}
		],
		"name": "flashLoan",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "isPair",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "isStToken",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "token",
				"type": "address"
			}
		],
		"name": "maxFlashLoan",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "pairOf",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "pairs",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "tokenA",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "tokenB",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "liquidity",
				"type": "uint256"
			}
		],
		"name": "removeLiquidity",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "amountA",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "amountB",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "token",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "stake",
		"outputs": [
			{
				"internalType": "address",
				"name": "stToken",
				"type": "address"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "stakedOf",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "tokenIn",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "tokenOut",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amountIn",
				"type": "uint256"
			}
		],
		"name": "swap",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "amountOut",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "tokens",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "token",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "staked",
				"type": "uint256"
			}
		],
		"name": "unstake",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	}
]