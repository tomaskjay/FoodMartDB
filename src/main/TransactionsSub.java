package main;
import java.util.Scanner;

public class TransactionsSub {

    public static void manageTransactions(Scanner scanner) {
        boolean back = false;
        while (!back) {
            System.out.println("\n=== Manage Transactions ===");
            System.out.println("1. Sales");
            System.out.println("2. Orders");
            System.out.println("3. Make a Return");
            System.out.println("4. Check Profit");
            System.out.println("5. View Popular");
            System.out.println("6. Back to Main Menu");
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
                        //manageReturns(scanner);
                        break;
                    case 4:
                        //manageProfit(scanner);
                        break;
                    case 5:
                        //managePopular(scanner);
                        break;
                    case 6:
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
}
