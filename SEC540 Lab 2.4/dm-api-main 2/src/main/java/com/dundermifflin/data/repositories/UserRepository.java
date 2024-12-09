package com.dundermifflin.data.repositories;

import com.dundermifflin.data.entities.User;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Spring Data JPA Repository for the {@link Result} entity.
 */
public interface UserRepository extends JpaRepository<User, Long> {

	public User findByUserName(String userName);

	public User findById(int id);
	
	public List<User> findAll();
	
	public void deleteById(int id);
}
