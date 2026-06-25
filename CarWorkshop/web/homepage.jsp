<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<%@ page import="dao.NotificationDAO, model.Notification, java.util.List" %>

<%
String ctxPath = request.getContextPath();
String username = (String) session.getAttribute("username");
String role     = (String) session.getAttribute("role");

if (username == null || username.trim().isEmpty()) { username = "Guest"; }
if (role == null) { role = "guest"; }
role = role.toLowerCase();

boolean isAdmin    = "admin".equals(role);
boolean isMechanic = "mechanic".equals(role);
boolean isCustomer = "customer".equals(role);
boolean isGuest    = "guest".equals(role);
boolean canEdit    = isAdmin || isMechanic;



List<Map<String,String>> recentBookings = new java.util.ArrayList<>();
if (isCustomer) {
    String userid = (String) session.getAttribute("userid");
    if (userid != null) {
        try (java.sql.Connection conn = util.DBConnection.getConnection()) {
            String sql = "SELECT b.bookingID, b.booking_date, b.booking_status, " +
                         "GROUP_CONCAT(s.service_name SEPARATOR ', ') AS services " +
                         "FROM booking b " +
                         "LEFT JOIN booking_services bs ON b.bookingID = bs.bookingID " +
                         "LEFT JOIN services s ON bs.service_id = s.service_id " +
                         "WHERE b.userid = ? " +
                         "GROUP BY b.bookingID " +
                         "ORDER BY b.booking_date DESC LIMIT 5";
            java.sql.PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, userid);
            java.sql.ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String,String> b = new java.util.LinkedHashMap<>();
                b.put("id",       rs.getString("bookingID"));
                b.put("date",     rs.getTimestamp("booking_date").toString());
                b.put("status",   rs.getString("booking_status"));
                b.put("services", rs.getString("services") != null ? rs.getString("services") : "—");
                recentBookings.add(b);
            }
        } catch (Exception e) { e.printStackTrace(); }
    }
}


String avatar    = username.substring(0, 1).toUpperCase();
String roleLabel = isAdmin ? "Administrator" : isMechanic ? "Mechanic" : isCustomer ? "Customer" : "Guest";

String bookingLink = isGuest
    ? "javascript:void(0)"
    : (isAdmin || isMechanic)
        ? request.getContextPath() + "/BookingServlet?action=adminList"
        : request.getContextPath() + "/BookingServlet?action=add";

String bookingOnclick = isGuest
    ? "showLoginPopup()"
    : "window.location.href='" + bookingLink + "'";


NotificationDAO notifDAO = new NotificationDAO();
List<Notification> latestNotifs = new java.util.ArrayList<>();
int unreadCount = 0;
String sessionUserid = (String) session.getAttribute("userid");
if (sessionUserid != null) {
    try {
        latestNotifs = notifDAO.getAll(sessionUserid);  // ← BARIS NI
        unreadCount  = notifDAO.countUnread(sessionUserid);
    } catch (Exception ex) { ex.printStackTrace(); }
}
%>

<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AutoCare Dashboard</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <style>
        /* ── HERO SLIDESHOW ── */
        .hero{position:relative;height:380px;overflow:hidden;background:#111;flex-shrink:0}
        .slide{position:absolute;inset:0;opacity:0;transition:opacity .8s;display:flex;align-items:center}
        .slide.active{opacity:1}
        .slide-bg{position:absolute;inset:0;background-size:cover;background-position:center;filter:brightness(.38)}
        .slide-cnt{position:relative;z-index:2;padding:0 44px;max-width:520px}
        .s-tag{font-size:10px;font-weight:700;color:#e85d04;text-transform:uppercase;letter-spacing:.15em;font-style:italic;margin-bottom:10px}
        .s-title{font-size:30px;font-weight:800;color:#fff;line-height:1.2;margin-bottom:12px}
        .s-title span{color:#e85d04}
        .s-desc{font-size:12px;color:#999;line-height:1.7;margin-bottom:18px}
        .s-btns{display:flex;gap:8px}
        .btn-o{background:#e85d04;color:#fff;border:none;padding:9px 20px;border-radius:4px;font-size:12px;font-weight:700;cursor:pointer}
        .btn-o:hover{background:#d04e00}
        .btn-g{background:transparent;color:#fff;border:1px solid #555;padding:9px 20px;border-radius:4px;font-size:12px;cursor:pointer}
        .btn-g:hover{border-color:#e85d04;color:#e85d04}
        .h-dots{position:absolute;bottom:14px;left:50%;transform:translateX(-50%);display:flex;gap:6px;z-index:5}
        .dot{width:7px;height:7px;border-radius:50%;background:#444;cursor:pointer;transition:background .2s}
        .dot.active{background:#e85d04}
        .h-arrows{position:absolute;top:50%;transform:translateY(-50%);width:100%;display:flex;justify-content:space-between;padding:0 12px;z-index:5}
        .slide-arr{background:rgba(0,0,0,.5);border:1px solid #333;color:#fff;width:32px;height:32px;border-radius:50%;display:flex;align-items:center;justify-content:center;cursor:pointer;font-size:15px;transition:all .15s}
        .slide-arr:hover{background:#e85d04;border-color:#e85d04}

        /* ── TICKER ── */
        .ticker{background:#e85d04;padding:8px 0;overflow:hidden;white-space:nowrap}
        .tk-inner{display:inline-flex;animation:tick 16s linear infinite}
        .tk-item{font-size:11px;font-weight:700;color:#fff;text-transform:uppercase;letter-spacing:.07em;padding:0 24px}
        @keyframes tick{0%{transform:translateX(0)}100%{transform:translateX(-50%)}}

        /* ── STATS BAR ── */
        .stats-bar{background:#111;padding:20px 28px;display:grid;grid-template-columns:repeat(4,1fr);text-align:center;gap:10px}
        .st-num{font-size:26px;font-weight:800;color:#e85d04}
        .st-lbl{font-size:10px;color:#666;text-transform:uppercase;letter-spacing:.07em;margin-top:3px}

        /* ── TESTIMONIALS ── */
        .testi{background:#fff;padding:44px 28px}
        .sec-hd{text-align:center;margin-bottom:24px}
        .sec-hd .itag{font-size:12px;font-style:italic;color:#e85d04;font-weight:700;margin-bottom:4px}
        .sec-hd h2{font-size:22px;font-weight:800;color:#111}
        .testi-grid{display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-top:24px}
        .tc{background:#f9f9f9;border-radius:9px;padding:20px;border:1px solid #eee}
        .tc-q{font-size:40px;color:#e85d04;line-height:.7;font-family:Georgia,serif;margin-bottom:8px;opacity:.3}
        .tc-txt{font-size:12px;color:#555;line-height:1.8;font-style:italic;margin-bottom:16px}
        .tc-auth{display:flex}
        .tc-name{background:#e85d04;color:#fff;font-size:11px;font-weight:700;padding:5px 12px;border-radius:3px 0 0 3px}
        .tc-svc{background:#111;color:#fff;font-size:10px;font-weight:600;padding:5px 12px;border-radius:0 3px 3px 0}

        /* ── CONTACT / FOOTER GRID ── */
        .contact{background:#111;padding:44px 28px;display:grid;grid-template-columns:1.2fr 1fr 1.2fr 1.4fr;gap:32px}
        .ct-col h2,.ct-col h3{font-size:18px;font-weight:800;color:#fff;margin-bottom:14px}
        .ct-col p{font-size:12px;color:#888;line-height:1.8}
        .ct-links{display:flex;flex-direction:column;gap:10px}
        .ct-links a{font-size:12px;color:#999;text-decoration:none}
        .ct-links a:hover{color:#e85d04}
        .ct-links .sub-link{padding-left:14px;font-size:11px}
        .ct-items{display:flex;flex-direction:column;gap:14px}
        .ct-row{display:flex;align-items:flex-start;gap:10px}
        .ct-ico{width:34px;height:34px;background:#e85d04;border-radius:6px;display:flex;align-items:center;justify-content:center;font-size:15px;flex-shrink:0}
        .ct-lbl{font-size:9px;color:#555;text-transform:uppercase;letter-spacing:.05em}
        .ct-val{font-size:12px;color:#ccc;font-weight:500;margin-top:2px;line-height:1.5}
        .h-list{display:flex;flex-direction:column;gap:6px}
        .h-row{display:flex;justify-content:space-between;align-items:center;padding:6px 0;border-bottom:1px solid #1e1e1e;font-size:12px}
        .h-row:last-child{border-bottom:none}
        .h-day{color:#999}
        .h-t{font-weight:700;color:#fff}
        .h-t.closed{color:#e85d04}

        /* ── NEW FOOTER ── */
        .ft{background:#080808;border-top:2px solid #e85d04;padding:14px 28px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
        .ft-brand{font-size:13px;font-weight:800;color:#fff}
        .ft-brand span{color:#e85d04}
        .ft-copy{font-size:10px;color:#333}
        .ft-links{display:flex;gap:14px}
        .ft-links a{font-size:10px;color:#333;text-decoration:none}
        .ft-links a:hover{color:#e85d04}

        /* ── GUEST ALERT TOPBAR ── */
        .guest-alert{display:flex;align-items:center;gap:8px;background:#1a0a00;border:1px solid #e85d04;border-radius:5px;padding:4px 12px;font-size:11px;color:#e85d04}
        .guest-alert a{color:#fff;background:#e85d04;padding:3px 10px;border-radius:3px;font-size:10px;font-weight:700;text-decoration:none;margin-left:4px}
        .guest-alert a:hover{background:#d04e00}
    </style>
</head>
<body>

<!-- ===== SIDEBAR ===== -->
<aside class="sidebar">
    <div class="logo-area">
        <img src="<%= request.getContextPath() %>/img/logo.png" 
             alt="AutoCare Logo" 
             style="width:120px; margin:0 auto 8px; display:block;">
        <div class="logo-title">AutoCare</div>
        <div class="logo-sub">Workshop</div>
    </div>

    <nav class="nav-section">

        <a href="homepage.jsp" class="nav-item active">
            <div class="nav-dot" style="background:#ef5350"></div>
            <span>Dashboard</span>
        </a>
        <a href="services.jsp" class="nav-item">
            <div class="nav-dot" style="background:#ffa726"></div>
            <span>Services</span>
        </a>
     <% if (isGuest) { %>
        <a href="javascript:void(0)" class="nav-item" onclick="showLoginPopup()">
            <div class="nav-dot" style="background:#ff8a65"></div><span>Booking</span>
        </a>
        <% } else { %>
        <a href="<%=ctxPath%>/BookingServlet?action=<%= canEdit ? "adminList" : "add" %>" class="nav-item">
            <div class="nav-dot" style="background:#ff8a65"></div><span>Booking</span>
        </a>
        <% } %>

        <% if (isAdmin || isMechanic) { %>
        <a href="WorkOrderServlet?action=list" class="nav-item">
            <div class="nav-dot" style="background:#42a5f5"></div>
            <span>Work Order</span>
        </a>
        <% } %>

        <% if (isAdmin || isCustomer) { %>
        <a href="<%=ctxPath%>/payment?tab=invoices" class="nav-item">
            <div class="nav-dot" style="background:#66bb6a"></div>
            <span>Payment</span>
        </a>
        <% } %>

        <% if (isAdmin) { %>
        <a href="inventory.jsp" class="nav-item">
            <div class="nav-dot" style="background:#ab47bc"></div>
            <span>Inventory</span>
        </a>
        <% } %>
        
        <% if (isAdmin) { %>
        <a href="<%=ctxPath%>/ReportServlet" class="nav-item">
            <div class="nav-dot" style="background:var(--muted)"></div>Reports
        </a>
       <% } %>
       <% if (isAdmin || isMechanic || isCustomer) { %>
        <a href="<%=ctxPath%>/SettingsServlet" class="nav-item">
            <div class="nav-dot" style="background:var(--muted)"></div>Settings
        </a>
        <% } %>

    </nav>

    <div class="sidebar-footer">
        <div class="user-box">
            <div class="avatar"><%= avatar %></div>
            <div class="user-info">
                <div class="user-name"><%= username %></div>
                <div class="user-role"><%= roleLabel %></div>
            </div>
            <a href="${pageContext.request.contextPath}/LogoutServlet" class="logout-btn" title="Log Out">⏻</a>
        </div>
    </div>

</aside>

<!-- ===== MAIN ===== -->
<main class="main">

    <!-- Topbar -->
    <header class="topbar">
        <div class="page-title">Dashboard </div>
       <div class="top-right">
            <% if (isGuest) { %>
            <div class="guest-alert">
                🔒 You are browsing as Guest
                <a href="login.jsp">Log In</a>
                <a href="register.jsp">Register</a>
            </div>
            <% } %>
            <div class="date-badge" id="dateDisplay"></div>

            <% if (!isGuest) { %>
            <div class="notif-wrap" id="notifWrap">
                <div class="bell" onclick="toggleNotif()">
                    🔔
                    <% if (unreadCount > 0) { %>
                    <span class="bell-badge"><%= unreadCount %></span>
                    <% } %>
                </div>
                <div class="notif-dropdown" id="notifDropdown">
                    <div class="notif-header">
                        <span>Notifications</span>
                        <% if (unreadCount > 0) { %>
                        <a href="<%= request.getContextPath() %>/notifications?action=markAllRead"
                           class="notif-markall">Mark all read</a>
                        <% } %>
                    </div>
                    <div class="notif-list">
                        <% if (latestNotifs.isEmpty()) { %>
                        <div class="notif-empty">No notifications yet 🔕</div>
                        <% } else {
                            for (Notification n : latestNotifs) { %>
                        <div class="notif-item <%= n.isRead() ? "" : "unread" %>">
                            <div class="notif-icon"><%= n.getTypeIcon() %></div>
                            <div class="notif-body">
                                <div class="notif-title"><%= n.getTitle() %></div>
                                <div class="notif-msg"><%= n.getMessage() %></div>
                                <div class="notif-time">
                                    <%= n.getCreatedAt() != null
                                        ? n.getCreatedAt().toString().substring(0,16) : "" %>
                                </div>
                            </div>
                            <% if (!n.isRead()) { %>
                            <a href="<%= request.getContextPath() %>/notifications?action=markRead&id=<%= n.getId() %>"
                               class="notif-read-btn" title="Mark as read">✓</a>
                            <% } %>
                        </div>
                        <% } } %>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    </header>

    

    <!-- ===== HERO SLIDESHOW ===== -->
    <div class="hero">
        <div class="slide active" id="s0">
            <div class="slide-bg" style="background-image:url('https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=1200&q=80')"></div>
            <div class="slide-cnt">
                <div class="s-tag">We Come to Serve You</div>
                <div class="s-title">Seamless Car Repairs<br>with <span>Pickup & Delivery</span></div>
                <div class="s-desc"></div>
                <div class="s-btns">
                    <button class="btn-o" onclick="<%= bookingOnclick %>">Book Now →</button>
                    <button class="btn-g" onclick="window.location.href='services.jsp'">Services</button>
                </div>
            </div>
        </div>
        <div class="slide" id="s1">
            <div class="slide-bg" style="background-image:url('https://images.unsplash.com/photo-1487754180451-c456f719a1fc?w=1200&q=80')"></div>
            <div class="slide-cnt">
                <div class="s-tag">Expert Auto Care</div>
                <div class="s-title">Trusted Workshop<br><span>Since 1991</span></div>
                <div class="s-desc"></div>
                <div class="s-btns">
                    <button class="btn-o" onclick="window.location.href='services.jsp'">Our Services →</button>
                </div>
            </div>
        </div>
        <div class="slide" id="s2">
            <div class="slide-bg" style="background-image:url('https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=1200&q=80')"></div>
            <div class="slide-cnt">
                <div class="s-tag">One-Stop Solution</div>
                <div class="s-title">All Your Car Needs<br><span>Under One Roof</span></div>
                <div class="s-desc">From routine services to major repairs — we handle it all for you.</div>
                <div class="s-btns">
                    <button class="btn-o" onclick="<%= bookingOnclick %>">Book A Service →</button>
                </div>
            </div>
        </div>
        <div class="h-arrows">
            <div class="slide-arr" onclick="mv(-1)">&#8249;</div>
            <div class="slide-arr" onclick="mv(1)">&#8250;</div>
        </div>
        <div class="h-dots">
            <div class="dot active" onclick="go(0)"></div>
            <div class="dot" onclick="go(1)"></div>
            <div class="dot" onclick="go(2)"></div>
        </div>
    </div>

    <!-- TICKER -->
    <div class="ticker">
        <div class="tk-inner">
            <span class="tk-item">🔧 Full Car Service</span><span class="tk-item">•</span>
            <span class="tk-item">🚗 Pickup & Delivery</span><span class="tk-item">•</span>
            <span class="tk-item">❄️ A/C Services</span><span class="tk-item">•</span>
            <span class="tk-item">🔩 Brake & Suspension</span><span class="tk-item">•</span>
            <span class="tk-item">🛞 Tyre Replacement</span><span class="tk-item">•</span>
            <span class="tk-item">🔋 Battery Check</span><span class="tk-item">•</span>
            <span class="tk-item">🔧 Full Car Service</span><span class="tk-item">•</span>
            <span class="tk-item">🚗 Pickup & Delivery</span><span class="tk-item">•</span>
            <span class="tk-item">❄️ A/C Services</span><span class="tk-item">•</span>
            <span class="tk-item">🔩 Brake & Suspension</span><span class="tk-item">•</span>
            <span class="tk-item">🛞 Tyre Replacement</span><span class="tk-item">•</span>
            <span class="tk-item">🔋 Battery Check</span><span class="tk-item">•</span>
        </div>
    </div>

    <!-- STATS BAR -->
    <div class="stats-bar">
        <div><div class="st-num">792+</div><div class="st-lbl">Cars Serviced This Year</div></div>
        <div><div class="st-num">629</div><div class="st-lbl">Satisfied Customers</div></div>
        <div><div class="st-num">30+</div><div class="st-lbl">Years Experience</div></div>
        <div><div class="st-num">5★</div><div class="st-lbl">Customer Rating</div></div>
    </div>
    
    <!-- ===== MY RECENT BOOKINGS (Customer only) ===== -->
    <% if (isCustomer && !recentBookings.isEmpty()) { %>
    <div style="background:#fff; padding:36px 28px;">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
            <div>
                <div style="font-size:11px; font-style:italic; color:#e85d04; font-weight:700; margin-bottom:4px;">Your Activity</div>
                <h2 style="font-size:22px; font-weight:800; color:#111; margin:0;">My Recent Bookings</h2>
            </div>
            <a href="<%=ctxPath%>/BookingServlet?action=add" 
               style="background:#e85d04; color:#fff; padding:8px 18px; border-radius:4px; font-size:12px; font-weight:700; text-decoration:none;">
                + New Booking
            </a>
        </div>

        <% for (Map<String,String> b : recentBookings) {
            String st = b.get("status");
            String stColor = "Confirmed".equals(st) ? "#2e7d32" :
                             "Completed".equals(st) ? "#1565c0" :
                             "Cancelled".equals(st) ? "#c62828" : "#e65100";
            String stBg    = "Confirmed".equals(st) ? "#e8f5e9" :
                             "Completed".equals(st) ? "#e3f2fd" :
                             "Cancelled".equals(st) ? "#ffebee" : "#fff3e0";
        %>
        <div style="display:flex; align-items:center; justify-content:space-between;
                    padding:14px 18px; margin-bottom:10px; border-radius:10px;
                    border:1px solid #eee; background:#fafafa;">
            <div>
                <div style="font-size:13px; font-weight:700; color:#111;"><%=b.get("id")%></div>
                <div style="font-size:12px; color:#888; margin-top:3px;"><%=b.get("services")%></div>
            </div>
            <div style="text-align:right;">
                <div style="font-size:11px; color:#aaa; margin-bottom:6px;"><%=b.get("date").substring(0,16)%></div>
                <span style="font-size:11px; font-weight:700; padding:4px 12px; border-radius:20px;
                             color:<%=stColor%>; background:<%=stBg%>;">
                    <%=st%>
                </span>
            </div>
        </div>
        <% } %>
    </div>
    <% } %>

    <!-- TESTIMONIALS -->
    <div class="testi">
        <div class="sec-hd">
            <div class="itag">What People Say</div>
            <h2>Our Testimonials</h2>
        </div>
        <div class="testi-grid">
            <div class="tc">
                <div class="tc-q">"</div>
                <div class="tc-txt">AutoCare made my car maintenance effortless! The pickup and delivery service was a game-changer, and the quality of work exceeded my expectations. Highly recommend!</div>
                <div class="tc-auth"><div class="tc-name">Daniel Nazir</div><div class="tc-svc">Major Service</div></div>
            </div>
            <div class="tc">
                <div class="tc-q">"</div>
                <div class="tc-txt">I was impressed by the professionalism of the technicians. They swiftly handled my car repairs and kept me informed throughout. Comforting to know my car is in good hands!</div>
                <div class="tc-auth"><div class="tc-name">Siti Alliyah</div><div class="tc-svc">A/C Service</div></div>
            </div>
        </div>
    </div>

    <!-- CONTACT / GET IN TOUCH -->
   
    <div class="contact">
    <!-- About -->
    

  

    <!-- Contact Details -->
    <div class="ct-col">
        <h2>Contact Details</h2>
        <div class="ct-items">
            <div class="ct-row">
                
                <div><div class="ct-lbl">Address</div><div class="ct-val">2, Jalan Bandar Baru<br>Kuala Nerus,Terengganu</div></div>
            </div>
            <div class="ct-row">
                
                <div><div class="ct-lbl">Phone</div><div class="ct-val">(+6) 06-233 0543<br>(+6) 013-713 7100</div></div>
            </div>
            <div class="ct-row">
               
                <div><div class="ct-lbl">Email</div><div class="ct-val">customercare@autocare.com.my<br><span style="font-size:10px;color:#555">We reply within 1 day</span></div></div>
            </div>
        </div>
    </div>

    <!-- Opening Hours -->
    <div class="ct-col">
        <h2>Opening Hours</h2>
        <div class="h-list">
            <div class="h-row"><span class="h-day">Monday</span><span class="h-t">08:00–17:00</span></div>
            <div class="h-row"><span class="h-day">Tuesday</span><span class="h-t">08:00–17:00</span></div>
            <div class="h-row"><span class="h-day">Wednesday</span><span class="h-t">08:00–17:00</span></div>
            <div class="h-row"><span class="h-day">Thursday</span><span class="h-t">08:00–17:00</span></div>
            <div class="h-row"><span class="h-day">Friday</span><span class="h-t">08:00–17:00</span></div>
            <div class="h-row"><span class="h-day">Saturday</span><span class="h-t">08:00–12:00</span></div>
            <div class="h-row"><span class="h-day">Sunday</span><span class="h-t closed">We're Closed</span></div>
        </div>
    </div>
</div>
    

    <!-- NEW FOOTER -->
    <div class="ft">
        <div class="ft-brand">Auto<span>Care</span></div>
        <div class="ft-copy">© 2025 AutoCare Workshop Management. All rights reserved.</div>
        <div class="ft-links">
            <a href="#">Privacy</a>
            <a href="#">Terms</a>
            <a href="#">Support</a>
        </div>
    </div>

</main>
<div class="overlay" id="loginPopup">
    <div class="modal" style="max-width:380px">
        <div class="del-body">
            <div class="del-icon">🔒</div>
            <div class="del-title">Login Required</div>
            <div class="del-sub">Please login first to make a booking.</div>
        </div>
        <div class="modal-foot" style="justify-content:center;padding-top:0">
            <a href="<%=ctxPath%>/login.jsp" class="btn-del-confirm" style="background:var(--gold);text-decoration:none;">Login</a>
            <button class="btn-cancel" onclick="closeLoginPopup()">Cancel</button>
        </div>
    </div>
</div>
<script>
    // Date display
    document.getElementById('dateDisplay').textContent = new Date().toLocaleDateString('en-MY', {
        weekday: 'short', day: 'numeric', month: 'long', year: 'numeric'
    });

    // Slideshow
    let c = 0, total = 3, timer;
    function go(n) {
        document.getElementById('s' + c).classList.remove('active');
        document.querySelectorAll('.dot')[c].classList.remove('active');
        c = n;
        document.getElementById('s' + c).classList.add('active');
        document.querySelectorAll('.dot')[c].classList.add('active');
        reset();
    }
    function mv(d) { go((c + d + total) % total); }
    function reset() { clearInterval(timer); timer = setInterval(() => mv(1), 4500); }
    reset();

    // Login popup
    function showLoginPopup() {
        document.getElementById('loginPopup').classList.add('open');
    }
    function closeLoginPopup() {
        document.getElementById('loginPopup').classList.remove('open');
    }
    document.getElementById('loginPopup').addEventListener('click', function(e) {
        if (e.target === this) closeLoginPopup();
    });

    // Notification bell
    function toggleNotif() {
        document.getElementById('notifDropdown').classList.toggle('open');
    }
    document.addEventListener('click', function(e) {
        var wrap = document.getElementById('notifWrap');
        if (wrap && !wrap.contains(e.target)) {
            var dd = document.getElementById('notifDropdown');
            if (dd) dd.classList.remove('open');
        }
    });
</script>

</body>
</html>
