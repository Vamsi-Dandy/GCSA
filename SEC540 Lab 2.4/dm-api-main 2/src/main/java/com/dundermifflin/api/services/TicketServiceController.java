package com.dundermifflin.api.services;

import java.util.ArrayList;

import jakarta.inject.Inject;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import com.dundermifflin.data.entities.Ticket;
import com.dundermifflin.data.repositories.TicketRepository;
import com.dundermifflin.data.repositories.TicketSearchRepository;
import com.dundermifflin.api.models.TicketSearchModel;

@RestController
public class TicketServiceController extends Throwable {

	/**
	 *
	 */
	private static final long serialVersionUID = -1398786867025934427L;

	@Inject
	TicketRepository repository;

	@Inject
	TicketSearchRepository searchRepository;

	@RequestMapping(path = "/api/ticket/{id}", method = RequestMethod.GET)
	public ResponseEntity<Ticket> getTicket(@PathVariable int id) throws Exception {
		Ticket t = repository.findById(id);
		if (t != null) {
			return new ResponseEntity<Ticket>(t, HttpStatus.OK);
		} else
			return new ResponseEntity<Ticket>(HttpStatus.NOT_FOUND);
	}

	@RequestMapping(path = "/api/ticket", method = RequestMethod.POST)
	public ResponseEntity<Ticket> postTicket(@RequestBody Ticket ticket) throws Exception {
		Ticket t = repository.findById(ticket.getId());

		// Set the properties
		t.setComments(ticket.getComments());
		t.setDescription(ticket.getDescription());

		repository.save(t);

		return new ResponseEntity<Ticket>(t, HttpStatus.OK);
	}

	@RequestMapping(path = "/api/ticket/search", method = RequestMethod.POST)
	public ResponseEntity<ArrayList<Ticket>> searchTickets(@RequestBody TicketSearchModel search) throws Exception {

		ArrayList<Ticket> tickets = new ArrayList<>();

		tickets = searchRepository.search(search.getSubmittedBy(), search.getCaller(), search.getStatus(),
				search.getDueDateTimestamp() != null ? search.getDueDateTimestamp().toString() : "");

		return new ResponseEntity<ArrayList<Ticket>>(tickets, HttpStatus.OK);
	}
}
