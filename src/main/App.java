package main;
import java.util.Scanner;

public class App {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        boolean exit = false;

        while (!exit) {
            // Display Main Menu
            System.out.println("\n=== Main Menu ===");
            System.out.println("    1. Orders and Sales");
            System.out.println("    2. Products");
            System.out.println("    3. Customers");
            System.out.println("    4. Employees");
            System.out.println("    5. Suppliers");
            System.out.println("    6. Inventory");
            System.out.println("    7. Exit");
            System.out.print(" Enter choice: ");

            // Get user's choice
            int choice = scanner.nextInt();

            // Handle user's choice
            switch (choice) {
                case 1:
                    OrderSalesManager.manageOrdersAndSales(scanner);
                    break;
                case 2:
                    ProductManager.manageProducts(scanner);
                    break;
                case 3:
                    CustomerManager.manageCustomers(scanner);
                    break;
                case 4:
                    EmployeeManager.manageEmployees(scanner);
                    break;
                case 5:
                    SupplierManager.manageSuppliers(scanner);
                    break;
                case 6:
                    InventoryManager.manageInventory(scanner);
                    break;
                case 7:
                    exit = true;
                    System.out.println("Exiting the application. Goodbye!");
                    break;
                default:
                    System.out.println("Invalid choice. Please try again.");
            }
        }

        scanner.close();
    }