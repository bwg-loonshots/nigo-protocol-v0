function mul18(amountStr){
	amountStr = String(amountStr)
	const _DEX18 = 10**18
	const amountSplitByPoint = amountStr.split('.')
	const amountDecimal = amountSplitByPoint[1] || 0
	let amount = Number(amountSplitByPoint[0] * _DEX18)
	for( i = 0 ; i < 18 && i < amountDecimal.length ; ++i){
		amount += amountDecimal[i] * (10**(18-i-1))
	}
	return amount
}


function mul9(amountStr){
	amountStr = String(amountStr)
	const _DEX9 = 10**9
	const amountSplitByPoint = amountStr.split('.')
	const amountDecimal = amountSplitByPoint[1] || 0
	let amount = Number(amountSplitByPoint[0] * _DEX9)
	for( i = 0 ; i < 9 && i < amountDecimal.length ; ++i){
		amount += amountDecimal[i] * (10**(9-i-1))
	}
	return amount
}

function avg(arr) {
  const sum = arr.reduce((a, v) => a + v);
  return Math.round(sum/arr.length);
}

function objectParsing(obj,depth){
	let txt = '{'
	if( obj ){
		txt += '<br/>'
	}	
	for(const key in obj){
		txt += '&nbsp;&nbsp;'.repeat(depth+1) + key + ' : '
		value = obj[key]
		if(typeof value == 'object'){
			value = objectParsing(value,depth+1)
		}
		txt += value + '<br/>'
	}
	txt += '&nbsp;&nbsp;'.repeat(depth) + '}<br/>'
	return txt
}