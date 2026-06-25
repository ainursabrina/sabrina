<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, util.DBConnection, java.util.*" %>
<%
    String ctxPath = request.getContextPath();
    HttpSession userSession = request.getSession(false);
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

   
    String avatar    = username.substring(0, 1).toUpperCase();
    String roleLabel = isAdmin ? "Administrator" : isMechanic ? "Mechanic" : isCustomer ? "Customer" : "Guest";
    // ── Category → image mapping ──────────────────────────────
  

    // ── Category → accent colour ──────────────────────────────
    Map<String,String> catColorMap = new LinkedHashMap<>();
    catColorMap.put("Oil & Lubricants",     "#e6a327");
    catColorMap.put("Brakes & Tires",       "#ff5b5b");
    catColorMap.put("Air Conditioning",     "#4d8dff");
    catColorMap.put("Electrical & Battery", "#f0c060");
    catColorMap.put("Full Service",         "#a86cff");
    catColorMap.put("Wash & Detailing",     "#42d392");
    catColorMap.put("Diagnostics",          "#4d8dff");
    catColorMap.put("Others",               "#7d879d");

    // ── Load services from DB ─────────────────────────────────
    List<Map<String,String>> services = new ArrayList<>();
    Connection conn = null;
    try {
        conn = DBConnection.getConnection();
        String sql = "SELECT * FROM services ORDER BY category, service_name";
        PreparedStatement ps = conn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String,String> s = new LinkedHashMap<>();
            s.put("id",       rs.getString("service_id"));
            s.put("name",     rs.getString("service_name"));
            s.put("desc",     rs.getString("service_desc") != null ? rs.getString("service_desc") : "");
            s.put("price",    rs.getString("price"));
            s.put("duration", rs.getString("duration") != null ? rs.getString("duration") : "-");
            s.put("category", rs.getString("category") != null ? rs.getString("category") : "Others");
            s.put("icon",     rs.getString("icon") != null ? rs.getString("icon") : "🔧");
            s.put("status",   rs.getString("status") != null ? rs.getString("status") : "available");
            s.put("image", rs.getString("image") != null ? rs.getString("image") : "");
            services.add(s);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }

    // ── Stats ─────────────────────────────────────────────────
    int totalSvc = services.size();
    int availSvc = 0;
    Set<String> cats = new LinkedHashSet<>();
    for (Map<String,String> s : services) {
        if ("available".equals(s.get("status"))) availSvc++;
        cats.add(s.get("category"));
    }

    String msgSuccess = request.getParameter("success");
    String msgError   = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="ms">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Services — AutoCare</title>
<link rel="stylesheet" href="<%=ctxPath%>/css/main.css">
<link rel="stylesheet" href="<%=ctxPath%>/css/services.css">
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
    <div class="nav-section">
        <a href="<%=ctxPath%>/homepage.jsp" class="nav-item">
            <div class="nav-dot" style="background:#ef5350"></div>Dashboard
        </a>
        <a href="<%=ctxPath%>/services.jsp" class="nav-item active">
            <div class="nav-dot" style="background:#ffcc66"></div>Services
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
        <% if (canEdit) { %>
        <a href="<%=ctxPath%>/WorkOrderServlet?action=list" class="nav-item">
            <div class="nav-dot" style="background:#42a5f5"></div>Work Order
        </a>
        <% } %>

        <% if (isAdmin || isCustomer) { %>
        <a href="<%=ctxPath%>/payment?tab=invoices" class="nav-item">
            <div class="nav-dot" style="background:#66bb6a"></div>Payment
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
        <% if (isAdmin || isMechanic || isCustomer) { %>
        <a href="<%=ctxPath%>/SettingsServlet" class="nav-item">
            <div class="nav-dot" style="background:var(--muted)"></div>Settings
        </a>
        <% } %>
    </div>
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
        <div class="page-title">Provided Services</div>
        <div class="top-right">
            <div class="date-box" id="dateBox"></div>
            <a href="<%=ctxPath%>/homepage.jsp" class="dashboard-btn">← Dashboard</a>
        </div>
    </div>

    <div class="content">

        <%-- Flash messages --%>
        <% if ("1".equals(msgSuccess)) { %>
        <div class="alert alert-success">✅ Service saved successfully!</div>
        <% } else if ("deleted".equals(msgSuccess)) { %>
        <div class="alert alert-success">🗑️ Service deleted successfully!</div>
        <% } else if (msgError != null) { %>
        <div class="alert alert-error">❌ Error: <%=msgError%></div>
        <% } %>

        <%-- Stats row (admin / mechanic only) --%>
        <% if (canEdit) { %>
        <div class="stats-row">
            <div class="stat-card" style="--c:var(--gold)">
                <div class="stat-val"><%=totalSvc%></div>
                <div class="stat-label">Total Services</div>
            </div>
            <div class="stat-card" style="--c:var(--green)">
                <div class="stat-val"><%=availSvc%></div>
                <div class="stat-label">Available</div>
            </div>
            <div class="stat-card" style="--c:var(--red)">
                <div class="stat-val"><%=totalSvc - availSvc%></div>
                <div class="stat-label">Unavailable</div>
            </div>
            <div class="stat-card" style="--c:var(--blue)">
                <div class="stat-val"><%=cats.size()%></div>
                <div class="stat-label">Categories</div>
            </div>
        </div>
        <% } %>

        <%-- Toolbar --%>
        <div class="toolbar">
            <div class="toolbar-left">
                <div class="search-wrap">
                    <span class="search-icon">🔍</span>
                    <input type="text" class="search-box" id="searchBox"
                           placeholder="Search services..." oninput="filterCards()">
                </div>
                <button class="filter-btn active" onclick="filterCat('all',this)">All</button>
                <% for (String cat : cats) { %>
                <button class="filter-btn" onclick="filterCat('<%=cat%>',this)"><%=cat%></button>
                <% } %>
            </div>
            <div style="display:flex;gap:8px;align-items:center;">
                <div class="view-toggle">
                    <button class="view-btn active" id="gridBtn" onclick="setView('grid')" title="Grid">⊞</button>
                    <button class="view-btn"         id="listBtn" onclick="setView('list')" title="List">☰</button>
                </div>
                <% if (canEdit) { %>
                <button class="add-btn" onclick="openAdd()">+ Add Service</button>
                <% } %>
            </div>
        </div>

        <!-- GRID VIEW -->
        <div id="gridView">
            <div class="svc-grid" id="svcGrid">
            <% for (Map<String,String> s : services) {
                String cat      = s.get("category");
                String catColor = catColorMap.getOrDefault(cat, "#e6a327");
                String imgPath = (s.get("image") != null && !s.get("image").isEmpty())
                ? s.get("image")
                : "img/svc-others.jpg";
                boolean isAvail = "available".equals(s.get("status"));
                String descText = s.get("desc").isEmpty()
                    ? "Quality service by our experienced mechanics."
                    : s.get("desc");
                // FIX: escape icon for HTML attribute
                String iconHtml = s.get("icon");
            %>
            <div class="svc-card"
                 data-cat="<%=cat%>"
                 data-name="<%=s.get("name").toLowerCase()%>">

                <div class="svc-card-banner">
                    <img src="<%=ctxPath%>/<%=imgPath%>"
                         alt="<%=cat%>"
                         onerror="this.style.display='none';this.parentElement.style.background='<%=catColor%>30'">
                    <div class="banner-overlay"></div>
                </div>

                <div class="svc-card-body">
                    <div class="svc-card-top">
                        <%-- FIX: output icon as direct HTML --%>
                        <div class="svc-icon" style="background:<%=catColor%>22"><%=iconHtml%></div>
                        <span class="svc-badge <%=isAvail ? "badge-avail" : "badge-unavail"%>">
                            <%=isAvail ? "✓ Available" : "✕ Unavailable"%>
                        </span>
                    </div>
                    <div class="svc-cat"><%=cat%></div>
                    <div class="svc-name"><%=s.get("name")%></div>
                    <div class="svc-desc"><%=descText%></div>
                    <div class="svc-footer">
                        <div>
                            <div class="svc-price">RM <%=s.get("price")%><small> / start</small></div>
                        </div>
                        <div class="svc-duration">⏱ <%=s.get("duration")%></div>
                    </div>
                    <% if (canEdit) { %>
                    <div class="card-actions">
                        <%-- FIX: guna data-* attributes untuk elak masalah quote dalam onclick --%>
                        <button class="btn-edit"
                                data-id="<%=s.get("id")%>"
                                data-name="<%=s.get("name").replace("\"","&quot;")%>"
                                data-cat="<%=cat%>"
                                data-price="<%=s.get("price")%>"
                                data-duration="<%=s.get("duration")%>"
                                data-desc="<%=s.get("desc").replace("\"","&quot;")%>"
                                data-icon="<%=s.get("icon")%>"
                                data-status="<%=s.get("status")%>"
                                onclick="openEditFromBtn(this)">✏️ Edit</button>
                        <button class="btn-del"
                                data-id="<%=s.get("id")%>"
                                data-name="<%=s.get("name").replace("\"","&quot;")%>"
                                onclick="openDelFromBtn(this)">🗑️</button>
                    </div>
                    <% } %>
                </div>
            </div>
            <% } %>
            </div>
            <div class="empty" id="emptyGrid" style="display:none;">
                <div class="empty-icon">🔧</div>
                <p>No services found.</p>
            </div>
        </div>

        <!-- LIST VIEW -->
        <div id="listView" style="display:none;">
            <div class="table-wrap">
                <table class="svc-table">
                    <thead>
                        <tr>
                            <th>Service</th>
                            <th>Category</th>
                            <th>Price (RM)</th>
                            <th>Duration</th>
                            <th>Status</th>
                            <% if (canEdit) { %><th>Action</th><% } %>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (Map<String,String> s : services) {
                        String cat      = s.get("category");
                        String catColor = catColorMap.getOrDefault(cat, "#e6a327");
                        boolean isAvail = "available".equals(s.get("status"));
                    %>
                    <tr>
                        <td>
                            <div class="tbl-name">
                                <div class="tbl-icon" style="background:<%=catColor%>22"><%=s.get("icon")%></div>
                                <div>
                                    <div style="font-weight:600"><%=s.get("name")%></div>
                                    <div style="font-size:11px;color:var(--muted)">#<%=s.get("id")%></div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <span class="cat-tag"
                                  style="background:<%=catColor%>18;color:<%=catColor%>;border-color:<%=catColor%>30">
                                <%=cat%>
                            </span>
                        </td>
                        <td><span class="price-col"><%=s.get("price")%></span></td>
                        <td style="color:var(--muted)"><%=s.get("duration")%></td>
                        <td>
                            <span class="svc-badge <%=isAvail ? "badge-avail" : "badge-unavail"%>">
                                <%=isAvail ? "✓ Active" : "✕ Inactive"%>
                            </span>
                        </td>
                        <% if (canEdit) { %>
                        <td>
                            <div class="action-col">
                                <button class="btn-edit"
                                        data-id="<%=s.get("id")%>"
                                        data-name="<%=s.get("name").replace("\"","&quot;")%>"
                                        data-cat="<%=cat%>"
                                        data-price="<%=s.get("price")%>"
                                        data-duration="<%=s.get("duration")%>"
                                        data-desc="<%=s.get("desc").replace("\"","&quot;")%>"
                                        data-icon="<%=s.get("icon")%>"
                                        data-status="<%=s.get("status")%>"
                                        onclick="openEditFromBtn(this)">✏️ Edit</button>
                                <button class="btn-del"
                                        data-id="<%=s.get("id")%>"
                                        data-name="<%=s.get("name").replace("\"","&quot;")%>"
                                        onclick="openDelFromBtn(this)">🗑️</button>
                            </div>
                        </td>
                        <% } %>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>

    </div><%-- /content --%>
</div><%-- /main --%>

<!-- ADD / EDIT MODAL -->
<div class="overlay" id="formModal">
    <div class="modal">
        <div class="modal-head">
            <div class="modal-title" id="modalTitle">Add <span>Service</span></div>
            <div class="modal-close" onclick="closeModal()">✕</div>
        </div>
        <div class="modal-body">
            <input type="hidden" id="fId">
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Service Name *</label>
                    <input class="form-input" type="text" id="fName" placeholder="e.g. Oil Change">
                </div>
                <div class="form-group">
                    <label class="form-label">Category *</label>
                    <select class="form-input" id="fCat">
                        <option value="">-- Select --</option>
                        <option>Oil &amp; Lubricants</option>
                        <option>Brakes &amp; Tires</option>
                        <option>Air Conditioning</option>
                        <option>Electrical &amp; Battery</option>
                        <option>Full Service</option>
                        <option>Wash &amp; Detailing</option>
                        <option>Diagnostics</option>
                        <option>Others</option>
                    </select>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Price (RM) *</label>
                    <input class="form-input" type="number" id="fPrice" placeholder="80" min="0">
                </div>
                <div class="form-group">
                    <label class="form-label">Duration *</label>
                    <select class="form-input" id="fDuration">
                        <option value="">-- Select --</option>
                        <option>30 minutes</option>
                        <option>45 minutes</option>
                        <option>1 hour</option>
                        <option>1.5 hours</option>
                        <option>2 hours</option>
                        <option>3 hours</option>
                        <option>4 hours</option>
                        <option>Full day</option>
                    </select>
                </div>
            </div>
            <div class="form-group">
                <label class="form-label">Description</label>
                <textarea class="form-input" id="fDesc" placeholder="Describe this service..."></textarea>
            </div>
            <div class="form-group">
                <label class="form-label">Icon</label>
                <div class="icon-grid" id="iconGrid"></div>
                <input type="hidden" id="fIcon" value="🔧">
            </div>
            <div class="form-group" style="margin:0">
                <div class="form-group">
                    <label class="form-label">Service Image</label>
                    <input class="form-input" type="file" id="fImage" accept="image/*">
                    <div id="imgPreview" style="margin-top:8px;display:none">
                        <img id="imgPreviewSrc" style="width:100%;max-height:120px;object-fit:cover;border-radius:8px">
                    </div>
                    <small style="color:var(--muted)">JPG/PNG.</small>
                </div>
                <label class="form-label">Status</label>
                <select class="form-input" id="fStatus">
                    <option value="available">✅ Available</option>
                    <option value="unavailable">❌ Unavailable</option>
                </select>
            </div>
        </div>
        <div class="modal-foot">
            <button class="btn-save"   onclick="saveService()">💾 Save</button>
            <button class="btn-cancel" onclick="closeModal()">Cancel</button>
        </div>
    </div>
</div>

<!-- DELETE MODAL -->
<div class="overlay" id="delModal">
    <div class="modal" style="max-width:400px">
        <div class="del-body">
            <div class="del-icon">🗑️</div>
            <div class="del-title">Delete Service?</div>
            <div class="del-sub" id="delSubText">This action cannot be undone.</div>
        </div>
        <div class="modal-foot" style="justify-content:center;padding-top:0">
            <button class="btn-del-confirm" onclick="confirmDel()">Yes, Delete</button>
            <button class="btn-cancel"      onclick="closeDel()">Cancel</button>
        </div>
    </div>
</div>

<div id="toast"></div>

<script>

var CTX = '<%=ctxPath%>';

// ── Date ──────────────────────────────────────────────────
const d = new Date();
const days   = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
document.getElementById('dateBox').textContent =
    days[d.getDay()] + ', ' + d.getDate() + ' ' + months[d.getMonth()] + ' ' + d.getFullYear();

// ── Icon picker ───────────────────────────────────────────
const ICONS = ['🛢️','🔄','🛑','❄️','🔋','🚿','⚙️','🏆','💻','🔧','🛞','🧰','💡','⛽','🔌','🧽','✨','🚗','🔦','🪛'];
let pickedIcon = '🔧';

function buildIconGrid() {
    const grid = document.getElementById('iconGrid');
    grid.innerHTML = '';
    ICONS.forEach(ic => {
        const div = document.createElement('div');
        div.className = 'icon-opt';
        div.textContent = ic;
        if (ic === pickedIcon) div.classList.add('picked');
        div.onclick = () => {
            pickedIcon = ic;
            document.getElementById('fIcon').value = ic;
            document.querySelectorAll('.icon-opt').forEach(x => x.classList.remove('picked'));
            div.classList.add('picked');
        };
        grid.appendChild(div);
    });
}

document.getElementById('fImage').addEventListener('change', function() {
    const file = this.files[0];
    if (file) {
        document.getElementById('imgPreview').style.display = 'block';
        document.getElementById('imgPreviewSrc').src = URL.createObjectURL(file);
    }
});

// ── View toggle ───────────────────────────────────────────
function setView(v) {
    document.getElementById('gridView').style.display = v === 'grid' ? 'block' : 'none';
    document.getElementById('listView').style.display = v === 'list' ? 'block' : 'none';
    document.getElementById('gridBtn').classList.toggle('active', v === 'grid');
    document.getElementById('listBtn').classList.toggle('active', v === 'list');
}

// ── Category filter ───────────────────────────────────────
let activeCat = 'all';
function filterCat(cat, btn) {
    activeCat = cat;
    document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    filterCards();
}
function filterCards() {
    const q     = document.getElementById('searchBox').value.toLowerCase();
    const cards = document.querySelectorAll('.svc-card');
    let visible = 0;
    cards.forEach(c => {
        const matchCat = activeCat === 'all' || c.dataset.cat === activeCat;
        const matchQ   = !q || c.dataset.name.includes(q);
        c.style.display = (matchCat && matchQ) ? 'block' : 'none';
        if (matchCat && matchQ) visible++;
    });
    document.getElementById('emptyGrid').style.display = visible === 0 ? 'block' : 'none';
}

// ── FIX: openEdit guna data-* attributes ─────────────────
function openEditFromBtn(btn) {
    openEdit(
        btn.dataset.id,
        btn.dataset.name,
        btn.dataset.cat,
        btn.dataset.price,
        btn.dataset.duration,
        btn.dataset.desc,
        btn.dataset.icon,
        btn.dataset.status
    );
}

function openDelFromBtn(btn) {
    openDel(btn.dataset.id, btn.dataset.name);
}

// ── Add / Edit modal ──────────────────────────────────────
function openAdd() {
    document.getElementById('fId').value       = '';
    document.getElementById('modalTitle').innerHTML = 'Add <span>Service</span>';
    document.getElementById('fName').value     = '';
    document.getElementById('fCat').value      = '';
    document.getElementById('fPrice').value    = '';
    document.getElementById('fDuration').value = '';
    document.getElementById('fDesc').value     = '';
    document.getElementById('fStatus').value   = 'available';
    pickedIcon = '🔧';
    document.getElementById('fIcon').value = '🔧';
    buildIconGrid();
    document.getElementById('formModal').classList.add('open');
}

function openEdit(id, name, cat, price, duration, desc, icon, status) {
    document.getElementById('fId').value       = id;
    document.getElementById('modalTitle').innerHTML = 'Edit <span>Service</span>';
    document.getElementById('fName').value     = name;
    document.getElementById('fCat').value      = cat;
    document.getElementById('fPrice').value    = price;
    document.getElementById('fDuration').value = duration;
    document.getElementById('fDesc').value     = desc;
    document.getElementById('fStatus').value   = status;
    pickedIcon = (icon && icon.trim()) ? icon.trim() : '🔧';
    document.getElementById('fIcon').value = pickedIcon;
    buildIconGrid();
    document.getElementById('formModal').classList.add('open');
}

function closeModal() {
    document.getElementById('formModal').classList.remove('open');
}


function saveService() {
    const name  = document.getElementById('fName').value.trim();
    const cat   = document.getElementById('fCat').value;
    const price = document.getElementById('fPrice').value;
    const dur   = document.getElementById('fDuration').value;

    if (!name || !cat || !price || !dur) {
        alert('Please fill in all required fields (*).');
        return;
    }

    const fd = new FormData();
    fd.append('action',      document.getElementById('fId').value ? 'edit' : 'add');
    fd.append('serviceId',   document.getElementById('fId').value);
    fd.append('serviceName', name);
    fd.append('category',    cat);
    fd.append('price',       price);
    fd.append('duration',    dur);
    fd.append('serviceDesc', document.getElementById('fDesc').value);
    fd.append('icon',        document.getElementById('fIcon').value);
    fd.append('status',      document.getElementById('fStatus').value);

    const imgFile = document.getElementById('fImage').files[0];
    if (imgFile) fd.append('image', imgFile);

    fetch(CTX + '/ServiceServlet', { method:'POST', body: fd })
        .then(r => r.ok ? location.reload() : alert('Server error'))
        .catch(() => alert('Network error'));
}

// ── Delete modal ──────────────────────────────────────────
let delId = '';
function openDel(id, name) {
    delId = id;
    document.getElementById('delSubText').textContent =
        'You are about to delete "' + name + '". This action cannot be undone.';
    document.getElementById('delModal').classList.add('open');
}
function closeDel() {
    document.getElementById('delModal').classList.remove('open');
}
function confirmDel() {
    const form  = document.createElement('form');
    form.method = 'POST';
    form.action = CTX + '/ServiceServlet';
    const a = document.createElement('input'); a.type='hidden'; a.name='action';    a.value='delete'; form.appendChild(a);
    const i = document.createElement('input'); i.type='hidden'; i.name='serviceId'; i.value=delId;    form.appendChild(i);
    document.body.appendChild(form);
    form.submit();
}

// Close overlay on outside click
['formModal','delModal'].forEach(id => {
    document.getElementById(id).addEventListener('click', function(e) {
        if (e.target === this) { closeModal(); closeDel(); }
    });
});

// ── Toast ─────────────────────────────────────────────────
function toast(msg) {
    const el = document.getElementById('toast');
    el.textContent = msg;
    el.classList.add('show');
    setTimeout(() => el.classList.remove('show'), 2500);
}
function showLoginPopup() {
    document.getElementById('loginPopup').classList.add('open');
}
function closeLoginPopup() {
    document.getElementById('loginPopup').classList.remove('open');
}
document.getElementById('loginPopup').addEventListener('click', function(e) {
    if (e.target === this) closeLoginPopup();
});
</script>
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

</body>
</html>