package org.elifesciences.validator;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.HashMap;
import java.util.Map;

// This is used to cache API queries from oXygen  so that the 
// endpoint(s) aren't spammed by automatic validation 
public class ApiCache {
    private static final Map<String, String> cache = new HashMap<>();
    private static final HttpClient client = HttpClient.newBuilder()
            .followRedirects(HttpClient.Redirect.NORMAL)
            .build();
    public static String getRPData(String id, String version) {
        if (id == null || version == null) return "missing-parameters";
        String cacheKey = id + "|" + version;
        if (cache.containsKey(cacheKey)) {
            return cache.get(cacheKey);
        }

        try {
            HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("https://api.elifesciences.org/reviewed-preprints/" + id + "v" + version))
                .header("Accept", "application/json")
                .timeout(java.time.Duration.ofSeconds(2))
                .GET()
                .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            int statusCode = response.statusCode();
            String result;

            if (statusCode == 200) {
                result = response.body();
            } else if (statusCode == 404) {
                result = "NOT_FOUND";
            } else {
                result = "SERVER_ERROR: " + statusCode;
            }

            cache.put(cacheKey, result); 
            return result;
            
        } catch (Exception e) {
            return "CONNECTION_FAILURE: " + e.getMessage();
        }
    }
}