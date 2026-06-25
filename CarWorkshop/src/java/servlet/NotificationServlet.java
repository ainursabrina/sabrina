package servlet;

import dao.NotificationDAO;
import model.Notification;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/notifications")
public class NotificationServlet extends HttpServlet {

    private NotificationDAO notifDAO;

    @Override
    public void init() throws ServletException {
        notifDAO = new NotificationDAO();
    }

    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userid") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String userid = (String) session.getAttribute("userid");
        String action = nvl(req.getParameter("action"));

        try {
            // ── Mark single as read ───────────────────────
            if ("markRead".equals(action)) {
                String idStr = req.getParameter("id");
                if (idStr != null && !idStr.isEmpty()) {
                    notifDAO.markRead(Integer.parseInt(idStr));
                }
                // Redirect balik ke page notification
                resp.sendRedirect(req.getContextPath() + "/notifications");
                return;
            }

            // ── Mark ALL as read ──────────────────────────
            if ("markAllRead".equals(action)) {
                notifDAO.markAllRead(userid);
                resp.sendRedirect(req.getContextPath() + "/notifications");
                return;
            }

            // ── Delete notification ───────────────────────
            if ("delete".equals(action)) {
                String idStr = req.getParameter("id");
                if (idStr != null && !idStr.isEmpty()) {
                    notifDAO.delete(Integer.parseInt(idStr));
                }
                resp.sendRedirect(req.getContextPath() + "/notifications");
                return;
            }

            // ── Load notification page ────────────────────
            List<Notification> allNotifs   = notifDAO.getAll(userid);
            int                unreadCount = notifDAO.countUnread(userid);

            req.setAttribute("allNotifs",   allNotifs);
            req.setAttribute("unreadCount", unreadCount);

            // Toast dari session
            String toast = (String) session.getAttribute("toast");
            if (toast != null) {
                req.setAttribute("toast", toast);
                session.removeAttribute("toast");
            }

            req.getRequestDispatcher("/notifications.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Error: " + e.getMessage());
            req.getRequestDispatcher("/notifications.jsp").forward(req, resp);
        }
    }


    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userid") == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String userid = (String) session.getAttribute("userid");
        String action = nvl(req.getParameter("action"));

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try {
            // ── Get latest 5 untuk dropdown ───────────────
            if ("getLatest".equals(action)) {
                List<Notification> list = notifDAO.getLatest5(userid);
                int unread = notifDAO.countUnread(userid);

                StringBuilder json = new StringBuilder();
                json.append("{");
                json.append("\"unread\":").append(unread).append(",");
                json.append("\"notifications\":[");

                for (int i = 0; i < list.size(); i++) {
                    Notification n = list.get(i);
                    json.append("{");
                    json.append("\"id\":").append(n.getId()).append(",");
                    json.append("\"title\":\"").append(escape(n.getTitle())).append("\",");
                    json.append("\"message\":\"").append(escape(n.getMessage())).append("\",");
                    json.append("\"type\":\"").append(escape(n.getType())).append("\",");
                    json.append("\"icon\":\"").append(escape(n.getTypeIcon())).append("\",");
                    json.append("\"isRead\":").append(n.isRead()).append(",");
                    json.append("\"invoiceId\":\"").append(escape(n.getInvoiceId())).append("\",");
                    json.append("\"workOrderId\":\"").append(escape(n.getWorkOrderId())).append("\",");
                    json.append("\"createdAt\":\"").append(n.getCreatedAt() != null
                        ? n.getCreatedAt().toString() : "").append("\"");
                    json.append("}");
                    if (i < list.size() - 1) json.append(",");
                }

                json.append("]}");
                resp.getWriter().write(json.toString());
                return;
            }

            // ── Mark all read via AJAX ────────────────────
            if ("markAllRead".equals(action)) {
                notifDAO.markAllRead(userid);
                resp.getWriter().write("{\"success\":true}");
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    // ── Escape JSON string ────────────────────────────────
    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }

    private String nvl(String s) { return s == null ? "" : s.trim(); }
}