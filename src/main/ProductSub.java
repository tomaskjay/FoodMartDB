package main;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Scanner;

public class ProductSub {
    public static void manageProducts(Scanner scanner) {
        boolean back = false;

        while (!back) {
            System.out.println("\n=== Manage Products ===");
            System.out.println("1. View All Products");
            System.out.println("2. Add New Product");
            System.out.println("3. Update Product");
            System.out.println("4. Delete Product");
            System.out.println("5. Back to Main Menu");
            System.out.print("Enter your choice: ");

            int choice = scanner.nextInt();

            switch (choice) {
                case 1:
                    viewAllProducts();
                    break;
                case 2:
                    addNewProduct(scanner);
                    break;
                case 3:
                    //updateProduct(scanner);
                    break;
                case 4:
                    //deleteProduct(scanner);
                    break;
                case 5:
                    back = true;
                    break;
                default:
                    System.out.println("Invalid choice. Please try again.");
            }
        }
    }

    private static void viewAllProducts() {
        //
    }

    private static void addNewProduct(Scanner scanner) {
        //
    }
}
