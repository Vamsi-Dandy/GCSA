package com.dundermifflin.data.repositories;

import com.dundermifflin.data.entities.Employee;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Spring Data JPA Repository for the {@link Result} entity.
 */
public interface EmployeeRepository extends JpaRepository<Employee, Long> {
	
	public Employee findById(int id);
	
	public Employee findByUserId(int id);
	
	public List<Employee> findByManagerId(int id);
}
