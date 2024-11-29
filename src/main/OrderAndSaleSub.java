package main;

import config.SQLConnection;
import utils.DatabaseHelper;

import java.sql.*;
import java.util.Scanner;

public class OrderAndSaleSub {

    public static void manageOrdersAndSales(Scanner scanner) {
        boolean back = false;

        while (!back) {
            System.out.println("\n=== Manage Orders and Sales ===");
            System.out.println("1. Sales");
            System.out.println("2. Orders");
            System.out.println("3. Back to Main Menu");
            System.out.print("Enter your choice: ");

            if (scanner.hasNextInt()) {
                int choice = scanner.nextInt();
                switch (choice) {
                    case 1:
                        manageSales(scanner);
                        break;
                    case 2:
                        manageOrders(scanner);
                        break;
                    case 3:
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

    private static void manageSales(Scanner scanner) {
        boolean back = false;

        while (!back) {
            System.out.println("\n=== Manage Sales ===");
            System.out.println("1. View All Sales");
            System.out.println("2. Make a Sale (Not Implemented)");
            System.out.println("3. Update a Sale");
            System.out.println("4. Delete a Sale");
            System.out.println("5. Back to Previous Menu");
            System.out.print("Enter your choice: ");

            if (scanner.hasNextInt()) {
                int choice = scanner.nextInt();
                switch (choice) {
                    case 1:
                        viewAllSales();
                        break;
                    case 2:
                        System.out.println("Feature not implemented yet.");
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

    private static void manageOrders(Scanner scanner) {
        boolean back = false;

        while (!back) {
            System.out.println("\n=== Manage Orders ===");
            System.out.println("1. View All Orders");
            System.out.println("2. Make an Order (Not Implemented)");
            System.out.println("3. Update an Order");
            System.out.println("4. Delete an Order");
            System.out.println("5. Back to Previous Menu");
            System.out.print("Enter your choice: ");

            if (scanner.hasNextInt()) {
                int choice = scanner.nextInt();
                switch (choice) {
                    case 1:
                        viewAllOrders();
                        break;
                    case 2:
                        System.out.println("Feature not implemented yet.");
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

    private static void updateSale(Scanner scanner) {
        System.out.print("Enter Sale ID to update: ");
        int saleID = scanner.nextInt();

        System.out.print("Enter new quantity: ");
        int quantity = scanner.nextInt();

        try (Connection conn = SQLConnection.getConnection();
             CallableStatement stmt = conn.prepareCall("{CALL UpdateSale(?, ?)}")) {

            stmt.setInt(1, saleID);
            stmt.setInt(2, quantity);

            stmt.executeUpdate();
            System.out.println("Sale updated successfully!");

        } catch (SQLException e) {
            System.out.println("Error updating sale: " + e.getMessage());
        }
    }

    private static void deleteSale(Scanner scanner) {
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

    private static void updateOrder(Scanner scanner) {
        System.out.print("Enter Order ID to update: ");
        int orderID = scanner.nextInt();

        System.out.print("Enter new quantity: ");
        int quantity = scanner.nextInt();

        try (Connection conn = SQLConnection.getConnection();
             CallableStatement stmt = conn.prepareCall("{CALL UpdateOrder(?, ?)}")) {

            stmt.setInt(1, orderID);
            stmt.setInt(2, quantity);

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
             CallableStatement stmt = conn.prepareCall("{CALL DeleteOrder(?)}")) {

            stmt.setInt(1, orderID);
            stmt.executeUpdate();
            System.out.println("Order deleted successfully!");

        } catch (SQLException e) {
            System.out.println("Error deleting order: " + e.getMessage());
        }
    }
}
