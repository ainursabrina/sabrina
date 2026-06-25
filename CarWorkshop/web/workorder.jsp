<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%
    String username = (String) session.getAttribute("username");
    String role     = (String) session.getAttribute("role");

    if (username == null || username.trim().isEmpty()) { username = "Guest"; }
    if (role == null) { role = "guest"; }
    role = role.toLowerCase();
    model.User sessionUser = (model.User) session.getAttribute("user");
    if (sessionUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    boolean isAdmin    = "admin".equals(role);
    boolean isMechanic = "mechanic".equals(role);
    boolean isCustomer = "customer".equals(role);
    boolean isGuest    = "guest".equals(role);

    String avatar    = username.substring(0, 1).toUpperCase();
    String roleLabel = isAdmin ? "Administrator" : isMechanic ? "Mechanic" : isCustomer ? "Customer" : "Guest";

    String bookingLink = (isAdmin || isMechanic)
        ? request.getContextPath() + "/BookingServlet?action=adminList"
        : request.getContextPath() + "/BookingServlet?action=add";
    String name    = sessionUser.getName();
    String id      = sessionUser.getUserid();
    String ctxPath = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Manage Work Order — AutoCare WMS</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
  <style>
    /* ── Modal overlay ── */
    .modal-overlay {
      display: none;
      position: fixed; inset: 0;
      background: rgba(0,0,0,.45);
      z-index: 999;
      align-items: center;
      justify-content: center;
    }
    .modal-overlay.open { display: flex; }
    .modal-box {
      background: var(--card, #fff);
      border-radius: 14px;
      padding: 28px 32px;
      width: 440px;
      max-width: 95vw;
      box-shadow: 0 8px 32px rgba(0,0,0,.18);
    }
    .modal-box h3 { margin: 0 0 18px; font-size: 16px; }
    .modal-box label { display: block; font-size: 13px; color: var(--muted); margin-bottom: 4px; margin-top: 14px; }
    .modal-box textarea,
    .modal-box input[type=text],
    .modal-box input[type=number],
    .modal-box select {
      width: 100%; box-sizing: border-box;
      border: 1px solid var(--border, #ddd);
      border-radius: 8px; padding: 8px 10px;
      font-size: 14px; background: var(--input-bg, #fafafa);
      color: var(--text);
    }
    .modal-box textarea { resize: vertical; min-height: 80px; }
    .modal-footer { display: flex; gap: 10px; margin-top: 20px; justify-content: flex-end; }
    .btn-cancel-modal {
      padding: 8px 18px; border-radius: 8px; border: 1px solid var(--border,#ddd);
      background: transparent; cursor: pointer; font-size: 13px; color: var(--muted);
    }
    .btn-save-modal {
      padding: 8px 20px; border-radius: 8px; border: none;
      background: #42a5f5; color: #fff; cursor: pointer; font-size: 13px; font-weight: 600;
    }
    /* ── Pagination ── */
    .pagination {
      display: flex; align-items: center; justify-content: center;
      gap: 8px; margin-top: 20px;
    }
    .pagination a, .pagination span {
      display: inline-flex; align-items: center; justify-content: center;
      min-width: 34px; height: 34px; border-radius: 8px;
      font-size: 13px; text-decoration: none;
      border: 1px solid var(--border, #ddd);
      color: var(--text);
      padding: 0 10px;
    }
    .pagination a:hover { background: var(--hover-bg, #f0f4ff); }
    .pagination .active { background: #42a5f5; color: #fff; border-color: #42a5f5; font-weight: 600; }
    .pagination .disabled { opacity: .4; pointer-events: none; }
    /* ── Mechanic notes preview chip ── */
    .notes-chip {
      display: inline-block; max-width: 160px;
      overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
      font-size: 11px; background: var(--hover-bg,#f0f4ff);
      border-radius: 6px; padding: 2px 7px;
      color: var(--muted); vertical-align: middle;
      cursor: pointer; border: 1px solid var(--border,#e0e0e0);
    }
    .charges-badge {
      font-size: 11px; color: #e65100;
      background: #fff3e0; border-radius: 6px;
      padding: 2px 7px; display: inline-block;
    }
    /* ── Delete button ── */
    .btn-delete {
      padding: 5px 10px; border-radius: 7px; border: none;
      background: #ef5350; color: #fff; cursor: pointer;
      font-size: 12px; font-weight: 600; width: 100%;
    }
    .btn-delete:hover { background: #e53935; }
    /* ── Feedback banner (delete success / error) ── */
    .wo-alert {
      display: flex; align-items: center; justify-content: space-between;
      gap: 12px; padding: 12px 16px; border-radius: 10px;
      margin-bottom: 16px; font-size: 13px; font-weight: 500;
    }
    .wo-alert.success { background: #e8f5e9; color: #2e7d32; border: 1px solid #a5d6a7; }
    .wo-alert.error    { background: #ffebee; color: #c62828; border: 1px solid #ef9a9a; }
    .wo-alert .close-alert {
      background: none; border: none; cursor: pointer;
      font-size: 14px; color: inherit; opacity: .7;
    }
    .wo-alert .close-alert:hover { opacity: 1; }
  </style>
</head>
<body>

<!-- SIDEBAR -->
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
    <a href="<%=bookingLink%>" class="nav-item">
      <div class="nav-dot" style="background:#ff8a65"></div><span>Booking</span>
    </a>
    <% if (isAdmin || isMechanic) { %>
    <a href="<%=ctxPath%>/WorkOrderServlet?action=list" class="nav-item active">
      <div class="nav-dot" style="background:#42a5f5"></div><span>Work Order</span>
    </a>
    <% } %>
    <% if (isAdmin) { %>
    <a href="<%=ctxPath%>/payment?tab=invoices" class="nav-item">
      <div class="nav-dot" style="background:#66bb6a"></div><span>Payment</span>
    </a>
    <a href="<%=ctxPath%>/InventoryServlet" class="nav-item">
      <div class="nav-dot" style="background:#ab47bc"></div><span>Inventory</span>
    </a>
    <a href="<%=ctxPath%>/ReportServlet" class="nav-item">
      <div class="nav-dot" style="background:#78909c"></div><span>Reports</span>
    </a>
    <% } %>
    <% if (isAdmin || isMechanic) { %>
    <a href="<%=ctxPath%>/SettingsServlet" class="nav-item">
      <div class="nav-dot" style="background:#78909c"></div><span>Settings</span>
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

<!-- MAIN -->
<main class="main">
  <div class="topbar">
    <div class="page-title">🔧 Work Order</div>
    <div class="topbar-right">
      <div class="date-badge" id="dateDisplay"></div>
    </div>
  </div>

  <div class="content">

    <%-- ── FEEDBACK BANNER: hasil dari redirect (delete success/error) ── --%>
    <c:if test="${param.deleted == '1'}">
      <div class="wo-alert success" id="woAlert">
        <span>✅ Work order delete successful.</span>
        <button type="button" class="close-alert" onclick="document.getElementById('woAlert').style.display='none'">✕</button>
      </div>
    </c:if>
    <c:if test="${param.error == 'hasInvoice'}">
      <div class="wo-alert error" id="woAlert">
        <span>❌ Cannot delete , this  work order has already in invoice list.</span>
        <button type="button" class="close-alert" onclick="document.getElementById('woAlert').style.display='none'">✕</button>
      </div>
    </c:if>
    <c:if test="${param.error == 'deleteFailed'}">
      <div class="wo-alert error" id="woAlert">
        <span>❌ Failed to delete, try again.</span>
        <button type="button" class="close-alert" onclick="document.getElementById('woAlert').style.display='none'">✕</button>
      </div>
    </c:if>
    <c:if test="${param.error == 'missingId'}">
      <div class="wo-alert error" id="woAlert">
        <span>❌ Work Order ID cannot undentified.</span>
        <button type="button" class="close-alert" onclick="document.getElementById('woAlert').style.display='none'">✕</button>
      </div>
    </c:if>

    <!-- ── STATS (dari DB total, bukan current page) ── -->
    <div class="wo-stats">
      <div class="wstat">
        <div class="wstat-label">Total</div>
        <div class="wstat-val">${totalRows}</div>
      </div>
      <div class="wstat">
        <div class="wstat-label">Pending</div>
        <div class="wstat-val">${statPending}</div>
      </div>
      <div class="wstat">
        <div class="wstat-label">In Progress</div>
        <div class="wstat-val">${statInProgress}</div>
      </div>
      <div class="wstat">
        <div class="wstat-label">Completed</div>
        <div class="wstat-val">${statCompleted}</div>
      </div>
      <div class="wstat">
        <div class="wstat-label">Cancelled</div>
        <div class="wstat-val">${statCancelled}</div>
      </div>
    </div>

    <!-- ── CREATE WORK ORDER (ADMIN ONLY) ── -->
    <c:if test="${sessionScope.user.role == 'admin'}">
      <div class="create-section">
        <div class="section-title">Create Work Order</div>
        <c:choose>
          <c:when test="${not empty pendingBookings}">
            <form action="WorkOrderServlet" method="post">
              <input type="hidden" name="action" value="create"/>
              <div class="form-grid">
                <div class="form-group">
                  <label>Choose Booking</label>
                  <select name="bookingID" required>
                    <option value="">-- Choose --</option>
                    <c:forEach var="pb" items="${pendingBookings}">
                      <option value="${pb.bookingID}">
                        ${pb.bookingID} | ${pb.customer_name} | ${pb.plate_no}
                      </option>
                    </c:forEach>
                  </select>
                </div>
                <div class="form-group">
                  <label>Assign Mechanic</label>
                  <select name="mechanic_id">
                    <option value="">-- Unassigned --</option>
                    <c:forEach var="m" items="${mechanics}">
                      <option value="${m.userid}">${m.name}</option>
                    </c:forEach>
                  </select>
                </div>
                <div class="form-group">
                  <label>Notes</label>
                  <input type="text" name="notes" placeholder="Additional note..."/>
                </div>
                <button type="submit" class="btn-create-wo">Create</button>
              </div>
            </form>
          </c:when>
          <c:otherwise>
            <p style="color:var(--muted); font-size:14px;">✅ All booking has work order.</p>
          </c:otherwise>
        </c:choose>
      </div>
    </c:if>

    <!-- ── WORK ORDER TABLE ── -->
    <div class="wo-table-section">
      <div class="wo-table-topbar">
        <h3>List of Work Order
          <small style="font-size:12px; font-weight:400; color:var(--muted);">
            — Page ${currentPage} of ${totalPages}
          </small>
        </h3>
        <select class="wo-filter-select" onchange="filterWO(this.value)">
          <option value="all">All Status</option>
          <option value="Pending">Pending</option>
          <option value="In Progress">In Progress</option>
          <option value="Completed">Completed</option>
          <option value="Cancelled">Cancelled</option>
        </select>
      </div>

      <table id="woTable">
        <thead>
          <tr>
            <th>WO ID</th>
            <th>Booking ID</th>
            <th>Customer</th>
            <th>Plate</th>
            <th>Service</th>
            <th>Mechanic</th>
            <th>Repair Info</th>
            <th>Status</th>
            <th>Date</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          <c:choose>
            <c:when test="${not empty workOrders}">
              <c:forEach var="wo" items="${workOrders}">
                <tr data-status="${wo.service_status}">
                  <td><span class="wo-id">${wo.work_order_id}</span></td>
                  <td><span class="booking-id">${wo.bookingID}</span></td>
                  <td>${wo.customer_name}</td>
                  <td><span class="plate-badge">${wo.plate_no}</span></td>
                  <td style="font-size:12px; color:var(--muted);">${not empty wo.services ? wo.services : '-'}</td>
                  <td>
                    <c:choose>
                      <c:when test="${not empty wo.mechanic_name}">
                        <span class="mechanic-chip">👤 ${wo.mechanic_name}</span>
                      </c:when>
                      <c:otherwise>
                        <span class="unassigned">Unassigned</span>
                      </c:otherwise>
                    </c:choose>
                  </td>

                  <%-- ── Repair Info column: notes + additional charges ── --%>
                  <td>
                    <c:if test="${not empty wo.mechanic_notes}">
                      <span class="notes-chip"
                            title="${wo.mechanic_notes}"
                            onclick="previewNotes('${wo.work_order_id}', `${wo.mechanic_notes}`)">
                        📝 ${wo.mechanic_notes}
                      </span><br/>
                    </c:if>
                    <c:if test="${not empty wo.additional_charges and wo.additional_charges != '0.00' and wo.additional_charges != '0'}">
                      <span class="charges-badge">+RM ${wo.additional_charges}</span>
                    </c:if>
                    <c:if test="${empty wo.mechanic_notes and (empty wo.additional_charges or wo.additional_charges == '0.00' or wo.additional_charges == '0')}">
                      <span style="color:var(--muted); font-size:12px;">—</span>
                    </c:if>
                  </td>

                  <td>
                    <c:choose>
                      <c:when test="${wo.service_status == 'Pending'}"><span class="status-badge s-pending">⏳ Pending</span></c:when>
                      <c:when test="${wo.service_status == 'In Progress'}"><span class="status-badge s-inprogress">🔧 In Progress</span></c:when>
                      <c:when test="${wo.service_status == 'Completed'}"><span class="status-badge s-completed">✅ Completed</span></c:when>
                      <c:when test="${wo.service_status == 'Cancelled'}"><span class="status-badge s-cancelled">❌ Cancelled</span></c:when>
                      <c:otherwise><span class="status-badge">${wo.service_status}</span></c:otherwise>
                    </c:choose>
                  </td>
                  <td style="font-size:12px; color:var(--muted);">${wo.createdDate}</td>

                  <td>
                    <div style="display:flex; flex-direction:column; gap:6px;">

                      <%-- ── Update Status + Repair Notes button ── --%>
                      <div style="display:flex; gap:6px; align-items:center;">
                        <select id="sel-${wo.work_order_id}"
                                style="flex:1; font-size:12px; padding:5px 8px; border-radius:7px; border:1px solid var(--border,#ddd);">
                          <option ${wo.service_status == 'Pending'     ? 'selected' : ''}>Pending</option>
                          <option ${wo.service_status == 'In Progress' ? 'selected' : ''}>In Progress</option>
                          <option ${wo.service_status == 'Completed'   ? 'selected' : ''}>Completed</option>
                          <option ${wo.service_status == 'Cancelled'   ? 'selected' : ''}>Cancelled</option>
                        </select>
                        <button type="button" class="btn-update"
                                onclick="openUpdateModal(
                                  '${wo.work_order_id}',
                                  document.getElementById('sel-${wo.work_order_id}').value,
                                  `${wo.notes}`,
                                  `${wo.mechanic_notes}`,
                                  '${wo.additional_charges}'
                                )">
                          Update
                        </button>
                      </div>

                      <%-- ── Assign Mechanic (Admin Only) ── --%>
                      <c:if test="${sessionScope.user.role == 'admin'}">
                        <form action="WorkOrderServlet" method="post" class="action-form">
                          <input type="hidden" name="action" value="assign"/>
                          <input type="hidden" name="work_order_id" value="${wo.work_order_id}"/>
                          <select name="mechanic_id">
                            <option value="">-- Assign --</option>
                            <c:forEach var="m" items="${mechanics}">
                              <option value="${m.userid}" ${wo.mechanic_id == m.userid ? 'selected' : ''}>${m.name}</option>
                            </c:forEach>
                          </select>
                          <button type="submit" class="btn-assign">Assign</button>
                        </form>
                      </c:if>

                      <%-- ── Delete Work Order (Admin Only) ── --%>
                      <c:if test="${sessionScope.user.role == 'admin'}">
                        <form action="WorkOrderServlet" method="post" class="action-form"
                              onsubmit="return confirm('Delete Work Order ${wo.work_order_id}? this action cannot undo.');">
                          <input type="hidden" name="action" value="delete"/>
                          <input type="hidden" name="work_order_id" value="${wo.work_order_id}"/>
                          <button type="submit" class="btn-delete">🗑 Delete</button>
                        </form>
                      </c:if>

                    </div>
                  </td>
                </tr>
              </c:forEach>
            </c:when>
            <c:otherwise>
              <tr>
                <td colspan="10">
                  <div class="empty-state">
                    <div class="icon">🔧</div>
                    <p>No work order yet. Create from booking above!</p>
                  </div>
                </td>
              </tr>
            </c:otherwise>
          </c:choose>
        </tbody>
      </table>

      <%-- ── PAGINATION ── --%>
      <c:if test="${totalPages > 1}">
        <div class="pagination">
          <%-- Prev --%>
          <c:choose>
            <c:when test="${currentPage > 1}">
              <a href="WorkOrderServlet?action=list&page=${currentPage - 1}">‹ Prev</a>
            </c:when>
            <c:otherwise>
              <span class="disabled">‹ Prev</span>
            </c:otherwise>
          </c:choose>

          <%-- Page numbers (tunjuk max 5 page number) --%>
          <c:set var="startPage" value="${currentPage - 2 < 1 ? 1 : currentPage - 2}"/>
          <c:set var="endPage"   value="${startPage + 4 > totalPages ? totalPages : startPage + 4}"/>
          <c:forEach var="p" begin="${startPage}" end="${endPage}">
            <c:choose>
              <c:when test="${p == currentPage}">
                <span class="active">${p}</span>
              </c:when>
              <c:otherwise>
                <a href="WorkOrderServlet?action=list&page=${p}">${p}</a>
              </c:otherwise>
            </c:choose>
          </c:forEach>

          <%-- Next --%>
          <c:choose>
            <c:when test="${currentPage < totalPages}">
              <a href="WorkOrderServlet?action=list&page=${currentPage + 1}">Next ›</a>
            </c:when>
            <c:otherwise>
              <span class="disabled">Next ›</span>
            </c:otherwise>
          </c:choose>
        </div>
      </c:if>

    </div><%-- end wo-table-section --%>
  </div><%-- end content --%>
</main>

<!-- ══════════════════════════════════════════
     MODAL — Update Status + Repair Notes + Caj Tambahan
     ══════════════════════════════════════════ -->
<div class="modal-overlay" id="updateModal">
  <div class="modal-box">
    <h3>🔧 Update Work Order</h3>
    <form action="WorkOrderServlet" method="post" id="updateForm">
      <input type="hidden" name="action"        value="updateStatus"/>
      <input type="hidden" name="work_order_id" id="modal-wo-id"/>
      <input type="hidden" name="notes"         id="modal-admin-notes"/>

      <label>Status</label>
      <select name="service_status" id="modal-status">
        <option>Pending</option>
        <option>In Progress</option>
        <option>Completed</option>
        <option>Cancelled</option>
      </select>

      <label>Service Notes 
    <span style="color:var(--muted);font-size:11px;">
        (Repairs performed / parts replaced)
    </span>
</label>

<textarea name="mechanic_notes" id="modal-mechanic-notes"
          placeholder="Enter details of repairs performed, parts replaced, and maintenance work completed..."></textarea>

      <label>Extra Charge (RM) <span style="color:var(--muted);font-size:11px;">(if any)</span></label>
      <input type="number" name="additional_charges" id="modal-charges"
             min="0" step="0.01" placeholder="0.00"/>

      <div class="modal-footer">
        <button type="button" class="btn-cancel-modal" onclick="closeModal()">Cancel</button>
        <button type="submit" class="btn-save-modal">Save</button>
      </div>
    </form>
  </div>
</div>

<!-- ══════════════════════════════════════════
     MODAL — Preview repair notes (read-only)
     ══════════════════════════════════════════ -->
<div class="modal-overlay" id="notesModal">
  <div class="modal-box">
    <h3>📝 Repair Notes</h3>
    <p id="notes-preview-text"
       style="font-size:14px; line-height:1.7; color:var(--text); white-space:pre-wrap;"></p>
    <div class="modal-footer">
      <button type="button" class="btn-cancel-modal" onclick="closeNotesModal()">Tutup</button>
    </div>
  </div>
</div>

<script>
document.getElementById('dateDisplay').textContent =
  new Date().toLocaleDateString('en-MY',{weekday:'short',day:'numeric',month:'long',year:'numeric'});

/* ── Filter by status (current page rows) ── */
function filterWO(status) {
  document.querySelectorAll('#woTable tbody tr[data-status]').forEach(row => {
    row.style.display = (status === 'all' || row.dataset.status === status) ? '' : 'none';
  });
}

/* ── Open update modal ── */
function openUpdateModal(woId, currentStatus, adminNotes, mechanicNotes, charges) {
  document.getElementById('modal-wo-id').value          = woId;
  document.getElementById('modal-admin-notes').value    = adminNotes;
  document.getElementById('modal-mechanic-notes').value = mechanicNotes === 'null' ? '' : mechanicNotes;
  document.getElementById('modal-charges').value        = (charges === 'null' || charges === '0.00' || charges === '0') ? '' : charges;

  const sel = document.getElementById('modal-status');
  for (let opt of sel.options) {
    opt.selected = opt.value === currentStatus;
  }

  /* sync status select dalam table bila modal dibuka */
  document.getElementById('updateModal').classList.add('open');
}

function closeModal() {
  document.getElementById('updateModal').classList.remove('open');
}

/* ── Preview notes modal ── */
function previewNotes(woId, notes) {
  document.getElementById('notes-preview-text').textContent = notes;
  document.getElementById('notesModal').classList.add('open');
}

function closeNotesModal() {
  document.getElementById('notesModal').classList.remove('open');
}

/* ── Close modal bila klik luar kotak ── */
document.getElementById('updateModal').addEventListener('click', function(e) {
  if (e.target === this) closeModal();
});
document.getElementById('notesModal').addEventListener('click', function(e) {
  if (e.target === this) closeNotesModal();
});

/* ── Auto-hide feedback banner lepas 5 saat ── */
(function () {
  const alertBox = document.getElementById('woAlert');
  if (alertBox) {
    setTimeout(() => { alertBox.style.display = 'none'; }, 5000);
  }
})();
</script>

</body>
</html>
