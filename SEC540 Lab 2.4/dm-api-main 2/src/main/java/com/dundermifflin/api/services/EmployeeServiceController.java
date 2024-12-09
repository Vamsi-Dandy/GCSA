package com.dundermifflin.api.services;

import jakarta.inject.Inject;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import com.dundermifflin.data.entities.Employee;
import com.dundermifflin.data.entities.User;
import com.dundermifflin.data.repositories.EmployeeRepository;
import com.dundermifflin.data.repositories.UserRepository;

@RestController
public class EmployeeServiceController {

	@Inject
	EmployeeRepository empRepository;

	@Inject
	UserRepository userRepository;

	@RequestMapping(path = "/api/employee/{id}", method = RequestMethod.GET)
	public ResponseEntity<Employee> getEmployee(@PathVariable int id) {

		Employee e = empRepository.findById(id);

		if (e != null) {
			return new ResponseEntity<Employee>(e, HttpStatus.OK);
		} else
			return new ResponseEntity<Employee>(HttpStatus.NOT_FOUND);
	}

	@RequestMapping(path = "/api/employee/user/{userName}", method = RequestMethod.GET)
	public ResponseEntity<Employee> getEmployeeByUserId(@PathVariable String userName) {

		User u = userRepository.findByUserName(userName);
		Employee e = empRepository.findByUserId(u.getId());

		if (e != null) {
			return new ResponseEntity<Employee>(e, HttpStatus.OK);
		} else
			return new ResponseEntity<Employee>(HttpStatus.NOT_FOUND);
	}
}
