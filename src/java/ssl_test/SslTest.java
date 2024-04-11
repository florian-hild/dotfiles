import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLException;

public class SslTest{

    public static void main(String[] args) {
        String url = "https://example.com"; // Replace with your HTTPS URL

        try {
            // Create URL object
            URL obj = new URL(url);
            // Open HTTPS connection
            HttpsURLConnection connection = (HttpsURLConnection) obj.openConnection();

            // Get response code
            int responseCode = connection.getResponseCode();
            System.out.println("Response Code: " + responseCode);

            // Read the response
            BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            String inputLine;
            StringBuilder response = new StringBuilder();

            while ((inputLine = in.readLine()) != null) {
                response.append(inputLine);
            }

            // Close the connection
            in.close();

            // Print the response
            System.out.println("Response: " + response.toString());
        } catch (SSLException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
