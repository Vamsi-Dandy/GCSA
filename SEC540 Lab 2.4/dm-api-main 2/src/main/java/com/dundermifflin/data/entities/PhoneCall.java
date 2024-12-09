package com.dundermifflin.data.entities;

import java.io.Serializable;
import java.sql.Timestamp;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name = "phone_call")
public class PhoneCall implements Serializable {

	private static final long serialVersionUID = 2336215474804025282L;

	public PhoneCall() {
		super();
	}

	public PhoneCall(final int id, final Timestamp callTime,
			final String notes, final Ticket ticketItem) {
		super();
		this.id = id;
		this.callTime = callTime;
		this.notes = notes;
		this.ticketItem = ticketItem;
	}

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private int id;

	@Column(name = "call_time")
	private Timestamp callTime;

	@Column(name = "notes", columnDefinition = "TEXT")
	private String notes;

	@JsonIgnore
	@ManyToOne(targetEntity = Ticket.class, cascade = CascadeType.ALL, fetch = FetchType.EAGER)
	@JoinColumn(name = "ticket_id")
	private Ticket ticketItem;

	public int getId() {
		return id;
	}

	public void setId(final int id) {
		this.id = id;
	}

	public Timestamp getCallTime() {
		return callTime;
	}

	public void setCallTime(final Timestamp callTime) {
		this.callTime = callTime;
	}

	public String getNotes() {
		return notes;
	}

	public void setNotes(final String notes) {
		this.notes = notes;
	}

	public Ticket getTicketItem() {
		return ticketItem;
	}

	public void setTicketItem(final Ticket ticketItem) {
		this.ticketItem = ticketItem;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result
				+ ((callTime == null) ? 0 : callTime.hashCode());
		result = prime * result
				+ ((ticketItem == null) ? 0 : ticketItem.hashCode());
		result = prime * result + id;
		result = prime * result + ((notes == null) ? 0 : notes.hashCode());
		return result;
	}

	@Override
	public boolean equals(final Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		final PhoneCall other = (PhoneCall) obj;
		if (callTime == null) {
			if (other.callTime != null)
				return false;
		} else if (!callTime.equals(other.callTime))
			return false;
		if (ticketItem == null) {
			if (other.ticketItem != null)
				return false;
		} else if (!ticketItem.equals(other.ticketItem))
			return false;
		if (id != other.id)
			return false;
		if (notes == null) {
			if (other.notes != null)
				return false;
		} else if (!notes.equals(other.notes))
			return false;
		return true;
	}

	@Override
	public String toString() {
		return "Call [id=" + id + ", callTime="
				+ callTime + ", notes=" + notes + ", ticketItem=" + ticketItem
				+ "]";
	}
}
