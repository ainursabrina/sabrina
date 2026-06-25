package dao;

import model.PaymentHistory;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * PaymentHistoryDAO.java
 * — Tambah customerFilter param pada getAll() dan search()
 *   supaya customer hanya nampak history dia sendiri.
 *   Admin pass null → nampak semua.
 */
public class PaymentHistoryDAO {

    private String nvl(String s) { return s == null ? "" : s; }

    private PaymentHistory map(ResultSet rs) throws SQLException {
        PaymentHistory h = new PaymentHistory();
        h.setId(rs.getInt("id"));
        h.setInvoiceId(nvl(rs.getString("invoice_id")));
        h.setReceiptNo(nvl(rs.getString("receipt_no")));
        h.setCustomer(nvl(rs.getString("customer")));
        h.setVehicle(nvl(rs.getString("vehicle")));
        h.setServices(nvl(rs.getString("services")));
        h.setAmount(rs.getDouble("amount"));
        h.setDiscount(rs.getDouble("discount"));
        h.setMethod(nvl(rs.getString("method")));
        h.setPayDate(nvl(rs.getString("pay_date")));
        h.setRecordedBy(nvl(rs.getString("recorded_by")));
        h.setRecordedAt(nvl(rs.getString("recorded_at")));
        h.setWoId(nvl(rs.getString("wo_id")));
        h.setBkId(nvl(rs.getString("bk_id")));
        h.setNotes(nvl(rs.getString("notes")));
        return h;
    }

    // ── Get ALL history ───────────────────────────────────
    // customerFilter = null  → admin, nampak semua
    // customerFilter = "Ali" → customer, nampak dia punya je
    public List<PaymentHistory> getAll(String customerFilter) throws SQLException {
        List<PaymentHistory> list = new ArrayList<>();
        boolean filterByCustomer = customerFilter != null && !customerFilter.trim().isEmpty();

        String sql = "SELECT * FROM payment_history"
                   + (filterByCustomer ? " WHERE LOWER(customer) = LOWER(?)" : "")
                   + " ORDER BY created_at DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (filterByCustomer) ps.setString(1, customerFilter.trim());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    // Overload untuk backward-compat (admin calls yang lama tak pass filter)
    public List<PaymentHistory> getAll() throws SQLException {
        return getAll(null);
    }

    // ── Search / filter history ───────────────────────────
    // customerFilter = null  → admin, cari dalam semua record
    // customerFilter = "Ali" → customer, cari dalam record dia je
    public List<PaymentHistory> search(String query, String method,
                                       String linked, String customerFilter)
            throws SQLException {

        List<PaymentHistory> list = new ArrayList<>();

        boolean hasQ              = query  != null && !query.trim().isEmpty();
        boolean hasMethod         = method != null && !method.isEmpty();
        boolean filterByCustomer  = customerFilter != null && !customerFilter.trim().isEmpty();

        StringBuilder sql = new StringBuilder("SELECT * FROM payment_history WHERE 1=1");

        // Filter customer (role-based) — paling utama
        if (filterByCustomer)
            sql.append(" AND LOWER(customer) = LOWER(?)");

        // Search keyword
        if (hasQ)
            sql.append(" AND (receipt_no LIKE ? OR invoice_id LIKE ? OR customer LIKE ? OR vehicle LIKE ?)");

        // Filter by method
        if (hasMethod)
            sql.append(" AND method = ?");

        // Filter linked/unlinked
        if ("linked".equals(linked))
            sql.append(" AND (COALESCE(wo_id,'') <> '' OR COALESCE(bk_id,'') <> '')");
        if ("unlinked".equals(linked))
            sql.append(" AND (COALESCE(wo_id,'') = '' AND COALESCE(bk_id,'') = '')");

        sql.append(" ORDER BY created_at DESC");

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int idx = 1;
            if (filterByCustomer) ps.setString(idx++, customerFilter.trim());
            if (hasQ) {
                String q = "%" + query.trim() + "%";
                ps.setString(idx++, q);
                ps.setString(idx++, q);
                ps.setString(idx++, q);
                ps.setString(idx++, q);
            }
            if (hasMethod) ps.setString(idx++, method);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    // Overload untuk backward-compat
    public List<PaymentHistory> search(String query, String method, String linked)
            throws SQLException {
        return search(query, method, linked, null);
    }

    // ── Get latest history entry by invoice ID ────────────
    public PaymentHistory getByInvoiceId(String invoiceId) throws SQLException {
        String sql = "SELECT * FROM payment_history WHERE invoice_id=? ORDER BY created_at DESC LIMIT 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, invoiceId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        }
        return null;
    }

    // ── Insert new history record ─────────────────────────
    public void insert(PaymentHistory h) throws SQLException {
        String sql = "INSERT INTO payment_history " +
            "(invoice_id, receipt_no, customer, vehicle, services, amount, discount, " +
            "method, pay_date, recorded_by, recorded_at, wo_id, bk_id, notes) " +
            "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1,  nvl(h.getInvoiceId()));
            ps.setString(2,  nvl(h.getReceiptNo()));
            ps.setString(3,  nvl(h.getCustomer()));
            ps.setString(4,  nvl(h.getVehicle()));
            ps.setString(5,  nvl(h.getServices()));
            ps.setDouble(6,  h.getAmount());
            ps.setDouble(7,  h.getDiscount());
            ps.setString(8,  nvl(h.getMethod()));
            ps.setString(9,  nvl(h.getPayDate()));
            ps.setString(10, nvl(h.getRecordedBy()));
            ps.setString(11, nvl(h.getRecordedAt()));
            ps.setString(12, nvl(h.getWoId()));
            ps.setString(13, nvl(h.getBkId()));
            ps.setString(14, nvl(h.getNotes()));
            ps.executeUpdate();
        }
    }

    // ── Delete history by invoice ID ──────────────────────
    public void deleteByInvoiceId(String invoiceId) throws SQLException {
        String sql = "DELETE FROM payment_history WHERE invoice_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, invoiceId);
            ps.executeUpdate();
        }
    }

    // ── Delete all history ────────────────────────────────
    public void deleteAll() throws SQLException {
        String sql = "DELETE FROM payment_history";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.executeUpdate();
        }
    }

    // ── Stats ─────────────────────────────────────────────
    // customerFilter = null → semua, "Ali" → dia punya je
    public double getTotalCollected(String customerFilter) throws SQLException {
        boolean filterByCustomer = customerFilter != null && !customerFilter.trim().isEmpty();
        String sql = "SELECT COALESCE(SUM(amount - discount), 0) FROM payment_history"
                   + (filterByCustomer ? " WHERE LOWER(customer) = LOWER(?)" : "");
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (filterByCustomer) ps.setString(1, customerFilter.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getDouble(1);
            }
        }
        return 0;
    }

    public double getTotalCollected() throws SQLException {
        return getTotalCollected(null);
    }

    public int countLinked() throws SQLException {
        String sql = "SELECT COUNT(*) FROM payment_history "
                   + "WHERE COALESCE(wo_id,'') <> '' OR COALESCE(bk_id,'') <> ''";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    // ── Generate next Receipt ID (atomic) ─────────────────
    public String nextReceiptId() throws SQLException {
        String upd = "UPDATE counters SET value = value + 1 WHERE name = 'receipt'";
        String get = "SELECT value FROM counters WHERE name = 'receipt'";
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try (PreparedStatement ps1 = con.prepareStatement(upd)) {
                ps1.executeUpdate();
            }
            try (PreparedStatement ps2 = con.prepareStatement(get);
                 ResultSet rs = ps2.executeQuery()) {
                con.commit();
                if (rs.next()) return String.format("RCP-%04d", rs.getInt(1));
            }
            con.commit();
        }
        return "RCP-0000";
    }
}