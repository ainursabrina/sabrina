<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
String username = (String) session.getAttribute("username");
String role     = (String) session.getAttribute("role");
if (username == null || username.trim().isEmpty()) { username = "Guest"; }
if (role == null) { role = "guest"; }
role = role.toLowerCase();
boolean isAdmin    = "admin".equals(role);
boolean isMechanic = "mechanic".equals(role);
boolean isCustomer = "customer".equals(role);
if (!isAdmin) { response.sendRedirect(request.getContextPath() + "/homepage.jsp"); return; }
String avatar    = username.substring(0, 1).toUpperCase();
String roleLabel = "Administrator";
String bookingLink = request.getContextPath() + "/BookingServlet?action=adminList";
String ctxPath = request.getContextPath();

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports — AutoCare WMS</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
</head>
<body>

<aside class="sidebar">
    <div class="logo-area">
        <img src="<%= request.getContextPath() %>/img/logo.png" 
             alt="AutoCare Logo" 
             style="width:120px; margin:0 auto 8px; display:block;">
        <div class="logo-title">AutoCare</div>
        <div class="logo-sub">Workshop</div>
    </div>
    <nav class="nav-section">
        <a href="homepage.jsp" class="nav-item">
            <div class="nav-dot" style="background:#ef5350"></div><span>Dashboard</span>
        </a>
        <a href="services.jsp" class="nav-item">
            <div class="nav-dot" style="background:#ffa726"></div><span>Services</span>
        </a>
        <a href="<%= bookingLink %>" class="nav-item">
            <div class="nav-dot" style="background:#ff8a65"></div><span>Booking</span>
        </a>
        <a href="WorkOrderServlet?action=list" class="nav-item">
            <div class="nav-dot" style="background:#42a5f5"></div><span>Work Order</span>
        </a>
        <a href="<%=ctxPath%>/payment?tab=invoices" class="nav-item">
            <div class="nav-dot" style="background:#66bb6a"></div><span>Payment</span>
        </a>
        <a href="<%= request.getContextPath() %>/InventoryServlet" class="nav-item">
            <div class="nav-dot" style="background:#ab47bc"></div><span>Inventory</span>
        </a>
        <a href="<%= request.getContextPath() %>/ReportServlet" class="nav-item active">
            <div class="nav-dot" style="background:var(--muted)"></div><span>Reports</span>
        </a>
        <a href="<%= request.getContextPath() %>/SettingsServlet" class="nav-item">
            <div class="nav-dot" style="background:var(--muted)"></div><span>Settings</span>
        </a>
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

<div class="main">
    <div class="topbar">
        <div class="page-title">Reports <span>Overview</span></div>
        <div class="top-right">
            <div class="date-badge" id="dateDisplay"></div>
        </div>
    </div>

    <div class="content">

        <!-- BOOKING SUMMARY -->
        <div class="section-title">📅 Booking Summary</div>
        <div class="wo-stats">
            <div class="wstat">
                <div class="wstat-label">Total</div>
                <div class="wstat-val">${bookingSummary['Total']}</div>
            </div>
            <div class="wstat" style="--accent:#7A5800;">
                <div class="wstat-label">Pending</div>
                <div class="wstat-val" style="color:#7A5800;">${bookingSummary['Pending']}</div>
            </div>
            <div class="wstat" style="--accent:var(--blue);">
                <div class="wstat-label">Confirmed</div>
                <div class="wstat-val" style="color:var(--blue);">${bookingSummary['Confirmed']}</div>
            </div>
            <div class="wstat" style="--accent:var(--green);">
                <div class="wstat-label">Completed</div>
                <div class="wstat-val" style="color:var(--green);">${bookingSummary['Completed']}</div>
            </div>
            <div class="wstat" style="--accent:var(--red);">
                <div class="wstat-label">Cancelled</div>
                <div class="wstat-val" style="color:var(--red);">${bookingSummary['Cancelled']}</div>
            </div>
        </div>

        <!-- WORK ORDER SUMMARY -->
        <div class="section-title">🔨 Work Order Summary</div>
        <div class="wo-stats">
            <div class="wstat">
                <div class="wstat-label">Total</div>
                <div class="wstat-val">${workOrderSummary['Total']}</div>
            </div>
            <div class="wstat" style="--accent:#7A5800;">
                <div class="wstat-label">Pending</div>
                <div class="wstat-val" style="color:#7A5800;">${workOrderSummary['Pending']}</div>
            </div>
            <div class="wstat" style="--accent:var(--blue);">
                <div class="wstat-label">In Progress</div>
                <div class="wstat-val" style="color:var(--blue);">${workOrderSummary['In Progress']}</div>
            </div>
            <div class="wstat" style="--accent:var(--green);">
                <div class="wstat-label">Completed</div>
                <div class="wstat-val" style="color:var(--green);">${workOrderSummary['Completed']}</div>
            </div>
            <div class="wstat" style="--accent:var(--red);">
                <div class="wstat-label">Cancelled</div>
                <div class="wstat-val" style="color:var(--red);">${workOrderSummary['Cancelled']}</div>
            </div>
        </div>

        <!-- USER SUMMARY -->
        <div class="section-title">👥 User Summary</div>
        <div class="wo-stats">
            <c:forEach var="entry" items="${userSummary}">
                <div class="wstat">
                    <div class="wstat-label">${entry.key}</div>
                    <div class="wstat-val">${entry.value}</div>
                </div>
            </c:forEach>
        </div>

        <!-- LOW STOCK TABLE -->
        <div class="section-title">📦 Low Stock Parts <span>— qty below 10</span></div>
        <div class="wo-table-section">
            <c:choose>
                <c:when test="${empty lowStockParts}">
                    <div class="wo-empty">
                        <div class="icon">✅</div>
                        <div style="font-size:16px;font-weight:600;color:var(--green);">All parts have sufficient stock</div>
                    </div>
                </c:when>
                <c:otherwise>
                    <table>
                        <thead>
                            <tr>
                                <th>Part ID</th>
                                <th>Part Name</th>
                                <th>Stock Qty</th>
                                <th>Unit Price</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="part" items="${lowStockParts}">
                                <tr>
                                    <td><span class="wo-id">#${part.partID}</span></td>
                                    <td style="font-weight:600;">${part.partName}</td>
                                    <td style="font-weight:700; color:${part.stockQty == '0' ? 'var(--red)' : '#7A5800'}">
                                        ${part.stockQty}
                                    </td>
                                    <td style="color:var(--accent);font-weight:600;">RM ${part.unitPrice}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${part.stockQty == '0'}">
                                                <span class="status-badge s-cancelled">Out of Stock</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-badge s-pending">Low Stock</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>

    </div>
</div>

<footer class="site-footer">
    <div class="footer-brand">Auto<span>Care</span></div>
    <div class="footer-copy">© 2025 AutoCare Workshop Management. All rights reserved.</div>
    <div class="footer-links">
        <a href="#">Privacy</a><a href="#">Terms</a><a href="#">Support</a>
    </div>
</footer>

<script>
document.getElementById('dateDisplay').textContent = new Date().toLocaleDateString('en-MY', {
    weekday: 'short', day: 'numeric', month: 'long', year: 'numeric'
});
</script>
</body>
</html>
