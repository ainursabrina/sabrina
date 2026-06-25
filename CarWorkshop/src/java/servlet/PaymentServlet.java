package servlet;

import dao.InvoiceDAO;
import dao.PaymentHistoryDAO;
import model.Invoice;
import model.PaymentHistory;
import service.ToyyibpayService;  
import javax.servlet.ServletOutputStream;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import dao.UserDAO;

@WebServlet(name = "PaymentServlet", urlPatterns = {"/payment", "/PaymentServlet","/payment/callback"})
public class PaymentServlet extends HttpServlet {

    private InvoiceDAO        invDAO;
    private UserDAO userDAO;
    private PaymentHistoryDAO histDAO;
    private ToyyibpayService  toyyibpay; 

    @Override
    public void init() throws ServletException {
        invDAO    = new InvoiceDAO();
        userDAO = new UserDAO();
        histDAO   = new PaymentHistoryDAO();
        toyyibpay = new ToyyibpayService(); 
    }

    private String today() {
        return new SimpleDateFormat("dd/MM/yyyy").format(new Date());
    }

    private void loadStats(HttpServletRequest req) throws Exception {
    String role   = (String) req.getSession().getAttribute("role");
    String userid = (String) req.getSession().getAttribute("userid");
    System.out.println("[loadStats] role: " + role + " | userid: " + userid);
    boolean isCustomer = "customer".equals(role);

    if (isCustomer) {
        req.setAttribute("totalRevenue", invDAO.getTotalRevenueByCustomer(userid));
        req.setAttribute("pendingCount", invDAO.countPendingByCustomer(userid));
        req.setAttribute("totalCount",   invDAO.countAllByCustomer(userid));
        req.setAttribute("overdueCount", invDAO.countByStatusAndCustomer("Overdue", userid));
    } else {
        req.setAttribute("totalRevenue", invDAO.getTotalRevenue());
        req.setAttribute("pendingCount", invDAO.countPending());
        req.setAttribute("totalCount",   invDAO.countAll());
        req.setAttribute("overdueCount", invDAO.countByStatus("Overdue"));
    }
}

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String tab    = req.getParameter("tab");
        String action = req.getParameter("action");
        if (action == null) action = "";

        // Check toyyibpayReturn DULU sebelum check tab
        if ("toyyibpayReturn".equals(action)) {
            try {
                System.out.println("=== TOYYIBPAY RETURN ===");
                System.out.println("status_id: " + req.getParameter("status_id"));
                System.out.println("billcode: "  + req.getParameter("billcode"));
                System.out.println("order_id: "  + req.getParameter("order_id"));
                System.out.println("refno: "     + req.getParameter("refno"));

                String statusId = nvl(req.getParameter("status_id"));
                String billCode = nvl(req.getParameter("billcode"));
                String orderId  = nvl(req.getParameter("order_id"));
                if (orderId.isEmpty()) {
                    orderId = nvl(req.getParameter("refno"));
                }
                String reason = nvl(req.getParameter("reason"));

                req.setAttribute("tpStatus",   statusId);
                req.setAttribute("tpBillCode", billCode);
                req.setAttribute("tpOrderId",  orderId);
                req.setAttribute("tpReason",   reason);

                if ("1".equals(statusId) && !orderId.isEmpty()) {
                    Invoice inv = invDAO.getById(orderId);
                    if (inv != null && !"Paid".equals(inv.getStatus())) {
                        inv.setStatus("Paid");
                        inv.setMethod("Online (Toyyibpay)");
                        invDAO.update(inv);

                        histDAO.deleteByInvoiceId(orderId);
                        String rcpId = histDAO.nextReceiptId();
                        PaymentHistory h = buildHistory(inv, rcpId, "Online (Toyyibpay)", today());
                        h.setNotes("Toyyibpay BillCode: " + billCode);
                        histDAO.insert(h);
                        triggerEmail(inv);

                        req.setAttribute("tpReceiptNo", rcpId);
                        req.getSession().setAttribute("toast",
                            "✅ Pembayaran Toyyibpay berjaya! No. Resit: " + rcpId);
                    }
                }
                req.getRequestDispatcher("/toyyibpayreturn.jsp").forward(req, resp);
            } catch (Exception e) {
                e.printStackTrace();
            }
            return;
        }

       
        if ("viewInvoice".equals(action)) {
            String id = req.getParameter("id");
            try {
                Invoice inv = invDAO.getById(id);
                req.setAttribute("viewInvoice", inv);
                req.getRequestDispatcher("/invoiceView.jsp").forward(req, resp);
            } catch (Exception e) {
                e.printStackTrace();
                req.getSession().setAttribute("toast", "❌ Gagal papar invoice: " + e.getMessage());
                resp.sendRedirect(req.getContextPath() + "/payment?tab=invoices&sel=" + id);
            }
            return;
        }

        if (tab == null || tab.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/payment?tab=invoices");
            return;
        }
        

        try {
            loadStats(req);

            // ── DELETE invoice ────────────────────────────
            if ("delete".equals(action)) {
                String id = req.getParameter("id");
                if (id != null && !id.isEmpty()) {
                    invDAO.delete(id);
                    histDAO.deleteByInvoiceId(id);
                    req.getSession().setAttribute("toast", "✅ Invoice " + id + " berjaya dipadam.");
                }
                resp.sendRedirect(req.getContextPath() + "/payment?tab=invoices");
                return;
            }

            // ── CLEAR ALL history ─────────────────────────
            if ("clearHistory".equals(action)) {
                histDAO.deleteAll();
                req.getSession().setAttribute("toast", "🗑 Semua history pembayaran dipadam.");
                resp.sendRedirect(req.getContextPath() + "/payment?tab=history");
                return;
            }

            // ── TAB: INVOICES ─────────────────────────────
            if ("invoices".equals(tab)) {
            String q      = nvl(req.getParameter("q"));
            String status = nvl(req.getParameter("status"));
            String linked = nvl(req.getParameter("linked"));
            String role           = (String) req.getSession().getAttribute("role");
            String userid         = (String) req.getSession().getAttribute("userid");
            String customerFilter = "customer".equals(role) ? userid : null;
            
            System.out.println("=== PAYMENT DEBUG ===");
            System.out.println("role: " + role);
            System.out.println("userid: " + userid);
            System.out.println("customerFilter: " + customerFilter);
            List<Invoice> invoices = invDAO.search(q, status, linked, customerFilter);  // ← UPDATED
            
            System.out.println("invoices found: " + invoices.size());
         
            
            req.setAttribute("invoices",     invoices);
            req.setAttribute("q",            q);
            req.setAttribute("filterStatus", status);
            req.setAttribute("filterLinked", linked);

            String selId = req.getParameter("sel");
                if (selId != null && !selId.isEmpty()) {
                    Invoice sel = invDAO.getById(selId);
                    req.setAttribute("selectedInvoice", sel);
                }
            }

            // ── TAB: HISTORY ──────────────────────────────
            
            if ("history".equals(tab)) {
            String q      = nvl(req.getParameter("q"));
            String method = nvl(req.getParameter("method"));
            String linked = nvl(req.getParameter("linked"));

            String role2     = (String) req.getSession().getAttribute("role");
            String username2   = (String) req.getSession().getAttribute("username");
            String custFilter = "customer".equals(role2) ? username2 : null;

            List<PaymentHistory> histList = histDAO.search(q, method, linked, custFilter);
            req.setAttribute("histList",       histList);
            req.setAttribute("histQ",          q);
            req.setAttribute("histMethod",     method);
            req.setAttribute("histLinked",     linked);
            req.setAttribute("totalCollected", histDAO.getTotalCollected());
            req.setAttribute("linkedCount",    histDAO.countLinked());
            req.setAttribute("histTotal",      histList.size());
           }
            req.setAttribute("tab", tab);

            String toast = (String) req.getSession().getAttribute("toast");
            if (toast != null) {
                req.setAttribute("toast", toast);
                req.getSession().removeAttribute("toast");
            }

            req.getRequestDispatcher("/payment.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Database error: " + e.getMessage());
            req.setAttribute("tab",   tab);
            req.getRequestDispatcher("/payment.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
 
        req.setCharacterEncoding("UTF-8");
     
        String pathInfo = req.getServletPath();
        if ("/payment/callback".equals(pathInfo)) {
            String refNo    = nvl(req.getParameter("refno"));
            String statusId = nvl(req.getParameter("status_id"));
            String billCode = nvl(req.getParameter("billcode"));
            String amount   = nvl(req.getParameter("amount"));

            System.out.println("[Toyyibpay Callback] Invoice: " + refNo
                + " | Status: " + statusId);

            try {
                if ("1".equals(statusId) && !refNo.isEmpty()) {
                    Invoice inv = invDAO.getById(refNo);
                    if (inv != null && !"Paid".equals(inv.getStatus())) {
                        inv.setStatus("Paid");
                        inv.setMethod("Online (Toyyibpay)");
                        invDAO.update(inv);

                        histDAO.deleteByInvoiceId(refNo);
                        String rcpId = histDAO.nextReceiptId();
                        PaymentHistory h = buildHistory(inv, rcpId, "Online (Toyyibpay)", today());
                        h.setNotes("Toyyibpay BillCode: " + billCode);
                        histDAO.insert(h);
                        System.out.println("[Callback] ✅ Paid. Receipt: " + rcpId);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            resp.getWriter().write("ok");
            return;
        }
        String action = nvl(req.getParameter("action"));

        try {

            // ── UPDATE STATUS ─────────────────────────────
            if ("updateStatus".equals(action)) {
                String id     = req.getParameter("id");
                String status = req.getParameter("status");
                invDAO.updateStatus(id, status);

                if ("Paid".equals(status)) {
                    Invoice inv = invDAO.getById(id);
                    PaymentHistory existing = histDAO.getByInvoiceId(id);
                    if (existing == null && inv != null) {
                        String rcpId = histDAO.nextReceiptId();
                        PaymentHistory h = buildHistory(inv, rcpId, "Cash", today());
                        histDAO.insert(h);
                        triggerEmail(inv);
                        req.getSession().setAttribute("toast",
                            "✅ Status dikemaskini → Paid. Receipt: " + rcpId);
                    } else {
                        req.getSession().setAttribute("toast",
                            "✅ Status dikemaskini → " + status);
                    }
                } else {
                    req.getSession().setAttribute("toast",
                        "✅ Status dikemaskini → " + status);
                }
                resp.sendRedirect(req.getContextPath() + "/payment?tab=invoices&sel=" + id);
                return;
            }
            // ── EDIT AMOUNT ───────────────────────────────
            if ("editAmount".equals(action)) {
    String id       = req.getParameter("id");
    double newAmt   = parseDouble(req.getParameter("amount"));
    double newDisc  = parseDouble(req.getParameter("discount"));
    String notes    = nvl(req.getParameter("notes"));
    String services = nvl(req.getParameter("services")); // ← TAMBAH

    Invoice inv = invDAO.getById(id);
    if (inv != null && !"Paid".equals(inv.getStatus())) {
        inv.setAmount(newAmt);
        inv.setDiscount(newDisc);
        inv.setNotes(notes);
        if (!services.isEmpty()) inv.setServices(services); // ← TAMBAH
        invDAO.update(inv);
        req.getSession().setAttribute("toast",
            "✅ Invoice Amount " + id + " updated.");
    } else {
        req.getSession().setAttribute("toast",
            "⚠️ Invoice cannot be edited —  Paid or not  exist.");
    }
    resp.sendRedirect(req.getContextPath() + "/payment?tab=invoices&sel=" + id);
    return;
}
            
            // ── PROCESS PAYMENT (Cash/Card/Cheque) ────────
            if ("processPayment".equals(action)) {
                String id     = req.getParameter("id");
                String method = nvl(req.getParameter("method"));
                String notes  = nvl(req.getParameter("notes"));

                // BARU: Kalau method = Toyyibpay, redirect ke gateway
                if ("Toyyibpay".equals(method)) {
                    Invoice inv = invDAO.getById(id);
                    if (inv != null) {
                        handleToyyibpayRedirect(req, resp, inv);
                    } else {
                        req.getSession().setAttribute("toast", "❌ Invoice tidak ditemui.");
                        resp.sendRedirect(req.getContextPath() + "/payment?tab=invoices&sel=" + id);
                    }
                    return;
                }

                Invoice inv = invDAO.getById(id);
                if (inv != null) {
                    inv.setStatus("Paid");
                    inv.setMethod(method);
                    inv.setNotes(notes);
                    invDAO.update(inv);

                    histDAO.deleteByInvoiceId(id);
                    String rcpId = histDAO.nextReceiptId();
                    PaymentHistory h = buildHistory(inv, rcpId, method, today());
                    h.setNotes(notes);
                    histDAO.insert(h);
                    triggerEmail(inv);

                    req.getSession().setAttribute("toast",
                        "✅ Pembayaran berjaya direkod! No. Resit: " + rcpId);
                } else {
                    req.getSession().setAttribute("toast", "❌ Invoice tidak ditemui.");
                }
                resp.sendRedirect(req.getContextPath() + "/payment?tab=invoices&sel=" + id);
                return;
            }

            if ("payToyyibpay".equals(action)) {
                String id    = req.getParameter("id");
                String email = nvl(req.getParameter("tp_email"));
                String phone = nvl(req.getParameter("tp_phone"));

                Invoice inv = invDAO.getById(id);
                if (inv == null) {
                    req.getSession().setAttribute("toast", "❌ Invoice tidak ditemui.");
                    resp.sendRedirect(req.getContextPath() + "/payment?tab=invoices&sel=" + id);
                    return;
                }

                String baseUrl = "http://localhost:8080/CarWorkshop_2";
                String returnUrl   = baseUrl + "/payment?tab=invoices&action=toyyibpayReturn";
                String callbackUrl = "";

                String desc = "AutoCare WMS — " + inv.getServices();
                double netAmount = inv.getNet();

                // Panggil Toyyibpay API untuk buat bill
                String billCode = toyyibpay.createBill(
                    inv.getId(), inv.getCustomer(),
                    email.isEmpty() ? "noreply@autocare.com" : email,
                    phone.isEmpty() ? "60100000000" : phone,
                    netAmount, desc, returnUrl, callbackUrl
                );

                if (billCode != null) {
                    // Simpan billCode dalam session untuk track
                    req.getSession().setAttribute("tp_billcode_" + id, billCode);
                    // Redirect ke payment page Toyyibpay
                    resp.sendRedirect(toyyibpay.getPaymentUrl(billCode));
                } else {
                    req.getSession().setAttribute("toast",
                        "❌ Gagal buat bil Toyyibpay. Semak konfigurasi API key.");
                    resp.sendRedirect(req.getContextPath() + "/payment?tab=invoices&sel=" + id);
                }
                return;
            }
            
            if ("toyyibpayCallback".equals(action)) {
                String refNo    = nvl(req.getParameter("refno"));     
                String statusId = nvl(req.getParameter("status_id"));  
                String billCode = nvl(req.getParameter("billcode"));
                String amount   = nvl(req.getParameter("amount"));    

                System.out.println("[Toyyibpay Callback] Invoice: " + refNo
                    + " | Status: " + statusId
                    + " | BillCode: " + billCode
                    + " | Amount: " + amount);

                if ("1".equals(statusId) && !refNo.isEmpty()) {
                    Invoice inv = invDAO.getById(refNo);
                    if (inv != null && !"Paid".equals(inv.getStatus())) {
                        inv.setStatus("Paid");
                        inv.setMethod("Online (Toyyibpay)");
                        invDAO.update(inv);

                        histDAO.deleteByInvoiceId(refNo);
                        String rcpId = histDAO.nextReceiptId();
                        PaymentHistory h = buildHistory(inv, rcpId, "Online (Toyyibpay)", today());
                        h.setNotes("Toyyibpay BillCode: " + billCode);
                        histDAO.insert(h);

                        System.out.println("[Toyyibpay Callback] ✅ Payment recorded. Receipt: " + rcpId);
                    }
                }

               
                resp.getWriter().write("ok");
                return;
            }

            // ── SAVE NEW RECORD (Record Payment tab) ──────
            if ("saveRecord".equals(action)) {
                String invIdRaw = nvl(req.getParameter("r_inv")).toUpperCase();
                String customer = nvl(req.getParameter("r_cust"));
                String vehicle  = nvl(req.getParameter("r_vehicle"));
                String services = nvl(req.getParameter("r_services"));
                double amount   = parseDouble(req.getParameter("r_amount"));
                double discount = parseDouble(req.getParameter("r_discount"));
                String method   = nvl(req.getParameter("r_method"));
                String dateRaw  = nvl(req.getParameter("r_date"));
                String status   = nvl(req.getParameter("r_status"));
                String notes    = nvl(req.getParameter("r_notes"));
                String woId     = nvl(req.getParameter("r_wo"));
                String bkId     = nvl(req.getParameter("r_bk"));

                if (customer.isEmpty() || amount <= 0) {
                    req.getSession().setAttribute("toast",
                        "⚠️ Nama pelanggan dan amaun diperlukan.");
                    resp.sendRedirect(req.getContextPath() + "/payment?tab=record");
                    return;
                }

                String fmtDate = today();
                if (!dateRaw.isEmpty()) {
                    try {
                        Date d = new SimpleDateFormat("yyyy-MM-dd").parse(dateRaw);
                        fmtDate = new SimpleDateFormat("dd/MM/yyyy").format(d);
                    } catch (Exception ignored) {}
                }

                Invoice existing = invIdRaw.isEmpty() ? null : invDAO.getById(invIdRaw);
                String finalId;

                if (existing != null) {
                    existing.setStatus(status);
                    existing.setMethod(method);
                    existing.setNotes(notes);
                    existing.setDiscount(discount);
                    if (!woId.isEmpty()) existing.setWoId(woId);
                    if (!bkId.isEmpty()) existing.setBkId(bkId);
                    invDAO.update(existing);
                    finalId = invIdRaw;
                } else {
                    finalId = invIdRaw.isEmpty() ? invDAO.nextInvoiceId() : invIdRaw;
                    Invoice newInv = new Invoice(
                        finalId, customer, vehicle, services,
                        amount, discount, status, fmtDate,
                        method, woId, bkId, notes
                    );
                    invDAO.insert(newInv);
                }

                if ("Paid".equals(status)) {
                    histDAO.deleteByInvoiceId(finalId);
                    String rcpId = histDAO.nextReceiptId();
                    Invoice saved = invDAO.getById(finalId);
                    if (saved != null) {
                        PaymentHistory h = buildHistory(saved, rcpId, method, fmtDate);
                        histDAO.insert(h);
                    }
                    req.getSession().setAttribute("toast",
                        "✅ Pembayaran disimpan! No. Resit: " + rcpId);
                } else {
                    req.getSession().setAttribute("toast",
                        "💾 Invoice disimpan. Status: " + status);
                }

                resp.sendRedirect(req.getContextPath() + "/payment?tab=invoices");
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("toast", "❌ Ralat: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/payment?tab=invoices");
        }
    }

    private void handleToyyibpayRedirect(HttpServletRequest req,
                                          HttpServletResponse resp,
                                          Invoice inv) throws Exception {
       
        String email = nvl(req.getParameter("tp_email"));
        String phone = nvl(req.getParameter("tp_phone"));

        String baseUrl = "http://localhost:8080/CarWorkshop_2";
        String returnUrl   = baseUrl + "/payment?tab=invoices&action=toyyibpayReturn";
        String callbackUrl = ""; 

        String desc      = "AutoCare WMS — " + (inv.getServices() != null ? inv.getServices() : inv.getId());
        double netAmount = inv.getNet();

        String billCode = toyyibpay.createBill(
            inv.getId(), inv.getCustomer(),
            email.isEmpty() ? "noreply@autocare.com" : email,
            phone.isEmpty() ? "60100000000" : phone,
            netAmount, desc, returnUrl, callbackUrl
        );

        if (billCode != null) {
            req.getSession().setAttribute("tp_billcode_" + inv.getId(), billCode);
            resp.sendRedirect(toyyibpay.getPaymentUrl(billCode));
        } else {
            req.getSession().setAttribute("toast",
                "❌ Gagal buat bil Toyyibpay. Semak API key dalam ToyyibpayService.java.");
            resp.sendRedirect(req.getContextPath()
                + "/payment?tab=invoices&sel=" + inv.getId());
        }
    }

    // ── Build PaymentHistory from Invoice ─────────────────
    private PaymentHistory buildHistory(Invoice inv, String rcpId,
                                        String method, String date) {
        PaymentHistory h = new PaymentHistory();
        h.setInvoiceId(inv.getId());
        h.setReceiptNo(rcpId);
        h.setCustomer(inv.getCustomer());
        h.setVehicle(inv.getVehicle()   != null ? inv.getVehicle()   : "");
        h.setServices(inv.getServices() != null ? inv.getServices()  : "");
        h.setAmount(inv.getAmount());
        h.setDiscount(inv.getDiscount());
        h.setMethod(method);
        h.setPayDate(inv.getInvDate()   != null ? inv.getInvDate()   : date);
        h.setRecordedBy("Admin");
        h.setRecordedAt(date);
        h.setWoId(inv.getWoId() != null ? inv.getWoId() : "");
        h.setBkId(inv.getBkId() != null ? inv.getBkId() : "");
        h.setNotes(inv.getNotes() != null ? inv.getNotes() : "");
        return h;
    }
    
    private void triggerEmail(Invoice inv) {
    try {
        String email = userDAO.getEmailByName(inv.getCustomer());
        if (email != null && !email.isEmpty()) {
            util.EmailService.sendServiceComplete(
                email,
                inv.getCustomer(),
                inv.getVehicle(),
                inv.getId(),
                inv.getNet()
            );
        } else {
            System.out.println("[Email] Skip — no email found for: " + inv.getCustomer());
        }
    } catch (Exception e) {
        System.out.println("[Email] Error: " + e.getMessage());
    }
}

    private String nvl(String s) { return (s == null) ? "" : s.trim(); }

    private double parseDouble(String s) {
        if (s == null || s.trim().isEmpty()) return 0.0;
        try { return Double.parseDouble(s.trim()); } catch (Exception e) { return 0.0; }
    }
}
