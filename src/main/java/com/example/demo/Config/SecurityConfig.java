package com.example.demo.Config;

import java.util.Arrays;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.oauth2.client.oidc.userinfo.OidcUserRequest;
import org.springframework.security.oauth2.client.oidc.userinfo.OidcUserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserService;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import com.example.demo.Entities.User;
import com.example.demo.Repositories.UserRepository;

@Configuration
@EnableWebSecurity
public class SecurityConfig { // <-- Notice: NO "extends WebSecurityConfigurerAdapter"

    @Autowired
    private UserRepository userRepository;

    // THIS IS THE NEW WAY TO CONFIGURE HTTPSECURITY
    // THIS IS THE NEW WAY TO CONFIGURE HTTPSECURITY
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .cors(cors -> cors.configurationSource(corsConfigurationSource())) // Use your CORS bean
                .csrf(csrf -> csrf.disable()) // New way to disable CSRF
                .authorizeHttpRequests(a -> a
                        // New way to define matchers
                        .requestMatchers(
                                "/", 
                                "/error", 
                                "/api/resources", 
                                "/api/resources/download/**",
                                "/api/resources/*/details",
                                "/api/resources/*/comments",
                                "/api/resources/search",
                                "/api/resources/categories",
                                "/api/test/**",
                                "/oauth2/**",
                                "/login/**"
                        ).permitAll()
                        .anyRequest().authenticated()
                )
                .oauth2Login(oauth -> oauth
                        .userInfoEndpoint(userInfo -> userInfo
                                .oidcUserService(oidcUserService())  // Use OIDC service for Google
                        )
                        .successHandler(successHandler()) // Tell oauth2Login to use your handler
                );

        return http.build(); // <-- Return the built HttpSecurity object
    }

    // This bean handles finding or creating a user in your DB after Google login
    // Google uses OIDC (OpenID Connect), so we need OidcUserService instead of OAuth2UserService
    @Bean
    public OAuth2UserService<OidcUserRequest, OidcUser> oidcUserService() {
        OidcUserService delegate = new OidcUserService();
        return userRequest -> {
            OidcUser oidcUser = delegate.loadUser(userRequest);
            String email = oidcUser.getAttribute("email");
            String name = oidcUser.getAttribute("name");

            System.out.println("=== OAuth Login Detected ===");
            System.out.println("Email: " + email);
            System.out.println("Name: " + name);

            User user = userRepository.findByEmail(email)
                    .orElseGet(() -> {
                        System.out.println("Creating new user: " + email);
                        User newUser = new User();
                        newUser.email = email;
                        newUser.name = name;
                        User savedUser = userRepository.save(newUser);
                        System.out.println("User saved with ID: " + savedUser.id);
                        return savedUser;
                    });
            
            System.out.println("User found/created: " + user.id + " - " + user.email);
            System.out.println("=========================");
            
            return oidcUser;
        };
    }

    // After login, redirect the user back to your React app
    private SimpleUrlAuthenticationSuccessHandler successHandler() {
        SimpleUrlAuthenticationSuccessHandler handler = new SimpleUrlAuthenticationSuccessHandler();
        handler.setDefaultTargetUrl("http://localhost:3000"); // URL of your frontend
        return handler;
    }

    // This bean allows your React frontend (on localhost:3000) to talk to this backend
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(Arrays.asList("http://localhost:3000"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("*"));
        configuration.setAllowCredentials(true);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

}