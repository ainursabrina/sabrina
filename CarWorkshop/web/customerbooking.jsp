<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="util.DBConnection" %>
<%
    String username = (String) session.getAttribute("username");
    String role     = (String) session.getAttribute("role");

    String avatar  = username.substring(0, 1).toUpperCase();
    String success = request.getParameter("success");

   
    List<Map<String,String>> myBookings = new ArrayList<>();
    String userid = (String) session.getAttribute("userid");
    if (userid != null) {
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT b.bookingID, b.booking_date, b.booking_status, " +
                         "GROUP_CONCAT(s.service_name SEPARATOR ', ') AS services " +
                         "FROM booking b " +
                         "LEFT JOIN booking_services bs ON b.bookingID = bs.bookingID " +
                         "LEFT JOIN services s ON bs.service_id = s.service_id " +
                         "WHERE b.userid = ? " +
                         "GROUP BY b.bookingID " +
                         "ORDER BY b.booking_date DESC";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, userid);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String,String> b = new LinkedHashMap<>();
                b.put("id",     rs.getString("bookingID"));
                b.put("date",   rs.getTimestamp("booking_date").toString());
                b.put("status", rs.getString("booking_status"));
                b.put("services", rs.getString("services"));
                myBookings.add(b);
            }
        } catch (Exception e) { e.printStackTrace(); }
    }

    
    List<Map<String,String>> serviceList = new ArrayList<>();
    try (Connection connSvc = DBConnection.getConnection()) {
        String svcSql = "SELECT service_name, price, icon FROM services WHERE status = 'available' ORDER BY service_name";
        PreparedStatement svcPs = connSvc.prepareStatement(svcSql);
        ResultSet svcRs = svcPs.executeQuery();
        while (svcRs.next()) {
            Map<String,String> svc = new LinkedHashMap<>();
            svc.put("name",  svcRs.getString("service_name"));
            svc.put("price", svcRs.getString("price"));
            svc.put("icon",  svcRs.getString("icon") != null ? svcRs.getString("icon") : "🔧");
            serviceList.add(svc);
        }
    } catch (Exception e) { e.printStackTrace(); }
    
   String ctxPath = request.getContextPath();
     String bookingError = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="ms">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Make booking | AutoCare</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
    <style>
        #panel-1, #panel-2, #panel-3 { display: none !important; }
        #panel-1.active, #panel-2.active, #panel-3.active { display: block !important; }
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
        <a href="homepage.jsp" class="nav-item">
            <div class="nav-dot" style="background:var(--accent)"></div>
            <span>Dashboard</span>
        </a>
        <a href="services.jsp" class="nav-item">
            <div class="nav-dot" style="background:#ffa726"></div>
            <span>Services</span>
        </a>
        <a href="${pageContext.request.contextPath}/BookingServlet?action=add" class="nav-item active">
            <div class="nav-dot" style="background:var(--accent)"></div>
            <span>Booking</span>
        </a>
        <a href="<%=ctxPath%>/payment?tab=invoices" class="nav-item">
            <div class="nav-dot" style="background:#66bb6a"></div>
            <span>Payment</span>
        </a>
        <a href="settings.jsp" class="nav-item">
            <div class="nav-dot" style="background:var(--muted)"></div>
            <span>Settings</span>
        </a>
    </nav>

    <div class="sidebar-footer">
        <div class="user-box">
            <div class="avatar"><%= avatar %></div>
            <div class="user-info">
                <div class="user-name"><%= username %></div>
                <div class="user-role">Customer</div>
            </div>
            <a href="${pageContext.request.contextPath}/LogoutServlet" class="logout-btn" title="Log Out">⏻</a>
        </div>
    </div>
</aside>

<!-- ===== MAIN ===== -->
<main class="main">

    <header class="topbar">
        <div class="page-title">Booking <span style="color:var(--accent);font-size:inherit;"></span></div>
        <div class="top-right">
            <div class="date-badge" id="dateDisplay"></div>
            <a href="homepage.jsp" class="dashboard-btn">← Dashboard</a>
        </div>
    </header>

    <div class="content">
        
        <%-- Error: slot taken --%>
        <% if ("slot_taken".equals(bookingError)) { %>
        <div style="background:#ff4444;color:white;padding:12px 16px;border-radius:8px;margin-bottom:16px;display:flex;align-items:center;gap:10px;">
            <span style="font-size:20px">⚠️</span>
            <span>Sorry, this time slot is already booked. Please choose another date or time.</span>
        </div>
        <% } %>
        
        <% if ("1".equals(success)) { %>
            <div id="toastSuccess" style="
                position:fixed; top:24px; right:24px; z-index:99999;
                background:#fff; border-radius:14px;
                border-left:5px solid #2e7d32;
                box-shadow:0 8px 24px rgba(0,0,0,0.15);
                padding:18px 24px; min-width:300px; max-width:380px;
                display:flex; align-items:center; gap:14px;
                animation: slideIn 0.4s ease;">
                <div style="font-size:2rem;">✅</div>
                <div>
                    <div style="font-weight:600; color:#2e7d32; font-size:1rem;">Booking Submitted!</div>
                    <div style="color:#555; font-size:0.875rem; margin-top:2px;">We will send confirmation shortly.</div>
                </div>
                <div onclick="document.getElementById('toastSuccess').style.display='none'"
                     style="margin-left:auto; cursor:pointer; color:#999; font-size:1.2rem;">✕</div>
            </div>
            <style>
            @keyframes slideIn {
                from { opacity:0; transform: translateX(60px); }
                to   { opacity:1; transform: translateX(0); }
            }
            </style>
            <script>
                setTimeout(() => {
                    const t = document.getElementById('toastSuccess');
                    if (t) t.style.display = 'none';
                }, 5000);
            </script>
            <% } %>

        <!-- Hero -->
        <div class="hero">
            <div class="hero-icon">📋</div>
            <h1>Book Your <span>Slot</span></h1>
            <p>Fill in the following information to book your service slot.</p>
        </div>

        <!-- Steps -->
        <div class="steps">
            <div class="step active" id="step-tab-1">
                <div class="step-number">1</div>Vehicle
            </div>
            <div class="step locked" id="step-tab-2">
                <div class="step-number">2</div>Service &amp; Time
            </div>
            <div class="step locked" id="step-tab-3">
                <div class="step-number">3</div>Confirm &amp; Submit
            </div>
        </div>

        <!-- ===== STEP 1: CAR ===== -->
        <div class="panel active" id="panel-1">
            <div class="form-card">
                <div class="form-title">
                    <div class="form-icon">🚗</div>
                    <h2>Vehicle Details</h2>
                </div>
                <div class="grid-2">
                    <div class="input-group">
                        <label>Plat Number *</label>
                        <input type="text" id="carPlate" placeholder="e.g. TBH45" required>
                    </div>
                    <div class="input-group">
                        <label>Type of vehicle *</label>
                        <select id="vehicleType" required>
                            <option value="">-- Choose --</option>
                            <option>Sedan</option>
                            <option>SUV</option>
                            <option>MPV</option>
                            <option>Hatchback</option>
                            <option>Pickup</option>
                        </select>
                    </div>
                    <div class="input-group">
                        <label>Brand *</label>
                        <input type="text" id="carBrand" placeholder="e.g. Perodua" required>
                    </div>
                    <div class="input-group">
                        <label>Model *</label>
                        <input type="text" id="carModel" placeholder="e.g. Myvi" required>
                    </div>
                    <div class="input-group">
                        <label>Year</label>
                        <input type="number" id="carYear" placeholder="e.g. 2020">
                    </div>
                    <div class="input-group">
                        <label>Color</label>
                        <input type="text" id="carColor" placeholder="e.g. Hitam">
                    </div>
                </div>
                <div class="input-group">
                    <label>Issues/Complaints</label>
                    <textarea id="remarks" placeholder="e.g. AC is not functioning well"></textarea>
                </div>
            </div>
            <div class="btn-row">
                <button class="btn-next" onclick="goStep2()">Next — Choose Service →</button>
            </div>
        </div>

        <!-- ===== STEP 2: SERVIS & MASA ===== -->
        <div class="panel" id="panel-2">
            <div class="form-card">
                <div class="form-title">
                    <div class="form-icon">🛠️</div>
                    <h2>Choose Service</h2>
                </div>

                <!-- FIX: Service cards diload dari database, bukan hardcoded -->
                <div class="service-grid">
                    <% for (Map<String,String> svc : serviceList) {
                        String svcName  = svc.get("name");
                        String svcPrice = svc.get("price");
                        String svcIcon  = svc.get("icon");
                    %>
                    <div class="service-card"
                         onclick="toggleService(this,'<%= svcName.replace("'", "\\'") %>',<%= svcPrice %>)">
                        <div class="service-icon"><%= svcIcon %></div>
                        <div class="service-name"><%= svcName %></div>
                        <div class="service-price">RM <%= svcPrice %></div>
                    </div>
                    <% } %>
                     <div class="service-card" id="othersCard"
                         onclick="toggleOthers(this)">
                        <div class="service-icon">🤷</div>
                        <div class="service-name">Others / Not Sure</div>
                        <div class="service-price" style="color:var(--muted); font-size:11px;">Price TBD by mechanic</div>
                    </div>
                </div>
            </div>

            <div class="form-card">
                <div class="form-title">
                    <div class="form-icon">📅</div>
                    <h2>Choose Date &amp; Time</h2>
                </div>
                <div class="grid-2">
                    <div class="input-group">
                        <label>Date *</label>
                        <input type="date" id="bookingDate" required>
                    </div>
                    <div class="input-group">
                        <label>Selected Time</label>
                        <div class="selected-time-display" id="selectedTimeDisplay">— Not Chosen —</div>
                    </div>
                </div>
                <div class="input-group">
                    <label>Time Slot *</label>
                    <div class="time-grid">
                        <div class="time-slot" onclick="selectTime(this,'8:30 AM')">8:30 AM</div>
                        <div class="time-slot" onclick="selectTime(this,'9:00 AM')">9:00 AM</div>
                        <div class="time-slot" onclick="selectTime(this,'9:30 AM')">9:30 AM</div>
                        <div class="time-slot" onclick="selectTime(this,'10:00 AM')">10:00 AM</div>
                        <div class="time-slot" onclick="selectTime(this,'10:30 AM')">10:30 AM</div>
                        <div class="time-slot" onclick="selectTime(this,'11:00 AM')">11:00 AM</div>
                        <div class="time-slot" onclick="selectTime(this,'11:30 AM')">11:30 AM</div>
                        <div class="time-slot" onclick="selectTime(this,'2:00 PM')">2:00 PM</div>
                        <div class="time-slot" onclick="selectTime(this,'2:30 PM')">2:30 PM</div>
                        <div class="time-slot" onclick="selectTime(this,'3:00 PM')">3:00 PM</div>
                        <div class="time-slot" onclick="selectTime(this,'3:30 PM')">3:30 PM</div>
                        <div class="time-slot" onclick="selectTime(this,'4:00 PM')">4:00 PM</div>
                        <div class="time-slot" onclick="selectTime(this,'4:30 PM')">4:30 PM</div>
                        <div class="time-slot" onclick="selectTime(this,'5:00 PM')">5:00 PM</div>
                        <div class="time-slot" onclick="selectTime(this,'5:30 PM')">5:30 PM</div>
                    </div>
                </div>
                <div class="input-group" style="margin-top:16px;">
                    <label>Additional Notes</label>
                    <textarea id="notes" placeholder="Any special requests or notes for the mechanic..."></textarea>
                </div>
            </div>

            <div class="btn-row">
                <button class="btn-back" onclick="goPanel(1)">← Back</button>
                <button class="btn-next" onclick="goStep3()">Next — Check Booking →</button>
            </div>
        </div>

        <!-- ===== STEP 3: SEMAK & HANTAR ===== -->
        <div class="panel" id="panel-3">
            <form action="${pageContext.request.contextPath}/BookingServlet" method="post" id="bookingForm" onsubmit="return validateSubmit()">

                <input type="hidden" name="carPlate"        id="h_carPlate">
                <input type="hidden" name="vehicleType"     id="h_vehicleType">
                <input type="hidden" name="carBrand"        id="h_carBrand">
                <input type="hidden" name="carModel"        id="h_carModel">
                <input type="hidden" name="manufactureYear" id="h_carYear">
                <input type="hidden" name="carColor"        id="h_carColor">
                <input type="hidden" name="remarks"         id="h_remarks">
                <input type="hidden" name="serviceName"     id="h_serviceName">
                <input type="hidden" name="bookingDate"     id="h_bookingDate">
                <input type="hidden" name="bookingTime"     id="h_bookingTime">
                <input type="hidden" name="totalPrice"      id="h_totalPrice">
                <input type="hidden" name="notes"           id="h_notes">

                <div class="review-card">
                    <div class="form-title">
                        <div class="form-icon">📋</div>
                        <h2>Check Your Booking</h2>
                    </div>

                    <div class="review-section-title">Car</div>
                    <div class="review-grid">
                        <div class="review-field">
                            <label>Plat Number</label>
                            <span id="r_carPlate">—</span>
                        </div>
                        <div class="review-field">
                            <label>Type</label>
                            <span id="r_vehicleType">—</span>
                        </div>
                        <div class="review-field">
                            <label>Vehicle</label>
                            <span id="r_carInfo">—</span>
                        </div>
                        <div class="review-field">
                            <label>Year / Color</label>
                            <span id="r_yearColor">—</span>
                        </div>
                    </div>

                    <div class="review-section-title">Service &amp; Schedule</div>
                    <div class="service-tags" id="r_serviceTags"></div>
                    <div class="review-grid">
                        <div class="review-field">
                            <label>Date</label>
                            <span id="r_date">—</span>
                        </div>
                        <div class="review-field">
                            <label>Time</label>
                            <span id="r_time">—</span>
                        </div>
                    </div>

                    <div class="total-row">
                        <span class="total-label">Estimated Total</span>
                        <span class="total-amount" id="r_total">RM 0</span>
                    </div>
                </div>

                <div class="btn-row">
                    <button type="button" class="btn-back" onclick="goPanel(2)">← Back</button>
                    <button type="submit" class="btn-next">✓ Send Booking</button>
                </div>
            </form>

            <!-- My Bookings -->
            <div style="margin-top:32px;">
                <div class="section-title" style="margin-bottom:16px;">My Booking</div>
                <% if (myBookings.isEmpty()) { %>
                    <div class="empty-state">No booking yet.</div>
                <% } else { %>
                    <% for (Map<String,String> b : myBookings) { %>
                    <div class="booking-card">
                        <div class="booking-left">
                            <div class="booking-id"><%=b.get("id")%></div>
                            <div class="booking-service"><%=b.get("services")%></div>
                        </div>
                        <div class="booking-right">
                            <div class="booking-date"><%=b.get("date")%></div>
                            <div class="booking-status"><%=b.get("status")%></div>
                        </div>
                    </div>
                    <% } %>
                <% } %>
            </div>
        </div>

    </div><!-- /content -->

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

    document.getElementById('bookingDate').min = new Date().toISOString().split('T')[0];

    let selectedServices = {};
    let selectedTime = '';
    let unlockedStep = 1;

    // ===== CUSTOM ALERT =====
    let afterAlertFn = null;

    function showAlert(msg, fn) {
        document.getElementById('alertMsg').textContent = msg;
        const modal = document.getElementById('customAlert');
        modal.style.display = 'flex';
        afterAlertFn = fn || null;
    }

    function closeAlert() {
        document.getElementById('customAlert').style.display = 'none';
        if (afterAlertFn) { afterAlertFn(); afterAlertFn = null; }
    }

    // ===== HIGHLIGHT =====
    function highlightEmpty(id, isSelect) {
        const el = document.getElementById(id);
        if (!el) return false;
        const empty = isSelect ? !el.value : !el.value.trim();
        if (empty) {
            el.style.border = '2px solid #e53935';
            el.style.background = '#fff5f5';
        } else {
            el.style.border = '';
            el.style.background = '';
        }
        return empty;
    }

    function scrollToFirst(ids, isSelects) {
        for (let i = 0; i < ids.length; i++) {
            const el = document.getElementById(ids[i]);
            const empty = isSelects[i] ? !el.value : !el.value.trim();
            if (empty) {
                el.scrollIntoView({ behavior: 'smooth', block: 'center' });
                el.focus();
                break;
            }
        }
    }

    function clearHighlight(id) {
        const el = document.getElementById(id);
        if (el) { el.style.border = ''; el.style.background = ''; }
    }

    ['carPlate','vehicleType','carBrand','carModel'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.addEventListener('input',  () => clearHighlight(id));
        if (el) el.addEventListener('change', () => clearHighlight(id));
    });

    // ===== TOGGLE SERVICE & TIME =====
    function toggleService(el, name, price) {
        if (el.classList.contains('selected')) {
            el.classList.remove('selected');
            delete selectedServices[name];
        } else {
            el.classList.add('selected');
            selectedServices[name] = price;
        }
        if (Object.keys(selectedServices).length > 0) {
            document.querySelector('.service-grid').style.outline = '';
        }
    }
    
    <% if ("slot_taken".equals(bookingError)) { %>
    window.addEventListener('load', function() {
        unlockedStep = 2;
        document.getElementById('step-tab-2').classList.remove('locked');
        goPanel(2);
    });
    <% } %>
        
    function selectTime(el, time) {
        document.querySelectorAll('.time-slot').forEach(s => s.classList.remove('selected'));
        el.classList.add('selected');
        selectedTime = time;
        document.getElementById('selectedTimeDisplay').textContent = time;
        document.querySelector('.time-grid').style.outline = '';
    }

    // ===== PANEL NAV =====
    function goPanel(n) {
        if (n > unlockedStep) return;
        // TUKAR BARIS NI:
        document.querySelectorAll('#panel-1, #panel-2, #panel-3').forEach(p => p.classList.remove('active'));
        document.getElementById('panel-' + n).classList.add('active');
        document.querySelectorAll('.step').forEach((s, i) => {
            s.classList.remove('active', 'done', 'locked');
            if (i + 1 < n) s.classList.add('done');
            else if (i + 1 === n) s.classList.add('active');
            else s.classList.add('locked');
        });
        window.scrollTo(0, 0);
    }

    // ===== STEP 1 → 2 =====
    function goStep2() {
        const ids      = ['carPlate','vehicleType','carBrand','carModel'];
        const isSelect = [false, true, false, false];
        const checks   = ids.map((id, i) => highlightEmpty(id, isSelect[i]));

        if (checks.some(c => c)) {
            scrollToFirst(ids, isSelect);
            showAlert('Please complete all vehicle information marked with * before continuing.');
            return;
        }
        unlockedStep = 2;
        document.getElementById('step-tab-2').classList.remove('locked');
        goPanel(2);
    }

    // ===== STEP 2 → 3 =====
    function goStep3() {
        if (Object.keys(selectedServices).length === 0) {
            const grid = document.querySelector('.service-grid');
            grid.style.outline = '2px solid #e53935';
            grid.scrollIntoView({ behavior: 'smooth', block: 'center' });
            showAlert('Choose at least one service.');
            return;
        }

        const dateEl = document.getElementById('bookingDate');
        if (!dateEl.value) {
            dateEl.style.border = '2px solid #e53935';
            dateEl.style.background = '#fff5f5';
            dateEl.scrollIntoView({ behavior: 'smooth', block: 'center' });
            dateEl.addEventListener('change', () => { dateEl.style.border = ''; dateEl.style.background = ''; }, { once: true });
            showAlert('Choose service date.');
            return;
        }

        if (!selectedTime) {
            const timeGrid = document.querySelector('.time-grid');
            timeGrid.style.outline = '2px solid #e53935';
            timeGrid.scrollIntoView({ behavior: 'smooth', block: 'center' });
            setTimeout(() => timeGrid.style.outline = '', 3000);
            showAlert('Choose time slot.');
            return;
        }

        const plate   = document.getElementById('carPlate').value;
        const type    = document.getElementById('vehicleType').value;
        const brand   = document.getElementById('carBrand').value;
        const model   = document.getElementById('carModel').value;
        const year    = document.getElementById('carYear').value;
        const color   = document.getElementById('carColor').value;
        const date    = dateEl.value;
        const remarks = document.getElementById('remarks').value;
        const notes   = document.getElementById('notes').value;

        document.getElementById('r_carPlate').textContent    = plate;
        document.getElementById('r_vehicleType').textContent = type;
        document.getElementById('r_carInfo').textContent     = brand + ' ' + model;
        document.getElementById('r_yearColor').textContent   = (year || '—') + ' / ' + (color || '—');

        const dateObj = new Date(date);
        const dNames  = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
        const mNames  = ['January','February','March','April','May','June','July','August','September','October','November','December'];
        document.getElementById('r_date').textContent =
            dNames[dateObj.getUTCDay()] + ', ' + dateObj.getUTCDate() + ' ' +
            mNames[dateObj.getUTCMonth()] + ' ' + dateObj.getUTCFullYear();
        document.getElementById('r_time').textContent = selectedTime;

        const tagsEl = document.getElementById('r_serviceTags');
        tagsEl.innerHTML = '';
        let total = 0;
        for (const [name, price] of Object.entries(selectedServices)) {
            total += price;
            const tag = document.createElement('div');
            tag.className = 'service-tag';
            tag.textContent = price > 0
                ? '⚙ ' + name + ' — RM ' + price
                : '🤷 ' + name + ' — Price TBD';
            tagsEl.appendChild(tag);
        }
        document.getElementById('r_total').textContent = 'RM ' + total;

        document.getElementById('h_carPlate').value    = plate;
        document.getElementById('h_vehicleType').value = type;
        document.getElementById('h_carBrand').value    = brand;
        document.getElementById('h_carModel').value    = model;
        document.getElementById('h_carYear').value     = year;
        document.getElementById('h_carColor').value    = color;
        document.getElementById('h_remarks').value     = remarks;
        document.getElementById('h_serviceName').value = Object.keys(selectedServices).join(', ');
        document.getElementById('h_bookingDate').value = date;
        document.getElementById('h_bookingTime').value = selectedTime;
        document.getElementById('h_totalPrice').value  = total;
        document.getElementById('h_notes').value       = notes;

        unlockedStep = 3;
        document.getElementById('step-tab-3').classList.remove('locked');
        goPanel(3);
    }

    // ===== VALIDATE SUBMIT =====
    function validateSubmit() {
        const plate   = document.getElementById('h_carPlate').value.trim();
        const type    = document.getElementById('h_vehicleType').value.trim();
        const brand   = document.getElementById('h_carBrand').value.trim();
        const model   = document.getElementById('h_carModel').value.trim();
        const service = document.getElementById('h_serviceName').value.trim();
        const date    = document.getElementById('h_bookingDate').value.trim();
        const time    = document.getElementById('h_bookingTime').value.trim();

        if (!plate || !type || !brand || !model) {
            showAlert('Maklumat kenderaan tidak lengkap. Sila kembali ke Step 1.', () => {
                goPanel(1);
                ['carPlate','vehicleType','carBrand','carModel'].forEach((id, i) =>
                    highlightEmpty(id, i === 1));
                scrollToFirst(['carPlate','vehicleType','carBrand','carModel'],[false,true,false,false]);
            });
            return false;
        }
        if (!service) {
            showAlert('Choose at least one service.', () => {
                goPanel(2);
                const grid = document.querySelector('.service-grid');
                grid.style.outline = '2px solid #e53935';
                grid.scrollIntoView({ behavior: 'smooth', block: 'center' });
            });
            return false;
        }
        if (!date) {
            showAlert('Choose service date.', () => {
                goPanel(2);
                const dateEl = document.getElementById('bookingDate');
                dateEl.style.border = '2px solid #e53935';
                dateEl.style.background = '#fff5f5';
                dateEl.scrollIntoView({ behavior: 'smooth', block: 'center' });
            });
            return false;
        }
        if (!time) {
            showAlert('Choose time slot.', () => {
                goPanel(2);
                const timeGrid = document.querySelector('.time-grid');
                timeGrid.style.outline = '2px solid #e53935';
                timeGrid.scrollIntoView({ behavior: 'smooth', block: 'center' });
            });
            return false;
        }
        return true;
    }
    // ===== OTHERS / NOT SURE =====
    function toggleOthers(el) {
        if (el.classList.contains('selected')) {
            el.classList.remove('selected');
            delete selectedServices['Others / Not Sure'];
        } else {
            el.classList.add('selected');
            selectedServices['Others / Not Sure'] = 0; // price 0, TBD
        }
        if (Object.keys(selectedServices).length > 0) {
            document.querySelector('.service-grid').style.outline = '';
        }
    }
</script>

<!-- Custom Alert Modal -->
<div id="customAlert" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.5); z-index:9999; align-items:center; justify-content:center;">
    <div style="background:#fff; border-radius:16px; padding:32px; max-width:380px; width:90%; text-align:center; box-shadow:0 8px 32px rgba(0,0,0,0.2);">
        <div id="alertIcon" style="font-size:2.5rem; margin-bottom:12px;">⚠️</div>
        <div id="alertMsg" style="font-size:1rem; color:#333; margin-bottom:24px; line-height:1.5;"></div>
        <button onclick="closeAlert()" style="background:var(--accent); color:#fff; border:none; padding:10px 32px; border-radius:8px; font-size:1rem; cursor:pointer;">OK</button>
    </div>
</div>

</body>
</html>
