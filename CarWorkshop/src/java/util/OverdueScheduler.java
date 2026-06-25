package util;

import dao.InvoiceDAO;
import dao.NotificationDAO;
import dao.UserDAO;
import model.Invoice;
import model.Notification;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.sql.*;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@WebListener
public class OverdueScheduler implements ServletContextListener {

    private ScheduledExecutorService scheduler;

    // ── Start bila server start ───────────────────────────
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newSingleThreadScheduledExecutor();

        // Check setiap 1 minit
        scheduler.scheduleAtFixedRate(() -> {
            try {
                checkOverdue();
            } catch (Exception e) {
                System.err.println("[OverdueScheduler] Error: " + e.getMessage());
                e.printStackTrace();
            }
        }, 1, 1, TimeUnit.MINUTES);

        System.out.println("[OverdueScheduler] ✅ Started — checking every 1 minute");
    }

    // ── Stop bila server stop ─────────────────────────────
    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdownNow();
            System.out.println("[OverdueScheduler] 🛑 Stopped");
        }
    }

    // ── Main check logic ──────────────────────────────────
    private void checkOverdue() {
        System.out.println("[OverdueScheduler] 🔍 Checking overdue invoices...");

        InvoiceDAO      invDAO  = new InvoiceDAO();
        NotificationDAO notifDAO = new NotificationDAO();
        UserDAO         userDAO  = new UserDAO();

        try {
            List<Invoice> pendingList = getOverdueCandidate();

            for (Invoice inv : pendingList) {
                String customerUserid = inv.getCustomerUserid();
                if (customerUserid == null || customerUserid.isEmpty()) continue;

                // ── Update status → Overdue ───────────────
                invDAO.updateStatus(inv.getId(), "Overdue");
                // Mark supaya tak hantar lagi
                String markSql = "UPDATE invoices SET overdue_notified = 1 WHERE userid = ?";
                try (Connection markCon = util.DBConnection.getConnection();
                     PreparedStatement markPs = markCon.prepareStatement(markSql)) {
                    markPs.setString(1, inv.getId());
                    markPs.executeUpdate();
                }
                System.out.println("[OverdueScheduler] ⚠️ Invoice " + inv.getId() + " → Overdue");

                // ── In-app notification ───────────────────
                boolean notifExists = notifDAO.exists(
                    customerUserid, "overdue", inv.getWoId()
                );

                if (!notifExists) {
                    Notification n = new Notification(
                        customerUserid,
                        "⚠️ Payment Overdue",
                        "Pembayaran untuk kenderaan " + inv.getVehicle() +
                        " (Invoice: " + inv.getId() + ") telah tamat tempoh. " +
                        "Sila buat pembayaran segera.",
                        "overdue",
                        inv.getId(),
                        inv.getWoId()
                    );
                    notifDAO.insert(n);
                }

                // ── Email alert ───────────────────────────
                try {
                    String email = userDAO.getEmailByUserid(customerUserid);
                    if (email != null && !email.isEmpty()) {
                        EmailService.sendPaymentOverdue(
                            email,
                            inv.getCustomer(),
                            inv.getVehicle(),
                            inv.getId(),
                            inv.getNet()
                        );
                        System.out.println("[OverdueScheduler] 📧 Overdue email sent: " + email);
                    }
                } catch (Exception e) {
                    System.err.println("[OverdueScheduler] Email error: " + e.getMessage());
                }
            }

        } catch (Exception e) {
            System.err.println("[OverdueScheduler] checkOverdue error: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // ── Query invoice yang dah lepas 30 minit, masih Pending ─
    private List<Invoice> getOverdueCandidate() throws SQLException {
        String sql =
        "SELECT i.*, " +
        "       i.customer_userid " +
        "FROM invoices i " +
        "WHERE i.status = 'Pending' " +
        "  AND i.due_date IS NOT NULL " +
        "  AND i.due_date < NOW() " +
        "  AND i.overdue_notified = 0";

        List<Invoice> list = new java.util.ArrayList<>();

        try (Connection con = util.DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Invoice inv = new Invoice();
                inv.setId(rs.getString("userid"));
                inv.setCustomer(rs.getString("customer"));
                inv.setCustomerUserid(rs.getString("customer_userid"));
                inv.setVehicle(nvl(rs.getString("vehicle")));
                inv.setServices(nvl(rs.getString("services")));
                inv.setAmount(rs.getDouble("amount"));
                inv.setDiscount(rs.getDouble("discount"));
                inv.setStatus(rs.getString("status"));
                inv.setWoId(nvl(rs.getString("wo_id")));
                inv.setBkId(nvl(rs.getString("bk_id")));
                inv.setNotes(nvl(rs.getString("notes")));
                list.add(inv);
            }
        }
        return list;
    }

    private String nvl(String s) { return s == null ? "" : s; }
}