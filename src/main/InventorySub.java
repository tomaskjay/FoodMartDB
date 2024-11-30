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
            System.out.println("3. Toss Expired Products");
            System.out.println("4. Back to Main Menu");
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
                        //tossExpiredProducts();
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

    private static void viewInventory() {
        try (Connection conn = SQLConnection.getConnection();
             CallableStatement stmt = conn.prepareCall("{CALL GetInventory}", 
                 ResultSet.TYPE_SCROLL_INSENSITIVE, 
                 ResultSet.CONCUR_READ_ONLY)) {

            ResultSet rs = stmt.executeQuery();
            System.out.println("\n=== Inventory List ===");
            DatabaseHelper.printResultSet(rs);

        } catch (SQLException e) {
            System.out.println("Error fetching inventory: " + e.getMessage());
        }
    }

    private static void moveProducts(Scanner scanner) {
        System.out.print("Enter Inventory ID to move: ");
        int inventoryID = scanner.nextInt();
    
        System.out.print("Enter Quantity to move to shelf: ");
        int quantityToMove = scanner.nextInt();
    
        try (Connection conn = SQLConnection.getConnection();
             CallableStatement stmt = conn.prepareCall("{CALL MoveProductToShelf(?, ?)}")) {
    
            // Set parameters for the stored procedure
            stmt.setInt(1, inventoryID);
            stmt.setInt(2, quantityToMove);
    
            // Execute the stored procedure
            stmt.execute();
    
            System.out.println("Product move operation completed successfully.");
    
        } catch (SQLException e) {
            System.out.println("Error moving products: " + e.getMessage());
        }
    }    
    
}