package dao;

import model.Inventory;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InventoryDAO {

    // GET ALL
    public List<Inventory> getAllInventory() {
        List<Inventory> list = new ArrayList<>();
        String sql = "SELECT * FROM inventory ORDER BY partID";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Inventory item = new Inventory();
                item.setPartID(rs.getInt("partID"));
                item.setPartName(rs.getString("partName"));
                item.setDescription(rs.getString("description"));
                item.setStockQty(rs.getInt("stockQty"));
                item.setUnitPrice(rs.getDouble("unitPrice"));
                list.add(item);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // GET BY ID
    public Inventory getInventoryById(int partID) {
        Inventory item = null;
        String sql = "SELECT * FROM inventory WHERE partID = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, partID);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                item = new Inventory();
                item.setPartID(rs.getInt("partID"));
                item.setPartName(rs.getString("partName"));
                item.setDescription(rs.getString("description"));
                item.setStockQty(rs.getInt("stockQty"));
                item.setUnitPrice(rs.getDouble("unitPrice"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return item;
    }

    // INSERT
    public boolean addInventory(Inventory item) {
        String sql = "INSERT INTO inventory (partName, description, stockQty, unitPrice) VALUES (?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, item.getPartName());
            ps.setString(2, item.getDescription());
            ps.setInt(3, item.getStockQty());
            ps.setDouble(4, item.getUnitPrice());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // UPDATE
    public boolean updateInventory(Inventory item) {
        String sql = "UPDATE inventory SET partName=?, description=?, stockQty=?, unitPrice=? WHERE partID=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, item.getPartName());
            ps.setString(2, item.getDescription());
            ps.setInt(3, item.getStockQty());
            ps.setDouble(4, item.getUnitPrice());
            ps.setInt(5, item.getPartID());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // DELETE
    public boolean deleteInventory(int partID) {
        String sql = "DELETE FROM inventory WHERE partID = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, partID);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}