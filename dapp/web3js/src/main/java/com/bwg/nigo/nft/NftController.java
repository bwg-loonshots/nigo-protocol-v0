package com.bwg.nigo.nft;

import java.io.IOException;
import java.io.InputStream;

import org.apache.commons.io.IOUtils;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class NftController {
	
	@GetMapping(value="/nft/metadata/{id}")
	public @ResponseBody NftMetadata getNftMetadata(@PathVariable int id) throws IOException {
		NftHardCoding hardcodedData = new NftHardCoding();
		return hardcodedData.metadatas.get(id);
	}
	
	@GetMapping(value="/nft/img/{id}", produces = MediaType.IMAGE_JPEG_VALUE)
	public @ResponseBody byte[] getNftImage(@PathVariable int id) throws IOException {
		InputStream in = getClass().getResourceAsStream("/static/nfts/img/"+id+".jpg");
		return IOUtils.toByteArray(in);
	}
	
}
