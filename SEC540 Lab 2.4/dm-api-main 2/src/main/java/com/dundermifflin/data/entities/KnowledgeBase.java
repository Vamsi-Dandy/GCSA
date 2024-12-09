package com.dundermifflin.data.entities;

import java.io.Serializable;
import java.util.List;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

@Entity
@Table(name = "knowledge_base")
public class KnowledgeBase implements Serializable {

	private static final long serialVersionUID = 8808904651040268388L;

	public KnowledgeBase() {
		super();
		// TODO Auto-generated constructor stub
	}

	public KnowledgeBase(final int id, final String title, final String url,
			final String notes, final String tags) {
		super();
		this.id = id;
		this.title = title;
		this.url = url;
		this.notes = notes;
		this.tags = tags;
	}

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "id")
	private int id;

	@Column(name = "title")
	private String title;

	@Column(name = "url", columnDefinition = "TEXT")
	private String url;

	@Column(name = "notes", columnDefinition = "TEXT")
	private String notes;

	@Column(name = "tags", columnDefinition = "TEXT")
	private String tags;

	@OneToMany(mappedBy = "knowledgeBase", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
	private List<Ticket> cases;

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

	public String getUrl() {
		return url;
	}

	public void setUrl(final String url) {
		this.url = url;
	}

	public String getNotes() {
		return notes;
	}

	public void setNotes(final String notes) {
		this.notes = notes;
	}

	public String getTags() {
		return tags;
	}

	public void setTags(final String tags) {
		this.tags = tags;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + id;
		result = prime * result + ((notes == null) ? 0 : notes.hashCode());
		result = prime * result + ((tags == null) ? 0 : tags.hashCode());
		result = prime * result + ((title == null) ? 0 : title.hashCode());
		result = prime * result + ((url == null) ? 0 : url.hashCode());
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
		final KnowledgeBase other = (KnowledgeBase) obj;
		if (id != other.id)
			return false;
		if (notes == null) {
			if (other.notes != null)
				return false;
		} else if (!notes.equals(other.notes))
			return false;
		if (tags == null) {
			if (other.tags != null)
				return false;
		} else if (!tags.equals(other.tags))
			return false;
		if (title == null) {
			if (other.title != null)
				return false;
		} else if (!title.equals(other.title))
			return false;
		if (url == null) {
			if (other.url != null)
				return false;
		} else if (!url.equals(other.url))
			return false;
		return true;
	}

	@Override
	public String toString() {
		return "KnowledgeBase [id=" + id + ", title=" + title + ", url=" + url
				+ ", notes=" + notes + ", tags=" + tags + "]";
	}
}
