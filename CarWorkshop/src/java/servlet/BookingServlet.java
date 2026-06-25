package servlet;

import model.User;
import model.Booking;
import util.DBConnection;

import java.io.IOException;
import java.sql.*;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/BookingServlet")
public class BookingServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "list";
        System.out.println("=== DOGET HIT === action=" + action);

        switch (action) {

            case "add":
                request.getRequestDispatcher("/customerbooking.jsp")
                        .forward(request, response);
                break;

            // -------------------------------------------------------
            // CUSTOMER - tengok booking sendiri je
            // -------------------------------------------------------
            case "list":
                try (Connection conn = DBConnection.getConnection()) {

                    HttpSession session = request.getSession(false);
                    User user = (session != null) ? (User) session.getAttribute("user") : null;

                    if (user == null) {
                        response.sendRedirect("login.jsp");
                        return;
                    }
                    
                    
                      if ("customer".equalsIgnoreCase(user.getRole())) {
                          response.sendRedirect(request.getContextPath() + "/BookingServlet?action=add");
                          return;
                      }
                    List<Booking> bookings = new ArrayList<>();

                    String sql =
                        "SELECT b.bookingID, v.plate_no, b.booking_date, b.booking_status " +
                        "FROM booking b " +
                        "JOIN vehicle v ON b.vehicle_id = v.vehicle_id " +
                        "WHERE b.userid = ? " +
                        "ORDER BY b.booking_date DESC";

                    PreparedStatement ps = conn.prepareStatement(sql);
                    ps.setString(1, user.getUserid());
                    ResultSet rs = ps.executeQuery();

                    while (rs.next()) {
                        Booking b = new Booking();
                        b.setBookingID(rs.getString("bookingID"));
                        b.setCarPlate(rs.getString("plate_no"));
                        b.setBookingDate(rs.getTimestamp("booking_date"));
                        b.setBookingStatus(rs.getString("booking_status"));
                        bookings.add(b);
                    }

                    System.out.println("Customer bookings size = " + bookings.size());

                    // BUG FIX: hantar 'bookings' bukan new ArrayList<>()
                    request.setAttribute("bookings", bookings);
                    request.getRequestDispatcher("/booking.jsp").forward(request, response);

                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;

            // -------------------------------------------------------
            // ADMIN - tengok SEMUA booking dari semua user
            // -------------------------------------------------------
            case "adminList":
                try (Connection conn = DBConnection.getConnection()) {

                    HttpSession session = request.getSession(false);
                    User user = (session != null) ? (User) session.getAttribute("user") : null;

                    // Pastikan yang login adalah admin
                    if (user == null || !("admin".equalsIgnoreCase(user.getRole()) || "mechanic".equalsIgnoreCase(user.getRole()))) {
                        response.sendRedirect("login.jsp");
                        return;
                    }
                    List<Booking> bookings = new ArrayList<>();

                    // Query semua booking + nama user + plate + services
                    String sql =
                        "SELECT b.bookingID, " +
                        "       u.name AS customer_name, " +
                        "       v.plate_no, " +
                        "       b.booking_date, " +
                        "       b.booking_status, " +
                        "       GROUP_CONCAT(s.service_name SEPARATOR ', ') AS services " +
                        "FROM booking b " +
                        "JOIN vehicle v  ON b.vehicle_id = v.vehicle_id " +
                        "JOIN users u    ON b.userid = u.userid " +
                        "LEFT JOIN booking_services bs ON b.bookingID = bs.bookingID " +
                        "LEFT JOIN services s          ON bs.service_id = s.service_id " +
                        "GROUP BY b.bookingID, u.name, v.plate_no, b.booking_date, b.booking_status " +
                        "ORDER BY b.booking_date DESC";

                    PreparedStatement ps = conn.prepareStatement(sql);
                    ResultSet rs = ps.executeQuery();

                    while (rs.next()) {
                        Booking b = new Booking();
                        b.setBookingID(rs.getString("bookingID"));
                        b.setCustomerName(rs.getString("customer_name")); // tambah field ni dalam model
                        b.setCarPlate(rs.getString("plate_no"));
                        b.setBookingDate(rs.getTimestamp("booking_date"));
                        b.setBookingStatus(rs.getString("booking_status"));
                        b.setServices(rs.getString("services")); // tambah field ni dalam model
                        bookings.add(b);
                    }
                   System.out.println("ADMIN LIST HIT");
                    System.out.println("Admin bookings size = " + bookings.size());

                    request.setAttribute("bookings", bookings);
                    request.getRequestDispatcher("/adminBookingList.jsp").forward(request, response);

                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;

            // -------------------------------------------------------
            // ADMIN - update status booking
            // -------------------------------------------------------
            case "updateStatus":
                try (Connection conn = DBConnection.getConnection()) {

                    HttpSession session = request.getSession(false);
                    User user = (session != null) ? (User) session.getAttribute("user") : null;

                    if (user == null || !("admin".equalsIgnoreCase(user.getRole()) || "mechanic".equalsIgnoreCase(user.getRole()))) {
                    response.sendRedirect("login.jsp");
                    return;
                }
                    String bookingId = request.getParameter("bookingID");
                    String newStatus = request.getParameter("status");

                    String sql = "UPDATE booking SET booking_status = ? WHERE bookingID = ?";
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ps.setString(1, newStatus);
                    ps.setString(2, bookingId);
                    ps.executeUpdate();
                   
                    // AUTO CREATE INVOICE bila status jadi Completed
        if ("Completed".equals(newStatus)) {
            // Ambil info booking
            String infoSql = 
                "SELECT u.name, u.userid, v.plate_no, " +
                "GROUP_CONCAT(s.service_name SEPARATOR ', ') AS services, " +
                "COALESCE(SUM(s.price), 0) AS total " +
                "FROM booking b " +
                "JOIN users u ON b.userid = u.userid " +
                "JOIN vehicle v ON b.vehicle_id = v.vehicle_id " +
                "LEFT JOIN booking_services bs ON b.bookingID = bs.bookingID " +
                "LEFT JOIN services s ON bs.service_id = s.service_id " +
                "WHERE b.bookingID = ? " +
                "GROUP BY u.name, u.userid, v.plate_no";

                PreparedStatement psInfo = conn.prepareStatement(infoSql);
                psInfo.setString(1, bookingId);
                ResultSet rs = psInfo.executeQuery();

                if (rs.next()) {
                    String customerName   = rs.getString("name");
                    String customerUserid = rs.getString("userid");
                    String plateNo        = rs.getString("plate_no");
                    String services       = rs.getString("services");
                    double total          = rs.getDouble("total");

                    // Generate Invoice ID
                    String getCounter = "SELECT value FROM counters WHERE name='invoice'";
                    String updCounter = "UPDATE counters SET value=value+1 WHERE name='invoice'";
                    PreparedStatement psUpd = conn.prepareStatement(updCounter);
                    psUpd.executeUpdate();
                    PreparedStatement psGet = conn.prepareStatement(getCounter);
                    ResultSet rsC = psGet.executeQuery();
                    String invoiceId = "INV-0001";
                    if (rsC.next()) invoiceId = String.format("INV-%04d", rsC.getInt(1));

                    // Check invoice belum wujud untuk booking ni
                    String checkInv = "SELECT userid FROM invoices WHERE bk_id=?";
                    PreparedStatement psCheck = conn.prepareStatement(checkInv);
                    psCheck.setString(1, bookingId);
                    ResultSet rsCheck = psCheck.executeQuery();

                    if (!rsCheck.next()) {
                        String today = new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date());
                        String insertInv = 
                            "INSERT INTO invoices (userid, customer, customer_userid, vehicle, services, " +
                            "amount, discount, status, inv_date, method, wo_id, bk_id, notes) " +
                            "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)";
                        PreparedStatement psInv = conn.prepareStatement(insertInv);
                        psInv.setString(1,  invoiceId);
                        psInv.setString(2,  customerName);
                        psInv.setString(3,  customerUserid);
                        psInv.setString(4,  plateNo);
                        psInv.setString(5,  services != null ? services : "");
                        psInv.setDouble(6,  total);
                        psInv.setDouble(7,  0.0);
                        psInv.setString(8,  "Pending");
                        psInv.setString(9,  today);
                        psInv.setString(10, "");
                        psInv.setString(11, "");
                        psInv.setString(12, bookingId);
                        psInv.setString(13, "");
                        psInv.executeUpdate();
                    }
                }
            }
                        response.sendRedirect(request.getContextPath() + "/BookingServlet?action=adminList");

                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;

            case "confirm":
                request.setAttribute("bookingID", request.getParameter("bookingID"));
                request.setAttribute("total", request.getParameter("total"));
                request.setAttribute("date", request.getParameter("date"));
                request.setAttribute("time", request.getParameter("time"));
                request.setAttribute("services", request.getParameter("services"));
                request.setAttribute("plate", request.getParameter("plate"));
                request.getRequestDispatcher("/bookingConfirm.jsp").forward(request, response);
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/BookingServlet?action=list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String userid = user.getUserid();

        String plateNo      = request.getParameter("carPlate");
        String carBrand     = request.getParameter("carBrand");
        String carModel     = request.getParameter("carModel");
        String carYearStr   = request.getParameter("manufactureYear");
        String serviceNames = request.getParameter("serviceName");
        String bookingDate  = request.getParameter("bookingDate");
        String bookingTime  = request.getParameter("bookingTime");
        String totalPrice   = request.getParameter("totalPrice");

        int carYear = 0;
        try {
            if (carYearStr != null) carYear = Integer.parseInt(carYearStr);
        } catch (Exception e) {
            carYear = 0;
        }

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. VEHICLE CHECK / INSERT
            String vehicleId = null;
            String checkVehicle = "SELECT vehicle_id FROM vehicle WHERE plate_no=? AND userid=?";
            try (PreparedStatement ps = conn.prepareStatement(checkVehicle)) {
                ps.setString(1, plateNo);
                ps.setString(2, userid);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) vehicleId = rs.getString("vehicle_id");
            }

            if (vehicleId == null) {
                vehicleId = "VH-" + System.currentTimeMillis();
                String insertVehicle =
                    "INSERT INTO vehicle (vehicle_id, userid, plate_no, brand, model, manufacturingYear) " +
                    "VALUES (?,?,?,?,?,?)";
                try (PreparedStatement ps = conn.prepareStatement(insertVehicle)) {
                    ps.setString(1, vehicleId);
                    ps.setString(2, userid);
                    ps.setString(3, plateNo);
                    ps.setString(4, carBrand);
                    ps.setString(5, carModel);
                    ps.setInt(6, carYear);
                    ps.executeUpdate();
                }
            }

           
        // 2. BOOKING ID - format BK-YYYYMMDD-XXX
        String datePart = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));

        String seqSQL = "SELECT COUNT(*) FROM booking WHERE bookingID LIKE ?";
        int seq = 1;
        try (PreparedStatement psSeq = conn.prepareStatement(seqSQL)) {
            psSeq.setString(1, "BK-" + datePart + "-%");
            ResultSet rsSeq = psSeq.executeQuery();
            if (rsSeq.next()) seq = rsSeq.getInt(1) + 1;
        }

        String bookingId = String.format("BK-%s-%03d", datePart, seq);

            // 3. FIX DATE & TIME
            LocalDate date   = LocalDate.parse(bookingDate);
            String timeStr   = bookingTime.trim().replace("\u00A0", " ");
            LocalTime time;

            if (timeStr.toLowerCase().contains("am") || timeStr.toLowerCase().contains("pm")) {
                DateTimeFormatter formatter12 = DateTimeFormatter.ofPattern("h:mm a", Locale.ENGLISH);
                time = LocalTime.parse(timeStr.toUpperCase(), formatter12);
            } else {
                DateTimeFormatter formatter24 = DateTimeFormatter.ofPattern("H:mm");
                time = LocalTime.parse(timeStr, formatter24);
            }

            LocalDateTime dateTime = LocalDateTime.of(date, time);
            
            // 3. CHECK DOUBLE BOOKING — same date & time
            String slotCheck = 
            "SELECT COUNT(*) FROM booking " +
            "WHERE booking_date = ? " +
            "AND booking_status NOT IN ('Cancelled', 'Completed')";
            try (PreparedStatement psSlot = conn.prepareStatement(slotCheck)) {
                psSlot.setTimestamp(1, Timestamp.valueOf(dateTime));
                ResultSet rsSlot = psSlot.executeQuery();
                if (rsSlot.next() && rsSlot.getInt(1) > 0) {
                    conn.rollback();
                    response.sendRedirect(request.getContextPath() + 
                        "/BookingServlet?action=add&error=slot_taken");
                    return;
                }
            }
            // 4. INSERT BOOKING
            String insertBooking =
                "INSERT INTO booking (bookingID, vehicle_id, userid, booking_date, booking_status) " +
                "VALUES (?,?,?,?,?)";
            try (PreparedStatement ps = conn.prepareStatement(insertBooking)) {
                ps.setString(1, bookingId);
                ps.setString(2, vehicleId);
                ps.setString(3, userid);
                ps.setTimestamp(4, Timestamp.valueOf(dateTime));
                ps.setString(5, "Pending");
                ps.executeUpdate();
            }

            // 5. INSERT BOOKING SERVICES
            if (serviceNames != null && !serviceNames.isEmpty()) {
                String[] services = serviceNames.split(",");
                for (String svc : services) {
                    svc = svc.trim();
                    String serviceId = null;
                    String findService = "SELECT service_id FROM services WHERE service_name=?";
                    try (PreparedStatement ps = conn.prepareStatement(findService)) {
                        ps.setString(1, svc);
                        ResultSet rs = ps.executeQuery();
                        if (rs.next()) serviceId = rs.getString("service_id");
                    }
                    if (serviceId != null) {
                        String insertSvc = "INSERT INTO booking_services (bookingID, service_id) VALUES (?,?)";
                        try (PreparedStatement ps = conn.prepareStatement(insertSvc)) {
                            ps.setString(1, bookingId);
                            ps.setString(2, serviceId);
                            ps.executeUpdate();
                        }
                    }
                }
            }

            conn.commit();

            response.sendRedirect(request.getContextPath() +
                "/BookingServlet?action=confirm&bookingID=" + bookingId +
                "&total=" + totalPrice +
                "&date=" + bookingDate +
                "&time=" + bookingTime +
                "&services=" + serviceNames +
                "&plate=" + plateNo);

        } catch (Exception e) {
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) {}
            e.printStackTrace();
            response.getWriter().println("ERROR: " + e.getMessage());
        }
    }
}