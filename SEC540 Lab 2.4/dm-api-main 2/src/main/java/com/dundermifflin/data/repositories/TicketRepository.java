package com.dundermifflin.data.repositories;

import com.dundermifflin.data.entities.Ticket;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Spring Data JPA Repository for the {@link Result} entity.
 */
public interface TicketRepository extends JpaRepository<Ticket, Long> {

	public Ticket findById(int id);

	public List<Ticket> findAll();
}
