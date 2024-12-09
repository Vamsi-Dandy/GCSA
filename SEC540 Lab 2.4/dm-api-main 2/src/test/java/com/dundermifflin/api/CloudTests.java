/*
package com.dundermifflin.api;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.util.Assert;

import com.amazonaws.AmazonServiceException;
import com.amazonaws.services.cloudfront.AmazonCloudFront;
import com.amazonaws.services.cloudfront.AmazonCloudFrontClient;
import com.amazonaws.services.cloudfront.AmazonCloudFrontClientBuilder;
import com.amazonaws.services.cloudfront.model.GetDistributionRequest;
import com.amazonaws.services.cloudfront.model.GetDistributionResult;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.Bucket;
import com.amazonaws.services.s3.model.ObjectListing;
import com.amazonaws.services.s3.model.S3Object;
import com.amazonaws.services.s3.model.S3ObjectInputStream;
import com.amazonaws.services.s3.model.S3ObjectSummary;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;


@RunWith(SpringRunner.class)
@SpringBootTest
public class CloudTests {
	
	@Value("${dundermifflin.s3.bucket}")
	private String s3BucketName;
	
	@Value("${dundermifflin.cloudfront.distributionid}")
	private String cloudFrontDistributionId;
	
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
	public void s3BucketItemDownload() {
		
		final AmazonS3 s3 = AmazonS3ClientBuilder.defaultClient();
		try {
		    
			List<Bucket> buckets = s3.listBuckets();
			
			System.out.println("Your Amazon S3 buckets are:");
			
			for (Bucket b : buckets) {
				if(b.getName().equals(s3BucketName)) {
					
					ObjectListing ol = s3.listObjects(b.getName());
				    List<S3ObjectSummary> objects = ol.getObjectSummaries();
				    
				    for(S3ObjectSummary os: objects) {
				    	
				    	S3Object o = s3.getObject(s3BucketName, os.getKey());
				    	
				    	if(o.getObjectMetadata().getContentType().equals("application/x-directory"))
			    			continue;
				    	
				    	System.out.println("   * " + os.getKey());
				    	
				    	//Get file content
				    	S3ObjectInputStream s3is = o.getObjectContent();
					    
					    File f = new File(os.getKey().split("/")[1]);
					    if(f.exists()) f.delete();
					    
					    FileOutputStream fos = new FileOutputStream(f);
					    byte[] read_buf = new byte[1024];
					    int read_len = 0;
					    while ((read_len = s3is.read(read_buf)) > 0) {
					        fos.write(read_buf, 0, read_len);
					    }
					    s3is.close();
					    fos.close();
					    
					    System.out.println(f.getAbsolutePath());
					    Assert.isTrue(f.exists(), "s3 file exists");
				    	break;
				    }
				}
			}
		} catch (AmazonServiceException e) {
		    System.err.println(e.getErrorMessage());
		    System.exit(1);
		} catch (FileNotFoundException e) {
		    System.err.println(e.getMessage());
		    System.exit(1);
		} catch (IOException e) {
		    System.err.println(e.getMessage());
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
	public void cloudFrontSignedUrlTest() {
		Protocol protocol = Protocol.https;
		String distributionDomain = "d3s4l2qp7afb4z.cloudfront.net";
		File privateKeyFile = new File("/Users/frank/Documents/dev/AWS/keys/cloudfront-private-key.der");
		String resourcePath = "Pay%20Stub%202017-09-30.pdf";
		String keyPairId = "APKAIGBNYV2MPTPJORFQ";
		//Date activeFrom = DateUtils.parseISO8601Date("2012-11-14T22:20:00.000Z");
		Date expiresOn = DateUtils.parseISO8601Date("2017-11-14T22:20:00.000Z");
		//String ipRange = "192.168.0.1/24";

		CookiesForCannedPolicy cookies = null;
		try {
			cookies = CloudFrontCookieSigner.getCookiesForCannedPolicy(protocol, distributionDomain,
					privateKeyFile, resourcePath, keyPairId, expiresOn);
		} catch (InvalidKeySpecException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		HttpClient client = new DefaultHttpClient();
		HttpGet httpGet = new HttpGet(SignerUtils.generateResourcePath(protocol, distributionDomain, resourcePath));

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

		//try {
		//	CookiesForCustomPolicy cookies2 = CloudFrontCookieSigner.getCookiesForCustomPolicy(protocol, distributionDomain,
		//			privateKeyFile, resourcePath, keyPairId, expiresOn, activeFrom, ipRange);
		//} catch (InvalidKeySpecException e) {
		//	// TODO Auto-generated catch block
		//	e.printStackTrace();
		//} catch (IOException e) {
		//	// TODO Auto-generated catch block
		//	e.printStackTrace();
		//}
	}
}
*/
