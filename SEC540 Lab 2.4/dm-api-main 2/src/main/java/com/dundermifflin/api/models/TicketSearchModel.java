package com.dundermifflin.api.models;

import java.util.Date;
import java.sql.Timestamp;
import java.text.ParseException;
import java.util.Locale;

import org.apache.commons.lang3.StringUtils;
import org.springframework.format.datetime.DateFormatter;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public class TicketSearchModel {

	private String submittedBy;

    private String caller;
    
	private String dueDate;
    
    private String status;

    
    public String getSubmittedBy() {
		return submittedBy;
	}

	public void setSubmittedBy(String submittedBy) {
		this.submittedBy = submittedBy;
	}

	public String getCaller() {
		return caller;
	}

	public void setCaller(String caller) {
		this.caller = caller;
	}

	public String getDueDate() {
		return dueDate;
	}

	public void setDueDate(String dueDate) {
		this.dueDate = dueDate;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}
	
	@JsonIgnore
	public Timestamp getDueDateTimestamp() {
		Timestamp ts = null;
		
		if(!StringUtils.isEmpty(getDueDate())) {
			DateFormatter format = new DateFormatter("MM/dd/yyyy");
			try {
				Date date = format.parse(getDueDate(), Locale.getDefault());
				ts = new Timestamp(date.getTime());
			} catch (ParseException e) {
				e.printStackTrace();
			}
		}
		
		return ts;
	}
}
