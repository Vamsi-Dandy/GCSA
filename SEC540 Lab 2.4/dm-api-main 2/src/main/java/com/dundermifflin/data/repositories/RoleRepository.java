package com.dundermifflin.data.repositories;

import com.dundermifflin.data.entities.Role;

import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Spring Data JPA Repository for the {@link Result} entity.
 */
public interface RoleRepository extends JpaRepository<Role, Long> {

}
