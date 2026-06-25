package servlet;

import dao.UserDAO;
import model.User;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name     = request.getParameter("fullname");
        String email    = request.getParameter("email");
        String phone    = request.getParameter("phone");
        String password = request.getParameter("password");
        String confirm  = request.getParameter("confirmPassword");

        String ic       = request.getParameter("ic");
        String address  = request.getParameter("address");

  
        if (name == null || email == null || phone == null || password == null ||
            name.isEmpty() || email.isEmpty() || phone.isEmpty() || password.isEmpty()) {

            request.setAttribute("error", "Sila isi semua field wajib!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirm)) {
            request.setAttribute("error", "Password tidak sama!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        try {

     
            if (userDAO.emailExists(email)) {
                request.setAttribute("error", "Email sudah digunakan!");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            User user = new User();
            user.setUserid(userDAO.generateUserId()); // 🔥 ADD THIS FIRST
            user.setName(name);
            user.setEmail(email);
            user.setPhone(phone);
            user.setPassword(password);

            user.setIc(ic);
            user.setAddress(address);

            user.setRole("customer");

         
            boolean success = userDAO.registerCustomer(user);

            if (success) {

                HttpSession session = request.getSession();
                session.setAttribute("user", user);
                session.setAttribute("username", user.getName());
                session.setAttribute("role", "customer");

                response.sendRedirect("homepage.jsp");

            } else {
                request.setAttribute("error", "Pendaftaran gagal!");
                request.getRequestDispatcher("register.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Server Error: " + e.getMessage());
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
}