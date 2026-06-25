package servlet;

import dao.ReportDAO;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import java.util.Map;

@WebServlet("/ReportServlet")
public class ReportServlet extends HttpServlet {

    private final ReportDAO dao = new ReportDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

     
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || !"admin".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/homepage.jsp");
            return;
        }
        
        Map<String, Integer> booking = dao.getBookingSummary();
        Map<String, Integer> workOrder = dao.getWorkOrderSummary();
        Map<String, Integer> users = dao.getUserSummary();

        System.out.println("=== REPORT DEBUG ===");
        System.out.println("Booking: " + booking);
        System.out.println("WorkOrder: " + workOrder);
        System.out.println("Users: " + users);
        System.out.println("====================");
    
        request.setAttribute("bookingSummary",  dao.getBookingSummary());
        request.setAttribute("workOrderSummary", dao.getWorkOrderSummary());
        request.setAttribute("lowStockParts",   dao.getLowStockParts());
        request.setAttribute("userSummary",     dao.getUserSummary());

        request.getRequestDispatcher("/report.jsp").forward(request, response);
    }
}
