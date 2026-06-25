<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

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

// Redirect non-admin away
if (!isAdmin && !isMechanic) {
    response.sendRedirect(request.getContextPath() + "/homepage.jsp");
    return;
}

String avatar    = username.substring(0, 1).toUpperCase();
String roleLabel = isAdmin ? "Administrator" : isMechanic ? "Mechanic" : isCustomer ? "Customer" : "Guest";

String bookingLink = (isAdmin || isMechanic)
    ? request.getContextPath() + "/BookingServlet?action=adminList"
    : request.getContextPath() + "/BookingServlet?action=add";
// Redirect ke servlet kalau inventories null (direct access)
if (request.getAttribute("inventories") == null) {
    response.sendRedirect(request.getContextPath() + "/InventoryServlet");
    return;
}

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inventory — AutoCare WMS</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/inventory.css">
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

        <a href="homepage.jsp" class="nav-item">
            <div class="nav-dot" style="background:#ef5350"></div>
            <span>Dashboard</span>
        </a>
        <a href="services.jsp" class="nav-item">
            <div class="nav-dot" style="background:#ffa726"></div>
            <span>Services</span>
        </a>
        <a href="<%= bookingLink %>" class="nav-item">
            <div class="nav-dot" style="background:#ff8a65"></div>
            <span>Booking</span>
        </a>

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

        <a href="<%= request.getContextPath() %>/InventoryServlet" class="nav-item active">
            <div class="nav-dot" style="background:#ab47bc"></div>
            <span>Inventory</span>
        </a>
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
<div class="main">

    <div class="topbar">
        <div class="page-title">Inventory <span>Parts &amp; Stock</span></div>
        <div class="top-right">
            <div class="date-badge" id="dateDisplay"></div>
            
            <a href="<%= request.getContextPath() %>/InventoryServlet?action=add" 
           class="btn btn-primary">+ Add Part</a>
        </div>
    </div>

    <div class="content">

        <c:if test="${not empty param.success}">
            <div class="alert-success">✅ Part saved successfully.</div>
        </c:if>

        <!-- STATS -->
        <c:set var="lowCount" value="0"/>
        <c:set var="outCount" value="0"/>
        <c:set var="inCount"  value="0"/>
        <c:forEach var="item" items="${inventories}">
            <c:choose>
                <c:when test="${item.stockQty == 0}"><c:set var="outCount" value="${outCount + 1}"/></c:when>
                <c:when test="${item.stockQty < 10}"><c:set var="lowCount" value="${lowCount + 1}"/></c:when>
                <c:otherwise><c:set var="inCount" value="${inCount + 1}"/></c:otherwise>
            </c:choose>
        </c:forEach>

        <div class="inv-stats">
            <div class="inv-stat">
                <div class="inv-stat-label">Total Parts</div>
                <div class="inv-stat-val">${fn:length(inventories)}</div>
            </div>
            <div class="inv-stat" style="--stat-color:var(--green);">
                <div class="inv-stat-label">In Stock</div>
                <div class="inv-stat-val">${inCount}</div>
            </div>
            <div class="inv-stat" style="--stat-color:#7A5800;">
                <div class="inv-stat-label">Low Stock</div>
                <div class="inv-stat-val">${lowCount}</div>
            </div>
            <div class="inv-stat" style="--stat-color:var(--red);">
                <div class="inv-stat-label">Out of Stock</div>
                <div class="inv-stat-val">${outCount}</div>
            </div>
        </div>

        <!-- TABLE -->
        <div class="inv-table-section">
            <div class="inv-table-topbar">
                <h3>📋 Parts List</h3>
                <div style="display:flex;gap:10px;align-items:center;">
                    <input type="text" id="searchInput" class="inv-search"
                           placeholder="Search part name..." oninput="filterTable()">
                    <select class="inv-filter" onchange="filterByStock(this.value)">
                        <option value="all">All Stock</option>
                        <option value="in">In Stock</option>
                        <option value="low">Low Stock</option>
                        <option value="out">Out of Stock</option>
                    </select>
                </div>
            </div>

            <c:choose>
                <c:when test="${empty inventories}">
                    <div class="inv-empty">
                        <div class="inv-empty-icon">📦</div>
                        <div class="inv-empty-title">No parts yet</div>
                        <p style="margin-bottom:20px;">Add your first part to get started.</p>
                        <a href="<%= request.getContextPath() %>/InventoryServlet?action=add"
                           class="btn btn-primary">+ Add First Part</a>
                    </div>
                </c:when>
                <c:otherwise>
                    <table id="inventoryTable">
                        <thead>
                            <tr>
                                <th>Part ID</th>
                                <th>Part Name</th>
                                <th>Description</th>
                                <th>Stock Qty</th>
                                <th>Unit Price</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="item" items="${inventories}">
                            <tr data-qty="${item.stockQty}">
                                <td><span class="inv-part-id">#${item.partID}</span></td>
                                <td><span class="inv-part-name">${item.partName}</span></td>
                                <td><span class="inv-desc">${item.description}</span></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${item.stockQty == 0}"><span class="inv-qty-low">${item.stockQty}</span></c:when>
                                        <c:when test="${item.stockQty < 10}"><span class="inv-qty-warn">${item.stockQty}</span></c:when>
                                        <c:otherwise><span class="inv-qty-ok">${item.stockQty}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td><span class="inv-price">RM <fmt:formatNumber value="${item.unitPrice}" pattern="#,##0.00"/></span></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${item.stockQty == 0}"><span class="inv-badge inv-badge-out">Out of Stock</span></c:when>
                                        <c:when test="${item.stockQty < 10}"><span class="inv-badge inv-badge-low">Low Stock</span></c:when>
                                        <c:otherwise><span class="inv-badge inv-badge-in">In Stock</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="inv-actions">
                                        <a href="<%= request.getContextPath() %>/InventoryServlet?action=edit&id=${item.partID}"
                                           class="inv-btn-edit">Edit</a>
                                        <a href="<%= request.getContextPath() %>/InventoryServlet?action=delete&id=${item.partID}"
                                           class="inv-btn-delete"
                                           onclick="return confirm('Delete ${item.partName}?')">Delete</a>
                                    </div>
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
function filterTable() {
    const q = document.getElementById('searchInput').value.toLowerCase();
    document.querySelectorAll('#inventoryTable tbody tr').forEach(row => {
        row.style.display = row.cells[1].textContent.toLowerCase().includes(q) ? '' : 'none';
    });
}
function filterByStock(val) {
    document.querySelectorAll('#inventoryTable tbody tr').forEach(row => {
        const qty = parseInt(row.dataset.qty);
        let show = true;
        if      (val === 'out') show = qty === 0;
        else if (val === 'low') show = qty > 0 && qty < 10;
        else if (val === 'in')  show = qty >= 10;
        row.style.display = show ? '' : 'none';
    });
}
</script>
</body>
</html>
