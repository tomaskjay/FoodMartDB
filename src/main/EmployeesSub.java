package main;

import config.SQLConnection;
import utils.DatabaseHelper;

import java.sql.*;
import java.util.Scanner;

public class EmployeesSub {

    public static void manageEmployees(Scanner scanner) {
        boolean back = false;

        while (!back) {
            System.out.println("\n=== Manage Employees ===");
            System.out.println("1. View");
            System.out.println("2. Add");
            System.out.println("3. Edit");
            System.out.println("4. Back to Main Menu");
            System.out.print("Enter your choice: ");

            if (scanner.hasNextInt()) {
                int choice = scanner.nextInt();
                switch (choice) {
                    case 1:
                        viewEmployees();
                        break;
                    case 2:
                        addEmployee(scanner);
                        break;
                    case 3:
                        editEmployee(scanner);
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

    private static void viewEmployees() {
        try (Connection conn = SQLConnection.getConnection();
             CallableStatement stmt = conn.prepareCall(
                 "{CALL GetAllEmployees}",
                 ResultSet.TYPE_SCROLL_INSENSITIVE,
                 ResultSet.CONCUR_READ_ONLY)) {

            // Execute the stored procedure
            ResultSet rs = stmt.executeQuery();

            // Display the results
            System.out.println("\n=== Employee List ===");
            DatabaseHelper.printResultSet(rs);

        } catch (SQLException e) {
            System.out.println("Error viewing employees: " + e.getMessage());
        }
    }

    private static void addEmployee(Scanner scanner) {
        System.out.print("Has this person worked at the FoodMart before? (yes/no): ");
        scanner.nextLine(); // Consume leftover newline
        String hasWorkedBefore = scanner.nextLine().trim().toLowerCase();

        if (hasWorkedBefore.equals("yes")) {
            System.out.print("Enter Employee ID: ");
            int employeeId = scanner.nextInt();

            try (Connection conn = SQLConnection.getConnection();
                 CallableStatement stmt = conn.prepareCall("{CALL CheckEmployeeStatus(?)}")) {

                // Set parameters for the stored procedure
                stmt.setInt(1, employeeId);

                // Execute the stored procedure
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    String status = rs.getString("status");
                    if (status.equals("fired")) {
                        System.out.println("This person cannot be hired because they were fired.");
                        return;
                    }
                } else {
                    System.out.println("Employee ID not found.");
                    return;
                }
            } catch (SQLException e) {
                System.out.println("Error checking employee status: " + e.getMessage());
                return;
            }
        }

        // Proceed to add a new employee
        System.out.print("Enter First Name: ");
        scanner.nextLine(); // Consume leftover newline
        String firstName = scanner.nextLine();

        System.out.print("Enter Last Name: ");
        String lastName = scanner.nextLine();

        System.out.print("Enter Age: ");
        int age = scanner.nextInt();

        System.out.print("Enter Email: ");
        scanner.nextLine(); // Consume leftover newline
        String email = scanner.nextLine();

        System.out.print("Enter Phone: ");
        String phone = scanner.nextLine();

        System.out.print("Enter Street Address: ");
        String street = scanner.nextLine();

        System.out.print("Enter City: ");
        String city = scanner.nextLine();

        System.out.print("Enter State (2 letters): ");
        String state = scanner.nextLine();

        System.out.print("Enter Zip Code: ");
        String zipCode = scanner.nextLine();

        System.out.print("Enter Position: ");
        String position = scanner.nextLine();

        System.out.print("Enter Hourly Wage: ");
        double hourlyWage = scanner.nextDouble();

        System.out.print("Enter Starting Date (YYYY-MM-DD): ");
        scanner.nextLine(); // Consume leftover newline
        String startDate = scanner.nextLine();

        try (Connection conn = SQLConnection.getConnection();
             CallableStatement addContactStmt = conn.prepareCall("{CALL AddContact(?, ?, ?, ?, ?, ?, ?)}");
             CallableStatement addEmployeeStmt = conn.prepareCall("{CALL AddEmployee(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}")) {

            // Add contact details
            addContactStmt.setString(1, email);
            addContactStmt.setString(2, phone);
            addContactStmt.setString(3, street);
            addContactStmt.setString(4, city);
            addContactStmt.setString(5, state);
            addContactStmt.setString(6, zipCode);
            addContactStmt.registerOutParameter(7, Types.INTEGER);

            addContactStmt.execute();
            int contactId = addContactStmt.getInt(7);

            // Add employee with the generated contact ID
            addEmployeeStmt.setString(1, firstName);
            addEmployeeStmt.setString(2, lastName);
            addEmployeeStmt.setInt(3, age);
            addEmployeeStmt.setInt(4, contactId);
            addEmployeeStmt.setString(5, position);
            addEmployeeStmt.setDouble(6, hourlyWage);
            addEmployeeStmt.setString(7, startDate);
            addEmployeeStmt.setNull(8, Types.VARCHAR); // end_date is null
            addEmployeeStmt.setInt(9, 0); // hours_worked starts at 0
            addEmployeeStmt.setString(10, "active");

            addEmployeeStmt.execute();

            System.out.println("Employee added successfully!");

        } catch (SQLException e) {
            System.out.println("Error adding employee: " + e.getMessage());
        }
    }

    private static void editEmployee(Scanner scanner) {
        System.out.print("Enter Employee ID to edit: ");
        int employeeId = scanner.nextInt();

        System.out.print("Enter new First Name: ");
        scanner.nextLine(); // Consume leftover newline
        String firstName = scanner.nextLine();

        System.out.print("Enter new Last Name: ");
        String lastName = scanner.nextLine();

        System.out.print("Enter new Age: ");
        int age = scanner.nextInt();

        System.out.print("Enter new Email: ");
        scanner.nextLine(); // Consume leftover newline
        String email = scanner.nextLine();

        System.out.print("Enter new Phone: ");
        String phone = scanner.nextLine();

        System.out.print("Enter new Street Address: ");
        String street = scanner.nextLine();

        System.out.print("Enter new City: ");
        String city = scanner.nextLine();

        System.out.print("Enter new State (2 letters): ");
        String state = scanner.nextLine();

        System.out.print("Enter new Zip Code: ");
        String zipCode = scanner.nextLine();

        System.out.print("Enter new Position: ");
        String position = scanner.nextLine();

        System.out.print("Enter new Hourly Wage: ");
        double hourlyWage = scanner.nextDouble();

        try (Connection conn = SQLConnection.getConnection();
             CallableStatement getContactStmt = conn.prepareCall("{CALL GetContactByEmployee(?)}");
             CallableStatement updateContactStmt = conn.prepareCall("{CALL UpdateContact(?, ?, ?, ?, ?, ?, ?)}");
             CallableStatement updateEmployeeStmt = conn.prepareCall("{CALL UpdateEmployee(?, ?, ?, ?, ?, ?)}")) {

            // Retrieve the contact ID associated with the employee
            getContactStmt.setInt(1, employeeId);
            ResultSet rs = getContactStmt.executeQuery();
            int contactId = -1;
            if (rs.next()) {
                contactId = rs.getInt("contact_id");
            } else {
                System.out.println("Error: Employee not found.");
                return;
            }

            // Update contact details
            updateContactStmt.setInt(1, contactId);
            updateContactStmt.setString(2, email);
            updateContactStmt.setString(3, phone);
            updateContactStmt.setString(4, street);
            updateContactStmt.setString(5, city);
            updateContactStmt.setString(6, state);
            updateContactStmt.setString(7, zipCode);

            updateContactStmt.execute();

            // Update employee details
            updateEmployeeStmt.setInt(1, employeeId);
            updateEmployeeStmt.setString(2, firstName);
            updateEmployeeStmt.setString(3, lastName);
            updateEmployeeStmt.setInt(4, age);
            updateEmployeeStmt.setString(5, position);
            updateEmployeeStmt.setDouble(6, hourlyWage);

            updateEmployeeStmt.execute();

            System.out.println("Employee updated successfully!");

        } catch (SQLException e) {
            System.out.println("Error editing employee: " + e.getMessage());
        }
    }
}
