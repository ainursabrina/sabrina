package dao;

import util.DBConnection;
import java.sql.*;
import java.util.*;

public class ReportDAO {

    // Total booking by status
    public Map<String, Integer> getBookingSummary() {
    Map<String, Integer> map = new LinkedHashMap<>();
    map.put("Total", 0);
    map.put("Pending", 0);
    map.put("Confirmed", 0);
    map.put("Completed", 0);
    map.put("Cancelled", 0);
    String sql = "SELECT booking_status, COUNT(*) as cnt FROM booking GROUP BY booking_status";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {
        int total = 0;
        while (rs.next()) {
            String status = rs.getString("booking_status");
            int cnt = rs.getInt("cnt");
            total += cnt;
            String key = normalizeStatus(status);
            if (map.containsKey(key)) map.put(key, cnt);
        }
        map.put("Total", total);
    } catch (Exception e) { e.printStackTrace(); }
    return map;
}

        public Map<String, Integer> getWorkOrderSummary() {
            Map<String, Integer> map = new LinkedHashMap<>();
            map.put("Total", 0);
            map.put("Pending", 0);
            map.put("In Progress", 0);
            map.put("Completed", 0);
            map.put("Cancelled", 0);
            String sql = "SELECT service_status, COUNT(*) as cnt FROM work_order GROUP BY service_status";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                int total = 0;
                while (rs.next()) {
                    String status = rs.getString("service_status");
                    int cnt = rs.getInt("cnt");
                    total += cnt;
                    String key = normalizeStatus(status);
                    if (map.containsKey(key)) map.put(key, cnt);
                }
                map.put("Total", total);
            } catch (Exception e) { e.printStackTrace(); }
            return map;
        }

    // Helper method — normalize DB status to map key
    private String normalizeStatus(String status) {
        if (status == null) return "";
        switch (status.toLowerCase().replace("_", " ").trim()) {
            case "pending":     return "Pending";
            case "confirmed":   return "Confirmed";
            case "completed":   return "Completed";
            case "cancelled":   return "Cancelled";
            case "in progress": return "In Progress";
            default:
                return status.substring(0,1).toUpperCase() + status.substring(1).toLowerCase();
        }
    }

    // Low stock parts (qty < 10)
    public List<Map<String, String>> getLowStockParts() {
        List<Map<String, String>> list = new ArrayList<>();
        String sql = "SELECT partID, partName, stockQty, unitPrice FROM inventory WHERE stockQty < 10 ORDER BY stockQty ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, String> row = new LinkedHashMap<>();
                row.put("partID",    rs.getString("partID"));
                row.put("partName",  rs.getString("partName"));
                row.put("stockQty",  rs.getString("stockQty"));
                row.put("unitPrice", rs.getString("unitPrice"));
                list.add(row);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // Total users by role
    public Map<String, Integer> getUserSummary() {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT role, COUNT(*) as cnt FROM users GROUP BY role";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String role = rs.getString("role");
                int cnt = rs.getInt("cnt");
                String key = role.substring(0,1).toUpperCase() + role.substring(1).toLowerCase();
                map.put(key, cnt);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return map;
    }
}