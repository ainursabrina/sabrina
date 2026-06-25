<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
String username = (String) session.getAttribute("username");
String userid   = (String) session.getAttribute("userid");
String role     = (String) session.getAttribute("role");

if (username == null || username.trim().isEmpty()) { username = "Guest"; }
if (role == null) { role = "guest"; }
role = role.toLowerCase();

boolean isAdmin    = "admin".equals(role);
boolean isMechanic = "mechanic".equals(role);
boolean isCustomer = "customer".equals(role);

String avatar    = username.substring(0, 1).toUpperCase();
String ctxPath   = request.getContextPath();
String msgSuccess = request.getParameter("success");
String msgError   = request.getParameter("error");
String roleLabel = isAdmin ? "Administrator" : isMechanic ? "Mechanic" : isCustomer ? "Customer" : "Guest";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Settings — AutoCare WMS</title>
    <link rel="stylesheet" href="<%=ctxPath%>/css/main.css">
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
        <a href="<%=ctxPath%>/homepage.jsp" class="nav-item">
            <div class="nav-dot" style="background:#ef5350"></div><span>Dashboard</span>
        </a>
        <a href="<%=ctxPath%>/services.jsp" class="nav-item">
            <div class="nav-dot" style="background:#ffa726"></div><span>Services</span>
        </a>
        <a href="<%=ctxPath%>/BookingServlet?action=adminList" class="nav-item">
            <div class="nav-dot" style="background:#ff8a65"></div><span>Booking</span>
        </a>
        <% if (isAdmin || isMechanic) { %>
        <a href="<%=ctxPath%>/WorkOrderServlet?action=list" class="nav-item">
            <div class="nav-dot" style="background:#42a5f5"></div><span>Work Order</span>
        </a>
        <% } %>
        <% if (isAdmin || isCustomer) { %>
        <a href="<%=ctxPath%>/payment?tab=invoices" class="nav-item">
            <div class="nav-dot" style="background:#66bb6a"></div><span>Payment</span>
        </a>
        <% } %>
        <% if (isAdmin) { %>
        <a href="<%=ctxPath%>/InventoryServlet" class="nav-item">
            <div class="nav-dot" style="background:#ab47bc"></div><span>Inventory</span>
        </a>
        <% } %>
        <% if (isAdmin) { %>
        <a href="<%=ctxPath%>/ReportServlet" class="nav-item">
            <div class="nav-dot" style="background:var(--muted)"></div><span>Reports</span>
        </a>
        <% } %>
        <a href="<%=ctxPath%>/SettingsServlet" class="nav-item active">
            <div class="nav-dot" style="background:var(--muted)"></div><span>Settings</span>
        </a>
    </nav>
    <div class="sidebar-footer">
        <div class="user-box">
            <div class="avatar"><%=avatar%></div>
            <div class="user-info">
                <div class="user-name"><%=username%></div>
                <div class="user-role"><%=roleLabel%></div>
            </div>
            <a href="<%=ctxPath%>/LogoutServlet" class="logout-btn" title="Log Out">⏻</a>
        </div>
    </div>
</aside>

<div class="main">
    <div class="topbar">
        <div class="page-title">Settings <span>Account</span></div>
        <div class="top-right">
            <div class="date-badge" id="dateDisplay"></div>
        </div>
    </div>

    <div class="content">

        <!-- ALERTS -->
        <% if ("1".equals(msgSuccess)) { %>
        <div class="alert-success">✅ Password berjaya dikemaskini!</div>
        <% } else if ("mismatch".equals(msgError)) { %>
        <div class="alert-success" style="background:#FDEAEA;border-color:#F5A3A3;color:#C62828;">
            ❌ Password baru tidak sepadan. Cuba semula.
        </div>
        <% } else if ("wrongpass".equals(msgError)) { %>
        <div class="alert-success" style="background:#FDEAEA;border-color:#F5A3A3;color:#C62828;">
            ❌ Password semasa tidak betul.
        </div>
        <% } else if ("tooshort".equals(msgError)) { %>
        <div class="alert-success" style="background:#FDEAEA;border-color:#F5A3A3;color:#C62828;">
            ❌ Password baru mesti sekurang-kurangnya 6 aksara.
        </div>
        <% } %>

        <!-- PROFILE CARD -->
        <div class="hero">
            <div class="hero-icon">⚙️</div>
            <h1>Manage <span> Your Profile</span></h1>
            <p>Manage your account and system preferences.</p>
        </div>

        <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;max-width:900px;">

            <!-- PROFILE INFO -->
            <div class="form-card">
                <div class="form-title">
                    <div class="form-icon">👤</div>
                    <h2>Profile Info</h2>
                </div>
                <div class="input-group">
                    <label>Username</label>
                    <input type="text" value="<%=username%>" disabled
                           style="background:var(--surface2);color:var(--muted);cursor:not-allowed;">
                </div>
                <div class="input-group">
                    <label>Role</label>
                    <input type="text" value="<%=roleLabel%>" disabled
                           style="background:var(--surface2);color:var(--muted);cursor:not-allowed;">
                </div>
                <div class="input-group" style="margin-bottom:0;">
                    <label>User ID</label>
                    <input type="text" value="<%=userid != null ? userid : "-"%>" disabled
                           style="background:var(--surface2);color:var(--muted);cursor:not-allowed;">
                </div>
            </div>

            <!-- CHANGE PASSWORD -->
            <div class="form-card">
                <div class="form-title">
                    <div class="form-icon">🔑</div>
                    <h2>Change Password</h2>
                </div>
                <form action="<%=ctxPath%>/SettingsServlet" method="post">
                    <div class="input-group">
                        <label for="currentPassword">Current Password</label>
                        <input type="password" id="currentPassword" name="currentPassword"
                               placeholder="Enter current password" required>
                    </div>
                    <div class="input-group">
                        <label for="newPassword">New Password</label>
                        <input type="password" id="newPassword" name="newPassword"
                               placeholder="Min 6 characters" required minlength="6">
                    </div>
                    <div class="input-group">
                        <label for="confirmPassword">Confirm New Password</label>
                        <input type="password" id="confirmPassword" name="confirmPassword"
                               placeholder="Repeat new password" required>
                    </div>
                    <div class="btn-row">
                        <button type="submit" class="btn-next">🔑 Update Password</button>
                    </div>
                </form>
            </div>

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
