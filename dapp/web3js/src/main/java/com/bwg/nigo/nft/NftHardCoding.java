package com.bwg.nigo.nft;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class NftHardCoding {
	public List<NftMetadata> metadatas = new ArrayList<NftMetadata>();
	private String[] menuArr = {"cho ramen","nigo ramen","nigo ramen","nigo ramen","gyoza","cho ramen"};
	
	
	public NftHardCoding() {
		for (int i = 0; i < 5; i++) {
			NftMetadata meta = new NftMetadata();
			meta.setName("nigo"+i);
			meta.setImage("localhost:8080/nft/img/"+i);
			meta.setDescription("nigo img "+i);
			
			NftAttribute attr1 = new NftAttribute();
			attr1.setTraitType("menu");
			attr1.setValue(menuArr[i]);
			meta.getAttributes().add(attr1);
			
			NftAttribute attr2 = new NftAttribute();
			attr2.setDisplayType("number");
			attr2.setTraitType("order");
			attr2.setValue(i);
			meta.getAttributes().add(attr2);
			
			metadatas.add(meta);
		}
	}
}
