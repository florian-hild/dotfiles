import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class OracleJDBCTest {
    public static void main(String[] args) {
        // JDBC URL, username, and password of Oracle database
        String jdbcUrl = "jdbc:oracle:thin:@ldap://ldap.sup-logistik.de:389/sup193u-cl,cn=OracleContext,dc=sup-logistik,dc=de";
        String username = "fiegeapfel";
        String password = "db_manager";

        try {
            // Load the Oracle JDBC driver
            Class.forName("oracle.jdbc.driver.OracleDriver");

            // Establish a connection
            Connection connection = DriverManager.getConnection(jdbcUrl, username, password);

            // Create a statement
            Statement statement = connection.createStatement();

            // Execute a query
            ResultSet resultSet = statement.executeQuery("SELECT TABLE_NAME FROM user_tables where rownum < 5 order by TABLE_NAME");

            // Process the result set
            while (resultSet.next()) {
                System.out.println("Table: " + resultSet.getString("TABLE_NAME"));
                // System.out.println("Column2: " + resultSet.getString("column2"));
                // Add more columns as needed
            }

            // Close the resources
            resultSet.close();
            statement.close();
            connection.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

