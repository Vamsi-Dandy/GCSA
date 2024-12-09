package com.dundermifflin.data.entities;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.Collection;
import java.util.List;
import java.util.StringJoiner;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.Table;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name = "user")
public class User implements Serializable, UserDetails {

	private static final long serialVersionUID = -7893751543782028904L;

	public User() {
		super();
	}

	public User(final String userName, final String password) {
		super();
		this.userName = userName;
		this.password = password;
	}

	public User(final int id, final String userName, final String password, final String passwordQuestion,
			final String passwordAnswer,
			final Timestamp createDate, final Integer invalidAttempts, final Timestamp lockDate, final Boolean active,
			final List<Role> roles) {
		super();
		this.id = id;
		this.userName = userName;
		this.password = password;
		this.passwordQuestion = passwordQuestion;
		this.passwordAnswer = passwordAnswer;
		this.createDate = createDate;
		this.invalidAttempts = invalidAttempts;
		this.lockDate = lockDate;
		this.active = active;
		this.roles = roles;
	}

	@Id
	@Column(name = "id")
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private int id;

	@Column(name = "user_name")
	private String userName;

	@Column(name = "password")
	private String password;

	@Column(name = "password_question")
	private String passwordQuestion;

	@Column(name = "password_answer")
	private String passwordAnswer;

	@Column(name = "active")
	private Boolean active;

	@Column(name = "create_date")
	private Timestamp createDate;

	@Column(name = "lock_date")
	private Timestamp lockDate;

	@Column(name = "invalid_attempts")
	private Integer invalidAttempts;

	@ManyToMany(fetch = FetchType.EAGER)
	@JoinTable(name = "user_role", joinColumns = @JoinColumn(name = "user_id", referencedColumnName = "id"), inverseJoinColumns = @JoinColumn(table = "role", name = "role_id", referencedColumnName = "id"))
	private List<Role> roles;

	public int getId() {
		return id;
	}

	public void setId(final int id) {
		this.id = id;
	}

	public String getUserName() {
		return userName;
	}

	public void setUserName(final String userName) {
		this.userName = userName;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(final String password) {
		this.password = password;
	}

	public String getPasswordQuestion() {
		return passwordQuestion;
	}

	public void setPasswordQuestion(final String passwordQuestion) {
		this.passwordQuestion = passwordQuestion;
	}

	public String getPasswordAnswer() {
		return passwordAnswer;
	}

	public void setPasswordAnswer(final String passwordAnswer) {
		this.passwordAnswer = passwordAnswer;
	}

	public Boolean getActive() {
		return active;
	}

	public void setActive(final Boolean active) {
		this.active = active;
	}

	public Timestamp getCreateDate() {
		return createDate;
	}

	public void setCreateDate(final Timestamp createDate) {
		this.createDate = createDate;
	}

	public Timestamp getLockDate() {
		return lockDate;
	}

	public void setLockDate(Timestamp lockDate) {
		this.lockDate = lockDate;
	}

	public Integer getInvalidAttempts() {
		return invalidAttempts;
	}

	public void setInvalidAttempts(Integer invalidAttempts) {
		this.invalidAttempts = invalidAttempts;
	}

	public List<Role> getRoles() {
		return roles;
	}

	public void setRoles(final List<Role> roles) {
		this.roles = roles;
	}

	@JsonIgnore
	public String getRoleName() {
		if (null == roles)
			return null;

		return roles.get(0).getName();
	}

	@JsonIgnore
	public String getRoleNames() {
		if (null == roles)
			return null;

		StringJoiner joiner = new StringJoiner(",");
		for (Role r : this.roles) {
			joiner.add(r.getName());
		}
		return joiner.toString();
	}

	@JsonIgnore
	@Override
	public Collection<? extends GrantedAuthority> getAuthorities() {
		return null;
	}

	@JsonIgnore
	@Override
	public String getUsername() {
		return getUserName();
	}

	@JsonIgnore
	@Override
	public boolean isAccountNonExpired() {
		return getActive();
	}

	@JsonIgnore
	@Override
	public boolean isAccountNonLocked() {
		return getActive();
	}

	@JsonIgnore
	@Override
	public boolean isCredentialsNonExpired() {
		return getActive();
	}

	@JsonIgnore
	@Override
	public boolean isEnabled() {
		return getActive();
	}

	@JsonIgnore
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((active == null) ? 0 : active.hashCode());
		result = prime * result + ((createDate == null) ? 0 : createDate.hashCode());
		result = prime * result + id;
		result = prime * result + ((invalidAttempts == null) ? 0 : invalidAttempts.hashCode());
		result = prime * result + ((lockDate == null) ? 0 : lockDate.hashCode());
		result = prime * result + ((password == null) ? 0 : password.hashCode());
		result = prime * result + ((passwordAnswer == null) ? 0 : passwordAnswer.hashCode());
		result = prime * result + ((passwordQuestion == null) ? 0 : passwordQuestion.hashCode());
		result = prime * result + ((roles == null) ? 0 : roles.hashCode());
		result = prime * result + ((userName == null) ? 0 : userName.hashCode());
		return result;
	}

	@JsonIgnore
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		User other = (User) obj;
		if (active == null) {
			if (other.active != null)
				return false;
		} else if (!active.equals(other.active))
			return false;
		if (createDate == null) {
			if (other.createDate != null)
				return false;
		} else if (!createDate.equals(other.createDate))
			return false;
		if (id != other.id)
			return false;
		if (invalidAttempts == null) {
			if (other.invalidAttempts != null)
				return false;
		} else if (!invalidAttempts.equals(other.invalidAttempts))
			return false;
		if (lockDate == null) {
			if (other.lockDate != null)
				return false;
		} else if (!lockDate.equals(other.lockDate))
			return false;
		if (password == null) {
			if (other.password != null)
				return false;
		} else if (!password.equals(other.password))
			return false;
		if (passwordAnswer == null) {
			if (other.passwordAnswer != null)
				return false;
		} else if (!passwordAnswer.equals(other.passwordAnswer))
			return false;
		if (passwordQuestion == null) {
			if (other.passwordQuestion != null)
				return false;
		} else if (!passwordQuestion.equals(other.passwordQuestion))
			return false;
		if (roles == null) {
			if (other.roles != null)
				return false;
		} else if (!roles.equals(other.roles))
			return false;
		if (userName == null) {
			if (other.userName != null)
				return false;
		} else if (!userName.equals(other.userName))
			return false;
		return true;
	}

	@JsonIgnore
	@Override
	public String toString() {
		return "User [id=" + id + ", userName=" + userName + ", password=" + password + ", passwordQuestion="
				+ passwordQuestion + ", passwordAnswer=" + passwordAnswer + ", active=" + active + ", createDate="
				+ createDate + ", lockDate=" + lockDate + ", invalidAttempts=" + invalidAttempts + ", roles=" + roles
				+ "]";
	}
}
