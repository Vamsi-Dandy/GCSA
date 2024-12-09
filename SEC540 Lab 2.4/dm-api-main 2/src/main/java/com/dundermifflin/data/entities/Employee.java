package com.dundermifflin.data.entities;

import java.io.Serializable;
import java.math.BigDecimal;
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
import jakarta.persistence.Transient;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
@Entity
@Table(name = "employee")
public class Employee implements Serializable {

	private static final long serialVersionUID = 27797320850250859L;

	public Employee() {
		super();
	}

	public Employee(final int id, final String company, final String emailAddress, final String lastName,
			final String firstName, final String jobTitle, final String businessPhone, final String homePhone,
			final String mobilePhone,
			final String faxNumber, final String address, final String city,
			final String state, final String postal_code, final String country,
			final String webPage, final String notes, final String attachments,
			final User user, final Timestamp dob, final String ssn,
			final String gender, final String vehicle,
			final String height, final String weight,
			final String w4MaritalStatus, final Boolean w4Exempt,
			final BigDecimal w4AdditionalWithholding,
			final String routingNumber, final String bankAccountNumber, final Employee manager) {
		super();
		this.id = id;
		this.company = company;
		this.emailAddress = emailAddress;
		this.firstName = firstName;
		this.lastName = lastName;
		this.jobTitle = jobTitle;
		this.businessPhone = businessPhone;
		this.homePhone = homePhone;
		this.mobilePhone = mobilePhone;
		this.faxNumber = faxNumber;
		this.address = address;
		this.city = city;
		this.state = state;
		this.postal_code = postal_code;
		this.country = country;
		this.webPage = webPage;
		this.notes = notes;
		this.attachments = attachments;
		this.user = user;
		this.dob = dob;
		this.ssn = ssn;
		this.gender = gender;
		this.vehicle = vehicle;
		this.height = height;
		this.weight = weight;
		this.w4MaritalStatus = w4MaritalStatus;
		this.w4Exempt = w4Exempt;
		this.w4AdditionalWithholding = w4AdditionalWithholding;
		this.routingNumber = routingNumber;
		this.bankAccountNumber = bankAccountNumber;
		this.manager = manager;
	}

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private int id;

	@Column(name = "company")
	private String company;

	@Column(name = "first_name")
	private String firstName;

	@Column(name = "last_name")
	private String lastName;

	@Column(name = "email_address")
	private String emailAddress;

	@Column(name = "job_title")
	private String jobTitle;

	@Column(name = "business_phone")
	private String businessPhone;

	@Column(name = "home_phone")
	private String homePhone;

	@Column(name = "mobile_phone")
	private String mobilePhone;

	@Column(name = "fax_number")
	private String faxNumber;

	@Column(name = "address")
	private String address;

	@Column(name = "city")
	private String city;

	@Column(name = "state")
	private String state;

	@Column(name = "postal_code")
	private String postal_code;

	@Column(name = "country")
	private String country;

	@Column(name = "web_page", columnDefinition = "TEXT")
	private String webPage;

	@Column(name = "notes", columnDefinition = "TEXT")
	private String notes;

	@Column(name = "attachments", columnDefinition = "TEXT")
	private String attachments;

	@ManyToOne(targetEntity = User.class, cascade = CascadeType.ALL, fetch = FetchType.EAGER)
	@JoinColumn(name = "user_id")
	private User user;

	@Column(name = "dob")
	private Timestamp dob;

	@Column(name = "ssn")
	private String ssn;

	@Column(name = "gender")
	private String gender;

	@Column(name = "vehicle")
	private String vehicle;

	@Column(name = "height")
	private String height;

	@Column(name = "weight")
	private String weight;

	@Column(name = "w4_marital_status")
	private String w4MaritalStatus;

	@Column(name = "w4_exempt")
	private Boolean w4Exempt;

	@Column(name = "w4_additional_withholding")
	private BigDecimal w4AdditionalWithholding;

	@Column(name = "routing_number")
	private String routingNumber;

	@Column(name = "bank_account_number")
	private String bankAccountNumber;

	@ManyToOne(targetEntity = Employee.class, cascade = CascadeType.ALL, fetch = FetchType.EAGER)
	@JoinColumn(name = "manager_id")
	private Employee manager;

	@Transient
	private String fullName;

	public int getId() {
		return id;
	}

	public void setId(final int id) {
		this.id = id;
	}

	public String getCompany() {
		return company;
	}

	public void setCompany(final String company) {
		this.company = company;
	}

	public String getLastName() {
		return lastName;
	}

	public void setLastName(final String lastName) {
		this.lastName = lastName;
	}

	public String getFirstName() {
		return firstName;
	}

	public void setFirstName(final String firstName) {
		this.firstName = firstName;
	}

	public String getEmailAddress() {
		return emailAddress;
	}

	public void setEmailAddress(final String emailAddress) {
		this.emailAddress = emailAddress;
	}

	public String getJobTitle() {
		return jobTitle;
	}

	public void setJobTitle(final String jobTitle) {
		this.jobTitle = jobTitle;
	}

	public String getBusinessPhone() {
		return businessPhone;
	}

	public void setBusinessPhone(final String businessPhone) {
		this.businessPhone = businessPhone;
	}

	public String getHomePhone() {
		return homePhone;
	}

	public void setHomePhone(final String homePhone) {
		this.homePhone = homePhone;
	}

	public String getMobilePhone() {
		return mobilePhone;
	}

	public void setMobilePhone(final String mobilePhone) {
		this.mobilePhone = mobilePhone;
	}

	public String getFaxNumber() {
		return faxNumber;
	}

	public void setFaxNumber(final String faxNumber) {
		this.faxNumber = faxNumber;
	}

	public String getAddress() {
		return address;
	}

	public void setAddress(final String address) {
		this.address = address;
	}

	public String getCity() {
		return city;
	}

	public void setCity(final String city) {
		this.city = city;
	}

	public String getState() {
		return state;
	}

	public void setState(final String state) {
		this.state = state;
	}

	public String getPostal_code() {
		return postal_code;
	}

	public void setPostal_code(final String postal_code) {
		this.postal_code = postal_code;
	}

	public String getCountry() {
		return country;
	}

	public void setCountry(final String country) {
		this.country = country;
	}

	public String getWebPage() {
		return webPage;
	}

	public void setWebPage(final String webPage) {
		this.webPage = webPage;
	}

	public String getNotes() {
		return notes;
	}

	public void setNotes(final String notes) {
		this.notes = notes;
	}

	public String getAttachments() {
		return attachments;
	}

	public void setAttachments(final String attachments) {
		this.attachments = attachments;
	}

	public User getUser() {
		return user;
	}

	public void setUser(final User user) {
		this.user = user;
	}

	public Employee getManager() {
		return manager;
	}

	public void setManager(final Employee manager) {
		this.manager = manager;
	}

	public String getFullName() {
		return String.format("%s %s", firstName, lastName);
	}

	public Timestamp getDob() {
		return dob;
	}

	public void setDob(final Timestamp dob) {
		this.dob = dob;
	}

	public String getSsn() {
		return ssn;
	}

	public void setSsn(final String ssn) {
		this.ssn = ssn;
	}

	public String getGender() {
		return gender;
	}

	public void setGender(final String gender) {
		this.gender = gender;
	}

	public String getVehicle() {
		return vehicle;
	}

	public void setVehicle(final String vehicle) {
		this.vehicle = vehicle;
	}

	public String getHeight() {
		return height;
	}

	public void setHeight(final String height) {
		this.height = height;
	}

	public String getWeight() {
		return weight;
	}

	public void setWeight(final String weight) {
		this.weight = weight;
	}

	public String getW4MaritalStatus() {
		return w4MaritalStatus;
	}

	public void setW4MaritalStatus(final String w4MaritalStatus) {
		this.w4MaritalStatus = w4MaritalStatus;
	}

	public Boolean getW4Exempt() {
		return w4Exempt;
	}

	public void setW4Exempt(final Boolean w4Exempt) {
		this.w4Exempt = w4Exempt;
	}

	public BigDecimal getW4AdditionalWithholding() {
		return w4AdditionalWithholding;
	}

	public void setW4AdditionalWithholding(
			final BigDecimal w4AdditionalWithholding) {
		this.w4AdditionalWithholding = w4AdditionalWithholding;
	}

	public String getRoutingNumber() {
		return routingNumber;
	}

	public void setRoutingNumber(final String routingNumber) {
		this.routingNumber = routingNumber;
	}

	public String getBankAccountNumber() {
		return bankAccountNumber;
	}

	public void setBankAccountNumber(final String bankAccountNumber) {
		this.bankAccountNumber = bankAccountNumber;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((address == null) ? 0 : address.hashCode());
		result = prime * result
				+ ((attachments == null) ? 0 : attachments.hashCode());
		result = prime * result
				+ ((businessPhone == null) ? 0 : businessPhone.hashCode());
		result = prime * result + ((city == null) ? 0 : city.hashCode());
		result = prime * result + ((company == null) ? 0 : company.hashCode());
		result = prime * result + ((country == null) ? 0 : country.hashCode());
		result = prime * result
				+ ((emailAddress == null) ? 0 : emailAddress.hashCode());
		result = prime * result
				+ ((faxNumber == null) ? 0 : faxNumber.hashCode());
		result = prime * result
				+ ((firstName == null) ? 0 : firstName.hashCode());
		result = prime * result
				+ ((homePhone == null) ? 0 : homePhone.hashCode());
		result = prime * result + id;
		result = prime * result
				+ ((jobTitle == null) ? 0 : jobTitle.hashCode());
		result = prime * result
				+ ((lastName == null) ? 0 : lastName.hashCode());
		result = prime * result
				+ ((mobilePhone == null) ? 0 : mobilePhone.hashCode());
		result = prime * result + ((notes == null) ? 0 : notes.hashCode());
		result = prime * result
				+ ((postal_code == null) ? 0 : postal_code.hashCode());
		result = prime * result + ((state == null) ? 0 : state.hashCode());
		result = prime * result + ((user == null) ? 0 : user.hashCode());
		result = prime * result + ((webPage == null) ? 0 : webPage.hashCode());
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
		final Employee other = (Employee) obj;
		if (address == null) {
			if (other.address != null)
				return false;
		} else if (!address.equals(other.address))
			return false;
		if (attachments == null) {
			if (other.attachments != null)
				return false;
		} else if (!attachments.equals(other.attachments))
			return false;
		if (businessPhone == null) {
			if (other.businessPhone != null)
				return false;
		} else if (!businessPhone.equals(other.businessPhone))
			return false;
		if (city == null) {
			if (other.city != null)
				return false;
		} else if (!city.equals(other.city))
			return false;
		if (company == null) {
			if (other.company != null)
				return false;
		} else if (!company.equals(other.company))
			return false;
		if (country == null) {
			if (other.country != null)
				return false;
		} else if (!country.equals(other.country))
			return false;
		if (emailAddress == null) {
			if (other.emailAddress != null)
				return false;
		} else if (!emailAddress.equals(other.emailAddress))
			return false;
		if (faxNumber == null) {
			if (other.faxNumber != null)
				return false;
		} else if (!faxNumber.equals(other.faxNumber))
			return false;
		if (firstName == null) {
			if (other.firstName != null)
				return false;
		} else if (!firstName.equals(other.firstName))
			return false;
		if (homePhone == null) {
			if (other.homePhone != null)
				return false;
		} else if (!homePhone.equals(other.homePhone))
			return false;
		if (id != other.id)
			return false;
		if (jobTitle == null) {
			if (other.jobTitle != null)
				return false;
		} else if (!jobTitle.equals(other.jobTitle))
			return false;
		if (lastName == null) {
			if (other.lastName != null)
				return false;
		} else if (!lastName.equals(other.lastName))
			return false;
		if (mobilePhone == null) {
			if (other.mobilePhone != null)
				return false;
		} else if (!mobilePhone.equals(other.mobilePhone))
			return false;
		if (notes == null) {
			if (other.notes != null)
				return false;
		} else if (!notes.equals(other.notes))
			return false;
		if (postal_code == null) {
			if (other.postal_code != null)
				return false;
		} else if (!postal_code.equals(other.postal_code))
			return false;
		if (state == null) {
			if (other.state != null)
				return false;
		} else if (!state.equals(other.state))
			return false;
		if (user == null) {
			if (other.user != null)
				return false;
		} else if (!user.equals(other.user))
			return false;
		if (webPage == null) {
			if (other.webPage != null)
				return false;
		} else if (!webPage.equals(other.webPage))
			return false;
		return true;
	}

	@Override
	public String toString() {
		return "Employee [id=" + id + ", company=" + company + ", lastName="
				+ lastName + ", firstName=" + firstName + ", emailAddress="
				+ emailAddress + ", jobTitle=" + jobTitle + ", businessPhone="
				+ businessPhone + ", homePhone=" + homePhone + ", mobilePhone="
				+ mobilePhone + ", faxNumber=" + faxNumber + ", address="
				+ address + ", city=" + city + ", state=" + state
				+ ", postal_code=" + postal_code + ", country=" + country
				+ ", webPage=" + webPage + ", notes=" + notes
				+ ", attachments=" + attachments + ", user=" + user + "]";
	}
}
