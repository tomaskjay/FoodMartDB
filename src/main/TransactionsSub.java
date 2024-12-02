package main;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Scanner;

import config.SQLConnection;

public class TransactionsSub {

    public static void manageTransactions(Scanner scanner) {
        boolean back = false;
        while (!back) {
            System.out.println("\n=== Manage Transactions ===");
            System.out.println("1. Sales");
            System.out.println("2. Orders");
            System.out.println("3. Make a Return");
            System.out.println("4. View Popular");
            System.out.println("5. Back to Main Menu");
            System.out.print("Enter your choice: ");

            if (scanner.hasNextInt()) {
                int choice = scanner.nextInt();
                switch (choice) {
                    case 1:
                        SalesSub.manageSales(scanner);
                        break;
                    case 2:
                        OrdersSub.manageOrders(scanner);
                        break;
                    case 3:
                        manageReturns(scanner);
                        break;
                    case 4:
                        viewPopularProducts();
                        break;
                    case 5:
                        back = true;
                        break;
                    default:
                        System.out.println("Invalid choice. Please try again.");
                }
            } else {
                System.out.println("Invalid input. Please enter a number.");
                scanner.next();
            }
        }
    }

    private static void manageReturns(Scanner scanner) {
        System.out.print("Enter Sale ID: ");
        int saleID = scanner.nextInt();
    
        System.out.print("Enter Returned Quantity: ");
        int returnedQuantity = scanner.nextInt();
        scanner.nextLine();
    
        if (returnedQuantity < 1) {
            System.out.println("Error: Returned quantity must be at least 1.");
            return;
        }
    
        System.out.print("Enter Return Date (YYYY-MM-DD): ");
        String returnDate = scanner.nextLine();
    
        System.out.print("Enter Reason (optional): ");
        String reason = scanner.nextLine();
        if (reason.isEmpty()) {
            reason = "No reason provided";
        }
    
        Connection conn = null;
    
        try {
            conn = SQLConnection.getConnection();
            conn.setAutoCommit(false); // Start transaction
    
            try (
                CallableStatement getSaleStmt = conn.prepareCall("{CALL GetSaleById(?)}");
                CallableStatement makeReturnStmt = conn.prepareCall("{CALL MakeReturn(?, ?, ?, ?)}")
            ) {
                // Fetch sale to validate it exists and show details
                getSaleStmt.setInt(1, saleID);
                ResultSet rs = getSaleStmt.executeQuery();
    
                if (!rs.next()) {
                    System.out.println("Error: Sale ID not found.");
                    conn.rollback(); // Rollback transaction
                    return;
                }
    
                // Display the sale details
                System.out.println("\n=== Sale Details ===");
                System.out.printf("Sale ID: %d\n", rs.getInt("sale_id"));
                System.out.printf("Inventory ID: %s\n", rs.getString("inventory_id"));
                System.out.printf("Customer ID: %d\n", rs.getInt("customer_id"));
                System.out.printf("Sale Quantity: %d\n", rs.getInt("sale_quantity"));
                System.out.printf("Sale Date: %s\n", rs.getString("sale_date"));
                System.out.printf("Sale Price: %.2f\n", rs.getDouble("sale_price"));
                System.out.printf("Total Returned Quantity: %d\n", rs.getInt("total_returned_quantity"));
    
                // Execute the MakeReturn procedure
                makeReturnStmt.setInt(1, saleID);
                makeReturnStmt.setInt(2, returnedQuantity);
                makeReturnStmt.setString(3, returnDate);
                makeReturnStmt.setString(4, reason);
                makeReturnStmt.execute();
    
                // Commit transaction
                conn.commit();
                System.out.println("Return processed successfully!");
            }
    
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback(); // Rollback transaction on error
                    System.out.println("Transaction rolled back due to error.");
                } catch (SQLException rollbackEx) {
                    System.out.println("Error during rollback: " + rollbackEx.getMessage());
                }
            }
            System.out.println("Error processing return: " + e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true); // Restore default behavior
                    conn.close(); // Close the connection
                } catch (SQLException closeEx) {
                    System.out.println("Error closing connection: " + closeEx.getMessage());
                }
            }
        }
    }
    

    private static void viewPopularProducts() {
        try (Connection conn = SQLConnection.getConnection();
             CallableStatement stmt = conn.prepareCall("{CALL GetPopularProducts}", 
                 ResultSet.TYPE_SCROLL_INSENSITIVE, 
                 ResultSet.CONCUR_READ_ONLY)) {
    
            ResultSet rs = stmt.executeQuery();
            System.out.println("\n=== Popular Products ===");
            System.out.printf("%-30s %-15s %-15s\n", "Product Name", "Total Sold", "Total Revenue");
    
            boolean foundProducts = false;
    
            while (rs.next()) {
                foundProducts = true;
                System.out.printf("%-30s %-15d $%-15.2f\n",
                    rs.getString("product_name"),
                    rs.getInt("total_sold"),
                    rs.getDouble("total_revenue"));
            }
    
            if (!foundProducts) {
                System.out.println("No sales data available.");
            }
    
        } catch (SQLException e) {
            System.out.println("Error fetching popular products: " + e.getMessage());
        }
    }    

}
