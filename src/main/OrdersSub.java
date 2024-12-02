package main;

import config.SQLConnection;
import utils.DatabaseHelper;

import java.sql.*;
import java.util.Scanner;

public class OrdersSub {
    public static void manageOrders(Scanner scanner) {
        boolean back = false;

        while (!back) {
            System.out.println("\n=== Manage Orders ===");
            System.out.println("1. View All Orders");
            System.out.println("2. Record an Order");
            System.out.println("3. Edit an Order");
            System.out.println("4. Remove an Order");
            System.out.println("5. Back to Previous Menu");
            System.out.print("Enter your choice: ");

            if (scanner.hasNextInt()) {
                int choice = scanner.nextInt();
                switch (choice) {
                    case 1:
                        viewAllOrders();
                        break;
                    case 2:
                        makeOrder(scanner);
                        break;
                    case 3:
                        updateOrder(scanner);
                        break;
                    case 4:
                        deleteOrder(scanner);
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

    private static void viewAllOrders() {
        try (Connection conn = SQLConnection.getConnection();
             CallableStatement stmt = conn.prepareCall("{CALL GetAllOrders}", 
                 ResultSet.TYPE_SCROLL_INSENSITIVE, 
                 ResultSet.CONCUR_READ_ONLY)) {

            ResultSet rs = stmt.executeQuery();
            System.out.println("\n=== Orders List ===");
            DatabaseHelper.printResultSet(rs);

        } catch (SQLException e) {
            System.out.println("Error fetching orders: " + e.getMessage());
        }
    }

    public static void makeOrder(Scanner scanner) {
        scanner.nextLine(); // Clear any leftover input before starting the method
    
        System.out.print("Is this a new product? (yes/no): ");
        String isNewProduct = "";
    
        // Loop to ensure valid input
        while (true) {
            isNewProduct = scanner.nextLine().trim().toLowerCase();
            if (isNewProduct.equals("yes") || isNewProduct.equals("no")) {
                break; // Valid input, exit loop
            }
            System.out.println("Invalid input. Please enter 'yes' or 'no'.");
            System.out.print("Is this a new product? (yes/no): ");
        }
    
        int productID;
    
        if (isNewProduct.equals("yes")) {
            productID = ProductsSub.addNewProduct(scanner); // Call the addNewProduct method
            if (productID == -1) {
                System.out.println("Failed to add product. Exiting Make Order.");
                return;
            }
        } else {
            System.out.print("Enter Product ID: ");
            while (!scanner.hasNextInt()) { // Ensure valid integer input
                System.out.println("Invalid input. Please enter a valid Product ID.");
                scanner.next(); // Consume invalid input
            }
            productID = scanner.nextInt();
            scanner.nextLine(); // Consume leftover newline
        }
    
        System.out.print("Enter Supplier ID: ");
        while (!scanner.hasNextInt()) { // Ensure valid integer input
            System.out.println("Invalid input. Please enter a valid Supplier ID.");
            scanner.next(); // Consume invalid input
        }
        int supplierID = scanner.nextInt();
        scanner.nextLine(); // Consume leftover newline
    
        System.out.print("Enter Total Quantity: ");
        while (!scanner.hasNextInt()) { // Ensure valid integer input
            System.out.println("Invalid input. Please enter a valid quantity.");
            scanner.next(); // Consume invalid input
        }
        int totalQuantity = scanner.nextInt();
        scanner.nextLine(); // Consume leftover newline
    
        System.out.print("Enter Order Date (YYYY-MM-DD): ");
        String orderDate = scanner.nextLine().trim();
    
        System.out.print("Enter Order Price: ");
        while (!scanner.hasNextDouble()) { // Ensure valid numeric input
            System.out.println("Invalid input. Please enter a valid order price.");
            scanner.next(); // Consume invalid input
        }
        double orderPrice = scanner.nextDouble();
        scanner.nextLine(); // Consume leftover newline
    
        try (Connection conn = SQLConnection.getConnection()) {
            conn.setAutoCommit(false); // Start transaction
    
            try (CallableStatement stmt = conn.prepareCall("{CALL MakeOrder(?, ?, ?, ?, ?)}")) {
                // Set parameters for the stored procedure
                stmt.setInt(1, productID);
                stmt.setInt(2, supplierID);
                stmt.setInt(3, totalQuantity);
                stmt.setString(4, orderDate);
                stmt.setDouble(5, orderPrice);
    
                // Execute the stored procedure
                stmt.executeUpdate();
    
                conn.commit(); // Commit transaction
                System.out.println("Order successfully created and added to inventory!");
            } catch (SQLException e) {
                conn.rollback(); // Rollback transaction on error
                System.out.println("Error creating order: " + e.getMessage());
            } finally {
                conn.setAutoCommit(true); // Reset auto-commit to default
            }
        } catch (SQLException e) {
            System.out.println("Database connection error: " + e.getMessage());
        }
    }    

    private static void updateOrder(Scanner scanner) {
        System.out.println("Only the order date and order price can be updated.");
        System.out.print("Enter Order ID to update: ");
        int orderID = scanner.nextInt();
        scanner.nextLine(); // Consume the leftover newline
    
        System.out.print("Do you want to update the order date? (yes/no): ");
        String updateDate = scanner.nextLine().trim().toLowerCase();
    
        String orderDate = null;
        if (updateDate.equals("yes")) {
            System.out.print("Enter new order date (YYYY-MM-DD): ");
            orderDate = scanner.nextLine().trim();
        }
    
        System.out.print("Do you want to update the order price? (yes/no): ");
        String updatePrice = scanner.nextLine().trim().toLowerCase();
    
        Double orderPrice = null;
        if (updatePrice.equals("yes")) {
            System.out.print("Enter new order price: ");
            while (!scanner.hasNextDouble()) {
                System.out.println("Invalid input. Please enter a valid price.");
                scanner.next(); // Consume invalid input
            }
            orderPrice = scanner.nextDouble();
            scanner.nextLine(); // Consume leftover newline
        }
    
        if (orderDate == null && orderPrice == null) {
            System.out.println("No updates made. Exiting.");
            return;
        }
    
        try (Connection conn = SQLConnection.getConnection();
             CallableStatement stmt = conn.prepareCall("{CALL UpdateOrder(?, ?, ?)}")) {
    
            // Set parameters for the stored procedure
            stmt.setInt(1, orderID);
    
            if (orderDate != null) {
                stmt.setString(2, orderDate);
            } else {
                stmt.setNull(2, java.sql.Types.DATE);
            }
    
            if (orderPrice != null) {
                stmt.setDouble(3, orderPrice);
            } else {
                stmt.setNull(3, java.sql.Types.DOUBLE);
            }
    
            // Execute the stored procedure
            stmt.executeUpdate();
            System.out.println("Order updated successfully!");
    
        } catch (SQLException e) {
            System.out.println("Error updating order: " + e.getMessage());
        }
    }    

    private static void deleteOrder(Scanner scanner) {
        System.out.print("Enter Order ID to delete: ");
        int orderID = scanner.nextInt();
    
        try (Connection conn = SQLConnection.getConnection();
             CallableStatement stmt = conn.prepareCall("{CALL DeleteOrderWithConflicts(?)}", 
                     ResultSet.TYPE_SCROLL_INSENSITIVE, 
                     ResultSet.CONCUR_READ_ONLY)) {
    
            stmt.setInt(1, orderID);
    
            // Execute and handle the first result set: Conflicting Inventory tuples
            boolean hasResults = stmt.execute();
            if (hasResults) {
                System.out.println("\nHere is a list of tuples in Inventory that conflict with deleting this order:");
                try (ResultSet rsInventory = stmt.getResultSet()) {
                    DatabaseHelper.printResultSet(rsInventory);
                }
            }
    
            // Move to the next result set: Conflicting Sales tuples
            if (stmt.getMoreResults()) {
                System.out.println("\nHere is a list of tuples in Sales that conflict with deleting this order:");
                try (ResultSet rsSales = stmt.getResultSet()) {
                    DatabaseHelper.printResultSet(rsSales);
                }
            }
    
            // Perform the deletion
            System.out.println("Attempting to delete the order...");
            if (!stmt.getMoreResults()) {
                System.out.println("Order and associated tuples have been deleted successfully.");
            }
    
        } catch (SQLException e) {
            System.out.println("Error deleting order: " + e.getMessage());
        }
    }
}
