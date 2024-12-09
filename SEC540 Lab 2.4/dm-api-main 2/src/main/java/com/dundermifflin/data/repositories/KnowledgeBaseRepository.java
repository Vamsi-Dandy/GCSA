package com.dundermifflin.data.repositories;

import com.dundermifflin.data.entities.KnowledgeBase;

import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Spring Data JPA Repository for the {@link Result} entity.
 */
public interface KnowledgeBaseRepository extends JpaRepository<KnowledgeBase, Long> {
	
	public KnowledgeBase findById(int id);
}
