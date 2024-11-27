package config;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class SQLConnection {

    public static void main(String[] args) {
        // Connection string for your database
        String connectionUrl = 
           "jdbc:sqlserver://cxp-sql-03\\tkj13;" +
           "database=FoodMartDB;" +
           "user=sa;" +
           "password=D2Uxg3ByIzvA0k;" +
           "encrypt=true;" +
           "trustServerCertificate=true;" +
           "loginTimeout=15;";

        // Attempt to establish the connection
        try (Connection connection = DriverManager.getConnection(connectionUrl)) {
            // Connection successful, do nothing
            System.out.println("Connected to database.");
        } catch (SQLException e) {
            // Print message if connection fails
            System.out.println("Failed to connect to the database. Please check your connection settings.");
        }
    }
}