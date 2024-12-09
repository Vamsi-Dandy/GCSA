package com.dundermifflin.data.config;

import java.util.Properties;

import jakarta.inject.Inject;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.spi.PersistenceProvider;
import javax.sql.DataSource;

import org.hibernate.dialect.HSQLDialect;
import org.hibernate.jpa.HibernatePersistenceProvider;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.jdbc.datasource.embedded.EmbeddedDatabase;
import org.springframework.jdbc.datasource.embedded.EmbeddedDatabaseBuilder;
import org.springframework.jdbc.datasource.embedded.EmbeddedDatabaseType;
import org.springframework.orm.jpa.JpaDialect;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.orm.jpa.JpaVendorAdapter;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.orm.jpa.vendor.Database;
import org.springframework.orm.jpa.vendor.HibernateJpaDialect;
import org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;

@Configuration
@EnableTransactionManagement
@EnableJpaRepositories(basePackages = "com.dundermifflin.data.repositories")
@EntityScan(basePackages = "com.dundermifflin.data.entities")
@ComponentScan({ "com.dundermifflin.data.services" })
public class PersistenceConfig {

	protected static final String[] JPA_ENTITY_PACKAGES = new String[] { "com.dundermifflin.data.entities" };

	@Inject
	private Environment env;

	/**
	 * Configure a file-based HSQLDB database.
	 *
	 * @return The HSQLDB {@link DataSource}.
	 */
	@Bean
	public DataSource dataSource() {

		final EmbeddedDatabaseBuilder builder = new EmbeddedDatabaseBuilder();
		EmbeddedDatabase db = builder.setType(EmbeddedDatabaseType.HSQL)
				.setName("dunder_mifflin")
				.addScript("dunder_mifflin.sql")
				.build();
		return db;
	}

	/**
	 * The Spring JPA entity manager factory configured with {@link DataSource},
	 * {@link JpaDialect}, {@link JpaVendorAdapter}, and
	 * {@link PersistenceProvider} instances, and set to scan the Entity
	 * packages configured in this class.
	 *
	 * @return A Spring JPA {@link LocalContainerEntityManagerFactoryBean}.
	 */
	@Bean
	@PersistenceContext
	public LocalContainerEntityManagerFactoryBean entityManagerFactory() {

		final LocalContainerEntityManagerFactoryBean emfb = new LocalContainerEntityManagerFactoryBean();
		emfb.setDataSource(dataSource());
		emfb.setJpaDialect(jpaDialect());
		emfb.setJpaVendorAdapter(jpaVendorAdapter());
		emfb.setPersistenceProvider(jpaPersistenceProvider());
		emfb.setPackagesToScan(JPA_ENTITY_PACKAGES);
		return emfb;
	}

	/**
	 * The JPA dialect to be used by this configuration. The CTF Server
	 * application uses the Hibernate JPA dialect.
	 *
	 * @return The Spring {@link JpaDialect} to use. Currently set to
	 *         {@link HibernateJpaDialect}.
	 */
	@Bean
	public JpaDialect jpaDialect() {
		return new HibernateJpaDialect();
	}

	/**
	 * The JPA persistence provider to be used by this configuration. The CTF
	 * Server application uses the Hibernate persistence provider.
	 *
	 * @return The JPA {@link PersistenceProvider}. Currently set to
	 *         {@link HibernatePersistence}.
	 */
	@Bean
	public PersistenceProvider jpaPersistenceProvider() {
		return new HibernatePersistenceProvider();
	}

	/**
	 * The JPA vendor adapter to be used by this configuration. The CTF Server
	 * application uses the Hibernate adapter configured to point to an HSQLDB
	 * instance.
	 *
	 * @return The {@link JpaVendorAdapter}. Currently set to
	 *         {@link HibernateJpaVendorAdapter}.
	 */
	@Bean
	public JpaVendorAdapter jpaVendorAdapter() {
		final HibernateJpaVendorAdapter adapter = new HibernateJpaVendorAdapter();
		adapter.setDatabasePlatform(HSQLDialect.class.getName());
		adapter.setDatabase(Database.HSQL);
		adapter.setShowSql("true".equalsIgnoreCase(env.getProperty("hibernate.show_sql")));
		return adapter;
	}

	@Bean
	public PlatformTransactionManager transactionManager() {
		JpaTransactionManager transactionManager = new JpaTransactionManager();
		transactionManager.setEntityManagerFactory(entityManagerFactory().getObject());

		return transactionManager;
	}

	final Properties additionalProperties() {
		final Properties hibernateProperties = new Properties();
		hibernateProperties.setProperty("hibernate.hbm2ddl.auto", env.getProperty("hibernate.hbm2ddl.auto"));
		hibernateProperties.setProperty("hibernate.dialect", env.getProperty("hibernate.dialect"));
		hibernateProperties.setProperty("hibernate.globally_quoted_identifiers",
				env.getProperty("hibernate.globally_quoted_identifiers"));
		return hibernateProperties;
	}
}
