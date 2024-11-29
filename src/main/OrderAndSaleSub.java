package main;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Date;
import java.sql.SQLException;
import java.sql.Types;
import java.util.Scanner;

import config.SQLConnection;

public class OrderAndSaleSub {
    public static void manageOrdersandSales(Scanner scanner) {
        boolean back = false;

        while (!back) {
            System.out.println("\n=== Manage Orders and Sales ===");
            System.out.println("1. Make an Order");
            System.out.println("2. Buy a Product");
            System.out.println("3. Return a Product");
            System.out.println("4. Back to Main Menu");
            System.out.print("Enter your choice: ");

            int choice = scanner.nextInt();

            switch (choice) {
                case 1:
                    // makeOrder();
                    break;
                case 2:
                    addSale(scanner);
                    break;
                case 3:
                    // updateProduct(scanner);
                    break;
                case 4:
                    back = true;
                    break;
                default:
                    System.out.println("Invalid choice. Please try again.");
            }
        }
    }

    private static void addSale(Scanner scanner) {
        try (Connection conn = SQLConnection.getConnection()) {
            // Step 1: Ask if the customer is an existing customer
            System.out.print("Have you shopped here before? (yes/no): ");
            scanner.nextLine(); // Consume leftover newline
            String hasShoppedBefore = scanner.nextLine().trim().toLowerCase();

            int customerId;
            if (hasShoppedBefore.equals("yes")) {
                // Step 2: Get customer ID
                System.out.print("Please enter your customer ID: ");
                customerId = scanner.nextInt();
                scanner.nextLine(); // Consume leftover newline
            } else {
                // Step 3: Add a new contact
                System.out.println("Let's create a new contact for you.");
                System.out.print("Enter your email: ");
                String email = scanner.nextLine();
                System.out.print("Enter your phone number: ");
                String phone = scanner.nextLine();
                System.out.print("Enter your street address: ");
                String street = scanner.nextLine();
                System.out.print("Enter your city: ");
                String city = scanner.nextLine();
                System.out.print("Enter your state (2 letters): ");
                String state = scanner.nextLine();
                System.out.print("Enter your zip code: ");
                String zipCode = scanner.nextLine();

                int contactId = addContact(conn, email, phone, street, city, state, zipCode);

                // Step 4: Add a new customer
                System.out.println("Now let's create a customer profile for you.");
                System.out.print("Enter your first name: ");
                String firstName = scanner.nextLine();
                System.out.print("Enter your last name: ");
                String lastName = scanner.nextLine();
                System.out.print("Enter your age: ");
                int age = scanner.nextInt();
                scanner.nextLine(); // Consume leftover newline

                customerId = addCustomer(conn, contactId, firstName, lastName, age);
            }

            // Step 5: Process the sale
            System.out.println("Let's process your sale.");
            System.out.print("Enter inventory ID: ");
            int inventoryId = scanner.nextInt();
            System.out.print("Enter sale quantity: ");
            int saleQuantity = scanner.nextInt();
            System.out.print("Enter sale date (YYYY-MM-DD): ");
            scanner.nextLine(); // Consume leftover newline
            String saleDate = scanner.nextLine();
            System.out.print("Enter sale price: ");
            double salePrice = scanner.nextDouble();

            processSale(conn, customerId, inventoryId, saleQuantity, saleDate, salePrice);

        } catch (SQLException e) {
            System.out.println("An error occurred while processing the sale: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private static int addContact(Connection conn, String email, String phone, String street, String city, String state, String zipCode) throws SQLException {
        String sql = "{CALL sp_add_contact(?, ?, ?, ?, ?, ?, ?)}";
        try (CallableStatement stmt = conn.prepareCall(sql)) {
            stmt.setString(1, email);
            stmt.setString(2, phone);
            stmt.setString(3, street);
            stmt.setString(4, city);
            stmt.setString(5, state);
            stmt.setString(6, zipCode);
            stmt.registerOutParameter(7, Types.INTEGER); // Output parameter for new_contact_id

            stmt.execute();
            int contactId = stmt.getInt(7);
            System.out.println("New contact created with ID: " + contactId);
            return contactId;
        }
    }

    private static int addCustomer(Connection conn, int contactId, String firstName, String lastName, int age) throws SQLException {
        String sql = "{CALL sp_add_customer(?, ?, ?, ?, ?)}"; // Adjusted to include output parameter
        try (CallableStatement stmt = conn.prepareCall(sql)) {
            stmt.setInt(1, contactId);
            stmt.setString(2, firstName);
            stmt.setString(3, lastName);
            stmt.setInt(4, age);
            stmt.registerOutParameter(5, Types.INTEGER); // Output parameter for new_customer_id

            stmt.execute();
            int customerId = stmt.getInt(5); // Retrieve the generated customer ID
            System.out.println("Customer added successfully with ID: " + customerId);
            return customerId;
        }
    }

    private static void processSale(Connection conn, int customerId, int inventoryId, int saleQuantity, String saleDate, double salePrice) throws SQLException {
        String sql = "{CALL sp_process_sale(?, ?, ?, ?, ?)}";
        try (CallableStatement stmt = conn.prepareCall(sql)) {
            stmt.setInt(1, customerId);
            stmt.setInt(2, inventoryId);
            stmt.setInt(3, saleQuantity);
            stmt.setDate(4, Date.valueOf(saleDate)); // Convert string to SQL date
            stmt.setDouble(5, salePrice);

            stmt.execute();
            System.out.println("Sale processed successfully.");
        }
    }
}
