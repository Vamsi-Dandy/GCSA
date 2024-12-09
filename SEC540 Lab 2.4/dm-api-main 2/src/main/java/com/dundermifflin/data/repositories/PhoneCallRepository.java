package com.dundermifflin.data.repositories;

import com.dundermifflin.data.entities.PhoneCall;

import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Spring Data JPA Repository for the {@link Result} entity.
 */
public interface PhoneCallRepository extends JpaRepository<PhoneCall, Long> {
	
	public PhoneCall findById(int id);
}
