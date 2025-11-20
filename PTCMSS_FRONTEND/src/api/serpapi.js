// SerpAPI Service - Google Maps Integration (via Backend Proxy)
const BACKEND_API_URL = "http://localhost:8080/api/serpapi";

/**
 * Remove Vietnamese accents from a string
 * This is needed because SerpAPI autocomplete works better with non-accented queries
 */
function removeVietnameseAccents(str) {
    return str
        .normalize("NFD")
        .replace(/[\u0300-\u036f]/g, "")
        .replace(/đ/g, "d")
        .replace(/Đ/g, "D");
}

/**
 * Calculate distance between two locations using SerpAPI Directions API
 * Now proxied through backend to avoid CORS issues
 * @param {string} startAddr - Starting address (e.g., "Hanoi Airport Terminal 1")
 * @param {string} endAddr - Ending address (e.g., "Pearl Westlake Hotel Hanoi")
 * @returns {Promise<{distance: number, duration: number, formattedDistance: string, formattedDuration: string}>}
 */
export async function calculateDistance(startAddr, endAddr) {
    if (!startAddr || !endAddr) {
        throw new Error("Both start and end addresses are required");
    }

    const params = new URLSearchParams({
        startAddr: startAddr,
        endAddr: endAddr,
    });

    try {
        const response = await fetch(`${BACKEND_API_URL}/distance?${params}`);

        if (!response.ok) {
            throw new Error(`Backend API error: ${response.status} ${response.statusText}`);
        }

        const apiResponse = await response.json();

        // Check if backend returned success
        if (!apiResponse.success || !apiResponse.data) {
            throw new Error(apiResponse.message || "Failed to get distance data");
        }

        const data = apiResponse.data;

        // Check if we have directions data
        if (!data.directions || data.directions.length === 0) {
            throw new Error("No route found between the two locations");
        }

        // Get the first (recommended) route
        const route = data.directions[0];

        // Extract distance and duration
        const distanceInMeters = route.distance; // in meters
        const distanceInKm = distanceInMeters / 1000; // convert to km
        const durationInSeconds = route.duration; // in seconds
        const durationInMinutes = Math.round(durationInSeconds / 60); // convert to minutes

        return {
            distance: Math.round(distanceInKm * 10) / 10, // Round to 1 decimal place
            duration: durationInMinutes,
            formattedDistance: route.formatted_distance || `${Math.round(distanceInKm * 10) / 10} km`,
            formattedDuration: route.formatted_duration || `${durationInMinutes} phút`,
            rawData: route, // Keep raw data for debugging
        };
    } catch (error) {
        console.error("SerpAPI calculateDistance error:", error);
        throw error;
    }
}

/**
 * Autocomplete places using Google Maps Autocomplete API (supports Vietnamese)
 * @param {string} query - Search query (e.g., "hồ hoàn kiếm" or "Hanoi Airport")
 * @returns {Promise<Array<{description: string, placeId: string}>>}
 */
export async function autocompletePlaces(query) {
    if (!query || query.trim().length < 2) {
        return [];
    }

    // Remove Vietnamese accents for better API results
    const normalizedQuery = removeVietnameseAccents(query);

    const params = new URLSearchParams({
        query: normalizedQuery,
    });

    try {
        const response = await fetch(`${BACKEND_API_URL}/autocomplete?${params}`);

        if (!response.ok) {
            console.error("Autocomplete API error:", response.status);
            return [];
        }

        const apiResponse = await response.json();

        // Check if backend returned success
        if (!apiResponse.success || !apiResponse.data) {
            return [];
        }

        const data = apiResponse.data;

        // Extract suggestions from SerpAPI response
        if (!data.suggestions || data.suggestions.length === 0) {
            return [];
        }

        // Map results to simpler format with full address and coordinates
        return data.suggestions.slice(0, 8).map((suggestion) => ({
            description: suggestion.value || suggestion.description || "",
            fullAddress: suggestion.subtext || suggestion.value || suggestion.description || "",
            placeId: suggestion.place_id || "",
            types: suggestion.types || [],
            latitude: suggestion.latitude,
            longitude: suggestion.longitude,
        }));
    } catch (error) {
        console.error("SerpAPI autocomplete error:", error);
        return [];
    }
}
