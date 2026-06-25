package servlet;

import dao.InventoryDAO;
import model.Inventory;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/InventoryServlet")
public class InventoryServlet extends HttpServlet {

    private final InventoryDAO dao = new InventoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "list";
        
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        switch (action) {

            case "add":
                request.getRequestDispatcher("/addInventory.jsp")
                        .forward(request, response);
                break;

            case "edit":
                try {
                    int editId = Integer.parseInt(request.getParameter("id"));
                    Inventory toEdit = dao.getInventoryById(editId);

                    request.setAttribute("inventory", toEdit);
                } catch (Exception e) {
                    e.printStackTrace();
                }

                request.getRequestDispatcher("/addInventory.jsp")
                        .forward(request, response);
                break;

            case "delete":
                try {
                    int delId = Integer.parseInt(request.getParameter("id"));
                    dao.deleteInventory(delId);
                } catch (Exception e) {
                    e.printStackTrace();
                }

                response.sendRedirect(request.getContextPath() + "/InventoryServlet");
                break;

            default:
                listInventory(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        String partName    = request.getParameter("partName");
        String description = request.getParameter("description");

        int stockQty = 0;
        double unitPrice = 0.0;

        try {
            stockQty = Integer.parseInt(request.getParameter("stockQty"));
            unitPrice = Double.parseDouble(request.getParameter("unitPrice"));
        } catch (Exception e) {
            e.printStackTrace();
        }

        if ("update".equalsIgnoreCase(action)) {

            try {
                int partID = Integer.parseInt(request.getParameter("partID"));

                Inventory item = new Inventory(
                        partID,
                        partName,
                        description,
                        stockQty,
                        unitPrice
                );

                dao.updateInventory(item);

            } catch (Exception e) {
                e.printStackTrace();
            }

        } else {

            Inventory item = new Inventory(
                    0,
                    partName,
                    description,
                    stockQty,
                    unitPrice
            );

            dao.addInventory(item);
        }

        response.sendRedirect(request.getContextPath() + "/InventoryServlet?success=1");
    }

    // ================================
    // CLEAN LIST HANDLER (IMPORTANT)
    // ================================
    private void listInventory(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        List<Inventory> inventories = dao.getAllInventory();

      
        request.setAttribute("inventories", inventories);

       
        int total = inventories.size();
        int low = 0;
        int out = 0;
        int inStock = 0;

        for (Inventory i : inventories) {
            int qty = i.getStockQty();

            if (qty == 0) out++;
            else if (qty < 10) low++;
            else inStock++;
        }

        request.setAttribute("totalParts", total);
        request.setAttribute("lowStock", low);
        request.setAttribute("outStock", out);
        request.setAttribute("inStock", inStock);

        request.getRequestDispatcher("/inventory.jsp")
                .forward(request, response);
    }
}