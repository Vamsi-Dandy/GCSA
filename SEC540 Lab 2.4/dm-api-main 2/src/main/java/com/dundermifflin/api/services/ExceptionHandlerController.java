package com.dundermifflin.api.services;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import com.dundermifflin.api.services.TicketServiceController;

@ControllerAdvice
public class ExceptionHandlerController {

	@ExceptionHandler(value = { TicketServiceController.class })
	public ResponseEntity<String> handleException(Exception e) {
		
		return new ResponseEntity<String>(e.toString(), HttpStatus.INTERNAL_SERVER_ERROR);
	}
}
