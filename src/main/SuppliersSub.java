package main;

import config.SQLConnection;
import utils.DatabaseHelper;

import java.sql.*;
import java.util.Scanner;

public class SuppliersSub {

    public static void manageSuppliers(Scanner scanner) {
        boolean back = false;

        while (!back) {
            System.out.println("\n=== Manage Suppliers ===");
            System.out.println("1. View");
            System.out.println("2. Add");
            System.out.println("3. Edit");
            System.out.println("4. Back to Main Menu");
            System.out.print("Enter your choice: ");

            if (scanner.hasNextInt()) {
                int choice = scanner.nextInt();
                switch (choice) {
                    case 1:
                        viewSuppliers();
                        break;
                    case 2:
                        addSupplier(scanner);
                        break;
                    case 3:
                        editSupplier(scanner);
                        break;
                    case 4:
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

    private static void viewSuppliers() {
        try (Connection conn = SQLConnection.getConnection();
             CallableStatement stmt = conn.prepareCall(
                 "{CALL GetAllSuppliers}",
                 ResultSet.TYPE_SCROLL_INSENSITIVE,
                 ResultSet.CONCUR_READ_ONLY)) {

            // Execute the stored procedure
            ResultSet rs = stmt.executeQuery();

            // Display the results
            System.out.println("\n=== Supplier List ===");
            DatabaseHelper.printResultSet(rs);

        } catch (SQLException e) {
            System.out.println("Error viewing suppliers: " + e.getMessage());
        }
    }

    private static void addSupplier(Scanner scanner) {
        System.out.print("Enter Supplier Name: ");
        scanner.nextLine(); // Consume leftover newline
        String supplierName = scanner.nextLine();

        System.out.print("Enter Email: ");
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
             CallableStatement addContactStmt = conn.prepareCall("{CALL AddContact(?, ?, ?, ?, ?, ?, ?)}");
             CallableStatement addSupplierStmt = conn.prepareCall("{CALL AddSupplier(?, ?)}")) {

            // Add contact details
            addContactStmt.setString(1, email);
            addContactStmt.setString(2, phone);
            addContactStmt.setString(3, street);
            addContactStmt.setString(4, city);
            addContactStmt.setString(5, state);
            addContactStmt.setString(6, zipCode);
            addContactStmt.registerOutParameter(7, Types.INTEGER);

            addContactStmt.execute();
            int contactId = addContactStmt.getInt(7);

            // Add supplier with the generated contact ID
            addSupplierStmt.setString(1, supplierName);
            addSupplierStmt.setInt(2, contactId);

            addSupplierStmt.execute();

            System.out.println("Supplier added successfully!");

        } catch (SQLException e) {
            System.out.println("Error adding supplier: " + e.getMessage());
        }
    }

    private static void editSupplier(Scanner scanner) {
        System.out.print("Enter Supplier ID to edit: ");
        int supplierId = scanner.nextInt();

        System.out.print("Enter new Supplier Name: ");
        scanner.nextLine(); // Consume leftover newline
        String supplierName = scanner.nextLine();

        System.out.print("Enter new Email: ");
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
             CallableStatement getContactStmt = conn.prepareCall("{CALL GetContactBySupplier(?)}");
             CallableStatement updateContactStmt = conn.prepareCall("{CALL UpdateContact(?, ?, ?, ?, ?, ?, ?)}");
             CallableStatement updateSupplierStmt = conn.prepareCall("{CALL UpdateSupplier(?, ?)}")) {

            // Retrieve the contact ID associated with the supplier
            getContactStmt.setInt(1, supplierId);
            ResultSet rs = getContactStmt.executeQuery();
            int contactId = -1;
            if (rs.next()) {
                contactId = rs.getInt("contact_id");
            } else {
                System.out.println("Error: Supplier not found.");
                return;
            }

            // Update contact details
            updateContactStmt.setInt(1, contactId);
            updateContactStmt.setString(2, email);
            updateContactStmt.setString(3, phone);
            updateContactStmt.setString(4, street);
            updateContactStmt.setString(5, city);
            updateContactStmt.setString(6, state);
            updateContactStmt.setString(7, zipCode);

            updateContactStmt.execute();

            // Update supplier name
            updateSupplierStmt.setInt(1, supplierId);
            updateSupplierStmt.setString(2, supplierName);

            updateSupplierStmt.execute();

            System.out.println("Supplier updated successfully!");

        } catch (SQLException e) {
            System.out.println("Error editing supplier: " + e.getMessage());
        }
    }
}
