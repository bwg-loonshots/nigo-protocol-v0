function modalShow(){
	modal.style.display = "flex"
}

function modalOff() {
     modal.style.display = "none"
}

function isModalOn() {
	return modal.style.display === "flex"
}

window.addEventListener("keyup", e => {
	if(isModalOn() && e.key === "Escape") {
		modalOff()
	}
})

function tokenItem(symbol,image,name,balance){
	let item = "<li class=\"token\" onclick=\"choiceToken('" 
 		+ symbol
 		+ "')\"> <div class=\"tokenImg\"><img src="
 		+ image
 		+ "> </div> <div class=\"tokenInfo\"> <div class=\"tokenSymbol\">"
 		+ symbol
 		+"</div> <div class=\"tokenName\">"
		+ name
		+ "</div> </div> <div class=\"tokenBalance\">"
		+ balance
		+ "</div> </li>";
	return item;
}