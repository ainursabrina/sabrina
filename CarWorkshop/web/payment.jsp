<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Invoice" %>
<%@ page import="model.PaymentHistory" %>
<%@ page import="dao.PaymentHistoryDAO" %>

<%
    String tab             = (String) request.getAttribute("tab");
    if (tab == null) tab = request.getParameter("tab"); 
    if (tab == null) tab   = "invoices";
    String toast           = (String) request.getAttribute("toast");
    Double totalRevenue    = (Double)  request.getAttribute("totalRevenue");
    Integer pendingCount   = (Integer) request.getAttribute("pendingCount");
    Integer totalCount     = (Integer) request.getAttribute("totalCount");
    Integer overdueCount   = (Integer) request.getAttribute("overdueCount");
    if (totalRevenue  == null) totalRevenue  = 0.0;
    if (pendingCount  == null) pendingCount  = 0;
    if (totalCount    == null) totalCount    = 0;
    if (overdueCount  == null) overdueCount  = 0;

    List<Invoice>        invoices  = (List<Invoice>)        request.getAttribute("invoices");
    List<PaymentHistory> histList  = (List<PaymentHistory>) request.getAttribute("histList");
    Invoice selectedInv            = (Invoice)              request.getAttribute("selectedInvoice");

    String q            = (String) request.getAttribute("q");             if(q==null)q="";
    String filterStatus = (String) request.getAttribute("filterStatus");  if(filterStatus==null)filterStatus="";
    String filterLinked = (String) request.getAttribute("filterLinked");  if(filterLinked==null)filterLinked="";
    String histQ        = (String) request.getAttribute("histQ");         if(histQ==null)histQ="";
    String histMethod   = (String) request.getAttribute("histMethod");    if(histMethod==null)histMethod="";
    String histLinked   = (String) request.getAttribute("histLinked");    if(histLinked==null)histLinked="";

    Double  totalCollected = (Double)  request.getAttribute("totalCollected"); if(totalCollected==null)totalCollected=0.0;
    Integer linkedCount    = (Integer) request.getAttribute("linkedCount");    if(linkedCount==null)linkedCount=0;
    Integer histTotal      = (Integer) request.getAttribute("histTotal");      if(histTotal==null)histTotal=0;
    int     unlinkedCount  = histTotal - linkedCount;

    String ctxPath = request.getContextPath();

    String username = (String) session.getAttribute("username");
    String role     = (String) session.getAttribute("role");

    if (username == null || username.trim().isEmpty()) username = "Guest";
    if (role == null) role = "guest";
    role = role.toLowerCase();

    boolean isAdmin    = "admin".equals(role);
    boolean isMechanic = "mechanic".equals(role);
    boolean isCustomer = "customer".equals(role);
    boolean isGuest    = "guest".equals(role);

    String avatar    = username.substring(0,1).toUpperCase();
    String roleLabel = isAdmin ? "Administrator" : isMechanic ? "Mechanic" : isCustomer ? "Customer" : "Guest";
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Manage Payment — AutoCare WMS</title>
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/payment.css">
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
        <a class="nav-item" href="homepage.jsp">
            <div class="nav-dot" style="background:#ef5350"></div>
            <span>Dashboard</span>
        </a>
    <a class="nav-item" href="<%=ctxPath%>/services.jsp">
      <div class="nav-dot" style="background:#ffa726"></div>
      <span>Services</span>
    </a>
        
    <a class="nav-item" href="<%=ctxPath%>/BookingServlet?action=<%= isAdmin || isMechanic ? "adminList" : "add" %>">
      <div class="nav-dot" style="background:#ff8a65"></div>
      <span>Booking</span>
    </a>

    <% if (isAdmin || isMechanic) { %>
    <a class="nav-item" href="<%=ctxPath%>/WorkOrderServlet?action=list">
      <div class="nav-dot" style="background:#42a5f5"></div>
      <span>Work Order</span>
    </a>
    <% } %>

    <% if (isAdmin || isCustomer) { %>
    <a class="nav-item active" href="<%=ctxPath%>/payment?tab=invoices">
      <div class="nav-dot" style="background:#66bb6a"></div>
      <span>Payment</span>
    </a>
    <% } %>

    <% if (isAdmin || isMechanic) { %>
    <a class="nav-item" href="<%=ctxPath%>/inventory.jsp">
      <div class="nav-dot" style="background:#ab47bc"></div>
      <span>Inventory</span>
    </a>
    <% } %>

     <% if (isAdmin) { %>
    <a class="nav-item" href="<%=ctxPath%>/report.jsp">
      <div class="nav-dot" style="background:var(--muted)"></div>
      <span>Reports</span>
    </a>
    <% } %>

    <% if (isAdmin || isMechanic || isCustomer) { %>
    <a class="nav-item" href="<%=ctxPath%>/settings.jsp">
      <div class="nav-dot" style="background:var(--muted)"></div>
      <span>Settings</span>
    </a>
    <% } %>
  </nav>

  <!-- FOOTER USER -->
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

<%-- ═══ MAIN ═══ --%>
<main class="main">
  <div class="topbar">
    <div class="page-title">Payment <span style="color:var(--muted);font-size:18px;font-weight:400"></span></div>
    <div class="topbar-right">
      <div class="date-badge" id="dateDisplay"></div>
    </div>
  </div>

  <div class="content">

    <%-- ═══ STATS ═══ --%>
    <div class="stats-grid">
      <div class="stat-card green">
        <div class="stat-icon">💰</div>
        <div class="stat-label">Total Revenue</div>
        <div class="stat-value">RM <%= String.format("%,.2f", totalRevenue) %></div>
        <div class="stat-sub">paid invoices</div>
      </div>
      <div class="stat-card orange">
        <div class="stat-icon">⏳</div>
        <div class="stat-label">Pending Payments</div>
        <div class="stat-value"><%= pendingCount %></div>
        <div class="stat-sub">awaiting payment</div>
      </div>
      <div class="stat-card blue">
        <div class="stat-icon">📋</div>
        <div class="stat-label">Total Invoices</div>
        <div class="stat-value"><%= totalCount %></div>
        <div class="stat-sub">all records</div>
      </div>
      <div class="stat-card red">
        <div class="stat-icon">🚨</div>
        <div class="stat-label">Overdue</div>
        <div class="stat-value"><%= overdueCount %></div>
        <div class="stat-sub"><%= overdueCount > 0 ? "needs attention!" : "none" %></div>
      </div>
    </div>

    <%-- ═══ TABS ═══ --%>
    <div class="tab-row">
    <a href="<%=ctxPath%>/payment?tab=invoices" class="tab-btn <%= "invoices".equals(tab) ? "active" : "" %>">💳 Invoices</a>
   
    <a href="<%=ctxPath%>/payment?tab=history"  class="tab-btn <%= "history".equals(tab)  ? "active" : "" %>">📜 History</a>
     <%-- ════════════════════════════════════════
        
    <% if (isAdmin) { %>
    <a href="<%=ctxPath%>/payment?tab=record"   class="tab-btn <%= "record".equals(tab)   ? "active" : "" %>">➕ Record Payment</a>
    <% } %>
     
    ════════════════════════════════════════ --%>
  </div>

    <%-- ════════════════════════════════════════
         TAB: INVOICES
    ════════════════════════════════════════ --%>
    <% if ("invoices".equals(tab)) { %>
    <div class="payment-layout">

      <%-- Invoice Table Panel --%>
      <div class="panel">
        <div class="panel-header">
          <div class="panel-title">Invoice List
            <span style="color:var(--muted);font-size:14px;font-weight:400">
              (<%= invoices != null ? invoices.size() : 0 %>)
            </span>
          </div>
          <div class="panel-actions">
            <form method="get" action="<%=ctxPath%>/payment" style="display:flex;gap:8px;flex-wrap:wrap">
              <input type="hidden" name="tab" value="invoices"/>
              <div class="search-box">
                <span>🔍</span>
                <input type="text" name="q" placeholder="Search invoice, customer..." value="<%=q%>">
              </div>
              <select name="status" class="form-control" style="width:140px;padding:8px 12px;font-size:13px">
                <option value="">All Status</option>
                <option value="Paid"    <%= "Paid".equals(filterStatus)    ? "selected" : "" %>>Paid</option>
                <option value="Pending" <%= "Pending".equals(filterStatus) ? "selected" : "" %>>Pending</option>
                <option value="Partial" <%= "Partial".equals(filterStatus) ? "selected" : "" %>>Partial</option>
                <option value="Overdue" <%= "Overdue".equals(filterStatus) ? "selected" : "" %>>Overdue</option>
              </select>
              <!--
              <select name="linked" class="form-control" style="width:130px;padding:8px 12px;font-size:13px">
                <option value="">All Types</option>
                <option value="linked"   <%= "linked".equals(filterLinked)   ? "selected" : "" %>>🔗 Linked</option>
                <option value="unlinked" <%= "unlinked".equals(filterLinked) ? "selected" : "" %>>📝 Standalone</option>
              </select>
              
              <button type="submit" class="btn btn-green btn-sm">🔍 Filter</button> -->
              <a href="<%=ctxPath%>/payment?tab=invoices" class="btn btn-outline btn-sm">Reset</a>
            </form>
          </div>
        </div>

        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Invoice No.</th>
                <th>Customer</th>
                <th>Vehicle</th>
                <th>Services</th>
                <th>Amount (RM)</th>
                <th>Status</th>
                <th>Date</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
            <% if (invoices == null || invoices.isEmpty()) { %>
              <tr><td colspan="8" style="text-align:center;padding:40px;color:var(--muted)">No invoices found.</td></tr>
            <% } else { for (Invoice inv : invoices) {
                String badgeCls = "badge-pending";
                if ("Paid".equals(inv.getStatus()))    badgeCls = "badge-paid";
                if ("Partial".equals(inv.getStatus())) badgeCls = "badge-partial";
                if ("Overdue".equals(inv.getStatus())) badgeCls = "badge-overdue";
                boolean isSelected = selectedInv != null && selectedInv.getId().equals(inv.getId());
                String linkLabel = "";
                if (inv.isLinked()) {
                    boolean hasWO = inv.getWoId()!=null && !inv.getWoId().isEmpty();
                    boolean hasBK = inv.getBkId()!=null && !inv.getBkId().isEmpty();
                    linkLabel = hasWO && hasBK ? "WO+BK" : hasWO ? "WO" : "BK";
                }
            %>
              <tr class="<%= isSelected ? "selected-row" : "" %>">
                <td>
                  <b><%=inv.getId()%></b>
                  <% if (inv.isLinked()) { %>
                    <span class="link-badge">🔗 <%=linkLabel%></span>
                  <% } else { %>
                    <span class="no-link-badge">📝 standalone</span>
                  <% } %>
                </td>
                <td><%=inv.getCustomer()%></td>
                <td style="color:var(--muted);font-size:12px"><%=inv.getVehicle()%></td>
                <td style="color:var(--muted);font-size:12px;max-width:160px;overflow:hidden;text-overflow:ellipsis"><%=inv.getServices()%></td>
                <td>
                  <b>RM <%=String.format("%.2f", inv.getNet())%></b>
                  <% if (inv.getDiscount() > 0) { %>
                    <br><span style="font-size:10px;color:var(--red)">-RM<%=String.format("%.2f",inv.getDiscount())%></span>
                  <% } %>
                </td>
                <td><span class="badge <%=badgeCls%>"><span class="badge-dot"></span><%=inv.getStatus()%></span></td>
                <td style="color:var(--muted);font-size:12px"><%=inv.getInvDate()%></td>
                <td>
                  <a href="<%=ctxPath%>/payment?tab=invoices&sel=<%=inv.getId()%>" class="btn btn-outline btn-sm">👁 Select</a>
                </td>
              </tr>
            <% } } %>
            </tbody>
          </table>
        </div>
      </div><%-- end panel --%>

      <%-- ═══ DETAIL / PAY PANEL ═══ --%>
      <div class="detail-panel">
        <div class="form-title">💳 Payment Details</div>

        <% if (selectedInv == null) { %>
          <div style="text-align:center;padding:32px 0;color:var(--muted)">
            <div style="font-size:44px;margin-bottom:14px;opacity:.25">💳</div>
            <div style="font-size:13px;line-height:1.7">Click 👁 Select on any invoice<br>to view or process payment.</div>
          </div>
        <% } else {
            boolean isPaid = "Paid".equals(selectedInv.getStatus());
            boolean hasWO = selectedInv.getWoId()!=null && !selectedInv.getWoId().isEmpty();
            boolean hasBK = selectedInv.getBkId()!=null && !selectedInv.getBkId().isEmpty();
        %>
          <div class="form-sub">Review details and process payment below.</div>
       
          <%-- Linked Records Box --%>
          <% if (selectedInv.isLinked()) { %>
          <div class="link-info">
            <div class="link-info-header">🔗 Linked Records</div>
            <% if (hasWO) { %>
            <div class="link-info-row">
              <span class="link-key">Work Order</span>
              <span class="link-val-blue"><%=selectedInv.getWoId()%></span>
            </div>
            <% } %>
            <% if (hasBK) { %>
            <div class="link-info-row">
              <span class="link-key">Booking</span>
              <span class="link-val-orange"><%=selectedInv.getBkId()%></span>
            </div>
            <% } %>
          </div>
          <% } else { %>
          <div class="no-link-box">
            📝 <b style="color:var(--text)">Standalone invoice</b> — not linked to any Work Order or Booking.
          </div>
          <% } %>
       

          <div class="form-group">
            <label class="form-label">Invoice No.</label>
            <input class="form-control" value="<%=selectedInv.getId()%>" readonly>
          </div>
          <div class="form-group">
            <label class="form-label">Customer</label>
            <input class="form-control" value="<%=selectedInv.getCustomer()%>" readonly>
          </div>
          <div class="form-group">
            <label class="form-label">Vehicle</label>
            <input class="form-control" value="<%=selectedInv.getVehicle()%>" readonly>
          </div>
          <div class="form-group">
            <label class="form-label">Services</label>
            <input class="form-control" value="<%=selectedInv.getServices()%>" readonly>
          </div>

          <div class="amount-display">
            <div class="amount-row"><span class="amount-label">Subtotal</span><span>RM <%=String.format("%.2f",selectedInv.getAmount())%></span></div>
            <div class="amount-row"><span class="amount-label">Discount</span><span style="color:var(--red)">-RM <%=String.format("%.2f",selectedInv.getDiscount())%></span></div>
            <div class="amount-row"><span class="amount-label">Total Due</span><span class="amount-total">RM <%=String.format("%.2f",selectedInv.getNet())%></span></div>
          </div>

          <%-- ═══ BARU: View Full Invoice (tab baru) ═══ --%>
          <a href="<%=ctxPath%>/payment?action=viewInvoice&id=<%=selectedInv.getId()%>"
             target="_blank"
             class="btn btn-green btn-full" style="margin-bottom:10px;text-align:center;display:block">
             🔍 View Full <%= isPaid ? "Receipt" : "Invoice" %>
          </a>

          <!--
            BARU: Download PDF / Email Invoice — DISABLE SEMENTARA
            Sebab openpdf-1.3.39.jar belum diletak dalam WEB-INF/lib,
            servlet action downloadPdf/emailPdf pun di-comment (lihat PaymentServlet.java).
            Bila jar dah siap dipasang, tambah balik block ni:

            <div style="display:flex;gap:8px;margin-bottom:16px">
              <a href="[ctxPath]/payment?action=downloadPdf&id=[invoiceId]"
                 class="btn btn-outline btn-sm" style="flex:1;text-align:center">
                 Download Receipt/Invoice PDF
              </a>
              <form method="post" action="[ctxPath]/payment" style="flex:1">
                <input type="hidden" name="action" value="emailPdf"/>
                <input type="hidden" name="id" value="[invoiceId]"/>
                <button type="submit" class="btn btn-outline btn-sm" style="width:100%">
                  Email Receipt/Invoice
                </button>
              </form>
            </div>
          -->

           <%-- TAMBAH DI SINI --%>
          <% if (isAdmin && !isPaid) { %>
          <details style="margin-bottom:16px">
            <summary style="cursor:pointer;font-weight:600;color:var(--accent)">
              ✏️ Edit Amount / Charges
            </summary>
            <form method="post" action="<%=ctxPath%>/payment" style="margin-top:12px">
              <input type="hidden" name="action" value="editAmount"/>
              <input type="hidden" name="id"     value="<%=selectedInv.getId()%>"/>
              <div class="form-group">
                <label class="form-label">Services</label>
                <input class="form-control" name="services"
                       value="<%=selectedInv.getServices()%>"
                       placeholder="e.g. Full Service, Tyre Replacement"/>
              </div>   
              <div class="form-row">
                <div class="form-group">
                  <label class="form-label">Amount (RM)</label>
                  <input class="form-control" name="amount" type="number" step="0.01"
                         value="<%=selectedInv.getAmount()%>" required/>
                </div>
                <div class="form-group">
                  <label class="form-label">Discount (RM)</label>
                  <input class="form-control" name="discount" type="number" step="0.01"
                         value="<%=selectedInv.getDiscount()%>"/>
                </div>
              </div>
              <div class="form-group">
                <label class="form-label">Notes</label>
                <input class="form-control" name="notes"
                       value="<%=selectedInv.getNotes()%>" 
                       placeholder="Sebab perubahan harga..."/>
              </div>
              <button type="submit" class="btn btn-green btn-sm">💾 Update Amount</button>
            </form>
          </details>
          <% } %>
          
          <!--
          <%-- Update Status --%>
          <div class="form-group">
            <label class="form-label">Update Status</label>
            <div class="status-row">
              <% String[] statuses = {"Paid","Pending","Partial","Overdue"};
                 String[] chipCls  = {"chip-paid","chip-pending","chip-partial","chip-overdue"};
                 String[] chipLbl  = {"✅ Paid","⏳ Pending","💙 Partial","🚨 Overdue"};
                 for (int si=0; si<statuses.length; si++) { %>
              <form method="post" action="<%=ctxPath%>/payment" style="display:inline">
                <input type="hidden" name="action" value="updateStatus"/>
                <input type="hidden" name="id"     value="<%=selectedInv.getId()%>"/>
                <input type="hidden" name="status" value="<%=statuses[si]%>"/>
                <button type="submit" class="status-chip <%=chipCls[si]%>"><%=chipLbl[si]%></button>
              </form>
              <% } %>
            </div>
          </div>

          <% if (isPaid) { %>
          <div class="paid-badge">✅ Paid via <b><%=selectedInv.getMethod() != null && !selectedInv.getMethod().isEmpty() ? selectedInv.getMethod() : "Cash"%></b></div>
          <% } else { %>
          
          
          <%-- Process Payment Form (Cash/Card/Cheque/DuitNow manual) --%>
          <form method="post" action="<%=ctxPath%>/payment">
            <input type="hidden" name="action" value="processPayment"/>
            <input type="hidden" name="id"     value="<%=selectedInv.getId()%>"/>
            <div class="form-group">
              <label class="form-label">Payment Method</label>
              <select name="method" class="form-control">
                
                <option value="Card">💳 Card</option>
                <option value="Online">📱 Toyyibpay</option>
                
              </select>
            </div>
            <div class="form-group">
              <label class="form-label">Notes (optional)</label>
              <textarea name="notes" class="form-control" rows="2" placeholder="e.g. Ref: DuitNow #12345..." style="resize:none"></textarea>
            </div>
            <div class="form-divider"></div>
            <button type="submit" class="btn btn-green btn-full">💾 Record Payment</button>
          </form>
           
          <%-- Simulate Toyyibpay --%>
           <form method="post" action="<%=ctxPath%>/payment">
                <input type="hidden" name="action" value="processPayment"/>
                <input type="hidden" name="id" value="<%=selectedInv.getId()%>"/>
                <input type="hidden" name="method" value="Online (Toyyibpay)"/>
                <button type="submit" class="btn btn-toyyibpay btn-full">
                    🧪 Simulate Toyyibpay Payment
                </button>
            </form>
          <%-- Divider --%>
          <div class="pay-divider">or pay online</div> 
          -->

          <%-- Toyyibpay Section --%>
          <div class="tp-section">
            <div class="tp-section-title">🌐 Pay via Toyyibpay Gateway</div>
            <div class="tp-logo-row">
              <div class="tp-logo-text">toyyibPay</div>
              <span class="tp-logo-sub">Payment Gateway Malaysia</span>
            </div>
            <div class="tp-channels">
              <span class="tp-channel-pill">🏦 FPX (All Banks)</span>
              <span class="tp-channel-pill">💳 Credit Card</span>
              <span class="tp-channel-pill">📱 DuitNow QR</span>
              <span class="tp-channel-pill">🏪 SPayLater</span>
            </div>
            <form method="post" action="<%=ctxPath%>/payment">
              <input type="hidden" name="action" value="payToyyibpay"/>
              <input type="hidden" name="id"     value="<%=selectedInv.getId()%>"/>
              <div class="form-group">
                <label class="form-label">Email Customer *</label>
                <input class="form-control" name="tp_email" type="email" placeholder="customer@email.com" required/>
              </div>
              <div class="form-group">
                <label class="form-label">Phone Number *</label>
                <input class="form-control" name="tp_phone" type="tel" placeholder="e.g. 0123456789" required/>
              </div>
              <p class="tp-hint">💡 The customer will be redirected to the ToyyibPay payment gateway to complete the transaction. Once the payment is successfully processed, the system will automatically update the payment status.</p>
              <button type="submit" class="btn btn-toyyibpay btn-full">
                🌐 Pay now via Toyyibpay — RM <%=String.format("%.2f", selectedInv.getNet())%>
              </button>
            </form>
          </div>

          <% } %>

          <div class="form-divider"></div>
          <%-- Delete --%>
          <form method="get" action="<%=ctxPath%>/payment" onsubmit="return confirm('Delete <%=selectedInv.getId()%>? This cannot be undone.')">
            <input type="hidden" name="action" value="delete"/>
            <input type="hidden" name="id"     value="<%=selectedInv.getId()%>"/>
            <input type="hidden" name="tab"    value="invoices"/>
            <button type="submit" class="btn btn-danger btn-full" style="margin-top:8px">🗑️ Delete Invoice</button>
          </form>
          <a href="<%=ctxPath%>/payment?tab=invoices" class="btn btn-ghost btn-full" style="margin-top:8px">✕ Clear</a>

        <% } %>
      </div><%-- end detail panel --%>

    </div><%-- end payment-layout --%>
    <% } %>

 
    <%-- ════════════════════════════════════════
         TAB: HISTORY
    ════════════════════════════════════════ --%>
    <% if ("history".equals(tab)) { %>
    <div class="panel" style="border-radius:14px;overflow:hidden">
      <div class="panel-header">
        <div class="panel-title">📜 Payment History</div>
        <div class="panel-actions">
          <form method="get" action="<%=ctxPath%>/payment" style="display:flex;gap:8px;flex-wrap:wrap">
            <input type="hidden" name="tab" value="history"/>
            <div class="search-box">
              <span>🔍</span>
              <input type="text" name="q" placeholder="Receipt, invoice, customer..." value="<%=histQ%>">
            </div>
            
            
          </form>
          <form method="get" action="<%=ctxPath%>/payment"
                onsubmit="return confirm('Delete all payment history? Invoices are not affected.')">
            <input type="hidden" name="action" value="clearHistory"/>
            <button type="submit" class="btn btn-danger btn-sm">🗑️ Clear All</button>
          </form>
        </div>
      </div>

      <%-- Summary Bar --%>
      <div class="hist-summary">
        <div class="hist-stat">
          <div class="hist-stat-dot" style="background:var(--green)"></div>
          <span class="hist-stat-val"><%=histTotal%></span>
          <span style="color:var(--muted)"> total receipts</span>
        </div>
        <div class="hist-stat">
          <div class="hist-stat-dot" style="background:var(--green)"></div>
          <span class="hist-stat-val">RM <%=String.format("%,.2f",totalCollected)%></span>
          <span style="color:var(--muted)"> collected</span>
        </div>
        <div class="hist-stat">
          <div class="hist-stat-dot" style="background:var(--blue)"></div>
          <span class="hist-stat-val"><%=linkedCount%></span>
          <span style="color:var(--muted)"> linked (WO/BK)</span>
        </div>
        <div class="hist-stat">
          <div class="hist-stat-dot" style="background:var(--muted)"></div>
          <span class="hist-stat-val"><%=unlinkedCount%></span>
          <span style="color:var(--muted)"> standalone</span>
        </div>
      </div>

      <div class="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Receipt No.</th>
              <th>Invoice No.</th>
              <th>Customer</th>
              <th>Vehicle</th>
              <th>Method</th>
              <th>Amount (RM)</th>
              <th>Linked To</th>
              <th>Date</th>
              <th>Recorded By</th>
            </tr>
          </thead>
          <tbody>
          <% if (histList == null || histList.isEmpty()) { %>
            <tr><td colspan="9" style="text-align:center;padding:40px;color:var(--muted)">No payment history found.</td></tr>
          <% } else { for (PaymentHistory h : histList) {
              boolean hLinked = h.isLinked();
              String hWoId = h.getWoId() != null ? h.getWoId() : "";
              String hBkId = h.getBkId() != null ? h.getBkId() : "";
              String linkLabel2 = (!hWoId.isEmpty() && !hBkId.isEmpty()) ? "WO+BK" : (!hWoId.isEmpty() ? "WO" : "BK");
              String methodIcon = "Online (Toyyibpay)".equals(h.getMethod()) ? "🌐" :
                                  "Cash".equals(h.getMethod())               ? "💵" :
                                  "Card".equals(h.getMethod())               ? "💳" :
                                  "Online".equals(h.getMethod())             ? "📱" :
                                  "Cheque".equals(h.getMethod())             ? "📝" : "💰";
              boolean isToyyibpay = "Online (Toyyibpay)".equals(h.getMethod());
          %>
            <tr>
              <td><b style="color:var(--green)"><%=h.getReceiptNo()%></b></td>
              <td style="color:var(--muted);font-size:12px"><%=h.getInvoiceId()%></td>
              <td><%=h.getCustomer()%></td>
              <td style="color:var(--muted);font-size:12px"><%=h.getVehicle() != null ? h.getVehicle() : "—"%></td>
              <td>
                <%=methodIcon%> <%=h.getMethod()%>
                <% if (isToyyibpay) { %>
                  <br><span class="tp-gateway-badge">via gateway</span>
                <% } %>
              </td>
              <td>
                <b>RM <%=String.format("%.2f", h.getNet())%></b>
                <% if (h.getDiscount() > 0) { %>
                  <br><span style="font-size:10px;color:var(--red)">disc -RM<%=String.format("%.2f",h.getDiscount())%></span>
                <% } %>
              </td>
              <td>
                <% if (hLinked) { %>
                  <span class="hist-link-pill pill-linked">🔗 <%=linkLabel2%></span>
                  <br><span style="font-size:10px;color:var(--muted)">
                    <% if (!hWoId.isEmpty()) { %><span style="color:var(--blue)"><%=hWoId%></span><% } %>
                    <% if (!hWoId.isEmpty() && !hBkId.isEmpty()) { %> · <% } %>
                    <% if (!hBkId.isEmpty()) { %><span style="color:var(--accent)"><%=hBkId%></span><% } %>
                  </span>
                <% } else { %>
                  <span class="hist-link-pill pill-unlinked">📝 standalone</span>
                <% } %>
              </td>
              <td style="color:var(--muted);font-size:12px"><%=h.getRecordedAt() != null ? h.getRecordedAt() : h.getPayDate()%></td>
              <td style="color:var(--muted);font-size:12px"><%=h.getRecordedBy()%></td>
            </tr>
          <% } } %>
          </tbody>
        </table>
      </div>

      <div class="pagination">
        <span>Showing <%=histList != null ? histList.size() : 0%> records</span>
      </div>
    </div>
    <% } %>

  </div><%-- /content --%>
</main>

<%-- ═══ TOAST ═══ --%>
<div id="toast">
  <span>✅</span>
  <span id="toastMsg"><%= toast != null ? toast : "" %></span>
</div>

<script>
  document.getElementById('dateDisplay').textContent =
    new Date().toLocaleDateString('en-MY',{weekday:'short',day:'numeric',month:'long',year:'numeric'});

  <% if (toast != null && !toast.isEmpty()) { %>
  (function(){
    var t = document.getElementById('toast');
    t.classList.add('show');
    setTimeout(function(){ t.classList.remove('show'); }, 3500);
  })();
  <% } %>
</script>
</body>
</html>
