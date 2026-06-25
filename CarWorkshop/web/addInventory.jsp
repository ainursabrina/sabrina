<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
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

if (!isAdmin && !isMechanic) {
    response.sendRedirect(request.getContextPath() + "/homepage.jsp");
    return;
}

String avatar    = username.substring(0, 1).toUpperCase();
String roleLabel = isAdmin ? "Administrator" : isMechanic ? "Mechanic" : isCustomer ? "Customer" : "Guest";
String bookingLink = (isAdmin || isMechanic)
    ? request.getContextPath() + "/BookingServlet?action=adminList"
    : request.getContextPath() + "/BookingServlet?action=add";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${empty inventory ? 'Add Part' : 'Edit Part'} — AutoCare WMS</title>
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
        <div class="page-title">
            <c:choose>
                <c:when test="${empty inventory}">Add Part</c:when>
                <c:otherwise>Edit Part</c:otherwise>
            </c:choose>
            <span>Inventory</span>
        </div>
        <div class="top-right">
            <div class="date-badge" id="dateDisplay"></div>
            <a href="<%= request.getContextPath() %>/InventoryServlet" class="back-btn">← Back to Inventory</a>
        </div>
    </div>

    <div class="content">

        <!-- HERO -->
        <div class="hero">
            <div class="hero-icon">📦</div>
            <h1>
                <c:choose>
                    <c:when test="${empty inventory}">New <span>Part</span></c:when>
                    <c:otherwise>Edit <span>${inventory.partName}</span></c:otherwise>
                </c:choose>
            </h1>
            <p>
                <c:choose>
                    <c:when test="${empty inventory}">Add a new spare part to the inventory.</c:when>
                    <c:otherwise>Update the details for this part.</c:otherwise>
                </c:choose>
            </p>
        </div>

        <!-- FORM CARD -->
        <div class="form-card inv-form-wrap">
            <div class="form-title">
                <div class="form-icon">🔩</div>
                <h2>Part Details</h2>
            </div>

            <form action="<%= request.getContextPath() %>/InventoryServlet" method="post">

                <c:if test="${not empty inventory}">
                    <input type="hidden" name="partID" value="${inventory.partID}">
                    <input type="hidden" name="action" value="update">
                </c:if>

                <div class="input-group">
                    <label for="partName">Part Name</label>
                    <input type="text" id="partName" name="partName"
                           placeholder="e.g. Brake Pad Set"
                           value="${inventory.partName}" required>
                </div>

                <div class="input-group">
                    <label for="description">Description</label>
                    <textarea id="description" name="description" rows="3"
                              placeholder="Brief description of this part...">${inventory.description}</textarea>
                </div>

                <div class="grid-2">
                    <div class="input-group">
                        <label for="stockQty">Stock Quantity</label>
                        <input type="number" id="stockQty" name="stockQty"
                               placeholder="0" min="0"
                               value="${inventory.stockQty}" required>
                    </div>
                    <div class="input-group">
                        <label for="unitPrice">Unit Price (RM)</label>
                        <input type="number" id="unitPrice" name="unitPrice"
                               placeholder="0.00" min="0" step="0.01"
                               value="${inventory.unitPrice}" required>
                    </div>
                </div>

                <!-- Stock Status Preview — guna class dari inventory.css -->
                <div id="stockPreview" class="inv-stock-preview"></div>

                <div class="btn-row">
                    <a href="<%= request.getContextPath() %>/InventoryServlet" class="btn-back">Cancel</a>
                    <button type="submit" class="btn-next">
                        <c:choose>
                            <c:when test="${empty inventory}">✅ Save Part</c:when>
                            <c:otherwise>✅ Update Part</c:otherwise>
                        </c:choose>
                    </button>
                </div>

            </form>
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

const qtyInput = document.getElementById('stockQty');
const preview  = document.getElementById('stockPreview');

function updatePreview() {
    const qty = parseInt(qtyInput.value) || 0;
    preview.style.display = 'block';
    preview.className = 'inv-stock-preview'; // reset
    if (qty === 0) {
        preview.classList.add('out');
        preview.textContent = '🔴 Status: Out of Stock';
    } else if (qty < 10) {
        preview.classList.add('low');
        preview.textContent = '🟡 Status: Low Stock (less than 10 units)';
    } else {
        preview.classList.add('ok');
        preview.textContent = '🟢 Status: In Stock';
    }
}

qtyInput.addEventListener('input', updatePreview);
if (qtyInput.value) updatePreview();
</script>

</body>
</html>
