package dao;

import model.Notification;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {

    // ── Map ResultSet → Notification ─────────────────────
    private Notification map(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setId(rs.getInt("id"));
        n.setUserid(rs.getString("userid"));
        n.setTitle(rs.getString("title"));
        n.setMessage(rs.getString("message"));
        n.setType(rs.getString("type"));
        n.setRead(rs.getInt("is_read") == 1);
        n.setInvoiceId(nvl(rs.getString("invoice_id")));
        n.setWorkOrderId(nvl(rs.getString("work_order_id")));
        n.setCreatedAt(rs.getTimestamp("created_at"));
        return n;
    }

    private String nvl(String s) { return s == null ? "" : s; }

    // ── Insert notification ───────────────────────────────
    public void insert(Notification n) throws SQLException {
        String sql = "INSERT INTO notifications " +
                     "(userid, title, message, type, is_read, invoice_id, work_order_id) " +
                     "VALUES (?, ?, ?, ?, 0, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, n.getUserid());
            ps.setString(2, n.getTitle());
            ps.setString(3, n.getMessage());
            ps.setString(4, n.getType());
            ps.setString(5, nvl(n.getInvoiceId()));
            ps.setString(6, nvl(n.getWorkOrderId()));
            ps.executeUpdate();
        }
    }

    // ── Get latest 5 untuk dropdown ───────────────────────
    public List<Notification> getLatest5(String userid) throws SQLException {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT * FROM notifications WHERE userid = ? " +
                     "ORDER BY created_at DESC LIMIT 5";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userid);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    // ── Get ALL untuk notification page ──────────────────
    public List<Notification> getAll(String userid) throws SQLException {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT * FROM notifications WHERE userid = ? " +
                     "ORDER BY created_at DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userid);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    // ── Count unread — untuk bell badge ──────────────────
    public int countUnread(String userid) throws SQLException {
        String sql = "SELECT COUNT(*) FROM notifications " +
                     "WHERE userid = ? AND is_read = 0";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userid);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    // ── Mark single as read ───────────────────────────────
    public void markRead(int id) throws SQLException {
        String sql = "UPDATE notifications SET is_read = 1 WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    // ── Mark ALL as read ──────────────────────────────────
    public void markAllRead(String userid) throws SQLException {
        String sql = "UPDATE notifications SET is_read = 1 WHERE userid = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userid);
            ps.executeUpdate();
        }
    }

    // ── Delete notification ───────────────────────────────
    public void delete(int id) throws SQLException {
        String sql = "DELETE FROM notifications WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    // ── Check dah ada notification type ni untuk WO ───────
    // Elak duplicate notification
    public boolean exists(String userid, String type, String workOrderId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM notifications " +
                     "WHERE userid = ? AND type = ? AND work_order_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userid);
            ps.setString(2, type);
            ps.setString(3, workOrderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        }
        return false;
    }
}