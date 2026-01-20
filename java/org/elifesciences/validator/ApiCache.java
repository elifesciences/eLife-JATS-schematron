package org.elifesciences.validator;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

// This is used to cache API queries from oXygen  so that the 
// endpoint(s) aren't spammed by automatic validation 
public class ApiCache {
    private static final Map<String, String> cache = new HashMap<>();

    public static String getRPData(String id, String version) {
        if (id == null || version == null) return "missing-parameters";
        String cacheKey = id + "|" + version;
        if (cache.containsKey(cacheKey)) {
            return cache.get(cacheKey);
        }

        try {
            URL url = new URL("https://api.elifesciences.org/reviewed-preprints/" + id + "v" + version);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Accept", "application/json");

            if (conn.getResponseCode() != 200) {
                return "{\"error\": \"HTTP Error: " + conn.getResponseCode() + "\"}";
            }

            BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            String inputLine;
            StringBuilder content = new StringBuilder();
            while ((inputLine = in.readLine()) != null) {
                content.append(inputLine);
            }
            in.close();
            conn.disconnect();

            String result = content.toString();
            cache.put(cacheKey, result);
            return result;

        } catch (Exception e) {
            return "{\"error\": \"Connection failed: " + e.getMessage() + "\"}";
        }
    }
}