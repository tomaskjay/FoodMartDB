package main;

import config.SQLConnection;
import utils.DatabaseHelper;

import java.sql.*;
import java.util.Scanner;

public class ProductsSub {
    public static void manageProducts(Scanner scanner) {
        boolean back = false;

        while (!back) {
            System.out.println("\n=== Manage Products ===");
            System.out.println("1. View All Products");
            System.out.println("2. Add New Product");
            System.out.println("3. Edit a Product");
            System.out.println("4. Remove a Product");
            System.out.println("5. Back to Main Menu");
            System.out.print("Enter your choice: ");

            if (scanner.hasNextInt()) {
                int choice = scanner.nextInt();
                switch (choice) {
                    case 1:
                        viewAllProducts();
                        break;
                    case 2:
                        addNewProduct(scanner);
                        break;
                    case 3:
                        updateProduct(scanner);
                        break;
                    case 4:
                        deleteProduct(scanner);
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

    private static void viewAllProducts() {
        try (Connection conn = SQLConnection.getConnection();
             CallableStatement stmt = conn.prepareCall("{CALL GetAllProducts}", 
                 ResultSet.TYPE_SCROLL_INSENSITIVE, 
                 ResultSet.CONCUR_READ_ONLY)) {

            ResultSet rs = stmt.executeQuery();
            System.out.println("\n=== Product List ===");
            DatabaseHelper.printResultSet(rs); // Use DatabaseHelper for dynamic display

        } catch (SQLException e) {
            System.out.println("Error fetching products: " + e.getMessage());
        }
    }

    public static int addNewProduct(Scanner scanner) {
        System.out.println("=== Add New Product ===");

        System.out.print("Enter product name: ");
        String productName = scanner.nextLine().trim(); // Use nextLine directly and trim spaces
    
        System.out.print("Enter section ID: ");
        while (!scanner.hasNextInt()) { // Ensure valid integer input
            System.out.println("Invalid input. Please enter a valid integer for section ID.");
            scanner.next(); // Consume invalid input
        }
        int sectionID = scanner.nextInt();
        scanner.nextLine(); // Consume leftover newline
    
        System.out.print("Enter shelf life (in days): ");
        while (!scanner.hasNextInt()) { // Ensure valid integer input
            System.out.println("Invalid input. Please enter a valid integer for shelf life.");
            scanner.next(); // Consume invalid input
        }
        int shelfLife = scanner.nextInt();
        scanner.nextLine(); // Consume leftover newline
    
        String insertQuery = "INSERT INTO Products (name, section_id, shelf_life) OUTPUT INSERTED.product_id VALUES (?, ?, ?)";
    
        try (Connection conn = SQLConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(insertQuery)) {
    
            // Set parameters for the PreparedStatement
            stmt.setString(1, productName);
            stmt.setInt(2, sectionID);
            stmt.setInt(3, shelfLife);
    
            // Execute the query and retrieve the generated product_id
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    int productID = rs.getInt(1);
                    System.out.println("Product added successfully! Product ID: " + productID);
                    return productID;
                }
            }
        } catch (SQLException e) {
            System.out.println("Error adding product: " + e.getMessage());
        }
    
        return -1; // Return -1 to indicate failure
    }

    private static void updateProduct(Scanner scanner) {
        System.out.print("Enter product ID to update: ");
        int productID = scanner.nextInt();

        System.out.print("Enter new product name: ");
        scanner.nextLine(); // Consume newline
        String name = scanner.nextLine();

        System.out.print("Enter new section ID: ");
        int sectionID = scanner.nextInt();

        System.out.print("Enter new shelf life (in days): ");
        int shelfLife = scanner.nextInt();

        try (Connection conn = SQLConnection.getConnection();
             CallableStatement stmt = conn.prepareCall("{CALL UpdateProduct(?, ?, ?, ?)}")) {

            stmt.setInt(1, productID);
            stmt.setString(2, name);
            stmt.setInt(3, sectionID);
            stmt.setInt(4, shelfLife);

            stmt.executeUpdate();
            System.out.println("Product updated successfully!");

        } catch (SQLException e) {
            System.out.println("Error updating product: " + e.getMessage());
        }
    }

    private static void deleteProduct(Scanner scanner) {
        System.out.print("Enter product ID to delete: ");
        int productID = scanner.nextInt();

        try (Connection conn = SQLConnection.getConnection();
             CallableStatement stmt = conn.prepareCall("{CALL DeleteProduct(?)}")) {

            stmt.setInt(1, productID);
            stmt.executeUpdate();
            System.out.println("Product deleted successfully!");

        } catch (SQLException e) {
            System.out.println("Error deleting product: " + e.getMessage());
        }
    }
}
