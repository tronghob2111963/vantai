package org.example.ptcmssbackend.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.ptcmssbackend.common.TokenType;
import org.example.ptcmssbackend.service.JwtService;
import org.example.ptcmssbackend.service.UserServiceDetail;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@Component
@Slf4j(topic = "CUSTOMIZE_REQUEST_FILTER")
@RequiredArgsConstructor
public class CustomizeRequestFilter extends OncePerRequestFilter {

    private final JwtService jwtService;
    private final UserServiceDetail userDetailsService;

    // Mở rộng EXCLUDED_PATHS: Thêm verification và password endpoints
    private static final List<String> EXCLUDED_PATHS = List.of(
            "/v3/api-docs", "/v3/api-docs/", "/v3/api-docs/swagger-config",
            "/swagger-ui", "/swagger-ui/", "/swagger-ui/index.html",
            "/swagger-ui/swagger-ui.css", "/swagger-ui/swagger-ui-bundle.js",
            "/swagger-ui/swagger-ui-standalone-preset.js", "/swagger-ui/swagger-initializer.js",
            "/swagger-resources", "/swagger-resources/",
            "/webjars/", "/webjars/**",
            "/actuator",
            "/api/auth/login", "/api/auth/register", "/api/auth/refresh-token",
            "/api/users",
            // THÊM MỚI: Verification & Password (bỏ qua JWT)
            "/verify", "/set-password",
            "/.well-known/**", "/favicon.ico"
            );
    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        String uri = request.getRequestURI();
        log.info("{} {}", request.getMethod(), uri);

        // Bỏ qua Swagger, Actuator và các API public
        if (isExcluded(uri)) {
            // Xử lý OPTIONS preflight cho excluded paths (trả 200 để browser pass)
            if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
                response.setStatus(HttpServletResponse.SC_OK);
                return;
            }
            filterChain.doFilter(request, response);
            return;
        }

        // Xử lý OPTIONS preflight cho non-excluded (CORS)
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            response.setStatus(HttpServletResponse.SC_OK);
            setCorsHeaders(request, response);
            return;
        }

        // Set CORS headers cho các request khác
        setCorsHeaders(request, response);

        // Xử lý JWT cho non-excluded
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            try {
                String username = jwtService.extractUsername(token, TokenType.ACCESS_TOKEN);
                if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                    UserDetails userDetails = userDetailsService.loadUserByUsername(username);
                    UsernamePasswordAuthenticationToken authToken =
                            new UsernamePasswordAuthenticationToken(
                                    userDetails, null, userDetails.getAuthorities());
                    authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                }
            } catch (Exception e) {
                log.error("Lỗi xác thực token: {}", e.getMessage());
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Invalid or expired token");
                return;
            }
        }

        filterChain.doFilter(request, response);
    }

    // Tách riêng method set CORS để tránh set cho excluded paths
    private void setCorsHeaders(HttpServletRequest request, HttpServletResponse response) {
        response.setHeader("Access-Control-Allow-Origin", "http://localhost:4200");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Authorization, Content-Type");
        response.setHeader("Access-Control-Allow-Credentials", "true");
        response.setHeader("Access-Control-Max-Age", "3600");
    }

    private boolean isExcluded(String uri) {
        return EXCLUDED_PATHS.stream().anyMatch(excluded ->
                uri.startsWith(excluded) || excluded.startsWith(uri)); // Cải thiện match (hai chiều cho exact)
    }
}