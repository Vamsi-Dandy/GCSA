package com.dundermifflin.api.services;

import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import com.dundermifflin.data.entities.Customer;

@RestController
public class CustomerServiceController {

	@RequestMapping(path = "/api/customer/{id}", method = RequestMethod.GET)
	public Customer getCustomer(@PathVariable int id) {
		return null;
	}
}
