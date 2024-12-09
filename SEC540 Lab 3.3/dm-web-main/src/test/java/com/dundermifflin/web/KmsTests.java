package com.dundermifflin.web;
/*
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.core.io.Resource;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.util.Assert;

import com.amazonaws.services.kms.AWSKMS;
import com.amazonaws.services.kms.AWSKMSClientBuilder;
import com.amazonaws.services.kms.model.DecryptRequest;
import com.amazonaws.services.kms.model.EncryptRequest;
import com.amazonaws.services.kms.model.GenerateDataKeyRequest;
import com.amazonaws.services.kms.model.GenerateDataKeyResult;
import com.amazonaws.util.BinaryUtils;
import com.amazonaws.util.IOUtils;

@SuppressWarnings("deprecation")
@RunWith(SpringRunner.class)
@SpringBootTest
public class KmsTests {

	@Value("${dundermifflin.kms.keyid}")
	private String kmsKeyArn;
	
	@Value("${dundermifflin.cloudfront.private-key}")
	private Resource cloudFrontPrivateKey;
	
	@Test
	public void encryptFileStream() throws IOException {
		
		final AWSKMS kms = AWSKMSClientBuilder.defaultClient();
		
		//Get the private key from the file input stream
		ByteBuffer keyBytes = ByteBuffer.wrap(IOUtils.toByteArray(cloudFrontPrivateKey.getInputStream()));
		EncryptRequest req = new EncryptRequest().withKeyId(kmsKeyArn).withPlaintext(keyBytes);
		ByteBuffer encKeyBytes = kms.encrypt(req).getCiphertextBlob();
		
		File f = new File(System.getProperty("user.dir") + "/src/main/resources/cloudfront-private-key.enc");
	    if(f.exists()) f.delete();
	    
	    FileOutputStream fos = new FileOutputStream(f);
	    fos.write(BinaryUtils.copyAllBytesFrom(encKeyBytes));
	    fos.close();
	    
	    Assert.isTrue(f.exists(), "file exists now!");
	}
	
	@Test
	public void decryptFileStream() throws IOException {
		
		final AWSKMS kms = AWSKMSClientBuilder.defaultClient();
		
		//Get the encrypted key bytes from the file input stream
		ByteBuffer encryptedBytes = ByteBuffer.wrap(IOUtils.toByteArray(cloudFrontPrivateKey.getInputStream()));
		DecryptRequest req = new DecryptRequest().withCiphertextBlob(encryptedBytes);
		ByteBuffer keyBytes = kms.decrypt(req).getPlaintext();
		byte[] key = BinaryUtils.copyAllBytesFrom(keyBytes);
		
		Assert.isTrue(key.length > 0, "decrypt works!");
	}
	
	@Test
	public void encryptData() {
		final AWSKMS kms = AWSKMSClientBuilder.defaultClient();
		
		final String secret = "supersecretvalue";
		ByteBuffer plaintextBytes = ByteBuffer.wrap(secret.getBytes(com.amazonaws.util.StringUtils.UTF8));
		EncryptRequest req = new EncryptRequest().withKeyId(kmsKeyArn).withPlaintext(plaintextBytes);
		ByteBuffer ciphertextBytes = kms.encrypt(req).getCiphertextBlob();
		final String ciphertext = BinaryUtils.toHex(BinaryUtils.copyAllBytesFrom(ciphertextBytes));
		System.out.println(ciphertext);
		Assert.isTrue(ciphertext.length() > 0, "encrypt test");
	}
	
	@Test
	public void decryptData() {
		
		final AWSKMS kms = AWSKMSClientBuilder.defaultClient();
		
		final String cipherText = "0102020078f8a62f385bd4b959078d79113f15074246e9ebad5cbd891ab1634c5ddec9fff401781eaf5b3e6b8e30f267ee79cafb3d4c0000006e306c06092a864886f70d010706a05f305d020100305806092a864886f70d010701301e060960864801650304012e3011040c9ab7caa45eaec94d7162cbca020110802bea184cf9a5efca64a6d3b6e0d35fec82235b4722a1be5d7c5c73138e18d64dcd9bdcc0ea595fae3dcbcb26";
		ByteBuffer cipherTextBytes = ByteBuffer.wrap(BinaryUtils.fromHex(cipherText));
		DecryptRequest req = new DecryptRequest().withCiphertextBlob(cipherTextBytes);
		ByteBuffer plainTextBytes = kms.decrypt(req).getPlaintext();
		String secret = new String(BinaryUtils.copyAllBytesFrom(plainTextBytes), com.amazonaws.util.StringUtils.UTF8);
		
		System.out.println(secret);
		Assert.isTrue(secret.length() > 0, "decrypt test");
	}

	@Test
	public void createDataKey() {
		
		final AWSKMS kms = AWSKMSClientBuilder.defaultClient();
		
		GenerateDataKeyRequest dataKeyRequest = new GenerateDataKeyRequest();
		dataKeyRequest.setKeyId(kmsKeyArn);
		dataKeyRequest.setKeySpec("AES_128");

		GenerateDataKeyResult dataKeyResult = kms.generateDataKey(dataKeyRequest);
		ByteBuffer plaintextKey = dataKeyResult.getPlaintext();
		ByteBuffer encryptedKey = dataKeyResult.getCiphertextBlob();
		
		final String plaintextKeyHex = BinaryUtils.toHex(BinaryUtils.copyAllBytesFrom(plaintextKey));
		System.out.println(plaintextKeyHex);
		Assert.isTrue(plaintextKeyHex.length() > 0, "data key hex test");
		
		final String encryptedKeyHex = BinaryUtils.toHex(BinaryUtils.copyAllBytesFrom(encryptedKey));
		System.out.println(encryptedKeyHex);
		Assert.isTrue(encryptedKeyHex.length() > 0, "enc data key hex test");	
	}
}
*/
