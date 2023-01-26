package com.bwg.nigo.stake;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class StakeController {
	
	@GetMapping("/deposit")
	public String deposit() {
		return "stake/deposit.html";
	}
	
	@GetMapping("/modal")
	public String modal() {
		return "modal.html";
	}
	
	@GetMapping("/swap")
	public String swap() {
		return "stake/swap.html";
	}
	
	@GetMapping("/addliquidity")
	public String addliquidity() {
		return "stake/addliquidity.html";
	}
	
}
