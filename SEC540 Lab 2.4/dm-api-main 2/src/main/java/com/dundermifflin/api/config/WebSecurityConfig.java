package com.dundermifflin.api.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationServiceException;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.util.matcher.RegexRequestMatcher;
import org.springframework.web.servlet.handler.HandlerMappingIntrospector;

import com.dundermifflin.data.config.PersistenceConfig;
import com.dundermifflin.data.repositories.TicketSearchRepository;

@Configuration
@EnableWebSecurity
@Import({ PersistenceConfig.class })
public class WebSecurityConfig {

    @Bean
    public SecurityFilterChain defaultFilterChain(HttpSecurity http) throws Exception {
        http
                .authorizeHttpRequests(authorize -> authorize
                        .requestMatchers(
                                RegexRequestMatcher.regexMatcher("/api/.*"))
                        .anonymous()
                        .anyRequest().authenticated())
                .csrf(csrf -> csrf.disable());
        return http.build();
    }

    @Bean
    public TicketSearchRepository searchRepository() {
        return new TicketSearchRepository();
    }
}
