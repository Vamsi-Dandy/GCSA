package com.dundermifflin.api.services;

import java.util.List;

import jakarta.inject.Inject;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import com.dundermifflin.data.entities.Employee;
import com.dundermifflin.data.repositories.EmployeeRepository;

@RestController
public class ManagerServiceController {

	@Inject
	EmployeeRepository empRepository;

	@RequestMapping(path = "/api/manager/directreports/{id}", method = RequestMethod.GET)
	public ResponseEntity<List<Employee>> getDirectReports(@PathVariable int id) {

		List<Employee> directReports = empRepository.findByManagerId(id);

		if (directReports != null) {
			return new ResponseEntity<List<Employee>>(directReports, HttpStatus.OK);
		} else {
			return new ResponseEntity<List<Employee>>(HttpStatus.NOT_FOUND);
		}
	}
}
