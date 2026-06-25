<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

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

String avatar    = username.substring(0, 1).toUpperCase();
String roleLabel = isAdmin ? "Administrator" : isMechanic ? "Mechanic" : isCustomer ? "Customer" : "Guest";
%>

<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Booking — AutoCare</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
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
        <a class="nav-item" href="homepage.jsp">
            <div class="nav-dot" style="background:var(--accent)"></div>
            <span>Dashboard</span>
        </a>
        
        <a class="nav-item" href="services.jsp">
            <div class="nav-dot" style="background:#ffa726"></div>
            <span>Services</span>
        </a>

        <c:choose>
            <c:when test="${sessionScope.role == 'admin' || sessionScope.role == 'mechanic'}">
                <a href="${pageContext.request.contextPath}/BookingServlet?action=adminList" class="nav-item active">
                    <div class="nav-dot" style="background:var(--accent)"></div>
                    <span>Booking</span>
                </a>
            </c:when>
            <c:otherwise>
                <a href="${pageContext.request.contextPath}/BookingServlet?action=add" class="nav-item active">
                    <div class="nav-dot" style="background:var(--accent)"></div>
                    <span>Booking</span>
                </a>
            </c:otherwise>
        </c:choose>


        <% if (isAdmin || isMechanic) { %>
        <a class="nav-item" href="WorkOrderServlet?action=list">
            <div class="nav-dot" style="background:#42a5f5"></div>
            <span>Work Order</span>
        </a>
        <% } %>

        <% if (isAdmin || isCustomer) { %>
        <a class="nav-item" href="<%=ctxPath%>/payment?tab=invoices">
            <div class="nav-dot" style="background:#66bb6a"></div>
            <span>Payment</span>
        </a>
        <% } %>

        <% if (isAdmin) { %>
        <a class="nav-item" href="inventory.jsp">
            <div class="nav-dot" style="background:#ab47bc"></div>
            <span>Inventory</span>
        </a>
        <% } %>
        
        <a href="#" class="nav-item">
            <div class="nav-dot" style="background:var(--muted)"></div>
            <span>Reports</span>
        </a>
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

    <header class="topbar">
        <div class="page-title"> Booking <span style="color:var(--accent)"></span></div>
        <div class="top-right">
            <div class="date-badge" id="dateDisplay"></div>
            <a href="${pageContext.request.contextPath}/BookingServlet?action=add" class="btn btn-primary">+ New Booking</a>
        </div>
    </header>

    <div class="content">
        <div class="panel">
            <div class="panel-head">
                <span>Booking List</span>
                <span style="font-size:13px;color:var(--muted);font-family:'DM Sans',sans-serif;font-weight:400;">
                    All customer 
                </span>
            </div>

            <div class="booking-list" style="padding:20px;">
                <c:forEach var="b" items="${bookings}">
                    <div class="booking-card">

                        <div class="booking-left">
                            <div class="booking-id">${b.bookingID}</div>
                            <div>
                                <div class="customer-name">${b.customerName}</div>
                                <div class="car-info">${b.carPlate}</div>
                            </div>
                        </div>

                        <div class="booking-service">${b.serviceName}</div>

                        <div class="booking-right">
                            <div class="booking-date">${b.bookingDate}</div>
                            <div class="booking-status
                                ${b.status eq 'Pending'   ? 'status-pending'   : ''}
                                ${b.status eq 'Confirmed' ? 'status-confirmed' : ''}
                                ${b.status eq 'Completed' ? 'status-completed' : ''}">
                                ${b.status}
                            </div>
                        </div>

                    </div>
                </c:forEach>
            </div>
        </div>
    </div>

</main>

<footer class="site-footer">
    <div class="footer-brand">Auto<span>Care</span></div>
    <div class="footer-copy">© 2025 AutoCare Workshop Management. All rights reserved.</div>
    <div class="footer-links">
        <a href="#">Privacy</a>
        <a href="#">Terms</a>
        <a href="#">Support</a>
    </div>
</footer>

<script>
    document.getElementById('dateDisplay').textContent = new Date().toLocaleDateString('en-MY', {
        weekday: 'short', day: 'numeric', month: 'long', year: 'numeric'
    });
</script>

</body>
</html>
