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
		return "testCall.html";
	}
	
	@GetMapping("/switch")
	public String switchChain() {
		return "switch.html";
	}
	
	@GetMapping("/testTx")
	public String testTx() {
		return "testTx.html";
	}
	
	@GetMapping("/testPair")
	public String testPair() {
		return "testPair.html";
	}	
	
	@GetMapping("/web3js")
	public String web3js() {
		return "web3js.html";
	}	
	
	@GetMapping("/subscribe")
	public String subscribe() {
		return "subscribe.html";
	}
	
	@GetMapping("/estimate")
	public String estimate() {
		return "estimate.html";
	}
}
