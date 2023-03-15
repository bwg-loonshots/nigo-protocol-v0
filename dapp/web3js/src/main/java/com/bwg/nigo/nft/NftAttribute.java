package com.bwg.nigo.nft;

public class NftAttribute {
	private String trait_type;
	private String display_type;
	private Object value;
	
	public String getTraitType() {
		return trait_type;
	}
	
	public void setTraitType(String trait) {
		this.trait_type = trait;
	}
	
	public String getDisplayType() {
		return display_type;
	}
	
	public void setDisplayType(String display) {
		this.display_type = display;
	}
	
	public Object getValue() {
		return value;
	}
	
	public void setValue(Object input) {
		this.value = input;
	}
}
