package com.bwg.nigo.nft;

import java.util.ArrayList;
import java.util.List;

public class NftMetadata {
	private String image;
	private String name;
	private String description;
	private List<NftAttribute> attributes = new ArrayList<NftAttribute>();
	
	public String getImage() {
		return image;
	}
	
	public void setImage(String image) {
		this.image = image;
	}
	
	public String getName() {
		return name;
	}
	
	public void setName(String name) {
		this.name = name;
	}
	
	public String getDescription() {
		return description;
	}
	
	public void setDescription(String description) {
		this.description = description;
	}
	
	public List getAttributes() {
		return attributes;
	}
}
