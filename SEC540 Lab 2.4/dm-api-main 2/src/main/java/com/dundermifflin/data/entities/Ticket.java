package com.dundermifflin.data.entities;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.List;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
@Entity
@Table(name = "ticket")
public class Ticket implements Serializable {

	private static final long serialVersionUID = 1983229795627585830L;

	public Ticket() {
		super();
		// TODO Auto-generated constructor stub
	}

	public Ticket(final int id, final String title, final Employee assignedTo,
			final Customer customer, final Employee openedBy,
			final Timestamp openedDate, final String status,
			final String category, final String priority,
			final String description, final Timestamp dueDate,
			final String comments, final Timestamp resolvedDate,
			final KnowledgeBase knowledgeBase, final String attachments) {
		super();
		this.id = id;
		this.title = title;
		this.assignedTo = assignedTo;
		this.customer = customer;
		this.openedBy = openedBy;
		this.openedDate = openedDate;
		this.status = status;
		this.category = category;
		this.priority = priority;
		this.description = description;
		this.dueDate = dueDate;
		this.comments = comments;
		this.resolvedDate = resolvedDate;
		this.knowledgeBase = knowledgeBase;
		this.attachments = attachments;
	}

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private int id;

	@Column(name = "title")
	private String title;

	@ManyToOne(targetEntity = Employee.class, cascade = CascadeType.ALL, fetch = FetchType.EAGER)
	@JoinColumn(name = "assigned_to_id")
	private Employee assignedTo;

	@ManyToOne(targetEntity = Customer.class, cascade = CascadeType.ALL, fetch = FetchType.EAGER)
	@JoinColumn(name = "customer_id")
	private Customer customer;

	@ManyToOne(targetEntity = Employee.class, cascade = CascadeType.ALL, fetch = FetchType.EAGER)
	@JoinColumn(name = "opened_by_id")
	private Employee openedBy;

	@Column(name = "opened_date")
	private Timestamp openedDate;

	@Column(name = "status")
	private String status;

	@Column(name = "category")
	private String category;

	@Column(name = "priority")
	private String priority;

	@Column(name = "description", columnDefinition = "TEXT")
	private String description;

	@Column(name = "due_date")
	private Timestamp dueDate;

	@Column(name = "comments", columnDefinition = "TEXT")
	private String comments;

	@Column(name = "resolved_date")
	private Timestamp resolvedDate;

	@Column(name = "attachments", columnDefinition = "TEXT")
	private String attachments;

	@OneToMany(mappedBy = "ticketItem", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
	private List<PhoneCall> calls;

	@ManyToOne(targetEntity = KnowledgeBase.class, cascade = CascadeType.ALL, fetch = FetchType.EAGER)
	@JoinColumn(name = "kb_id")
	private KnowledgeBase knowledgeBase;

	public int getId() {
		return id;
	}

	public void setId(final int id) {
		this.id = id;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(final String title) {
		this.title = title;
	}

	public Employee getAssignedTo() {
		return assignedTo;
	}

	public void setAssignedTo(final Employee assignedTo) {
		this.assignedTo = assignedTo;
	}

	public Customer getCustomer() {
		return customer;
	}

	public void setCustomer(final Customer customer) {
		this.customer = customer;
	}

	public Employee getOpenedBy() {
		return openedBy;
	}

	public void setOpenedBy(final Employee openedBy) {
		this.openedBy = openedBy;
	}

	public Timestamp getOpenedDate() {
		return openedDate;
	}

	public void setOpenedDate(final Timestamp openedDate) {
		this.openedDate = openedDate;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(final String status) {
		this.status = status;
	}

	public String getCategory() {
		return category;
	}

	public void setCategory(final String category) {
		this.category = category;
	}

	public String getPriority() {
		return priority;
	}

	public void setPriority(final String priority) {
		this.priority = priority;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(final String description) {
		this.description = description;
	}

	public Timestamp getDueDate() {
		return dueDate;
	}

	public void setDueDate(final Timestamp dueDate) {
		this.dueDate = dueDate;
	}

	public String getComments() {
		return comments;
	}

	public void setComments(final String comments) {
		this.comments = comments;
	}

	public Timestamp getResolvedDate() {
		return resolvedDate;
	}

	public void setResolvedDate(final Timestamp resolvedDate) {
		this.resolvedDate = resolvedDate;
	}

	public KnowledgeBase getKnowledgeBase() {
		return knowledgeBase;
	}

	public void setKnowledgeBase(final KnowledgeBase knowledgeBase) {
		this.knowledgeBase = knowledgeBase;
	}

	public String getAttachments() {
		return attachments;
	}

	public void setAttachments(final String attachments) {
		this.attachments = attachments;
	}

	public List<PhoneCall> getCalls() {
		return calls;
	}

	public void setCalls(final List<PhoneCall> calls) {
		this.calls = calls;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result
				+ ((attachments == null) ? 0 : attachments.hashCode());
		result = prime * result + ((calls == null) ? 0 : calls.hashCode());
		result = prime * result
				+ ((category == null) ? 0 : category.hashCode());
		result = prime * result
				+ ((comments == null) ? 0 : comments.hashCode());
		result = prime * result
				+ ((customer == null) ? 0 : customer.hashCode());
		result = prime * result
				+ ((description == null) ? 0 : description.hashCode());
		result = prime * result + ((dueDate == null) ? 0 : dueDate.hashCode());
		result = prime * result + id;
		result = prime * result
				+ ((knowledgeBase == null) ? 0 : knowledgeBase.hashCode());
		result = prime * result
				+ ((openedBy == null) ? 0 : openedBy.hashCode());
		result = prime * result
				+ ((openedDate == null) ? 0 : openedDate.hashCode());
		result = prime * result
				+ ((priority == null) ? 0 : priority.hashCode());
		result = prime * result + ((assignedTo == null) ? 0 : assignedTo.hashCode());
		result = prime * result
				+ ((resolvedDate == null) ? 0 : resolvedDate.hashCode());
		result = prime * result + ((status == null) ? 0 : status.hashCode());
		result = prime * result + ((title == null) ? 0 : title.hashCode());
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
		final Ticket other = (Ticket) obj;
		if (attachments == null) {
			if (other.attachments != null)
				return false;
		} else if (!attachments.equals(other.attachments))
			return false;
		if (calls == null) {
			if (other.calls != null)
				return false;
		} else if (!calls.equals(other.calls))
			return false;
		if (category == null) {
			if (other.category != null)
				return false;
		} else if (!category.equals(other.category))
			return false;
		if (comments == null) {
			if (other.comments != null)
				return false;
		} else if (!comments.equals(other.comments))
			return false;
		if (customer == null) {
			if (other.customer != null)
				return false;
		} else if (!customer.equals(other.customer))
			return false;
		if (description == null) {
			if (other.description != null)
				return false;
		} else if (!description.equals(other.description))
			return false;
		if (dueDate == null) {
			if (other.dueDate != null)
				return false;
		} else if (!dueDate.equals(other.dueDate))
			return false;
		if (id != other.id)
			return false;
		if (knowledgeBase == null) {
			if (other.knowledgeBase != null)
				return false;
		} else if (!knowledgeBase.equals(other.knowledgeBase))
			return false;
		if (openedBy == null) {
			if (other.openedBy != null)
				return false;
		} else if (!openedBy.equals(other.openedBy))
			return false;
		if (openedDate == null) {
			if (other.openedDate != null)
				return false;
		} else if (!openedDate.equals(other.openedDate))
			return false;
		if (priority == null) {
			if (other.priority != null)
				return false;
		} else if (!priority.equals(other.priority))
			return false;
		if (assignedTo == null) {
			if (other.assignedTo != null)
				return false;
		} else if (!assignedTo.equals(other.assignedTo))
			return false;
		if (resolvedDate == null) {
			if (other.resolvedDate != null)
				return false;
		} else if (!resolvedDate.equals(other.resolvedDate))
			return false;
		if (status == null) {
			if (other.status != null)
				return false;
		} else if (!status.equals(other.status))
			return false;
		if (title == null) {
			if (other.title != null)
				return false;
		} else if (!title.equals(other.title))
			return false;
		return true;
	}

	@Override
	public String toString() {
		return "Case [id=" + id + ", title=" + title + ", assignedTo=" + assignedTo
				+ ", customer=" + customer + ", openedBy=" + openedBy
				+ ", calls=" + calls + ", openedDate=" + openedDate
				+ ", status=" + status + ", category=" + category
				+ ", priority=" + priority + ", description=" + description
				+ ", dueDate=" + dueDate + ", comments=" + comments
				+ ", resolvedDate=" + resolvedDate + ", knowledgeBase="
				+ knowledgeBase + ", attachments=" + attachments + "]";
	}

}
