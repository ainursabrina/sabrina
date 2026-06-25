package util;
import javax.mail.*;
import javax.mail.internet.*;
import java.util.Properties;

import javax.activation.DataHandler;
import javax.activation.DataSource;
import javax.mail.util.ByteArrayDataSource;

public class EmailService {
    private static final String FROM_EMAIL   = "dienasofea05@gmail.com";
    private static final String APP_PASSWORD = "euch irog wpsy ctlg";

    // ── Helper: create session ────────────────────────────
    private static Session getSession() {
        Properties props = new Properties();
        props.put("mail.smtp.auth",            "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host",            "smtp.gmail.com");
        props.put("mail.smtp.port",            "587");
        return Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM_EMAIL, APP_PASSWORD);
            }
        });
    }

    // ── Helper: send email ────────────────────────────────
    private static void send(String toEmail, String subject, String body) {
        try {
            Message msg = new MimeMessage(getSession());
            msg.setFrom(new InternetAddress(FROM_EMAIL));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            msg.setSubject(subject);
            msg.setText(body);
            Transport.send(msg);
            System.out.println("✅ Email sent to: " + toEmail);
        } catch (MessagingException e) {
            e.printStackTrace();
            System.out.println("❌ Email failed: " + e.getMessage());
        }
    }

    // ── Helper: send email WITH PDF attachment ────────────
    private static void sendWithAttachment(String toEmail, String subject, String body,
                                            byte[] pdfBytes, String attachmentName) {
        try {
            Message msg = new MimeMessage(getSession());
            msg.setFrom(new InternetAddress(FROM_EMAIL));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            msg.setSubject(subject);

            // Body part
            MimeBodyPart textPart = new MimeBodyPart();
            textPart.setText(body);

            // Attachment part
            MimeBodyPart attachPart = new MimeBodyPart();
            DataSource ds = new ByteArrayDataSource(pdfBytes, "application/pdf");
            attachPart.setDataHandler(new DataHandler(ds));
            attachPart.setFileName(attachmentName);

            Multipart multipart = new MimeMultipart();
            multipart.addBodyPart(textPart);
            multipart.addBodyPart(attachPart);

            msg.setContent(multipart);
            Transport.send(msg);
            System.out.println("✅ Email with attachment sent to: " + toEmail);
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("❌ Email with attachment failed: " + e.getMessage());
        }
    }

    public static void sendServiceComplete(String toEmail, String customerName,
                                            String plateNo, String invoiceId,
                                            double totalAmount) {
        String subject = "AutoCare WMS — Vehicle Service Completed ✅";
        String body =
            "Dear " + customerName + ",\n\n" +
            "Your vehicle (" + plateNo + ") service has been completed.\n\n" +
            "Invoice No : " + invoiceId + "\n" +
            "Total      : RM " + String.format("%.2f", totalAmount) + "\n\n" +
            "Please make your payment within 30 minutes to avoid overdue status.\n\n" +
            "Pay online: http://localhost:8080/CarWorkshop_2/payment?tab=invoices\n\n" +
            "Thank you for choosing AutoCare Workshop!";
        send(toEmail, subject, body);
    }


    // ── 2. BARU — Progress Update ─────────────────────────
    public static void sendProgressUpdate(String toEmail, String customerName,
                                           String plateNo, String workOrderId,
                                           String status) {
        String statusMsg;
        switch (status) {
            case "In Progress":
                statusMsg = " Your vehicle is currently being serviced by our mechanic.";
                break;
            case "Completed":
                statusMsg = " Your vehicle service is completed! Please proceed with payment.";
                break;
            case "Cancelled":
                statusMsg = "Your work order has been cancelled. Please contact us for more info.";
                break;
            default:
                statusMsg = "Status updated to: " + status;
        }

        String subject = "AutoCare WMS — Vehicle Status Update 🔧";
        String body =
            "Dear " + customerName + ",\n\n" +
            "Update on your vehicle (" + plateNo + "):\n\n" +
            statusMsg + "\n\n" +
            "Work Order : " + workOrderId + "\n\n" +
            "Track your vehicle: http://localhost:8080/CarWorkshop_2/WorkOrderServlet?action=list\n\n" +
            "Thank you for choosing AutoCare Workshop!";
        send(toEmail, subject, body);
    }

    // ── 3. BARU — Payment Overdue Alert ───────────────────
    public static void sendPaymentOverdue(String toEmail, String customerName,
                                           String plateNo, String invoiceId,
                                           double totalAmount) {
        String subject = "AutoCare WMS — ⚠️ Payment Overdue Notice";
        String body =
            "Dear " + customerName + ",\n\n" +
            "This is a reminder that your payment is now OVERDUE.\n\n" +
            "Vehicle    : " + plateNo + "\n" +
            "Invoice No : " + invoiceId + "\n" +
            "Amount Due : RM " + String.format("%.2f", totalAmount) + "\n\n" +
            "Please make your payment as soon as possible.\n\n" +
            "Pay online: http://localhost:8080/CarWorkshop_2/payment?tab=invoices\n\n" +
            "If you have already made payment, please ignore this notice.\n\n" +
            "Thank you for choosing AutoCare Workshop!";
        send(toEmail, subject, body);
    }

    // ── 4. BARU — Email Invoice/Receipt PDF to customer ───
    public static void sendInvoicePdf(String toEmail, String customerName,
                                       String invoiceId, double totalAmount,
                                       boolean isPaid, byte[] pdfBytes) {
        String docLabel = isPaid ? "Receipt" : "Invoice";
        String subject  = "AutoCare WMS — Your " + docLabel + " " + invoiceId;
        String body =
            "Dear " + customerName + ",\n\n" +
            "Please find attached your " + docLabel.toLowerCase() + " (" + invoiceId + ").\n\n" +
            "Total Amount: RM " + String.format("%.2f", totalAmount) + "\n\n" +
            (isPaid ? "This invoice has been paid in full. Thank you!\n\n"
                    : "Please make payment at your earliest convenience:\n" +
                      "http://localhost:8080/CarWorkshop_2/payment?tab=invoices\n\n") +
            "Thank you for choosing AutoCare Workshop!";

        String fileName = docLabel + "_" + invoiceId + ".pdf";
        sendWithAttachment(toEmail, subject, body, pdfBytes, fileName);
    }
}