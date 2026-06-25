<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
String username = (String) session.getAttribute("username");
String role     = (String) session.getAttribute("role");

if(username == null || username.trim().isEmpty()){ username = "Guest"; }
if(role == null){ role = "guest"; }
role = role.toLowerCase();

boolean isAdmin    = "admin".equals(role);
boolean isMechanic = "mechanic".equals(role);
boolean isCustomer = "customer".equals(role);
boolean isGuest    = "guest".equals(role);

String avatar    = username.substring(0,1).toUpperCase();
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
<title>AutoCare</title>
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

    <div class="nav-section">
        <div class="nav-label">Main</div>
        <a href="<%= request.getContextPath() %>/homepage.jsp" class="nav-item">
            <div class="nav-dot" style="background:var(--accent)"></div>
            <span>Dashboard</span>
        </a>

        <div class="nav-label">Modules</div>
        <a href="<%= bookingLink %>" class="nav-item">
            <div class="nav-dot" style="background:var(--accent)"></div>
            <span>Booking</span>
        </a>
        <a href="<%= request.getContextPath() %>/services.jsp" class="nav-item">
            <div class="nav-dot" style="background:var(--accent2)"></div>
            <span>Our Services</span>
        </a>

        <% if(isAdmin || isMechanic){ %>
        <a href="<%= request.getContextPath() %>/WorkOrderServlet?action=list" class="nav-item">
            <div class="nav-dot" style="background:var(--blue)"></div>
            <span>Work Order</span>
        </a>
        <% } else { %>
        <div class="nav-item locked">
            <div class="nav-dot" style="background:var(--blue)"></div>
            <span>Work Order</span>
        </div>
        <% } %>

        <% if(isAdmin || isCustomer){ %>
        <a href="<%= request.getContextPath() %>/payment.jsp" class="nav-item">
            <div class="nav-dot" style="background:var(--green)"></div>
            <span>Payment</span>
        </a>
        <% } else { %>
        <div class="nav-item locked">
            <div class="nav-dot" style="background:var(--green)"></div>
            <span>Payment</span>
        </div>
        <% } %>

        <% if(isAdmin){ %>
        <a href="<%= request.getContextPath() %>/inventory.jsp" class="nav-item">
            <div class="nav-dot" style="background:var(--gold)"></div>
            <span>Inventory</span>
        </a>
        <% } else { %>
        <div class="nav-item locked">
            <div class="nav-dot" style="background:var(--gold)"></div>
            <span>Inventory</span>
        </div>
        <% } %>

        <div class="nav-label">System</div>
        <a href="#" class="nav-item">
            <div class="nav-dot" style="background:rgba(255,255,255,.3)"></div>
            <span>Reports</span>
        </a>
        <a href="#" class="nav-item">
            <div class="nav-dot" style="background:rgba(255,255,255,.3)"></div>
            <span>Settings</span>
        </a>
    </div>

    <div class="sidebar-footer">
        <div class="user-box">
            <div class="avatar"><%= avatar %></div>
            <div class="user-info">
                <div class="user-name"><%= username %></div>
                <div class="user-role"><%= roleLabel %></div>
            </div>
            <a href="<%= request.getContextPath() %>/LogoutServlet" class="logout-btn">⏻</a>
        </div>
    </div>
</aside>