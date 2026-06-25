package servlet;

import model.User;
import util.DBConnection;

import java.io.IOException;
import java.sql.*;
import java.util.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import dao.InvoiceDAO;
import dao.UserDAO;
import dao.NotificationDAO;
import model.Invoice;
import model.Notification;


import util.EmailService;

@WebServlet("/WorkOrderServlet")
public class WorkOrderServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10; 
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "list";

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        switch (action) {
            case "list":
                try (Connection conn = DBConnection.getConnection()) {

                   
                    int page = 1;
                    try {
                        String pageParam = request.getParameter("page");
                        if (pageParam != null) page = Integer.parseInt(pageParam);
                        if (page < 1) page = 1;
                    } catch (NumberFormatException e) {
                        page = 1;
                    }
                    int offset = (page - 1) * PAGE_SIZE;

                    List<Map<String, String>> workOrders = new ArrayList<>();

                    String sql;

                    if ("admin".equalsIgnoreCase(user.getRole())) {
                        sql =
                            "SELECT wo.work_order_id, wo.bookingID, wo.service_status, " +
                            "       wo.notes, wo.mechanic_notes, wo.additional_charges, " +
                            "       wo.createdDate, wo.mechanic_id, " +
                            "       u.name AS customer_name, " +
                            "       v.plate_no, " +
                            "       m.name AS mechanic_name, " +
                            "       GROUP_CONCAT(s.service_name SEPARATOR ', ') AS services " +
                            "FROM work_order wo " +
                            "JOIN booking b      ON wo.bookingID = b.bookingID " +
                            "JOIN vehicle v       ON b.vehicle_id = v.vehicle_id " +
                            "JOIN users u         ON b.userid = u.userid " +
                            "LEFT JOIN users m    ON wo.mechanic_id = m.userid " +
                            "LEFT JOIN booking_services bs ON wo.bookingID = bs.bookingID " +
                            "LEFT JOIN services s          ON bs.service_id = s.service_id " +
                            "GROUP BY wo.work_order_id " +
                            "ORDER BY wo.createdDate DESC, wo.work_order_id DESC " +
                            "LIMIT ? OFFSET ?";
                    } else {
                        sql =
                            "SELECT wo.work_order_id, wo.bookingID, wo.service_status, " +
                            "       wo.notes, wo.mechanic_notes, wo.additional_charges, " +
                            "       wo.createdDate, wo.mechanic_id, " +
                            "       u.name AS customer_name, " +
                            "       v.plate_no, " +
                            "       m.name AS mechanic_name, " +
                            "       GROUP_CONCAT(s.service_name SEPARATOR ', ') AS services " +
                            "FROM work_order wo " +
                            "JOIN booking b      ON wo.bookingID = b.bookingID " +
                            "JOIN vehicle v       ON b.vehicle_id = v.vehicle_id " +
                            "JOIN users u         ON b.userid = u.userid " +
                            "LEFT JOIN users m    ON wo.mechanic_id = m.userid " +
                            "LEFT JOIN booking_services bs ON wo.bookingID = bs.bookingID " +
                            "LEFT JOIN services s          ON bs.service_id = s.service_id " +
                            "WHERE wo.mechanic_id = ? " +
                            "GROUP BY wo.work_order_id " +
                            "ORDER BY b.booking_date ASC, wo.work_order_id ASC " +
                            "LIMIT ? OFFSET ?";         
                    }

                    PreparedStatement ps = conn.prepareStatement(sql);
                    if (!"admin".equalsIgnoreCase(user.getRole())) {
                        ps.setString(1, user.getUserid());
                        ps.setInt(2, PAGE_SIZE);
                        ps.setInt(3, offset);
                    } else {
                        ps.setInt(1, PAGE_SIZE);
                        ps.setInt(2, offset);
                    }

                    ResultSet rs = ps.executeQuery();

                    while (rs.next()) {
                        Map<String, String> wo = new LinkedHashMap<>();
                        wo.put("work_order_id",     rs.getString("work_order_id"));
                        wo.put("bookingID",          rs.getString("bookingID"));
                        wo.put("service_status",     rs.getString("service_status"));
                        wo.put("notes",              rs.getString("notes"));
                        wo.put("mechanic_notes",     rs.getString("mechanic_notes"));   // <-- BARU
                        wo.put("additional_charges", rs.getString("additional_charges")); // <-- BARU
                        wo.put("createdDate",        rs.getString("createdDate"));
                        wo.put("mechanic_id",        rs.getString("mechanic_id"));
                        wo.put("mechanic_name",      rs.getString("mechanic_name"));
                        wo.put("customer_name",      rs.getString("customer_name"));
                        wo.put("plate_no",           rs.getString("plate_no"));
                        wo.put("services",           rs.getString("services"));
                        workOrders.add(wo);
                    }

                    int totalRows = 0;
                    String countSql;
                    if ("admin".equalsIgnoreCase(user.getRole())) {
                        countSql = "SELECT COUNT(*) FROM work_order";
                        PreparedStatement countPs = conn.prepareStatement(countSql);
                        ResultSet countRs = countPs.executeQuery();
                        if (countRs.next()) totalRows = countRs.getInt(1);
                    } else {
                        countSql = "SELECT COUNT(*) FROM work_order WHERE mechanic_id = ?";
                        PreparedStatement countPs = conn.prepareStatement(countSql);
                        countPs.setString(1, user.getUserid());
                        ResultSet countRs = countPs.executeQuery();
                        if (countRs.next()) totalRows = countRs.getInt(1);
                    }
                    int totalPages = (int) Math.ceil((double) totalRows / PAGE_SIZE);

                 
                    int statPending = 0, statInProgress = 0, statCompleted = 0, statCancelled = 0;
                    String statSql;
                    if ("admin".equalsIgnoreCase(user.getRole())) {
                        statSql = "SELECT service_status, COUNT(*) AS cnt FROM work_order GROUP BY service_status";
                    } else {
                        statSql = "SELECT service_status, COUNT(*) AS cnt FROM work_order WHERE mechanic_id = ? GROUP BY service_status";
                    }
                    PreparedStatement statPs = conn.prepareStatement(statSql);
                    if (!"admin".equalsIgnoreCase(user.getRole())) {
                        statPs.setString(1, user.getUserid());
                    }
                    ResultSet statRs = statPs.executeQuery();
                    while (statRs.next()) {
                        String st  = statRs.getString("service_status");
                        int    cnt = statRs.getInt("cnt");
                        if ("Pending".equalsIgnoreCase(st))     statPending    = cnt;
                        else if ("In Progress".equalsIgnoreCase(st)) statInProgress = cnt;
                        else if ("Completed".equalsIgnoreCase(st))   statCompleted  = cnt;
                        else if ("Cancelled".equalsIgnoreCase(st))   statCancelled  = cnt;
                    }

            
                    List<Map<String, String>> mechanics = new ArrayList<>();
                    String mechSql = "SELECT userid, name FROM users WHERE role = 'mechanic'";
                    PreparedStatement mechPs = conn.prepareStatement(mechSql);
                    ResultSet mechRs = mechPs.executeQuery();
                    while (mechRs.next()) {
                        Map<String, String> m = new HashMap<>();
                        m.put("userid", mechRs.getString("userid"));
                        m.put("name",   mechRs.getString("name"));
                        mechanics.add(m);
                    }

                 
                    List<Map<String, String>> pendingBookings = new ArrayList<>();
                    if ("admin".equalsIgnoreCase(user.getRole())) {
                        String pendingSql =
                            "SELECT b.bookingID, u.name AS customer_name, v.plate_no, b.booking_date " +
                            "FROM booking b " +
                            "JOIN vehicle v ON b.vehicle_id = v.vehicle_id " +
                            "JOIN users u   ON b.userid = u.userid " +
                            "WHERE b.bookingID NOT IN (SELECT bookingID FROM work_order) " +
                            "ORDER BY b.booking_date DESC";
                        PreparedStatement pendingPs = conn.prepareStatement(pendingSql);
                        ResultSet pendingRs = pendingPs.executeQuery();
                        while (pendingRs.next()) {
                            Map<String, String> pb = new HashMap<>();
                            pb.put("bookingID",     pendingRs.getString("bookingID"));
                            pb.put("customer_name", pendingRs.getString("customer_name"));
                            pb.put("plate_no",      pendingRs.getString("plate_no"));
                            pb.put("booking_date",  pendingRs.getString("booking_date"));
                            pendingBookings.add(pb);
                        }
                    }

                    System.out.println("Work orders size = " + workOrders.size());
                    System.out.println("Pending bookings = " + pendingBookings.size());
                    System.out.println("Page " + page + " of " + totalPages);

                    request.setAttribute("workOrders",     workOrders);
                    request.setAttribute("mechanics",      mechanics);
                    request.setAttribute("pendingBookings", pendingBookings);
                    request.setAttribute("currentPage",    page);
                    request.setAttribute("totalPages",     totalPages);
                    request.setAttribute("totalRows",      totalRows);
                    request.setAttribute("statPending",    statPending);
                    request.setAttribute("statInProgress", statInProgress);
                    request.setAttribute("statCompleted",  statCompleted);
                    request.setAttribute("statCancelled",  statCancelled);
                    request.getRequestDispatcher("workorder.jsp").forward(request, response);

                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/WorkOrderServlet?action=list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "";

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        switch (action) {

            case "create":
                if (!"admin".equalsIgnoreCase(user.getRole())) {
                    response.sendRedirect("login.jsp");
                    return;
                }

                try (Connection conn = DBConnection.getConnection()) {

                    String bookingId  = request.getParameter("bookingID");
                    String mechanicId = request.getParameter("mechanic_id");
                    String notes      = request.getParameter("notes");

                    String workOrderId = "WO-" + System.currentTimeMillis();

                    String sql =
                        "INSERT INTO work_order " +
                        "  (work_order_id, bookingID, mechanic_id, service_status, notes, " +
                        "   mechanic_notes, additional_charges, createdDate) " +
                        "VALUES (?, ?, ?, 'Pending', ?, NULL, 0.00, CURDATE())";

                    PreparedStatement ps = conn.prepareStatement(sql);
                    ps.setString(1, workOrderId);
                    ps.setString(2, bookingId);
                    ps.setString(3, mechanicId.isEmpty() ? null : mechanicId);
                    ps.setString(4, notes);
                    ps.executeUpdate();

                    // Update booking status jadi Confirmed
                    String updateBooking =
                        "UPDATE booking SET booking_status = 'Confirmed' WHERE bookingID = ?";
                    PreparedStatement updatePs = conn.prepareStatement(updateBooking);
                    updatePs.setString(1, bookingId);
                    updatePs.executeUpdate();

                    System.out.println("Work order created: " + workOrderId);

                    response.sendRedirect(request.getContextPath() + "/WorkOrderServlet?action=list");

                } catch (Exception e) {
                    e.printStackTrace();
                    response.getWriter().println("ERROR: " + e.getMessage());
                }
                break;


            case "updateStatus":
                try (Connection conn = DBConnection.getConnection()) {

                    String workOrderId      = request.getParameter("work_order_id");
                    String newStatus        = request.getParameter("service_status");
                    String notes            = request.getParameter("notes");
                    String mechanicNotes    = request.getParameter("mechanic_notes");     // <-- BARU: apa yang dibaiki
                    String additionalParam  = request.getParameter("additional_charges"); // <-- BARU: harga tambahan

                    double additionalCharges = 0.00;
                    try {
                        if (additionalParam != null && !additionalParam.trim().isEmpty()) {
                            additionalCharges = Double.parseDouble(additionalParam.trim());
                        }
                    } catch (NumberFormatException e) {
                        additionalCharges = 0.00;
                    }


                    String sql =
                        "UPDATE work_order " +
                        "SET service_status = ?, notes = ?, " +
                        "    mechanic_notes = ?, additional_charges = ? " +
                        "WHERE work_order_id = ?";
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ps.setString(1, newStatus);
                    ps.setString(2, notes);
                    ps.setString(3, mechanicNotes);
                    ps.setDouble(4, additionalCharges);
                    ps.setString(5, workOrderId);
                    ps.executeUpdate();

                    String progressInfoSql =
                        "SELECT b.userid, u.name AS customer_name, v.plate_no " +
                        "FROM work_order wo " +
                        "JOIN booking b  ON wo.bookingID = b.bookingID " +
                        "JOIN vehicle v  ON b.vehicle_id = v.vehicle_id " +
                        "JOIN users u    ON b.userid = u.userid " +
                        "WHERE wo.work_order_id = ?";
                    PreparedStatement progressPs = conn.prepareStatement(progressInfoSql);
                    progressPs.setString(1, workOrderId);
                    ResultSet progressRs = progressPs.executeQuery();

                    if (progressRs.next()) {
                        String custUserid = progressRs.getString("userid");
                        String custName   = progressRs.getString("customer_name");
                        String plateNo    = progressRs.getString("plate_no");
                  
                       
                        String custEmail = null;  // ← BARU
                        String emailQuery = "SELECT email FROM users WHERE userid = ?";
                        PreparedStatement emailPs2 = conn.prepareStatement(emailQuery);
                        emailPs2.setString(1, custUserid);
                        ResultSet emailRs2 = emailPs2.executeQuery();
                        if (emailRs2.next()) {
                            custEmail = emailRs2.getString("email");
                        }
    
                       NotificationDAO notifDAO2 = new NotificationDAO();

                    
                        String notifTitle, notifMsg, notifType;
                        switch (newStatus) {
                            case "In Progress":
                                notifTitle = "Vehicle in Progress";
                                notifMsg   = "Vehcicle " + plateNo + 
                                             " is currently being serviced by our mechanic";
                                notifType  = "progress";
                                break;
                            case "Cancelled":
                                notifTitle = "Work Order Cancelled";
                                notifMsg   = "Work order for vechicle " + plateNo + 
                                             " has been cancelled. Please contact us for more.";
                                notifType  = "progress";
                                break;
                            case "Completed":
                  
                                notifTitle = null;
                                notifMsg   = null;
                                notifType  = null;
                                break;
                            default:
                                notifTitle = "Status Updated";
                                notifMsg   = "Status vehicle " + plateNo + 
                                             " updated to: " + newStatus;
                                notifType  = "progress";
                        }

                        if (notifTitle != null) {
                            boolean exists = notifDAO2.exists(custUserid, notifType, workOrderId);
                            if (!exists) {
                                Notification progressNotif = new Notification(
                                    custUserid,
                                    notifTitle,
                                    notifMsg,
                                    notifType,
                                    "",
                                    workOrderId
                                );
                                notifDAO2.insert(progressNotif);
                            }

                     
                            if (custEmail != null && !custEmail.isEmpty()) {
                                EmailService.sendProgressUpdate(
                                    custEmail, custName, plateNo, workOrderId, newStatus
                                );
                            }
                        }
                    }
                    if ("Completed".equalsIgnoreCase(newStatus)) {

                        String updateBooking =
                            "UPDATE booking SET booking_status = 'Completed' " +
                            "WHERE bookingID = (SELECT bookingID FROM work_order WHERE work_order_id = ?)";
                        PreparedStatement updatePs = conn.prepareStatement(updateBooking);
                        updatePs.setString(1, workOrderId);
                        updatePs.executeUpdate();


                        String infoSql =
                            "SELECT wo.bookingID, b.userid, u.name AS customer_name, v.plate_no, " +
                            "       v.brand, v.model, " +
                            "       GROUP_CONCAT(s.service_name SEPARATOR ', ') AS services, " +
                            "       COALESCE(SUM(s.price), 0) AS service_total, " +
                            "       wo.additional_charges, wo.mechanic_notes " +
                            "FROM work_order wo " +
                            "JOIN booking b   ON wo.bookingID = b.bookingID " +
                            "JOIN vehicle v   ON b.vehicle_id = v.vehicle_id " +
                            "JOIN users u     ON b.userid = u.userid " +
                            "LEFT JOIN booking_services bs ON wo.bookingID = bs.bookingID " +
                            "LEFT JOIN services s          ON bs.service_id = s.service_id " +
                            "WHERE wo.work_order_id = ? " +
                            "GROUP BY wo.bookingID, b.userid, u.name, v.plate_no, v.brand, v.model, " +
                            "         wo.additional_charges, wo.mechanic_notes";
                        PreparedStatement infoPs = conn.prepareStatement(infoSql);
                        infoPs.setString(1, workOrderId);
                        ResultSet infoRs = infoPs.executeQuery();

                        if (infoRs.next()) {
                            String existCheck = "SELECT COUNT(*) FROM invoices WHERE wo_id = ?";
                            PreparedStatement existPs = conn.prepareStatement(existCheck);
                            existPs.setString(1, workOrderId);
                            ResultSet existRs = existPs.executeQuery();
                            existRs.next();
                            boolean alreadyExists = existRs.getInt(1) > 0;

                            if (!alreadyExists) {
                                
                                double serviceTotal    = infoRs.getDouble("service_total");
                                double addCharges      = infoRs.getDouble("additional_charges");
                                double totalAmount     = serviceTotal + addCharges;
                                String mNotes          = infoRs.getString("mechanic_notes");

                        
                                String invoiceNotes = "Auto-generated upon WO completion";
                                if (mNotes != null && !mNotes.trim().isEmpty()) {
                                    invoiceNotes += " | Repair notes: " + mNotes;
                                }
                                if (addCharges > 0) {
                                    invoiceNotes += " | Additional charges: RM " +
                                        String.format("%.2f", addCharges);
                                }

                                InvoiceDAO invDAO = new InvoiceDAO();
                                Invoice inv = new Invoice();
                                inv.setId(invDAO.nextInvoiceId());
                                inv.setCustomer(infoRs.getString("customer_name"));
                                inv.setCustomerUserid(infoRs.getString("userid"));
                                inv.setVehicle(infoRs.getString("plate_no"));
                                inv.setServices(infoRs.getString("services") != null
                                    ? infoRs.getString("services") : "");
                                inv.setAmount(totalAmount);   // <-- sudah include additional_charges
                                inv.setDiscount(0.0);
                                inv.setStatus("Pending");
                                inv.setInvDate(new java.text.SimpleDateFormat("dd/MM/yyyy")
                                    .format(new java.util.Date()));
                                inv.setMethod("");
                                inv.setWoId(workOrderId);
                                inv.setBkId(infoRs.getString("bookingID"));
                                inv.setNotes(invoiceNotes);
                                invDAO.insert(inv);
              
                                String dueSql = 
                                    "UPDATE invoices SET due_date = DATE_ADD(NOW(), INTERVAL 30 MINUTE) " +
                                    "WHERE userid = ?";
                                PreparedStatement duePs = conn.prepareStatement(dueSql);
                                duePs.setString(1, inv.getId());
                                duePs.executeUpdate();
                                System.out.println("[WorkOrder] due_date set for: " + inv.getId());

                         
                                NotificationDAO notifDAO = new NotificationDAO();
                                boolean notifExists = notifDAO.exists(
                                    infoRs.getString("userid"), "ready", workOrderId
                                );
                                if (!notifExists) {
                                    Notification notif = new Notification(
                                        infoRs.getString("userid"),
                                        "Vehicle Ready",
                                        "Your vehicle " + infoRs.getString("plate_no") + 
                                        " as been serviced. Please make payment within 30 minutes." +
                                        " (Invoice: " + inv.getId() + " | Amaun: RM " + 
                                        String.format("%.2f", totalAmount) + ")",
                                        "ready",
                                        inv.getId(),
                                        workOrderId
                                    );
                                    notifDAO.insert(notif);
                                }
                             
                                String emailSql =
                                    "SELECT email FROM users WHERE userid = ?";
                                PreparedStatement emailPs = conn.prepareStatement(emailSql);
                                emailPs.setString(1, infoRs.getString("userid"));
                                ResultSet emailRs = emailPs.executeQuery();

                                if (emailRs.next()) {
                                    String customerEmail = emailRs.getString("email");
                                    String customerName  = infoRs.getString("customer_name");
                                    String plateNo       = infoRs.getString("plate_no");
                                    String invoiceId     = inv.getId();

                                    EmailService.sendServiceComplete(
                                        customerEmail,
                                        customerName,
                                        plateNo,
                                        invoiceId,
                                        totalAmount
                                    );
                                }
                                System.out.println("Invoice created: " + inv.getId() +
                                    " | Total: RM " + String.format("%.2f", totalAmount));
                            }
                        }
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                    System.err.println("ERROR updateStatus: " + e.getMessage());
                }

                response.sendRedirect(request.getContextPath() + "/WorkOrderServlet?action=list");
                break;

            case "assign":
                if (!"admin".equalsIgnoreCase(user.getRole())) {
                    response.sendRedirect("login.jsp");
                    return;
                }

                try (Connection conn = DBConnection.getConnection()) {

                    String workOrderId = request.getParameter("work_order_id");
                    String mechanicId  = request.getParameter("mechanic_id");

                    String sql = "UPDATE work_order SET mechanic_id = ? WHERE work_order_id = ?";
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ps.setString(1, mechanicId);
                    ps.setString(2, workOrderId);
                    ps.executeUpdate();

                    response.sendRedirect(request.getContextPath() + "/WorkOrderServlet?action=list");

                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;


            case "delete":
                if (!"admin".equalsIgnoreCase(user.getRole())) {
                    response.sendRedirect("login.jsp");
                    return;
                }

                try (Connection conn = DBConnection.getConnection()) {

                    String workOrderId = request.getParameter("work_order_id");

                    if (workOrderId == null || workOrderId.trim().isEmpty()) {
                        response.sendRedirect(request.getContextPath()
                            + "/WorkOrderServlet?action=list&error=missingId");
                        return;
                    }

                    String checkInvoiceSql = "SELECT COUNT(*) FROM invoices WHERE wo_id = ?";
                    PreparedStatement checkPs = conn.prepareStatement(checkInvoiceSql);
                    checkPs.setString(1, workOrderId);
                    ResultSet checkRs = checkPs.executeQuery();
                    checkRs.next();
                    boolean hasInvoice = checkRs.getInt(1) > 0;

                    if (hasInvoice) {
                    
                        System.out.println("Delete blocked: WO " + workOrderId +
                            " has linked invoice(s).");
                        response.sendRedirect(request.getContextPath()
                            + "/WorkOrderServlet?action=list&error=hasInvoice");
                        return;
                    }


                    String deleteSql = "DELETE FROM work_order WHERE work_order_id = ?";
                    PreparedStatement deletePs = conn.prepareStatement(deleteSql);
                    deletePs.setString(1, workOrderId);
                    int rowsAffected = deletePs.executeUpdate();

                    System.out.println("Work order deleted: " + workOrderId +
                        " (rows affected: " + rowsAffected + ")");

                    response.sendRedirect(request.getContextPath()
                        + "/WorkOrderServlet?action=list&deleted=1");

                } catch (SQLException e) {
                    e.printStackTrace();
                    // Contoh: FK constraint dari jadual lain yang tak dijangka
                    response.sendRedirect(request.getContextPath()
                        + "/WorkOrderServlet?action=list&error=deleteFailed");
                } catch (Exception e) {
                    e.printStackTrace();
                    response.sendRedirect(request.getContextPath()
                        + "/WorkOrderServlet?action=list&error=deleteFailed");
                }
                break;


            default:
                response.sendRedirect(request.getContextPath() + "/WorkOrderServlet?action=list");
        }
    }
}