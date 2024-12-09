/*
package com.dundermifflin.api;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;


import javax.inject.Inject;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.util.Assert;

import com.dundermifflin.data.entities.Customer;
import com.dundermifflin.data.entities.Employee;
import com.dundermifflin.data.entities.KnowledgeBase;
import com.dundermifflin.data.entities.PhoneCall;
import com.dundermifflin.data.entities.Ticket;
import com.dundermifflin.data.entities.User;
import com.dundermifflin.data.repositories.CustomerRepository;
import com.dundermifflin.data.repositories.EmployeeRepository;
import com.dundermifflin.data.repositories.KnowledgeBaseRepository;
import com.dundermifflin.data.repositories.PhoneCallRepository;
import com.dundermifflin.data.repositories.TicketRepository;
import com.dundermifflin.data.repositories.TicketSearchRepository;
import com.dundermifflin.data.repositories.UserRepository;

@RunWith(SpringRunner.class)
@SpringBootTest
public class DatabaseTests {

	@Inject
	EmployeeRepository empRepository;
	
	@Inject
	CustomerRepository custRepository;
	
	@Inject
	KnowledgeBaseRepository kbRepository;
	
	@Inject 
	PhoneCallRepository phoneRepository;
	
	@Inject
	TicketRepository ticketRepository;
	
	@Inject
	TicketSearchRepository searchRepository;
	
	@Inject
	UserRepository userRepository;
	
	@Test
	public void contextLoads() {
	}
	
	@Test
	public void employeeDataTest() {
		Integer id = 2;
		Employee e = empRepository.findById(id);
		
		Assert.isTrue(e.getId() == id, "Database test - id match.");
		Assert.isTrue(e.getFirstName().equals("Jim"), "Database test - name match");
		
		Assert.isTrue(e.getManager() != null, "Manger is not null");
		Assert.isTrue(e.getManager().getId() == 1, "Manager is Michael");
		
		Employee e2 = empRepository.findByUserId(1);
		Assert.isTrue(e2.getFirstName().equals("Michael"), "by user name test");
		Assert.isTrue(e2.getUser().getUserName().equals("mscott"), "by user name - user name test");
		Assert.isTrue(e2.getUser().getRoleNames().equals("Manager"), "role check");
	}
	
	@Test
	public void customerDataTest() {
		Integer id = 1;
		Customer c = custRepository.findById(id);
		
		Assert.isTrue(c.getId() == id, "Database test - id match.");
		Assert.isTrue(c.getFirstName().equals("Toby"), "Database test - name match");
	}
	
	@Test
	public void kbDataTest() {
		Integer id = 1;
		KnowledgeBase kb = kbRepository.findById(id);
		
		Assert.isTrue(kb.getId() == id, "Database test - id match.");
		Assert.isTrue(kb.getTitle().equals("Dwight's Super Desk"), "Database test - name match");
	}
	
	@Test
	public void phoneCallDataTest() {
		Integer id = 1;
		PhoneCall p = phoneRepository.findById(id);
		
		Assert.isTrue(p.getId() == id, "Database test - id match.");
		Assert.isTrue(p.getCallTime().getDate() == 11, "Database test - name match");
		
		Ticket t = p.getTicketItem();
		Assert.isTrue(t.getStatus().equals("Assigned"), "ticket status match");
		
		Employee aTo = t.getAssignedTo();
		Assert.isTrue(aTo.getFirstName().equals("Jim"), "assigned to name");
		
		Employee aOp = t.getOpenedBy();
		Assert.isTrue(aOp.getFirstName().equals("Dwight"), "opened by name");
		
		Customer c = t.getCustomer();
		Assert.isTrue(c.getFirstName().equals("Toby"), "customer first name");
	}

	@Test
	public void ticketDataTest() {
		
		List<Ticket> tickets = ticketRepository.findAll();
		
		Assert.isTrue(tickets.size() > 0, "objects returned");
	}
	
	@Test
	public void userDataTest() {
		String username = "mscott";
		User u = userRepository.findByUserName(username);
		Assert.isTrue(u.getUsername().equals(username), "username match");
		Assert.isTrue(u.getRoles().size() > 0, "has roles");
		Assert.isTrue(u.getRoleNames().contains("Manager"), "role name match");
	}
	
	@Test
	public void createUserTest() {
		
		//Create entity and save
		User u = userRepository.findByUserName("bobbytables");
		Assert.isNull(u, "New user");
		
		User entity = new User();
		//entity.setId(7);
		entity.setUserName("bobbytables");
		entity.setCreateDate(Timestamp.valueOf(LocalDateTime.now()));
		entity.setPassword("'; DROP TABLE user; -- ");
		entity.setActive(true);
		userRepository.save(entity);
		
		//Pull object from the db
		entity = userRepository.findByUserName(entity.getUserName());
		Assert.isTrue(entity.getId() > 0, "user id is assigned");
	}
	
	@Test
	public void getDirectReportTest() {
		int id = 1;
		
		List<Employee> directReports = empRepository.findByManagerId(id);
		
		Assert.isTrue(directReports.size() > 0, "directReports were found");
	}
	
	@Test
	public void searchTest() throws SQLException {
		List<Ticket> all = searchRepository.search("", "", "", "");
		Assert.isTrue(all.size() >= 10, "all items found");
		
		List<Ticket> dwight = searchRepository.search("Dwight", "",  "",  "");
		Assert.isTrue(dwight.size() >= 3 && dwight.size() < all.size(), "submitted items found");
		
		List<Ticket> michael = searchRepository.search("", "Michael", "", "");
		Assert.isTrue(michael.size() == 0, "caller items found");
		
		List<Ticket> submitted = searchRepository.search("", "", "Submit", "");
		Assert.isTrue(submitted.size() >= 5 && submitted.size() < all.size(), "submitted items found");
		
		List<Ticket> due = searchRepository.search("", "", "", "2017-01-01");
		Assert.isTrue(due.size() >= 6 && due.size() < all.size(), "due items found");
	}
}
*/