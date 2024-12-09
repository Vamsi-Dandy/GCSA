/*
package com.dundermifflin.web;

import org.apache.http.HttpResponse;
import org.apache.http.client.*;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.core.io.Resource;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.util.Assert;

import com.amazonaws.AmazonServiceException;
import com.amazonaws.auth.RSA;
import com.amazonaws.services.cloudfront.AmazonCloudFront;
import com.amazonaws.services.cloudfront.AmazonCloudFrontClientBuilder;
import com.amazonaws.services.cloudfront.CloudFrontCookieSigner;
import com.amazonaws.services.cloudfront.CloudFrontUrlSigner;
import com.amazonaws.services.cloudfront.CloudFrontCookieSigner.CookiesForCannedPolicy;
import com.amazonaws.services.cloudfront.CloudFrontCookieSigner.CookiesForCustomPolicy;
import com.amazonaws.services.cloudfront.model.Distribution;
import com.amazonaws.services.cloudfront.model.GetDistributionRequest;
import com.amazonaws.services.cloudfront.model.GetDistributionResult;
import com.amazonaws.services.cloudfront.model.Signer;
import com.amazonaws.services.cloudfront.util.SignerUtils;
import com.amazonaws.services.kms.AWSKMS;
import com.amazonaws.services.kms.AWSKMSClientBuilder;
import com.amazonaws.services.kms.model.DecryptRequest;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.*;
import com.amazonaws.util.BinaryUtils;
import com.amazonaws.util.IOUtils;
import com.dundermifflin.web.models.discount.DiscountModel;
import com.dundermifflin.web.services.CloudFrontService;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.security.PrivateKey;
import java.security.spec.InvalidKeySpecException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.TimeZone;

import javax.inject.Inject;


@SuppressWarnings("deprecation")
@RunWith(SpringRunner.class)
@SpringBootTest
public class CloudFrontTests {
	
	@Inject
	CloudFrontService service;
	
	@Value("${dundermifflin.s3.bucket}")
	private String s3BucketName;
	
	@Value("${dundermifflin.cloudfront.distributionid}")
	private String cloudFrontDistributionId;
	
    @Value("${dundermifflin.cloudfront.private-key}")
    private Resource cloudFrontPrivateKey;
	
    @Value("${dundermifflin.kms.keyid}")
	private String kmsKeyArn;
    
    private static final String TAG_NAME = "Name";
	private static final String TAG_DESCRIPTION = "Description";
	
	@Test
	public void s3BucketListTest() {
		
		final AmazonS3 s3 = AmazonS3ClientBuilder.defaultClient();
		List<Bucket> buckets = s3.listBuckets();
		
		System.out.println("Your Amazon S3 buckets are:");
		
		for (Bucket b : buckets) {

			if(b.getName().equals(s3BucketName)) {
				System.out.println("* " + b.getName());
				
				ObjectListing ol = s3.listObjects(b.getName());
			    List<S3ObjectSummary> objects = ol.getObjectSummaries();
			    for(S3ObjectSummary os: objects) {
			    	System.out.println("   * " + os.getKey());
			    }
			}
		}
		
		Assert.isTrue(buckets.size() > 0, "bucket size test.");
	}
	
	@Test
	public void s3BucketDiscountItemsTest() {
		
		
		final AmazonS3 s3 = AmazonS3ClientBuilder.defaultClient();
		
		try {
		    
			List<Bucket> buckets = s3.listBuckets();
			
			for (Bucket b : buckets) {
				if(b.getName().equals(s3BucketName)) {
					
					ObjectListing ol = s3.listObjects(b.getName());
				    List<S3ObjectSummary> objects = ol.getObjectSummaries();
				    
				    for(S3ObjectSummary os: objects) {
				    	
				    	S3Object o = s3.getObject(s3BucketName, os.getKey());
				    	
				    	if(o.getObjectMetadata().getContentType().equals("application/x-directory"))
			    			continue;
				    	
				    	DiscountModel item = new DiscountModel();
				    	item.setKey(os.getKey());
				    	
				    	GetObjectTaggingRequest tagRequest = new GetObjectTaggingRequest(s3BucketName, os.getKey());
				    	GetObjectTaggingResult  tagResponse = s3.getObjectTagging(tagRequest);
				        
				    	List<Tag> tags = tagResponse.getTagSet();
				    	for(Tag t: tags) {
				    		
				    		if(t.getKey().equals(TAG_NAME))
				    			item.setName(t.getValue());
				    		
				    		if(t.getKey().equals(TAG_DESCRIPTION))
				    			item.setDescription(t.getValue());
				    	}
				    	
				    	System.out.println("Discount Item: " + item.toString());
				    	
				    	//Get file content
				    	//S3ObjectInputStream s3is = o.getObjectContent();
					    
					    //File f = new File(os.getKey().split("/")[1]);
					    //if(f.exists()) f.delete();
					    
					    //FileOutputStream fos = new FileOutputStream(f);
					    //byte[] read_buf = new byte[1024];
					    //int read_len = 0;
					    //while ((read_len = s3is.read(read_buf)) > 0) {
					    //    fos.write(read_buf, 0, read_len);
					   // }
					    //s3is.close();
					    //fos.close();
					    
					    //System.out.println(f.getAbsolutePath());
					    //Assert.isTrue(f.exists(), "s3 file exists");
				    	//break;
				    }
				}
			}
		} catch (AmazonServiceException e) {
		    System.err.println(e.getErrorMessage());
		    System.exit(1);
		}
	}

	@Test
	public void cloudFrontListTest() {

		//Get cloud front domain name from distribution id
		final AmazonCloudFront cloudFront = AmazonCloudFrontClientBuilder.defaultClient();
		GetDistributionRequest distributionRequest = new GetDistributionRequest(cloudFrontDistributionId);
		GetDistributionResult distribution = cloudFront.getDistribution(distributionRequest);
		String cloudFrontDomain = distribution.getDistribution().getDomainName();
				
		final AmazonS3 s3 = AmazonS3ClientBuilder.defaultClient();
		List<Bucket> buckets = s3.listBuckets();
		
		for (Bucket b : buckets) {
			
			if(b.getName().equals(s3BucketName)) {
				
				ObjectListing ol = s3.listObjects(b.getName());
			    List<S3ObjectSummary> objects = ol.getObjectSummaries();
			    for(S3ObjectSummary os: objects) {
			    	
			    	S3Object o = s3.getObject(s3BucketName, os.getKey());
			    	
			    	if(o.getObjectMetadata().getContentType().equals("application/x-directory"))
		    			continue;
			    	
			    	String url = String.format("https://%s/%s", cloudFrontDomain, os.getKey());
			    	System.out.println(url);
			    }
			}
		}		
	}
	
	@Test
	public void cloudFrontSignedCannedCookieTest() throws InvalidKeySpecException, IOException {
		
		//Get the cloud front distribution
		Distribution distribution = service.getCloudFrontDistribution();
		
		//Get the domain & key pair id
		String distributionDomain = distribution.getDomainName();
		String keyPairId = "";
		List<Signer> signers = distribution.getActiveTrustedSigners().getItems();
		for (Signer s : signers) {
			List<String> keys = s.getKeyPairIds().getItems();
			if(!keys.isEmpty())
				keyPairId = keys.get(0);
		}
		
		//Get the coupons from the bucket
		ArrayList<DiscountModel> discounts = service.getDiscounts(distribution);
		
		Calendar expirationDate = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
		expirationDate.add(Calendar.MINUTE, 15);

		for(DiscountModel d : discounts) {
			
			System.out.println(d.toString());
			
			CookiesForCannedPolicy cookies = null;
			try {
				cookies = CloudFrontCookieSigner.getCookiesForCannedPolicy(SignerUtils.Protocol.https
						, distributionDomain, cloudFrontPrivateKey.getFile(), d.getKey()
						, keyPairId, expirationDate.getTime());
			
			} catch (InvalidKeySpecException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
			HttpClient client = new DefaultHttpClient();
			HttpGet httpGet = new HttpGet(d.getUrl());
			httpGet.addHeader("Cookie", cookies.getExpires().getKey() + "=" + cookies.getExpires().getValue());
			httpGet.addHeader("Cookie", cookies.getSignature().getKey() + "=" + cookies.getSignature().getValue());
			httpGet.addHeader("Cookie", cookies.getKeyPairId().getKey() + "=" + cookies.getKeyPairId().getValue());

			System.out.println(cookies.getExpires().getKey() + "=" + cookies.getExpires().getValue());
			System.out.println(cookies.getSignature().getKey() + "=" + cookies.getSignature().getValue());
			System.out.println(cookies.getKeyPairId().getKey() + "=" + cookies.getKeyPairId().getValue());

			try {
				HttpResponse response = client.execute(httpGet);
				System.out.println(response.toString());
			} catch (ClientProtocolException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			finally {
				
			}
		}
	}
	
	@Test
	public void cloudFrontSignedCustomCookieTest() throws InvalidKeySpecException, IOException {
		
		//Get the cloud front distribution
		Distribution distribution = service.getCloudFrontDistribution();
		
		//Get the domain & key pair id
		String distributionDomain = distribution.getDomainName();
		String keyPairId = "";
		List<Signer> signers = distribution.getActiveTrustedSigners().getItems();
		for (Signer s : signers) {
			List<String> keys = s.getKeyPairIds().getItems();
			if(!keys.isEmpty())
				keyPairId = keys.get(0);
		}
		
		//Get the coupons from the bucket
		ArrayList<DiscountModel> discounts = service.getDiscounts(distribution);
		
		Calendar activeDate = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
		activeDate.add(Calendar.MINUTE, -1);
		Calendar expirationDate = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
		expirationDate.add(Calendar.MINUTE, 15);
		
		CookiesForCustomPolicy customCookies = null;
		try {
			
			customCookies = CloudFrontCookieSigner.getCookiesForCustomPolicy(SignerUtils.Protocol.https
					, distributionDomain, cloudFrontPrivateKey.getFile(), "coupons/*", keyPairId
					, expirationDate.getTime(), activeDate.getTime(), "0.0.0.0/0");
		} catch (InvalidKeySpecException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		for(DiscountModel d : discounts) {
			
			System.out.println(d.toString());
		
			HttpClient client = new DefaultHttpClient();
			HttpGet httpGet = new HttpGet(d.getUrl());
			httpGet.addHeader("Cookie", customCookies.getPolicy().getKey() + "=" + customCookies.getPolicy().getValue());
			httpGet.addHeader("Cookie", customCookies.getSignature().getKey() + "=" + customCookies.getSignature().getValue());
			httpGet.addHeader("Cookie", customCookies.getKeyPairId().getKey() + "=" + customCookies.getKeyPairId().getValue());

			System.out.println(customCookies.getPolicy().getKey() + "=" + customCookies.getPolicy().getValue());
			System.out.println(customCookies.getSignature().getKey() + "=" + customCookies.getSignature().getValue());
			System.out.println(customCookies.getKeyPairId().getKey() + "=" + customCookies.getKeyPairId().getValue());

			try {
				HttpResponse response = client.execute(httpGet);
				System.out.println(response.toString());
			} catch (ClientProtocolException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
			finally {
				
			}
		}
	}
	
	@Test
	public void cloudFrontSignedUrlTest() throws InvalidKeySpecException, IOException {
		
		//Get the cloud front distribution
		Distribution distribution = service.getCloudFrontDistribution();
		
		//Get the domain & key pair id
		String distributionDomain = distribution.getDomainName();
		String keyPairId = "";
		List<Signer> signers = distribution.getActiveTrustedSigners().getItems();
		for (Signer s : signers) {
			List<String> keys = s.getKeyPairIds().getItems();
			if(!keys.isEmpty())
				keyPairId = keys.get(0);
		}
		
		//Get the coupons from the bucket
		ArrayList<DiscountModel> discounts = service.getDiscounts(distribution);
		
		Calendar activeDate = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
		activeDate.add(Calendar.MINUTE, -1);
		Calendar expirationDate = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
		expirationDate.add(Calendar.MINUTE, 15);
				
		for(DiscountModel d : discounts) {
			
			System.out.println(d.toString());
		
			try {
				PrivateKey key = RSA.privateKeyFromPKCS8(IOUtils.toByteArray(cloudFrontPrivateKey.getInputStream()));
				final String resourcePath = SignerUtils.generateResourcePath(SignerUtils.Protocol.https, distributionDomain, d.getKey());
				final String policy = CloudFrontUrlSigner.buildCustomPolicyForSignedUrl(resourcePath, expirationDate.getTime(), "0.0.0.0/0", activeDate.getTime());
				String signedUrl = CloudFrontUrlSigner.getSignedURLWithCustomPolicy(resourcePath, keyPairId, key, policy);
				d.setUrl(signedUrl);
				
			} catch (InvalidKeySpecException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
			
			HttpClient client = new DefaultHttpClient();
			HttpGet httpGet = new HttpGet(d.getUrl());
			
			System.out.println(d.getUrl());
			
			try {
				HttpResponse response = client.execute(httpGet);
				System.out.println(response.toString());
			} catch (ClientProtocolException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
			finally {
				
			}
		}
	}
	
	@Test
	public void cloudFrontSignedUrlEncryptedKeyTest() throws InvalidKeySpecException, IOException {
		
		//Get the cloud front distribution
		Distribution distribution = service.getCloudFrontDistribution();
		
		//Get the domain & key pair id
		String distributionDomain = distribution.getDomainName();
		String keyPairId = "";
		List<Signer> signers = distribution.getActiveTrustedSigners().getItems();
		for (Signer s : signers) {
			List<String> keys = s.getKeyPairIds().getItems();
			if(!keys.isEmpty())
				keyPairId = keys.get(0);
		}
		
		//Get the coupons from the bucket
		ArrayList<DiscountModel> discounts = service.getDiscounts(distribution);
		
		Calendar activeDate = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
		activeDate.add(Calendar.MINUTE, -1);
		Calendar expirationDate = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
		expirationDate.add(Calendar.MINUTE, 15);
				
		for(DiscountModel d : discounts) {
			
			System.out.println(d.toString());
		
			try {
				//Decrypt the key
				final AWSKMS kms = AWSKMSClientBuilder.defaultClient();
				
				//Get the encrypted key bytes from the file input stream
				ByteBuffer encryptedBytes = ByteBuffer.wrap(IOUtils.toByteArray(cloudFrontPrivateKey.getInputStream()));
				DecryptRequest req = new DecryptRequest().withCiphertextBlob(encryptedBytes);
				ByteBuffer keyBytes = kms.decrypt(req).getPlaintext();
				
				//Load the key data and generate URLs
				PrivateKey key = RSA.privateKeyFromPKCS8(BinaryUtils.copyAllBytesFrom(keyBytes));
				final String resourcePath = SignerUtils.generateResourcePath(SignerUtils.Protocol.https, distributionDomain, d.getKey());
				final String policy = CloudFrontUrlSigner.buildCustomPolicyForSignedUrl(resourcePath, expirationDate.getTime(), "0.0.0.0/0", activeDate.getTime());
				String signedUrl = CloudFrontUrlSigner.getSignedURLWithCustomPolicy(resourcePath, keyPairId, key, policy);
				d.setUrl(signedUrl);
				
			} catch (InvalidKeySpecException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
			
			HttpClient client = new DefaultHttpClient();
			HttpGet httpGet = new HttpGet(d.getUrl());
			
			System.out.println(d.getUrl());
			
			try {
				HttpResponse response = client.execute(httpGet);
				System.out.println(response.toString());
			} catch (ClientProtocolException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
			finally {
				
			}
		}
	}
}
*/