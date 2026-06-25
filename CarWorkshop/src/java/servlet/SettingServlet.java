package servlet;

import dao.UserDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/SettingsServlet")
public class SettingServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String role = (String) request.getSession().getAttribute("role");
        if (role == null || !("admin".equalsIgnoreCase(role) || "mechanic".equalsIgnoreCase(role) || "customer".equalsIgnoreCase(role))) {
            response.sendRedirect(request.getContextPath() + "/homepage.jsp");
            return;
        }

        request.getRequestDispatcher("/settings.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");
        if (role == null || (!("admin".equalsIgnoreCase(role)) 
                  && !("mechanic".equalsIgnoreCase(role)) 
                  && !("customer".equalsIgnoreCase(role)))) {
        response.sendRedirect(request.getContextPath() + "/homepage.jsp");
        return;
        }
        
        String userid      = (String) session.getAttribute("userid");
        String currentPass = request.getParameter("currentPassword");
        String newPass     = request.getParameter("newPassword");
        String confirmPass = request.getParameter("confirmPassword");

        // Validate
        if (!newPass.equals(confirmPass)) {
            response.sendRedirect(request.getContextPath() + "/SettingsServlet?error=mismatch");
            return;
        }

        if (newPass.length() < 6) {
            response.sendRedirect(request.getContextPath() + "/SettingsServlet?error=tooshort");
            return;
        }

        boolean ok = userDAO.updatePassword(userid, currentPass, newPass);

        if (ok) {
            response.sendRedirect(request.getContextPath() + "/SettingsServlet?success=1");
        } else {
            response.sendRedirect(request.getContextPath() + "/SettingsServlet?error=wrongpass");
        }
    }
}
