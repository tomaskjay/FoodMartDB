package config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class SQLConnection {

    // Database connection details
    private static final String CONNECTION_URL = 
        "jdbc:sqlserver://cxp-sql-03\\tkj13;" +
        "database=FoodMartDB;" +
        "user=sa;" +
        "password=D2Uxg3ByIzvA0k;" +
        "encrypt=true;" +
        "trustServerCertificate=true;" +
        "loginTimeout=15;";

    /**
     * Establishes and returns a database connection.
     * 
     * @return Connection object for the database
     * @throws SQLException if the connection fails
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(CONNECTION_URL);
    }

    public static void main(String[] args) {
        // Test the connection
        try (Connection connection = SQLConnection.getConnection()) {
            System.out.println("Connected to database.");
        } catch (SQLException e) {
            System.out.println("Failed to connect to the database. Please check your connection settings.");
            e.printStackTrace();
        }
    }
}
