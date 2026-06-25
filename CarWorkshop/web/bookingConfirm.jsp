<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String bookingID = (String) request.getAttribute("bookingID");
    String total     = (String) request.getAttribute("total");
    String date      = (String) request.getAttribute("date");
    String time      = (String) request.getAttribute("time");
    String services  = (String) request.getAttribute("services");
    String plate     = (String) request.getAttribute("plate");

    if (bookingID == null) {
        response.sendRedirect("BookingServlet?action=add");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Booking Done | AutoCare</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
</head>
<body>

    <!-- ===== TOAST NOTIFICATION ===== -->
<div id="toast" style="
    position:fixed; top:24px; right:24px; z-index:99999;
    background:#fff; border-radius:14px;
    border-left:5px solid #2e7d32;
    box-shadow:0 8px 24px rgba(0,0,0,0.15);
    padding:18px 24px; min-width:300px; max-width:380px;
    display:flex; align-items:center; gap:14px;
    animation: slideIn 0.4s ease;">
    <div style="font-size:2rem;">✅</div>
    <div>
        <div style="font-weight:700; color:#2e7d32; font-size:1rem;">Booking Confirmed!</div>
        <div style="color:#666; font-size:0.85rem; margin-top:3px;">Your slot has been booked successfully.</div>
    </div>
    <div onclick="document.getElementById('toast').remove()"
         style="margin-left:auto; cursor:pointer; color:#aaa; font-size:1.1rem; padding:4px;">✕</div>
</div>

<style>
@keyframes slideIn {
    from { opacity:0; transform:translateX(80px); }
    to   { opacity:1; transform:translateX(0); }
}
</style>

<script>
    setTimeout(() => {
        const t = document.getElementById('toast');
        if (t) t.style.display = 'none';
    }, 5000);
</script>
<!-- ===== END TOAST ===== -->

<div class="confirm-wrap">
    <div class="confirm-card">

        <div class="confirm-icon">✅</div>
        <div class="confirm-title">Booking Successful!</div>
        <div class="confirm-subtitle">
            Your booking has been received. We will update your shortly.
        </div>

        <div class="booking-no-box">
            <div class="booking-no-label">Your Boking Num</div>
            <div class="booking-no-value"><%= bookingID %></div>
        </div>

        <div class="confirm-details">
            <div class="detail-row">
                <span class="detail-label">Plat Num</span>
                <span class="detail-value"><%= plate %></span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Service</span>
                <span class="detail-value"><%= services %></span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Date</span>
                <span class="detail-value"><%= date %></span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Time</span>
                <span class="detail-value"><%= time %></span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Estimated Total</span>
                <span class="detail-value detail-total">RM <%= total %></span>
            </div>
        </div>

        <a href="homepage.jsp" class="btn-home">← Back to Dashboard</a>
       

    </div>
</div>

</body>
</html>
