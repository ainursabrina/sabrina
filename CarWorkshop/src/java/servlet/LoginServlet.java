package servlet;

import dao.UserDAO;
import model.User;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String loginType = request.getParameter("loginType");
        HttpSession session = request.getSession();

        String role = null;
        String username = null;
        User user = null;
        UserDAO userDAO = new UserDAO();

        // ================= STAFF LOGIN =================
        if ("staff".equals(loginType)) {

           String userId = request.getParameter("userId");
            String password = request.getParameter("password");

            user = userDAO.login(userId, password);

            if (user != null &&
               (user.getRole().equals("admin") ||
                user.getRole().equals("mechanic"))) {

                role = user.getRole();
                username = user.getName();

                session.setAttribute("user", user);

            } else {

                request.setAttribute("error", "Invalid staff login");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }
        }

        // ================= CUSTOMER LOGIN =================
        else if ("customer".equals(loginType)) {

            String email = request.getParameter("emailphone");
            String password = request.getParameter("password");

            user = userDAO.login(email, password);

            if (user != null) {

                role = user.getRole();
                username = user.getName();

                // ONLY STORE OBJECT (IMPORTANT)
                session.setAttribute("user", user);

            } else {

                request.setAttribute("custError", "Invalid customer login");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }
        }

        // ================= INVALID TYPE =================
        else {
            response.sendRedirect("login.jsp");
            return;
        }

        // ================= COMMON SESSION =================
      
      
        session.setAttribute("user",     user);
        session.setAttribute("userid",   user.getUserid());   // ← PENTING
        session.setAttribute("username", user.getName());
        session.setAttribute("role",     user.getRole());

        // ================= CACHE CONTROL =================
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        // ================= REDIRECT =================
        switch (role) {

            case "admin":
            case "mechanic":
            case "customer":
                response.sendRedirect("homepage.jsp");
                break;

            default:
                response.sendRedirect("login.jsp");
                break;
        }
    }
}