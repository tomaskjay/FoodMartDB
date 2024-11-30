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
            System.out.println("2. Record a Sale (Not Implemented)");
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
                        addSale();
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

    private static void addSale() {

    }


    private static void updateSale(Scanner scanner) {
        System.out.print("Enter Sale ID to update: ");
        int saleID = scanner.nextInt();
    
        System.out.print("Enter new quantity: ");
        int newQuantity = scanner.nextInt();
    
        try (Connection conn = SQLConnection.getConnection();
             CallableStatement stmt = conn.prepareCall("{CALL UpdateSale(?, ?)}")) {
    
            // Set the parameters for the stored procedure
            stmt.setInt(1, saleID);
            stmt.setInt(2, newQuantity);
    
            // Execute the stored procedure
            stmt.execute();
    
            // Retrieve and print any messages from the stored procedure
            System.out.println("Sale and inventory update operation completed. Check logs or database for details.");
    
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
