package com.dundermifflin.api.services;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;

import jakarta.inject.Inject;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import com.dundermifflin.api.models.UserSearchModel;
import com.dundermifflin.data.entities.User;
import com.dundermifflin.data.repositories.UserRepository;

@RestController
public class UserServiceController {

	@Inject
	private UserRepository repository;

	@RequestMapping(path = "/api/user/{id}", method = RequestMethod.DELETE)
	public ResponseEntity<String> deleteUserById(@PathVariable int id) {

		try {
			repository.deleteById(id);
			return new ResponseEntity<String>("Success", HttpStatus.OK);
		} catch (Exception ex) {
			return new ResponseEntity<String>("Fail", HttpStatus.NOT_FOUND);
		}
	}

	@RequestMapping(path = "/api/user/{id}", method = RequestMethod.GET)
	public ResponseEntity<User> getUserById(@PathVariable int id) {

		User user = null;
		try {
			user = repository.findById(id);
			return new ResponseEntity<User>(user, HttpStatus.OK);
		} catch (Exception ex) {
			return new ResponseEntity<User>(HttpStatus.NOT_FOUND);
		}
	}

	@RequestMapping(path = "/api/user/search", method = RequestMethod.POST)
	public ResponseEntity<User> findByUsername(@RequestBody UserSearchModel request) {

		User user = null;

		try {
			user = repository.findByUserName(request.getUserName());

			if (user == null)
				return new ResponseEntity<User>(HttpStatus.NOT_FOUND);
			else
				return new ResponseEntity<User>(user, HttpStatus.OK);

		} catch (Exception e) {
			System.out.println(e.toString());
			return new ResponseEntity<User>(HttpStatus.INTERNAL_SERVER_ERROR);
		}
	}

	@RequestMapping(path = "/api/user", method = RequestMethod.GET)
	public ResponseEntity<ArrayList<User>> findAllUsers() {

		ArrayList<User> users;

		try {
			users = (ArrayList<User>) repository.findAll();
			return new ResponseEntity<ArrayList<User>>(users, HttpStatus.OK);

		} catch (Exception e) {
			System.out.println(e.toString());
			return new ResponseEntity<ArrayList<User>>(HttpStatus.INTERNAL_SERVER_ERROR);
		}
	}

	@RequestMapping(path = "/api/user", method = RequestMethod.POST)
	public ResponseEntity<User> postUser(@RequestBody User user) {

		User entity = repository.findById(user.getId());

		// user already exists
		if (entity == null)
			throw new UsernameNotFoundException("Invalid user id");

		// Create entity and save
		entity.setPassword(user.getPassword());
		entity.setPasswordQuestion(user.getPasswordQuestion());
		entity.setPasswordAnswer(user.getPasswordAnswer());
		repository.save(entity);

		// Pull object from the db
		user = repository.findById(entity.getId());

		// Return to client
		return new ResponseEntity<User>(user, HttpStatus.OK);
	}

	@RequestMapping(path = "/api/user/create", method = RequestMethod.POST)
	public ResponseEntity<User> createUser(@RequestBody User user) {

		User entity = repository.findByUserName(user.getUsername());

		// user already exists
		if (entity != null)
			throw new UsernameNotFoundException("Invalid username");

		// Create entity and save
		entity = new User();
		entity.setUserName(user.getUsername());
		entity.setPassword(user.getPassword());
		entity.setCreateDate(Timestamp.valueOf(LocalDateTime.now()));
		entity.setActive(true);
		repository.save(entity);

		// Pull object from the db
		user = repository.findByUserName(entity.getUserName());

		// Return to client
		return new ResponseEntity<User>(user, HttpStatus.OK);
	}
}