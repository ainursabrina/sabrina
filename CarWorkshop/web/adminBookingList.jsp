<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, util.DBConnection, java.util.*" %>
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
    <title>Manage Booking — AutoCare</title>
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
            <div class="nav-dot" style="background:#ef5350"></div>
            <span>Dashboard</span>
        </a>

        <a class="nav-item" href="services.jsp">
            <div class="nav-dot" style="background:#ffa726"></div>
            <span>Services</span>
        </a>

        <c:choose>
            <c:when test="${sessionScope.role == 'admin' || sessionScope.role == 'mechanic'}">
                <a href="${pageContext.request.contextPath}/BookingServlet?action=adminList" class="nav-item active">
                    <div class="nav-dot" style="background:#ff8a65"></div>
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
        <% } else { %>
        <div class="nav-item locked">
            <div class="nav-dot" style="background:#42a5f5"></div>
            <span>Work Order</span>
        </div>
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

        <% if (isAdmin) { %>
        <a href="<%=ctxPath%>/ReportServlet" class="nav-item">
            <div class="nav-dot" style="background:var(--muted)"></div>Reports
        </a>
        <% } %>

        <% if (isAdmin || isMechanic) { %>
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
        <div class="page-title">Booking</div>
        <div class="top-right">
            <div class="date-badge" id="dateDisplay"></div>
        </div>
    </header>

    <div class="content">
        <div class="panel">
            <div class="panel-head">
                <span>Booking List</span>
                <span style="font-size:13px;color:var(--muted);font-family:'DM Sans',sans-serif;font-weight:400;">
                    All customer booking
                </span>
            </div>
            
            <div style="padding:16px 20px; border-bottom:1px solid var(--border); display:flex; gap:12px; flex-wrap:wrap; align-items:center;">
    <input type="text" id="filterName" placeholder="🔍 Search customer / booking ID..."
        style="padding:8px 14px; border:1px solid var(--border); border-radius:8px; font-size:13px; width:240px; outline:none;">
    
    <select id="filterStatus" style="padding:8px 14px; border:1px solid var(--border); border-radius:8px; font-size:13px; outline:none;">
        <option value="">All Status</option>
        <option value="Pending">Pending</option>
        <option value="Confirmed">Confirmed</option>
        <option value="Completed">Completed</option>
        <option value="Cancelled">Cancelled</option>
    </select>

    <select id="sortBy" style="padding:8px 14px; border:1px solid var(--border); border-radius:8px; font-size:13px; outline:none;">
        <option value="date-desc">Date ↓ Newest</option>
        <option value="date-asc">Date ↑ Oldest</option>
        <option value="name-asc">Customer A–Z</option>
        <option value="name-desc">Customer Z–A</option>
        <option value="status">Status</option>
    </select>

    <span id="filterCount" style="font-size:12px; color:var(--muted); margin-left:auto;"></span>
</div>

            <div class="booking-list" style="padding:20px;" id="bookingList">
                <c:forEach var="b" items="${bookings}">
                    <div class="booking-card"
                         data-name="${fn:toLowerCase(b.customerName)}"
                         data-id="${fn:toLowerCase(b.bookingID)}"
                         data-status="${b.bookingStatus}"
                         data-date="${b.bookingDate}">

                        <div class="booking-left">
                            <div class="booking-id">${b.bookingID}</div>
                            <div>
                                <div class="customer-name">${b.customerName}</div>
                                <div class="car-info">${b.carPlate}</div>
                            </div>
                        </div>

                        <div class="booking-service">${b.services}</div>

                        <div class="booking-right">
                            <div class="booking-date">${b.bookingDate}</div>
                            <div class="booking-status
                                ${b.bookingStatus eq 'Pending'   ? 'status-pending'   : ''}
                                ${b.bookingStatus eq 'Confirmed' ? 'status-confirmed' : ''}
                                ${b.bookingStatus eq 'Completed' ? 'status-completed' : ''}
                                ${b.bookingStatus eq 'Cancelled' ? 'status-cancelled' : ''}">
                                ${b.bookingStatus}
                            </div>
                        </div>
                    </div>
                </c:forEach>

                <c:if test="${empty bookings}">
                    <div class="empty-state">No bookings found.</div>
                </c:if>
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
    
    document.getElementById('dateDisplay').textContent = new Date().toLocaleDateString('en-MY', {
        weekday: 'short', day: 'numeric', month: 'long', year: 'numeric'
    });

    function applyFilter() {
        const search = document.getElementById('filterName').value.toLowerCase();
        const status = document.getElementById('filterStatus').value;
        const sort   = document.getElementById('sortBy').value;

        const list  = document.getElementById('bookingList');
        const cards = Array.from(list.querySelectorAll('.booking-card'));

        // Filter
        let visible = cards.filter(c => {
            const matchSearch = c.dataset.name.includes(search) || c.dataset.id.includes(search);
            const matchStatus = !status || c.dataset.status === status;
            return matchSearch && matchStatus;
        });

        // Hide all
        cards.forEach(c => c.style.display = 'none');

        // Sort
        const statusOrder = { Pending:1, Confirmed:2, Completed:3, Cancelled:4 };
        visible.sort((a, b) => {
            if (sort === 'date-desc') return new Date(b.dataset.date) - new Date(a.dataset.date);
            if (sort === 'date-asc')  return new Date(a.dataset.date) - new Date(b.dataset.date);
            if (sort === 'name-asc')  return a.dataset.name.localeCompare(b.dataset.name);
            if (sort === 'name-desc') return b.dataset.name.localeCompare(a.dataset.name);
            if (sort === 'status')    return (statusOrder[a.dataset.status]||9) - (statusOrder[b.dataset.status]||9);
            return 0;
        });

        // Show sorted
        visible.forEach(c => {
            c.style.display = '';
            list.appendChild(c);
        });

        document.getElementById('filterCount').textContent = visible.length + ' booking(s) shown';
    }

    document.getElementById('filterName').addEventListener('input', applyFilter);
    document.getElementById('filterStatus').addEventListener('change', applyFilter);
    document.getElementById('sortBy').addEventListener('change', applyFilter);

    // Init count
    applyFilter();
</script>

</body>
</html>
