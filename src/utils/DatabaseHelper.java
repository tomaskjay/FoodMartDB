package utils;

import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;

public class DatabaseHelper {

    public static void printResultSet(ResultSet rs) throws SQLException {
        ResultSetMetaData metaData = rs.getMetaData();
        int columnCount = metaData.getColumnCount();

        // Determine the column widths for alignment
        int[] columnWidths = new int[columnCount];
        String[] columnNames = new String[columnCount];
        for (int i = 1; i <= columnCount; i++) {
            columnNames[i - 1] = metaData.getColumnName(i);
            columnWidths[i - 1] = Math.max(metaData.getColumnName(i).length(), 15); // Minimum width
        }

        // Adjust column widths based on data content
        while (rs.next()) {
            for (int i = 1; i <= columnCount; i++) {
                int dataLength = rs.getString(i) != null ? rs.getString(i).length() : 4; // Account for "null"
                columnWidths[i - 1] = Math.max(columnWidths[i - 1], dataLength);
            }
        }
        rs.beforeFirst(); // Reset cursor to the start of the ResultSet

        // Print column headers
        for (int i = 0; i < columnCount; i++) {
            System.out.printf("%-" + columnWidths[i] + "s ", columnNames[i]);
        }
        System.out.println();

        // Print separator
        for (int i = 0; i < columnCount; i++) {
            System.out.print("-".repeat(columnWidths[i]) + " ");
        }
        System.out.println();

        // Print data rows
        while (rs.next()) {
            for (int i = 1; i <= columnCount; i++) {
                String data = rs.getString(i) != null ? rs.getString(i) : "null";
                System.out.printf("%-" + columnWidths[i - 1] + "s ", data);
            }
            System.out.println();
        }
    }
}
