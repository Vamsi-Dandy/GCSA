/*
package com.dundermifflin.api;

import java.util.ArrayList;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.util.Assert;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.dundermifflin.data.entities.Employee;
import com.dundermifflin.data.entities.Ticket;
import com.dundermifflin.data.entities.User;


@RunWith(SpringRunner.class)
@SpringBootTest
public class ApiTests {

	
	@Value("${service.url}")
	private String serviceUrl;
	
	@Test
	public void ticketSearch() {
		String submittedBy = "Dwight%') AND ' -- ";
		String caller = "";
		String dueDate = "";
		String status = "";
		
		//Build post parameter JSON
		ObjectMapper mapper = new ObjectMapper();
		ObjectNode ticketSearch = mapper.createObjectNode();
		ticketSearch.put("submittedBy", submittedBy);
		ticketSearch.put("caller", caller);
		ticketSearch.put("dueDate", dueDate);
		ticketSearch.put("status", status);

		//Headers
		HttpHeaders headers = new HttpHeaders();
		headers.setContentType(MediaType.APPLICATION_JSON);
		
		//Request
		HttpEntity<String> request = new HttpEntity<String>(ticketSearch.toString(), headers);

		//Search database with sproc call
		RestTemplate template = new RestTemplate();
		ResponseEntity<ArrayList<Ticket>> response = template.exchange(String.format("%s/ticket/search", serviceUrl), HttpMethod.POST
				, request, new ParameterizedTypeReference<ArrayList<Ticket>>() {});
		
		if(response.getStatusCode() != HttpStatus.OK)
		{
			System.out.println(response.getBody());
			Assert.isTrue(response.getStatusCode().equals(HttpStatus.OK), "return code OK");
		}
		else
		{
			ArrayList<Ticket> tickets = response.getBody();
			Assert.isTrue(tickets.size() > 0, "entries found");
		}
	}
	
	@Test
	public void saveTicketTest() {
		
		Integer caseNumber = 8;
		
		//Get the ticket
		Ticket t = null;
		
		RestTemplate template = new RestTemplate();
		ResponseEntity<Ticket> entity = template.getForEntity(String.format("%s/ticket/%s", serviceUrl, caseNumber), Ticket.class);
		
		if(entity.getStatusCode() == HttpStatus.OK) {
			t = entity.getBody();
		}
		
		Assert.isTrue(t.getId() == caseNumber, "case match");
		
		//Save the ticket
		ObjectMapper mapper = new ObjectMapper();
		
		//Headers
		HttpHeaders headers = new HttpHeaders();
		headers.setContentType(MediaType.APPLICATION_JSON);
		
		//Request
		HttpStatus code = HttpStatus.INTERNAL_SERVER_ERROR;
		
		try {
			HttpEntity<String> request = new HttpEntity<String>(mapper.writeValueAsString(t), headers);
			
			//Make the call
			ResponseEntity<Ticket> response = template.exchange(String.format("%s/ticket", serviceUrl), HttpMethod.POST
					, request, Ticket.class);
			
			code = response.getStatusCode();
			
		} catch (JsonProcessingException e) {
			e.printStackTrace();
			Assert.isTrue(false, "Exception occured");
		}
		
		Assert.isTrue(code.equals(HttpStatus.OK), "Stats code OK");
	}
	
	@Test
	public void getUserTest() {
		
		User user = null;
		String username = "mscott";
		
		//Build post parameter JSON
		ObjectMapper mapper = new ObjectMapper();
		ObjectNode search = mapper.createObjectNode();
		search.put("userName", username);
		
		//Headers
		HttpHeaders headers = new HttpHeaders();
		headers.setContentType(MediaType.APPLICATION_JSON);
		
		//Request
		HttpEntity<String> request = new HttpEntity<String>(search.toString(), headers);

		//Make the call
		ResponseEntity<User> response = null;

		RestTemplate template = new RestTemplate();
		response = template.exchange(String.format("%s/user/search", serviceUrl), HttpMethod.POST
				, request, new ParameterizedTypeReference<User>() {});
	
		if(response.getStatusCode() != HttpStatus.OK)
		{
			System.out.println(response.getBody());
			Assert.isTrue(response.getStatusCode().equals(HttpStatus.OK), "return code OK");
		}
		else
		{
			user = response.getBody();
			Assert.isTrue(user.getUserName().equals(username), "user found");
			Assert.isTrue(user.getRoleNames().contains("Manager"), "manager role found.");
		}
	}

	@Test
	public void userSearchTest() {
		
		//Headers
		HttpHeaders headers = new HttpHeaders();
		headers.setContentType(MediaType.APPLICATION_JSON);
		
		//Request
		HttpEntity<String> request = new HttpEntity<String>(null, headers);

		//Make the call
		ResponseEntity<ArrayList<User>> response = null;
		
		RestTemplate template = new RestTemplate();
		response = template.exchange(String.format("%s/user", serviceUrl), HttpMethod.GET
			, request, new ParameterizedTypeReference<ArrayList<User>>() {});
	
		
		if(response.getStatusCode() != HttpStatus.OK)
		{
			System.out.println(response.getBody());
			Assert.isTrue(response.getStatusCode().equals(HttpStatus.OK), "return code OK");
		}
		else
		{
			ArrayList<User> users = response.getBody();
			Assert.isTrue(users.size() > 0, "entries found");
		}
	}
	
	@Test
	public void createUserTest() {
		
		String userName = "bobbytables";
		String password = "' OR 1=1 -- ";
		
		//Build post parameter JSON
		ObjectMapper mapper = new ObjectMapper();
		ObjectNode node = mapper.createObjectNode();
		node.put("userName", userName);
		node.put("password", password);
		
		//Headers
		HttpHeaders headers = new HttpHeaders();
		headers.setContentType(MediaType.APPLICATION_JSON);
		
		//Request
		HttpEntity<String> request = new HttpEntity<String>(node.toString(), headers);

		//Make the call
		ResponseEntity<User> response = null;
		RestTemplate template = new RestTemplate();
		response = template.exchange(String.format("%s/user", serviceUrl), HttpMethod.POST
			, request, new ParameterizedTypeReference<User>() {});
		
	
		if(response.getStatusCode() != HttpStatus.OK)
		{
			System.out.println(response.getBody());
			Assert.isTrue(response.getStatusCode().equals(HttpStatus.OK), "return code OK");
		}
		else
		{
			User u = response.getBody();
			Assert.isTrue(u.getId() > 0, "user created");
			Assert.isTrue(u.getUsername().equals(userName), "user created");
		}
	}
	
	@Test
	public void directReportTest() {
		int managerId = 1;
		
		//Headers
		HttpHeaders headers = new HttpHeaders();
		headers.setContentType(MediaType.APPLICATION_JSON);
		
		//Request
		HttpEntity<String> request = new HttpEntity<String>(null, headers);

		//Make the call
		ResponseEntity<ArrayList<Employee>> response = null;
		
		RestTemplate template = new RestTemplate();
		response = template.exchange(String.format("%s/manager/directreports/%s", serviceUrl, managerId), HttpMethod.GET
			, request, new ParameterizedTypeReference<ArrayList<Employee>>() {});
		
		if(response.getStatusCode() != HttpStatus.OK)
		{
			System.out.println(response.getBody());
			Assert.isTrue(response.getStatusCode().equals(HttpStatus.OK), "return code OK");
		}
		else
		{
			ArrayList<Employee> employees = response.getBody();
			Assert.isTrue(employees.size() > 0, "entries found");
		}
	}
}
*/
