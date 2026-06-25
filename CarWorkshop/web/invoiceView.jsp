<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Invoice" %>

<%
    Invoice inv = (Invoice) request.getAttribute("viewInvoice");
    String ctxPath = request.getContextPath();

    if (inv == null) {
%>
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>Invoice Not Found</title></head>
<body style="font-family:sans-serif;text-align:center;padding:60px;color:#999">
  <h2>❌ Invoice not found</h2>
  <p>The invoice you're looking for doesn't exist or was removed.</p>
</body></html>
<%
        return;
    }

    boolean isPaid = "Paid".equals(inv.getStatus());
    String docLabel = isPaid ? "RECEIPT" : "INVOICE";
    boolean hasWO = inv.getWoId() != null && !inv.getWoId().isEmpty();
    boolean hasBK = inv.getBkId() != null && !inv.getBkId().isEmpty();

    String statusColor = isPaid ? "#2e7d32" :
                          "Overdue".equals(inv.getStatus()) ? "#c62828" :
                          "Partial".equals(inv.getStatus()) ? "#1565c0" : "#ef6c00";
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title><%=docLabel%> <%=inv.getId()%> — AutoCare WMS</title>
  <style>
    * { box-sizing: border-box; margin:0; padding:0; }
    body {
      font-family: 'Segoe UI', Arial, sans-serif;
      background: #f0efe9;
      padding: 40px 20px;
      color: #212121;
    }
    .doc {
      max-width: 720px;
      margin: 0 auto;
      background: #fff;
      border-radius: 14px;
      box-shadow: 0 4px 24px rgba(0,0,0,0.08);
      overflow: hidden;
    }
    .doc-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      padding: 36px 40px 24px;
      border-bottom: 2px solid #f0efe9;
    }
    .company-name { font-size: 22px; font-weight: 700; color: #212121; }
    .company-sub { font-size: 12px; color: #9e9e9e; margin-top: 2px; }
    .doc-label { font-size: 28px; font-weight: 800; color: #2e7d32; text-align: right; letter-spacing: 1px; }
    .doc-no { font-size: 13px; color: #9e9e9e; text-align: right; margin-top: 2px; }

    .info-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 18px 24px;
      padding: 28px 40px;
    }
    .info-item .label { font-size: 11px; font-weight: 700; color: #9e9e9e; text-transform: uppercase; letter-spacing: .5px; margin-bottom: 4px; }
    .info-item .value { font-size: 15px; color: #212121; font-weight: 500; }

    .link-strip {
      margin: 0 40px 20px;
      padding: 10px 16px;
      background: #f7f6f1;
      border-radius: 8px;
      font-size: 12px;
      color: #757575;
    }
    .link-strip b { color: #424242; }

    table.svc {
      width: calc(100% - 80px);
      margin: 0 40px;
      border-collapse: collapse;
    }
    table.svc th {
      background: #2e7d32;
      color: #fff;
      text-align: left;
      padding: 10px 14px;
      font-size: 12px;
      text-transform: uppercase;
      letter-spacing: .5px;
    }
    table.svc th:last-child, table.svc td:last-child { text-align: right; }
    table.svc td {
      padding: 14px;
      border-bottom: 1px solid #f0efe9;
      font-size: 14px;
    }

    .totals {
      width: 280px;
      margin: 20px 40px 0 auto;
      padding: 0 0 0 0;
    }
    .totals-row {
      display: flex;
      justify-content: space-between;
      padding: 6px 0;
      font-size: 14px;
      color: #616161;
    }
    .totals-row.final {
      border-top: 2px solid #f0efe9;
      margin-top: 8px;
      padding-top: 12px;
      font-size: 19px;
      font-weight: 800;
      color: #e64a19;
    }
    .totals-row.discount span:last-child { color: #c62828; }

    .status-banner {
      margin: 28px 40px 0;
      padding: 14px;
      border-radius: 10px;
      text-align: center;
      font-weight: 700;
      font-size: 15px;
      color: #fff;
      background: <%=statusColor%>;
    }

    .notes-box {
      margin: 18px 40px 0;
      font-size: 12.5px;
      color: #757575;
    }

    .doc-footer {
      text-align: center;
      padding: 30px 40px 36px;
      margin-top: 10px;
      border-top: 1px solid #f0efe9;
      font-size: 11.5px;
      color: #bdbdbd;
    }

    @media print {
      body { background: #fff; padding: 0; }
      .doc { box-shadow: none; border-radius: 0; max-width: 100%; }
    }
  </style>
</head>
<body>

  <div class="doc">

    <div class="doc-header">
      <div>
        <div class="company-name">AutoCare Workshop</div>
        <div class="company-sub">Workshop Management System</div>
      </div>
      <div>
        <div class="doc-label"><%=docLabel%></div>
        <div class="doc-no"><%=inv.getId()%></div>
      </div>
    </div>

    <div class="info-grid">
      <div class="info-item">
        <div class="label">Customer</div>
        <div class="value"><%=inv.getCustomer()%></div>
      </div>
      <div class="info-item">
        <div class="label">Date</div>
        <div class="value"><%=inv.getInvDate()%></div>
      </div>
      <div class="info-item">
        <div class="label">Vehicle</div>
        <div class="value"><%=inv.getVehicle() != null ? inv.getVehicle() : "—"%></div>
      </div>
      <div class="info-item">
        <div class="label">Status</div>
        <div class="value"><%=inv.getStatus()%></div>
      </div>
    </div>

    <% if (inv.isLinked()) { %>
    <div class="link-strip">
      🔗 Linked to:
      <% if (hasWO) { %> <b>Work Order <%=inv.getWoId()%></b><% } %>
      <% if (hasWO && hasBK) { %> &nbsp;·&nbsp; <% } %>
      <% if (hasBK) { %> <b>Booking <%=inv.getBkId()%></b><% } %>
    </div>
    <% } %>

    <table class="svc">
      <thead>
        <tr><th>Description</th><th>Amount (RM)</th></tr>
      </thead>
      <tbody>
        <tr>
          <td><%=inv.getServices() != null ? inv.getServices() : "—"%></td>
          <td><%=String.format("%.2f", inv.getAmount())%></td>
        </tr>
      </tbody>
    </table>

    <div class="totals">
      <div class="totals-row">
        <span>Subtotal</span>
        <span>RM <%=String.format("%.2f", inv.getAmount())%></span>
      </div>
      <div class="totals-row discount">
        <span>Discount</span>
        <span>-RM <%=String.format("%.2f", inv.getDiscount())%></span>
      </div>
      <div class="totals-row final">
        <span>Total Due</span>
        <span>RM <%=String.format("%.2f", inv.getNet())%></span>
      </div>
    </div>

    <div class="status-banner">
      <%= isPaid
          ? ("✅ PAID via " + (inv.getMethod() != null && !inv.getMethod().isEmpty() ? inv.getMethod() : "Cash"))
          : ("STATUS: " + inv.getStatus()) %>
    </div>

    <% if (inv.getNotes() != null && !inv.getNotes().isEmpty()) { %>
    <div class="notes-box">
      <b>Notes:</b> <%=inv.getNotes()%>
    </div>
    <% } %>

    <div class="doc-footer">
      Generated by AutoCare WMS &nbsp;·&nbsp; Thank you for choosing AutoCare Workshop!
    </div>

  </div>

</body>
</html>
