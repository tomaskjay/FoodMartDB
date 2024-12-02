package main;

import config.SQLConnection;
import utils.DatabaseHelper;

import java.sql.*;
import java.util.Scanner;

public class SalesSub {
    public static void manageSales(Scanner scanner) {
        boolean back = false;

        while (!back) {
            System.out.println("\n=== Manage Sales ===");
            System.out.println("1. View All Sales");
            System.out.println("2. Record a Sale");
            System.out.println("3. Edit a Sale");
            System.out.println("4. Remove a Sale");
            System.out.println("5. Back to Previous Menu");
            System.out.print("Enter your choice: ");

            if (scanner.hasNextInt()) {
                int choice = scanner.nextInt();
                switch (choice) {
                    case 1:
                        viewAllSales();
                        break;
                    case 2:
                        addSale(scanner);
                        break;
                    case 3:
                        updateSale(scanner);
                        break;
                    case 4:
                        deleteSale(scanner);
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

    private static void viewAllSales() {
        try (Connection conn = SQLConnection.getConnection();
             CallableStatement stmt = conn.prepareCall("{CALL GetAllSales}", 
                 ResultSet.TYPE_SCROLL_INSENSITIVE, 
                 ResultSet.CONCUR_READ_ONLY)) {

            ResultSet rs = stmt.executeQuery();
            System.out.println("\n=== Sales List ===");
            DatabaseHelper.printResultSet(rs);

        } catch (SQLException e) {
            System.out.println("Error fetching sales: " + e.getMessage());
        }
    }

    private static void addSale(Scanner scanner) {
        System.out.print("Is this an existing customer? (yes/no): ");
        scanner.nextLine(); // Consume leftover newline
        String isExistingCustomer = scanner.nextLine().trim().toLowerCase();
    
        int customerId;
    
        if (isExistingCustomer.equals("yes")) {
            System.out.print("Enter Customer ID: ");
            customerId = scanner.nextInt();
    
            // Validate customer ID
            try (Connection conn = SQLConnection.getConnection();
                 CallableStatement stmt = conn.prepareCall("{CALL GetCustomerById(?)}")) {
    
                stmt.setInt(1, customerId);
                ResultSet rs = stmt.executeQuery();
    
                if (!rs.next()) {
                    System.out.println("Error: Customer ID not found.");
                    return;
                }
    
            } catch (SQLException e) {
                System.out.println("Error verifying customer: " + e.getMessage());
                return;
            }
        } else {
            // Add a new customer
            CustomersSub.addCustomer(scanner);
    
            // Retrieve the newly added customer's ID
            try (Connection conn = SQLConnection.getConnection();
                 CallableStatement stmt = conn.prepareCall("{CALL GetLastCustomerId}")) {
    
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    customerId = rs.getInt("customer_id");
                    System.out.println("New customer added with ID: " + customerId);
                } else {
                    System.out.println("Error retrieving new customer ID.");
                    return;
                }
    
            } catch (SQLException e) {
                System.out.println("Error retrieving new customer ID: " + e.getMessage());
                return;
            }
        }
    
        System.out.print("Enter Inventory ID to sell: ");
        int inventoryId = scanner.nextInt();
    
        System.out.print("Enter Sale Quantity: ");
        int saleQuantity = scanner.nextInt();
    
        System.out.print("Enter Sale Date (YYYY-MM-DD): ");
        scanner.nextLine(); // Consume leftover newline
        String saleDate = scanner.nextLine();
    
        System.out.print("Enter Total Sale Price: ");
        double salePrice = scanner.nextDouble();
    
        Connection conn = null;
        try {
            conn = SQLConnection.getConnection();
            conn.setAutoCommit(false); // Start transaction
    
            try (
                CallableStatement getInventoryStmt = conn.prepareCall("{CALL GetInventoryById(?)}");
                CallableStatement updateInventoryStmt = conn.prepareCall("{CALL UpdateInventory(?)}");
                CallableStatement addSaleStmt = conn.prepareCall("{CALL RecordSale(?, ?, ?, ?, ?)}")
            ) {
                // Validate inventory ID and ensure it's from the shelf
                getInventoryStmt.setInt(1, inventoryId);
                ResultSet rs = getInventoryStmt.executeQuery();
    
                if (!rs.next()) {
                    System.out.println("Error: Inventory ID not found.");
                    conn.rollback(); // Rollback transaction
                    return;
                }
    
                String location = rs.getString("location");
                int currentQuantity = rs.getInt("quantity");
    
                if (!location.equalsIgnoreCase("shelf")) {
                    System.out.println("Error: Only items from the shelf can be sold.");
                    conn.rollback(); // Rollback transaction
                    return;
                }
    
                if (saleQuantity > currentQuantity) {
                    System.out.println("Error: Insufficient quantity on the shelf.");
                    conn.rollback(); // Rollback transaction
                    return;
                }
    
                // Record the sale
                addSaleStmt.setInt(1, inventoryId);
                addSaleStmt.setInt(2, customerId);
                addSaleStmt.setInt(3, saleQuantity);
                addSaleStmt.setString(4, saleDate);
                addSaleStmt.setDouble(5, salePrice);
    
                addSaleStmt.execute();
    
                // Update inventory
                if (saleQuantity == currentQuantity) {
                    // If all items are sold, update inventory to sold
                    updateInventoryStmt.setInt(1, inventoryId);
                    updateInventoryStmt.execute();
                    System.out.println("All items sold. Inventory updated to sold with quantity set to 0.");
                } else {
                    // Otherwise, decrement the quantity
                    try (CallableStatement decrementInventoryStmt = conn.prepareCall("{CALL DecrementInventory(?, ?)}")) {
                        decrementInventoryStmt.setInt(1, inventoryId);
                        decrementInventoryStmt.setInt(2, saleQuantity);
                        decrementInventoryStmt.execute();
                        System.out.println("Inventory updated. Remaining quantity: " + (currentQuantity - saleQuantity));
                    }
                }
    
                conn.commit(); // Commit transaction
                System.out.println("Sale recorded successfully!");
    
            } catch (SQLException e) {
                conn.rollback(); // Rollback transaction
                System.out.println("Error during transaction: " + e.getMessage());
            }
    
        } catch (SQLException e) {
            System.out.println("Error recording sale: " + e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true); // Restore auto-commit
                    conn.close();
                } catch (SQLException e) {
                    System.out.println("Error closing connection: " + e.getMessage());
                }
            }
        }
    }        

    private static void updateSale(Scanner scanner) {
        System.out.println("Note: Sale quantity cannot be changed.");
        System.out.print("Enter Sale ID to update: ");
        int saleID = scanner.nextInt();
        scanner.nextLine(); // Consume leftover newline
    
        System.out.print("Do you want to update the Customer ID? (yes/no): ");
        String updateCustomerId = scanner.nextLine().trim().toLowerCase();
        Integer customerId = null;
        if (updateCustomerId.equals("yes")) {
            System.out.print("Enter new Customer ID: ");
            while (!scanner.hasNextInt()) {
                System.out.println("Invalid input. Please enter a valid Customer ID.");
                scanner.next(); // Consume invalid input
            }
            customerId = scanner.nextInt();
            scanner.nextLine(); // Consume leftover newline
        }
    
        System.out.print("Do you want to update the Sale Date? (yes/no): ");
        String updateDate = scanner.nextLine().trim().toLowerCase();
        String saleDate = null;
        if (updateDate.equals("yes")) {
            System.out.print("Enter new Sale Date (YYYY-MM-DD): ");
            saleDate = scanner.nextLine().trim();
        }
    
        System.out.print("Do you want to update the Sale Price? (yes/no): ");
        String updatePrice = scanner.nextLine().trim().toLowerCase();
        Double salePrice = null;
        if (updatePrice.equals("yes")) {
            System.out.print("Enter new Sale Price: ");
            while (!scanner.hasNextDouble()) {
                System.out.println("Invalid input. Please enter a valid price.");
                scanner.next(); // Consume invalid input
            }
            salePrice = scanner.nextDouble();
            scanner.nextLine(); // Consume leftover newline
        }
    
        // Check if any updates are requested
        if (customerId == null && saleDate == null && salePrice == null) {
            System.out.println("No updates were made. Exiting.");
            return;
        }
    
        try (Connection conn = SQLConnection.getConnection();
             CallableStatement stmt = conn.prepareCall("{CALL UpdateSale(?, ?, ?, ?)}")) {
    
            // Set the parameters for the stored procedure
            stmt.setInt(1, saleID);
    
            if (customerId != null) {
                stmt.setInt(2, customerId);
            } else {
                stmt.setNull(2, java.sql.Types.INTEGER);
            }
    
            if (saleDate != null) {
                stmt.setString(3, saleDate);
            } else {
                stmt.setNull(3, java.sql.Types.DATE);
            }
    
            if (salePrice != null) {
                stmt.setDouble(4, salePrice);
            } else {
                stmt.setNull(4, java.sql.Types.DOUBLE);
            }
    
            // Execute the stored procedure
            stmt.execute();
            System.out.println("Sale updated successfully!");
    
        } catch (SQLException e) {
            System.out.println("Error updating sale: " + e.getMessage());
        }
    }    

    private static void deleteSale(Scanner scanner) {
        System.out.println("Deleting a sale isn't recommended. This won't return any products to the inventory.");
        System.out.println("Consider making a return instead. Proceed with deleting the sale? (yes/no)");
    
        scanner.nextLine(); // Consume any leftover newline
        String confirmation = scanner.nextLine().trim().toLowerCase();
    
        if (confirmation.equals("yes")) {
            System.out.print("Enter Sale ID to delete: ");
            int saleID = scanner.nextInt();
    
            try (Connection conn = SQLConnection.getConnection();
                 CallableStatement stmt = conn.prepareCall("{CALL DeleteSale(?)}")) {
    
                stmt.setInt(1, saleID);
                stmt.executeUpdate();
                System.out.println("Sale deleted successfully!");
    
            } catch (SQLException e) {
                System.out.println("Error deleting sale: " + e.getMessage());
            }
        } else {
            System.out.println("Sale deletion canceled.");
        }
    }
}
