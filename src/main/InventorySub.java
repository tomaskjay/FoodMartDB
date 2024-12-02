package main;

import config.SQLConnection;
import utils.DatabaseHelper;

import java.sql.*;
import java.util.Scanner;

public class InventorySub {

    public static void manageInventory(Scanner scanner) {
        boolean back = false;

        while (!back) {
            System.out.println("\n=== Manage Inventory ===");
            System.out.println("1. View Inventory");
            System.out.println("2. Move Products from Storage to Shelf");
            System.out.println("3. Mark Expired Products");
            System.out.println("4. Detect Shoplifting");
            System.out.println("5. Back to Main Menu");
            System.out.print("Enter your choice: ");

            if (scanner.hasNextInt()) {
                int choice = scanner.nextInt();
                switch (choice) {
                    case 1:
                        viewInventory();
                        break;
                    case 2:
                        moveProducts(scanner);
                        break;
                    case 3:
                        markExpiredProducts();
                        break;
                    case 4:
                        detectShoplifting();
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

    private static void viewInventory() {
        try (Connection conn = SQLConnection.getConnection()) {
            conn.setAutoCommit(false); // Start transaction
    
            try (CallableStatement stmt = conn.prepareCall("{CALL GetInventory}", 
                    ResultSet.TYPE_SCROLL_INSENSITIVE, 
                    ResultSet.CONCUR_READ_ONLY)) {
    
                ResultSet rs = stmt.executeQuery();
                System.out.println("\n=== Inventory List ===");
                DatabaseHelper.printResultSet(rs);
    
                conn.commit(); // Commit transaction
            } catch (SQLException e) {
                conn.rollback(); // Rollback transaction on error
                System.out.println("Error fetching inventory: " + e.getMessage());
            } finally {
                conn.setAutoCommit(true); // Reset auto-commit to default
            }
        } catch (SQLException e) {
            System.out.println("Database connection error: " + e.getMessage());
        }
    }    

    private static void moveProducts(Scanner scanner) {
        System.out.print("Enter Inventory ID to move: ");
        int inventoryID = scanner.nextInt();
    
        System.out.print("Enter Quantity to move to shelf: ");
        int quantityToMove = scanner.nextInt();
    
        try (Connection conn = SQLConnection.getConnection()) {
            conn.setAutoCommit(false); // Start transaction
    
            try (CallableStatement stmt = conn.prepareCall("{CALL MoveProductToShelf(?, ?)}")) {
                // Set parameters for the stored procedure
                stmt.setInt(1, inventoryID);
                stmt.setInt(2, quantityToMove);
    
                // Execute the stored procedure
                stmt.execute();
    
                conn.commit(); // Commit transaction
                System.out.println("Product move operation completed successfully.");
            } catch (SQLException e) {
                conn.rollback(); // Rollback transaction on error
                System.out.println("Error moving products: " + e.getMessage());
            } finally {
                conn.setAutoCommit(true); // Reset auto-commit to default
            }
        } catch (SQLException e) {
            System.out.println("Database connection error: " + e.getMessage());
        }
    }
    
    private static void markExpiredProducts() {
        try (Connection conn = SQLConnection.getConnection()) {
            conn.setAutoCommit(false); // Start transaction
    
            try (CallableStatement stmt = conn.prepareCall("{CALL MarkExpiredProducts}", 
                    ResultSet.TYPE_SCROLL_INSENSITIVE, 
                    ResultSet.CONCUR_READ_ONLY)) {
    
                ResultSet rs = stmt.executeQuery();
                System.out.println("\n=== Expired Products Marked ===");
                DatabaseHelper.printResultSet(rs);
    
                conn.commit(); // Commit transaction
                System.out.println("Expired products have been marked as 'expired' in the inventory.");
    
            } catch (SQLException e) {
                conn.rollback(); // Rollback transaction on error
                System.out.println("Error marking expired products: " + e.getMessage());
            } finally {
                conn.setAutoCommit(true); // Reset auto-commit to default
            }
        } catch (SQLException e) {
            System.out.println("Database connection error: " + e.getMessage());
        }
    }

    private static void detectShoplifting() {
        try (Connection conn = SQLConnection.getConnection()) {
            conn.setAutoCommit(false); // Start transaction
    
            try (CallableStatement stmt = conn.prepareCall("{CALL DetectShoplifting}", 
                    ResultSet.TYPE_SCROLL_INSENSITIVE, 
                    ResultSet.CONCUR_READ_ONLY)) {
    
                ResultSet rs = stmt.executeQuery();
                System.out.println("\n=== Potential Shoplifting Detected ===");
                System.out.printf("%-20s %-15s %-15s %-15s %-15s\n", 
                    "Product Name", "Total Ordered", "Total Sold", "Total Inventory", "Discrepancy");
    
                boolean foundDiscrepancies = false;
    
                while (rs.next()) {
                    foundDiscrepancies = true;
                    System.out.printf("%-20s %-15d %-15d %-15d %-15d\n",
                        rs.getString("product_name"),
                        rs.getInt("total_ordered"),
                        rs.getInt("total_sold"),
                        rs.getInt("total_inventory"),
                        rs.getInt("discrepancy"));
                }
    
                if (!foundDiscrepancies) {
                    System.out.println("No discrepancies found. All products accounted for.");
                }
    
                conn.commit(); // Commit transaction
                System.out.println("Transaction committed successfully.");
            } catch (SQLException e) {
                conn.rollback(); // Rollback transaction on error
                System.out.println("Error detecting shoplifting, rolling back transaction: " + e.getMessage());
            } finally {
                conn.setAutoCommit(true); // Reset auto-commit to default
            }
        } catch (SQLException e) {
            System.out.println("Database connection error: " + e.getMessage());
        }
    }    
}