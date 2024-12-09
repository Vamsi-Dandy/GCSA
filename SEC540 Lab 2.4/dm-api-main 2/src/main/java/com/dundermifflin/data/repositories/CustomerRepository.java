package com.dundermifflin.data.repositories;

import com.dundermifflin.data.entities.Customer;

import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Spring Data JPA Repository for the {@link Result} entity.
 */
public interface CustomerRepository extends JpaRepository<Customer, Long> {
	
	public Customer findById(int id);
}
