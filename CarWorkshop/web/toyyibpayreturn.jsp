<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String statusId  = (String) request.getAttribute("tpStatus");
    String billCode  = (String) request.getAttribute("tpBillCode");
    String orderId   = (String) request.getAttribute("tpOrderId");
    String reason    = (String) request.getAttribute("tpReason");
    String receiptNo = (String) request.getAttribute("tpReceiptNo");

    if (statusId  == null) statusId  = "";
    if (billCode  == null) billCode  = "";
    if (orderId   == null) orderId   = "";
    if (reason    == null) reason    = "";
    if (receiptNo == null) receiptNo = "";

    boolean isSuccess = "1".equals(statusId);
    boolean isPending = "3".equals(statusId);

    String ctxPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title><%= isSuccess ? "Payment Successful" : isPending ? "Payment Pending" : "Payment Failed" %> — AutoCare WMS</title>
  
  <link rel="stylesheet" href="<%= request.getContextPath() %>/css/main.css">
  <style>
    :root{
      --bg:#0d0f14;--surface:#161a23;--surface2:#1e2333;
      --accent:#e8a020;--red:#e84040;--blue:#4080e8;
      --green:#40c880;--text:#eef0f5;--muted:#7a8099;
      --border:rgba(255,255,255,0.07);
    }
    *{margin:0;padding:0;box-sizing:border-box;}
    body{
      background:var(--bg);color:var(--text);
      font-family:'DM Sans',sans-serif;
      min-height:100vh;display:flex;align-items:center;
      justify-content:center;overflow-x:hidden;
    }
    body::before{
      content:'';position:fixed;inset:0;
      background-image:
        linear-gradient(rgba(64,200,128,.025) 1px,transparent 1px),
        linear-gradient(90deg,rgba(64,200,128,.025) 1px,transparent 1px);
      background-size:40px 40px;pointer-events:none;z-index:0;
    }
    .card{
      position:relative;z-index:1;
      background:var(--surface);border:1px solid var(--border);
      border-radius:20px;padding:48px 40px;
      max-width:480px;width:90%;text-align:center;
      box-shadow:0 24px 64px rgba(0,0,0,.5);
    }

    /* ── Icon circle ── */
    .icon-circle{
      width:88px;height:88px;border-radius:50%;
      display:flex;align-items:center;justify-content:center;
      font-size:40px;margin:0 auto 24px;
    }
    .icon-success{ background:rgba(64,200,128,.12); border:2px solid rgba(64,200,128,.3); }
    .icon-pending{ background:rgba(232,160,32,.12);  border:2px solid rgba(232,160,32,.3); }
    .icon-fail{    background:rgba(232,64,64,.12);   border:2px solid rgba(232,64,64,.3);  }

    /* ── Heading ── */
    .status-title{
      font-family:'Barlow Condensed',sans-serif;
      font-size:32px;font-weight:800;margin-bottom:8px;
    }
    .success-title{ color:var(--green); }
    .pending-title{ color:var(--accent); }
    .fail-title{    color:var(--red);    }

    .status-sub{font-size:14px;color:var(--muted);line-height:1.7;margin-bottom:28px;}

    /* ── Details box ── */
    .detail-box{
      background:var(--surface2);border:1px solid var(--border);
      border-radius:12px;padding:18px 20px;margin-bottom:24px;
      text-align:left;
    }
    .detail-row{
      display:flex;justify-content:space-between;align-items:center;
      font-size:13px;padding:6px 0;
    }
    .detail-row:not(:last-child){ border-bottom:1px solid var(--border); }
    .detail-key{ color:var(--muted); }
    .detail-val{ font-weight:600; }
    .val-green{ color:var(--green); }
    .val-blue{  color:#4a9fd4;     }
    .val-orange{ color:var(--accent); }

    /* ── Receipt badge (success only) ── */
    .receipt-badge{
      background:rgba(64,200,128,.08);
      border:1px solid rgba(64,200,128,.25);
      border-radius:10px;padding:14px 18px;
      margin-bottom:24px;text-align:left;
    }
    .receipt-label{
      font-size:10px;text-transform:uppercase;
      letter-spacing:1.2px;color:var(--muted);margin-bottom:6px;
    }
    .receipt-no{
      font-family:'Barlow Condensed',sans-serif;
      font-size:26px;font-weight:800;color:var(--green);
      letter-spacing:1px;
    }

    /* ── Toyyibpay branding ── */
    .tp-brand{
      font-size:11px;color:var(--muted);margin-bottom:24px;
      display:flex;align-items:center;justify-content:center;gap:6px;
    }
    .tp-brand-name{
      font-family:'Barlow Condensed',sans-serif;
      font-size:13px;font-weight:700;color:#1a6fba;
    }

    /* ── Buttons ── */
    .btn{
      display:block;width:100%;padding:13px;border-radius:10px;
      font-size:14px;font-weight:600;cursor:pointer;border:none;
      transition:all .2s;font-family:'DM Sans',sans-serif;
      text-decoration:none;margin-bottom:10px;
    }
    .btn-green{ background:var(--green);color:#0d0f14; }
    .btn-green:hover{ background:#50d890; }
    .btn-outline{
      background:transparent;color:var(--text);
      border:1px solid var(--border);
    }
    .btn-outline:hover{ background:var(--surface2); }
    .btn-orange{ background:var(--accent);color:#0d0f14; }
    .btn-orange:hover{ background:#f0b030; }

    /* ── Pulse animation (success icon) ── */
    @keyframes pulse{
      0%{box-shadow:0 0 0 0 rgba(64,200,128,.4);}
      70%{box-shadow:0 0 0 18px rgba(64,200,128,0);}
      100%{box-shadow:0 0 0 0 rgba(64,200,128,0);}
    }
    .icon-success{ animation:pulse 2s ease-out 1; }
  </style>
</head>
<body>

<div class="card">

  <% if (isSuccess) { %>
  <%-- ═══ SUCCESS ═══ --%>
  <div class="icon-circle icon-success">✅</div>
  <div class="status-title success-title">Payment Sucessfull!</div>
  <div class="status-sub">
    Thank you! Your payment has been successfully received and processed.
  </div>

  <% if (!receiptNo.isEmpty()) { %>
  <div class="receipt-badge">
    <div class="receipt-label">Receipt No</div>
    <div class="receipt-no"><%=receiptNo%></div>
  </div>
  <% } %>

  <div class="detail-box">
    <% if (!orderId.isEmpty()) { %>
    <div class="detail-row">
      <span class="detail-key">Invoice No</span>
      <span class="detail-val val-blue"><%=orderId%></span>
    </div>
    <% } %>
    <% if (!billCode.isEmpty()) { %>
    <div class="detail-row">
      <span class="detail-key">Toyyibpay BillCode</span>
      <span class="detail-val" style="font-size:12px;color:var(--muted)"><%=billCode%></span>
    </div>
    <% } %>
    <div class="detail-row">
      <span class="detail-key">Status</span>
      <span class="detail-val val-green">✅ Paid</span>
    </div>
    <div class="detail-row">
      <span class="detail-key">Method</span>
      <span class="detail-val">🌐 Toyyibpay Gateway</span>
    </div>
  </div>

  <div class="tp-brand">
    This payment was processed by<span class="tp-brand-name">toyyibPay</span> · Payment Successful
  </div>

  <a href="<%=ctxPath%>/payment?tab=history" class="btn btn-green">📜 See Payment History</a>
  <a href="<%=ctxPath%>/payment?tab=invoices" class="btn btn-outline">💳 Return to Invoice</a>

  <% } else if (isPending) { %>
  <%-- ═══ PENDING ═══ --%>
  <div class="icon-circle icon-pending">⏳</div>
  <div class="status-title pending-title">Payment Pending</div>
  <div class="status-sub">
    Your payment is being processed. Please wait for verification from your bank.
    Invoice status will be updated automatically when payment has been verified.
  </div>

  <div class="detail-box">
    <% if (!orderId.isEmpty()) { %>
    <div class="detail-row">
      <span class="detail-key">Invoice No</span>
      <span class="detail-val val-blue"><%=orderId%></span>
    </div>
    <% } %>
    <% if (!billCode.isEmpty()) { %>
    <div class="detail-row">
      <span class="detail-key">BillCode</span>
      <span class="detail-val" style="font-size:12px;color:var(--muted)"><%=billCode%></span>
    </div>
    <% } %>
    <div class="detail-row">
      <span class="detail-key">Status</span>
      <span class="detail-val val-orange">⏳ Wait for verification</span>
    </div>
  </div>

  <div class="tp-brand">
    This payment was processed by<span class="tp-brand-name">toyyibPay</span>
  </div>

  <a href="<%=ctxPath%>/payment?tab=invoices<%= !orderId.isEmpty() ? "&sel="+orderId : "" %>"
     class="btn btn-orange">🔄 Check Invoice Status</a>
  <a href="<%=ctxPath%>/payment?tab=invoices" class="btn btn-outline">💳 Return to Invoice</a>

  <% } else { %>
  <%-- ═══ FAILED ═══ --%>
  <div class="icon-circle icon-fail">❌</div>
  <div class="status-title fail-title">Payment Failed</div>
  <div class="status-sub">
    Sorry,  your payment could not be processed successfully.
    <% if (!reason.isEmpty()) { %>
      <br><span style="color:var(--red);font-size:13px">Reason: <%=reason%></span>
    <% } %>
    <br><br>>Please try again or choose a different payment method.

  <div class="detail-box">
    <% if (!orderId.isEmpty()) { %>
    <div class="detail-row">
      <span class="detail-key">Invoice No</span>
      <span class="detail-val val-blue"><%=orderId%></span>
    </div>
    <% } %>
    <div class="detail-row">
      <span class="detail-key">Status</span>
      <span class="detail-val" style="color:var(--red)">❌ Failed / Cancelled</span>
    </div>
  </div>

  <div class="tp-brand">
    Try again with <span class="tp-brand-name">toyyibPay</span>
  </div>

  <a href="<%=ctxPath%>/payment?tab=invoices<%= !orderId.isEmpty() ? "&sel="+orderId : "" %>"
     class="btn btn-outline" style="border-color:rgba(232,64,64,.3);color:var(--red)">
    🔁 Try Again
  </a>
  <a href="<%=ctxPath%>/payment?tab=invoices" class="btn btn-outline">💳 Return to Invoice</a>

  <% } %>

</div>

</body>
</html>
