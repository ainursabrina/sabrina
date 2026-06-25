package service;

import java.io.*;
import java.net.*;
import java.util.*;

public class ToyyibpayService {

    private static final String TOYYIBPAY_BASE_URL = "https://toyyibpay.com";

 
    // Ambil dari: https://toyyibpay.com/index.php/profile (Secret Key)
    private static final String USER_SECRET_KEY = "wvn4e6c0-ytom-c6wk-0b7j-82su56j7dns7";


    // Ambil dari: Toyyibpay Dashboard > Category (create dulu kalau belum ada)
    private static final String CATEGORY_CODE = "zh0fofzo";


 
    public String createBill(String invoiceId, String customer, String email,
                              String phone, double amountRM, String description,
                              String returnUrl, String callbackUrl) throws IOException {

        // Toyyibpay amount dalam SEN (cents), bukan RM
        int amountSen = (int) Math.round(amountRM * 100);

        // Build POST parameters
        Map<String, String> params = new LinkedHashMap<>();
        params.put("userSecretKey",       USER_SECRET_KEY);
        params.put("categoryCode",        CATEGORY_CODE);
        params.put("billName",            "AutoCare - " + invoiceId);
        params.put("billDescription",     description.length() > 99
                                              ? description.substring(0, 99)
                                              : description);
        params.put("billPriceSetting",    "1");       // 1 = fixed price
        params.put("billPayorInfo",       "1");       // 1 = require payor info
        params.put("billAmount",          String.valueOf(amountSen));
        params.put("billReturnUrl",       returnUrl);
        params.put("billCallbackUrl",     callbackUrl);
        params.put("billExternalReferenceNo", invoiceId);   // ← ID kita untuk track
        params.put("billTo",              customer);
        params.put("billEmail",           email);
        params.put("billPhone",           sanitizePhone(phone));
        params.put("billSplitPayment",    "0");
        params.put("billSplitPaymentArgs","");
        params.put("billPaymentChannel", "0");        // 0 = semua channel (FPX + Credit Card)
        params.put("billContentEmail",    "Terima kasih kerana membayar dengan AutoCare WMS.");
        params.put("billChargeToCustomer","0");       // 0 = kita tanggung bayaran
        params.put("billExpiryDate",      "");        // kosong = no expiry
        params.put("billExpiryDays",      "3");       // expire dalam 3 hari

        // POST ke Toyyibpay API
        String response = httpPost(TOYYIBPAY_BASE_URL + "/index.php/api/createBill", params);
        System.out.println("[ToyyibPay Response]: " + response);

        // Response format: [{"BillCode":"abc123xyz"}]
        // Parse manually (tanpa library JSON)
        if (response != null && response.contains("BillCode")) {
            String billCode = extractJson(response, "BillCode");
            return billCode;
        }

        System.err.println("[ToyyibpayService] createBill failed. Response: " + response);
        return null;
    }

    public String getPaymentUrl(String billCode) {
        return TOYYIBPAY_BASE_URL + "/" + billCode;
    }

    
    public String getPaymentStatus(String billCode) throws IOException {
        Map<String, String> params = new LinkedHashMap<>();
        params.put("userSecretKey", USER_SECRET_KEY);
        params.put("billCode",      billCode);

        String response = httpPost(TOYYIBPAY_BASE_URL + "/index.php/api/getBillTransactions", params);

        // Response adalah array of transactions
        // Cari status_id: 1 = success
        if (response != null && response.contains("\"status_id\":\"1\"")) {
            return "1";  // Paid
        } else if (response != null && response.contains("\"status_id\":\"3\"")) {
            return "3";  // Pending
        }
        return "0";  // Failed / not found
    }

    /** Hantar HTTP POST form request */
    private String httpPost(String urlStr, Map<String, String> params) throws IOException {
        StringBuilder sb = new StringBuilder();
        for (Map.Entry<String, String> e : params.entrySet()) {
            if (sb.length() > 0) sb.append("&");
            sb.append(URLEncoder.encode(e.getKey(),   "UTF-8"));
            sb.append("=");
            sb.append(URLEncoder.encode(e.getValue(), "UTF-8"));
        }
        byte[] postData = sb.toString().getBytes("UTF-8");

        URL url = new URL(urlStr);
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("POST");
        con.setDoOutput(true);
        con.setRequestProperty("Content-Type",   "application/x-www-form-urlencoded");
        con.setRequestProperty("Content-Length",  String.valueOf(postData.length));
        con.setConnectTimeout(15_000);
        con.setReadTimeout(15_000);

        try (OutputStream os = con.getOutputStream()) {
            os.write(postData);
        }

        int code = con.getResponseCode();
        InputStream is = (code >= 200 && code < 300)
                ? con.getInputStream()
                : con.getErrorStream();

        BufferedReader reader = new BufferedReader(new InputStreamReader(is, "UTF-8"));
        StringBuilder result = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) result.append(line);
        reader.close();

        return result.toString();
    }

    /** Extract nilai dari JSON string secara mudah (tanpa library) */
    private String extractJson(String json, String key) {
        // Cari "key":"value" atau "key": "value"
        String search = "\"" + key + "\"";
        int idx = json.indexOf(search);
        if (idx < 0) return null;
        idx = json.indexOf("\"", idx + search.length() + 1); // skip :
        if (idx < 0) return null;
        int end = json.indexOf("\"", idx + 1);
        if (end < 0) return null;
        return json.substring(idx + 1, end);
    }

    /** Format no telefon ke format Toyyibpay: 601XXXXXXXX */
    private String sanitizePhone(String phone) {
        if (phone == null) return "60100000000";
        phone = phone.replaceAll("[^0-9]", "");
        if (phone.startsWith("0")) phone = "6" + phone;
        if (!phone.startsWith("60")) phone = "60" + phone;
        return phone;
    }
}