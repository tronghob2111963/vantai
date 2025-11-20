package org.example.ptcmssbackend.controller;

import lombok.RequiredArgsConstructor;
import org.example.ptcmssbackend.dto.response.common.ApiResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;

import java.util.Map;

/**
 * SerpAPI Proxy Controller
 * Purpose: Proxy requests to SerpAPI to avoid CORS issues and protect API key
 */
@RestController
@RequestMapping("/api/serpapi")
@RequiredArgsConstructor
public class SerpApiController {

    @Value("${serpapi.key}")
    private String serpApiKey;

    private final RestTemplate restTemplate = new RestTemplate();

    /**
     * Calculate distance between two locations
     * @param startAddr Starting address
     * @param endAddr Ending address
     * @return Distance and duration information
     */
    @GetMapping("/distance")
    public ResponseEntity<?> calculateDistance(
            @RequestParam String startAddr,
            @RequestParam String endAddr
    ) {
        try {
            // Build SerpAPI URL
            String serpApiUrl = UriComponentsBuilder
                    .fromHttpUrl("https://serpapi.com/search")
                    .queryParam("engine", "google_maps_directions")
                    .queryParam("api_key", serpApiKey)
                    .queryParam("start_addr", startAddr)
                    .queryParam("end_addr", endAddr)
                    .queryParam("travel_mode", "0") // 0 = Driving
                    .queryParam("distance_unit", "0") // 0 = Kilometers
                    .toUriString();

            // Set headers to avoid 403 error
            HttpHeaders headers = new HttpHeaders();
            headers.set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36");
            HttpEntity<String> entity = new HttpEntity<>(headers);

            // Call SerpAPI
            System.out.println("DEBUG: Calling SerpAPI with URL: " + serpApiUrl);
            Map<String, Object> response = restTemplate.exchange(
                serpApiUrl,
                HttpMethod.GET,
                entity,
                Map.class
            ).getBody();

            System.out.println("DEBUG: SerpAPI response: " + response);

            if (response == null || !response.containsKey("directions")) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.<Map<String, Object>>builder()
                                .success(false)
                                .message("No route found between the two locations")
                                .data(null)
                                .build());
            }

            return ResponseEntity.ok(ApiResponse.<Map<String, Object>>builder()
                    .success(true)
                    .message("Distance calculated successfully")
                    .data(response)
                    .build());

        } catch (Exception e) {
            System.err.println("ERROR in calculateDistance: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.internalServerError()
                    .body(ApiResponse.<Map<String, Object>>builder()
                            .success(false)
                            .message("Error calling SerpAPI: " + e.getMessage())
                            .data(null)
                            .build());
        }
    }

    /**
     * Autocomplete places (using Google Maps Autocomplete API via SerpAPI)
     * @param query Search query (supports Vietnamese)
     * @return List of place suggestions
     */
    @GetMapping("/autocomplete")
    public ResponseEntity<?> autocompletePlaces(@RequestParam String query) {
        try {
            if (query == null || query.trim().length() < 2) {
                return ResponseEntity.ok(ApiResponse.<Map<String, Object>>builder()
                        .success(true)
                        .message("Query too short")
                        .data(Map.of("suggestions", new java.util.ArrayList<>()))
                        .build());
            }

            // Build SerpAPI Autocomplete URL
            // ll = GPS coordinates - Format: @latitude,longitude,zoom
            // Using exact format from SerpAPI Playground example
            String serpApiUrl = UriComponentsBuilder
                    .fromHttpUrl("https://serpapi.com/search")
                    .queryParam("engine", "google_maps_autocomplete")
                    .queryParam("api_key", serpApiKey)
                    .queryParam("q", query)
                    .queryParam("ll", "@40.7455096,-74.0083012,14z")  // Using example coordinates from Playground
                    .queryParam("hl", "vi")  // Vietnamese language
                    .queryParam("gl", "vn")  // Vietnam country code
                    .toUriString();

            // Set headers
            HttpHeaders headers = new HttpHeaders();
            headers.set("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36");
            HttpEntity<String> entity = new HttpEntity<>(headers);

            // Call SerpAPI
            System.out.println("DEBUG Autocomplete: Calling SerpAPI with URL: " + serpApiUrl);
            Map<String, Object> response = restTemplate.exchange(
                serpApiUrl,
                HttpMethod.GET,
                entity,
                Map.class
            ).getBody();

            System.out.println("DEBUG Autocomplete: SerpAPI response: " + response);

            return ResponseEntity.ok(ApiResponse.<Map<String, Object>>builder()
                    .success(true)
                    .message("Autocomplete suggestions retrieved")
                    .data(response)
                    .build());

        } catch (Exception e) {
            System.err.println("ERROR in autocompletePlaces: " + e.getMessage());
            return ResponseEntity.internalServerError()
                    .body(ApiResponse.<Map<String, Object>>builder()
                            .success(false)
                            .message("Error calling SerpAPI: " + e.getMessage())
                            .data(null)
                            .build());
        }
    }
}
