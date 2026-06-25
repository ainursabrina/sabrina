package dao;

import model.Invoice;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;


public class InvoiceDAO {

    // ── Map ResultSet → Invoice ───────────────────────────
    private Invoice map(ResultSet rs) throws SQLException {
        Invoice inv = new Invoice();
        inv.setId(rs.getString("userid"));
        inv.setCustomer(rs.getString("customer"));
        
        inv.setVehicle(nvl(rs.getString("vehicle")));
        inv.setServices(nvl(rs.getString("services")));
        inv.setAmount(rs.getDouble("amount"));
        inv.setDiscount(rs.getDouble("discount"));
        inv.setStatus(nvl(rs.getString("status")));
        inv.setInvDate(nvl(rs.getString("inv_date")));
        inv.setMethod(nvl(rs.getString("method")));
        inv.setWoId(nvl(rs.getString("wo_id")));
        inv.setBkId(nvl(rs.getString("bk_id")));
        inv.setNotes(nvl(rs.getString("notes")));
        inv.setCustomerUserid(nvl(rs.getString("customer_userid")));
        return inv;
    }

    private String nvl(String s) { return s == null ? "" : s; }

    // ── Get ALL invoices (no filter) — called on page load ─
    public List<Invoice> getAll() throws SQLException {
        List<Invoice> list = new ArrayList<>();
        String sql = "SELECT * FROM invoices ORDER BY created_at DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    // ── Search / filter invoices ──────────────────────────
    // If all params empty → returns ALL invoices (same as getAll)
    // ── Search / filter invoices (admin — no filter) ──────
        public List<Invoice> search(String query, String status, String linked) throws SQLException {
            return search(query, status, linked, null);
        }

        // ── Search / filter invoices (dengan customerFilter) ──
        public List<Invoice> search(String query, String status, 
                                     String linked, String customerFilter) throws SQLException {
            List<Invoice> list = new ArrayList<>();

            boolean hasQ             = query  != null && !query.trim().isEmpty();
            boolean hasStatus        = status != null && !status.isEmpty();
            boolean filterByCustomer = customerFilter != null && !customerFilter.trim().isEmpty();

            StringBuilder sql = new StringBuilder("SELECT * FROM invoices WHERE 1=1");

            if (filterByCustomer)
                sql.append(" AND customer_userid = ?");
            if (hasQ)
               sql.append(" AND (userid LIKE ? OR customer LIKE ? OR vehicle LIKE ? OR services LIKE ?)");;
            if (hasStatus)
                sql.append(" AND status = ?");
            if ("linked".equals(linked))
                sql.append(" AND (wo_id IS NOT NULL AND wo_id <> '' OR bk_id IS NOT NULL AND bk_id <> '')");
            if ("unlinked".equals(linked))
                sql.append(" AND (COALESCE(wo_id,'') = '' AND COALESCE(bk_id,'') = '')");

            sql.append(" ORDER BY created_at DESC");

            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql.toString())) {
                int idx = 1;
                if (filterByCustomer) ps.setString(idx++, customerFilter.trim());
                if (hasQ) {
                    String q2 = "%" + query.trim() + "%";
                    ps.setString(idx++, q2);
                    ps.setString(idx++, q2);
                    ps.setString(idx++, q2);
                    ps.setString(idx++, q2);
                }
                if (hasStatus) ps.setString(idx++, status);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) list.add(map(rs));
                }
            }
            return list;
        }

    // ── Get single invoice by ID ──────────────────────────
    public Invoice getById(String id) throws SQLException {
        if (id == null || id.trim().isEmpty()) return null;
        String sql = "SELECT * FROM invoices WHERE userid = ?"; 
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, id.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    // ── Insert new invoice ────────────────────────────────
    public void insert(Invoice inv) throws SQLException {
        String sql = "INSERT INTO invoices " +
        "(userid, customer, customer_userid, vehicle, services, amount, discount, " +
        " status, inv_date, method, wo_id, bk_id, notes) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1,  inv.getId());
            ps.setString(2,  inv.getCustomer());
            ps.setString(3, nvl(inv.getCustomerUserid()));
            ps.setString(4,  nvl(inv.getVehicle()));
            ps.setString(5,  nvl(inv.getServices()));
            ps.setDouble(6,  inv.getAmount());
            ps.setDouble(7,  inv.getDiscount());
            ps.setString(8,  nvl(inv.getStatus()));
            ps.setString(9,  nvl(inv.getInvDate()));
            ps.setString(10,  nvl(inv.getMethod()));
            ps.setString(11, nvl(inv.getWoId()));
            ps.setString(12, nvl(inv.getBkId()));
            ps.setString(13, nvl(inv.getNotes()));
            ps.executeUpdate();
        }
    }

    // ── Update full invoice ───────────────────────────────
    public void update(Invoice inv) throws SQLException {
        String sql = "UPDATE invoices SET " +
            "customer=?, vehicle=?, services=?, amount=?, discount=?, " +
            "status=?, inv_date=?, method=?, wo_id=?, bk_id=?, notes=? " +
            "WHERE userid=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1,  nvl(inv.getCustomer()));
            ps.setString(2,  nvl(inv.getVehicle()));
            ps.setString(3,  nvl(inv.getServices()));
            ps.setDouble(4,  inv.getAmount());
            ps.setDouble(5,  inv.getDiscount());
            ps.setString(6,  nvl(inv.getStatus()));
            ps.setString(7,  nvl(inv.getInvDate()));
            ps.setString(8,  nvl(inv.getMethod()));
            ps.setString(9,  nvl(inv.getWoId()));
            ps.setString(10, nvl(inv.getBkId()));
            ps.setString(11, nvl(inv.getNotes()));
            ps.setString(12, inv.getId());
            ps.executeUpdate();
        }
    }

    // ── Update status only ────────────────────────────────
    public void updateStatus(String id, String status) throws SQLException {
        String sql = "UPDATE invoices SET status=? WHERE userid=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, id);
            ps.executeUpdate();
        }
    }

    // ── Delete invoice ────────────────────────────────────
    public void delete(String id) throws SQLException {
        String sql = "DELETE FROM invoices WHERE userid=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.executeUpdate();
        }
    }

    // ── Stats ─────────────────────────────────────────────
    public double getTotalRevenue() throws SQLException {
        String sql = "SELECT COALESCE(SUM(amount - discount), 0) FROM invoices WHERE status='Paid'";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getDouble(1);
        }
        return 0;
    }

    public int countByStatus(String status) throws SQLException {
        String sql = "SELECT COUNT(*) FROM invoices WHERE status=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public int countPending() throws SQLException {
        String sql = "SELECT COUNT(*) FROM invoices WHERE status IN ('Pending','Partial')";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public int countAll() throws SQLException {
        String sql = "SELECT COUNT(*) FROM invoices";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    // ── Generate next Invoice ID ──────────────────────────
    public String nextInvoiceId() throws SQLException {
        String sql = "UPDATE counters SET value = value + 1 WHERE name = 'invoice'";
        String get = "SELECT value FROM counters WHERE name = 'invoice'";
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try (PreparedStatement ps1 = con.prepareStatement(sql)) {
                ps1.executeUpdate();
            }
            try (PreparedStatement ps2 = con.prepareStatement(get);
                 ResultSet rs = ps2.executeQuery()) {
                if (rs.next()) {
                int val = rs.getInt(1);  // ← simpan dulu sebelum commit
                con.commit();
                return String.format("INV-%04d", val);
            }
            }
            con.commit();
        }
        return "INV-0000";
    }
    
    public double getTotalRevenueByCustomer(String userid) throws SQLException {
    String sql = "SELECT COALESCE(SUM(amount - discount), 0) FROM invoices WHERE status='Paid' AND customer_userid=?";
    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setString(1, userid);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) return rs.getDouble(1);
    }
    return 0;
}

public int countPendingByCustomer(String userid) throws SQLException {
    String sql = "SELECT COUNT(*) FROM invoices WHERE status IN ('Pending','Partial') AND customer_userid=?";
    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setString(1, userid);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) return rs.getInt(1);
    }
    return 0;
}

public int countAllByCustomer(String userid) throws SQLException {
    String sql = "SELECT COUNT(*) FROM invoices WHERE customer_userid=?";
    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setString(1, userid);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) return rs.getInt(1);
    }
    return 0;
}

public int countByStatusAndCustomer(String status, String userid) throws SQLException {
    String sql = "SELECT COUNT(*) FROM invoices WHERE status=? AND customer_userid=?";
    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setString(1, status);
        ps.setString(2, userid);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) return rs.getInt(1);
    }
    return 0;
}
}