package com.bwg.nigo.home;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {
	@GetMapping("/")
	public String home() {
		return "index.html";
	}
	
	@GetMapping("/testCall")
	public String testCall() {
		return "metamask/testCall.html";
	}
	
	@GetMapping("/switch")
	public String switchChain() {
		return "metamask/switch.html";
	}
	
	@GetMapping("/testTx")
	public String testTx() {
		return "metamask/testTx.html";
	}
	
	@GetMapping("/testPair")
	public String testPair() {
		return "metamask/testPair.html";
	}	
	
	@GetMapping("/web3js")
	public String web3js() {
		return "metamask/web3js.html";
	}	
	
	@GetMapping("/subscribe")
	public String subscribe() {
		return "metamask/subscribe.html";
	}
	
	@GetMapping("/estimate")
	public String estimate() {
		return "metamask/estimate.html";
	}
	
	@GetMapping("/interSwap")
	public String interSwap() {
		return "interSwap.html";
	}
	
	@GetMapping("/testProvider")
	public String testProvider() {
		return "testProvider.html";
	}
}
