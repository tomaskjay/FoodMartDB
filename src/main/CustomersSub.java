package main;

import config.SQLConnection;
import utils.DatabaseHelper;

import java.sql.*;
import java.util.Scanner;

public class CustomersSub {

    public static void manageCustomers(Scanner scanner) {
        boolean back = false;

        while (!back) {
            System.out.println("\n=== Manage Customers ===");
            System.out.println("1. View");
            System.out.println("2. Add");
            System.out.println("3. Edit");
            System.out.println("4. Remove");
            System.out.println("5. Back to Main Menu");
            System.out.print("Enter your choice: ");

            if (scanner.hasNextInt()) {
                int choice = scanner.nextInt();
                switch (choice) {
                    case 1:
                        viewCustomers();
                        break;
                    case 2:
                        addCustomer(scanner);
                        break;
                    case 3:
                        editCustomer(scanner);
                        break;
                    case 4:
                        removeCustomer(scanner);
                        break;
                    case 5:
                        back = true;
                        break;
                    default:
                        System.out.println("Invalid choice. Please try again.");
                }
            } else {
                System.out.println("Invalid input. Please enter a number.");
                scanner.next(); // Consume invalid input
            }
        }
    }

    private static void viewCustomers() {
        try (Connection conn = SQLConnection.getConnection();
             CallableStatement stmt = conn.prepareCall(
                 "{CALL GetAllCustomers}",
                 ResultSet.TYPE_SCROLL_INSENSITIVE,
                 ResultSet.CONCUR_READ_ONLY)) {

            // Execute the stored procedure
            ResultSet rs = stmt.executeQuery();

            // Display the results
            System.out.println("\n=== Customer List ===");
            DatabaseHelper.printResultSet(rs);

        } catch (SQLException e) {
            System.out.println("Error viewing customers: " + e.getMessage());
        }
    }

    static void addCustomer(Scanner scanner) {
        System.out.print("Enter First Name: ");
        scanner.nextLine(); // Consume leftover newline
        String firstName = scanner.nextLine();

        System.out.print("Enter Last Name: ");
        String lastName = scanner.nextLine();

        System.out.print("Enter Age: ");
        int age = scanner.nextInt();

        System.out.print("Enter Email: ");
        scanner.nextLine(); // Consume leftover newline
        String email = scanner.nextLine();

        System.out.print("Enter Phone: ");
        String phone = scanner.nextLine();

        System.out.print("Enter Street Address: ");
        String street = scanner.nextLine();

        System.out.print("Enter City: ");
        String city = scanner.nextLine();

        System.out.print("Enter State (2 letters): ");
        String state = scanner.nextLine();

        System.out.print("Enter Zip Code: ");
        String zipCode = scanner.nextLine();

        try (Connection conn = SQLConnection.getConnection();
             CallableStatement stmt = conn.prepareCall("{CALL AddCustomer(?, ?, ?, ?, ?, ?, ?, ?, ?)}")) {

            // Set parameters for the stored procedure
            stmt.setString(1, firstName);
            stmt.setString(2, lastName);
            stmt.setInt(3, age);
            stmt.setString(4, email);
            stmt.setString(5, phone);
            stmt.setString(6, street);
            stmt.setString(7, city);
            stmt.setString(8, state);
            stmt.setString(9, zipCode);

            // Execute the stored procedure
            stmt.executeUpdate();

            System.out.println("Customer added successfully!");

        } catch (SQLException e) {
            System.out.println("Error adding customer: " + e.getMessage());
        }
    }

    private static void editCustomer(Scanner scanner) {
        System.out.print("Enter Customer ID to edit: ");
        int customerId = scanner.nextInt();

        System.out.print("Enter new First Name: ");
        scanner.nextLine(); // Consume leftover newline
        String firstName = scanner.nextLine();

        System.out.print("Enter new Last Name: ");
        String lastName = scanner.nextLine();

        System.out.print("Enter new Age: ");
        int age = scanner.nextInt();

        System.out.print("Enter new Email: ");
        scanner.nextLine(); // Consume leftover newline
        String email = scanner.nextLine();

        System.out.print("Enter new Phone: ");
        String phone = scanner.nextLine();

        System.out.print("Enter new Street Address: ");
        String street = scanner.nextLine();

        System.out.print("Enter new City: ");
        String city = scanner.nextLine();

        System.out.print("Enter new State (2 letters): ");
        String state = scanner.nextLine();

        System.out.print("Enter new Zip Code: ");
        String zipCode = scanner.nextLine();

        try (Connection conn = SQLConnection.getConnection();
             CallableStatement stmt = conn.prepareCall("{CALL EditCustomer(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}")) {

            // Set parameters for the stored procedure
            stmt.setInt(1, customerId);
            stmt.setString(2, firstName);
            stmt.setString(3, lastName);
            stmt.setInt(4, age);
            stmt.setString(5, email);
            stmt.setString(6, phone);
            stmt.setString(7, street);
            stmt.setString(8, city);
            stmt.setString(9, state);
            stmt.setString(10, zipCode);

            // Execute the stored procedure
            stmt.executeUpdate();

            System.out.println("Customer updated successfully!");

        } catch (SQLException e) {
            System.out.println("Error editing customer: " + e.getMessage());
        }
    }

    private static void removeCustomer(Scanner scanner) {
        System.out.print("Enter Customer ID to remove: ");
        int customerId = scanner.nextInt();
    
        try (Connection conn = SQLConnection.getConnection();
             CallableStatement stmt = conn.prepareCall("{CALL RemoveCustomer(?)}")) {
    
            // Set the parameter for the stored procedure
            stmt.setInt(1, customerId);
    
            // Execute the stored procedure
            stmt.execute();
    
            System.out.println("Customer removed successfully.");
    
        } catch (SQLException e) {
            System.out.println("Error removing customer: " + e.getMessage());
        }
    }
    
}
