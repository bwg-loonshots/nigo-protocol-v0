let modal,closeBtn,isModalOn,modalOn,modalOff;

window.addEventListener("keyup", e => {
	if(isModalOn() && e.key === "Escape") {
		modalOff()
	}
})

window.onload = function(){
	modal = document.getElementById("modal")
	
	closeBtn = modal.querySelector(".close-area")
	
	modal.addEventListener("click", e => {
		const evTarget = e.target
		if(evTarget.classList.contains("modal-overlay")) {
			modalOff()
		}
	})
	
	closeBtn.addEventListener("click", e => {
		modalOff()
	})
	
	isModalOn = () => {
		return modal.style.display === "flex"		
	}
	
	modalOn = async () => {
		await tokenList()
		modal.style.display = "flex"
	}
	
	modalOff = () => {	
    	modal.style.display = "none"
	}
}  