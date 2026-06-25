package servlet;

import util.DBConnection;
import java.io.IOException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.Part;
import java.io.*;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ServiceServlet")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024) 
public class ServiceServlet extends HttpServlet {

    @Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");

    String action = request.getParameter("action");
    Connection conn = null;

    try {
        conn = DBConnection.getConnection();

        switch(action) {
            case "add":
    String imagePath = handleImageUpload(request, "");
    String newId = generateServiceId(conn);
    String insertSql = "INSERT INTO services (service_id, service_name, service_desc, price, " +
                       "duration, additional_fee, category, icon, status, image) " +
                       "VALUES (?,?,?,?,?,0,?,?,?,?)";
    try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
        ps.setString(1, newId);
        ps.setString(2, request.getParameter("serviceName"));
        ps.setString(3, request.getParameter("serviceDesc"));
        ps.setDouble(4, Double.parseDouble(request.getParameter("price")));
        ps.setString(5, request.getParameter("duration"));
        ps.setString(6, request.getParameter("category"));
        ps.setString(7, request.getParameter("icon"));
        ps.setString(8, request.getParameter("status"));
        ps.setString(9, imagePath); 
        ps.executeUpdate();
    }
    response.sendRedirect(request.getContextPath() + "/services.jsp?success=1");
    break;
    
    case "delete":
    try {
        String deleteSql = "DELETE FROM services WHERE service_id=?";
        try(PreparedStatement ps = conn.prepareStatement(deleteSql)){
            ps.setString(1, request.getParameter("serviceId"));
            int rows = ps.executeUpdate();
            System.out.println("Deleted rows: " + rows + " for ID: " + request.getParameter("serviceId"));
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    response.sendRedirect(request.getContextPath() + "/services.jsp?success=deleted");
    break;

    case "edit":
    String serviceId = request.getParameter("serviceId");

  
    String oldImage = "";
    String fetchSql = "SELECT image FROM services WHERE service_id = ?";
    try (PreparedStatement fetchPs = conn.prepareStatement(fetchSql)) {
        fetchPs.setString(1, serviceId);
        ResultSet fetchRs = fetchPs.executeQuery();
        if (fetchRs.next() && fetchRs.getString("image") != null) {
            oldImage = fetchRs.getString("image");
        }
    }

    String editImagePath = handleImageUpload(request, oldImage);

    String updateSql = "UPDATE services SET service_name=?, service_desc=?, price=?, " +
                       "duration=?, category=?, icon=?, status=?, image=? " +
                       "WHERE service_id=?";
    try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
        ps.setString(1, request.getParameter("serviceName"));
        ps.setString(2, request.getParameter("serviceDesc"));
        ps.setDouble(3, Double.parseDouble(request.getParameter("price")));
        ps.setString(4, request.getParameter("duration"));
        ps.setString(5, request.getParameter("category"));
        ps.setString(6, request.getParameter("icon"));
        ps.setString(7, request.getParameter("status"));
        ps.setString(8, editImagePath);
        ps.setString(9, serviceId);
        int rows = ps.executeUpdate();
        System.out.println("Edit rows updated: " + rows + " for ID: " + serviceId);
    }
    response.sendRedirect(request.getContextPath() + "/services.jsp?success=1");
    break;
        }

    } catch(SQLException e){
        e.printStackTrace();
        response.sendRedirect(request.getContextPath() + "/services.jsp?error=" + e.getMessage());
    } finally {
        try{ if(conn!=null) conn.close(); } catch(SQLException e){}
    }
}


private String handleImageUpload(HttpServletRequest req, String existingImage) {
    try {
        Part filePart = req.getPart("image");
        if (filePart == null || filePart.getSize() == 0) {
            return existingImage; 
        }

        String fileName = filePart.getSubmittedFileName();
        if (fileName == null || fileName.isEmpty()) return existingImage;

        
        String ext      = fileName.substring(fileName.lastIndexOf('.'));
        String newName  = "svc_" + System.currentTimeMillis() + ext;

        String uploadDir = getServletContext().getRealPath("/img/services/");
        File dir = new File(uploadDir);
        if (!dir.exists()) dir.mkdirs();

        filePart.write(uploadDir + File.separator + newName);
        return "img/services/" + newName; 

    } catch (Exception e) {
        e.printStackTrace();
        return existingImage;
    }
}


private String generateServiceId(Connection conn) throws SQLException {
    String query = "SELECT COALESCE(MAX(CAST(SUBSTRING(service_id, 5) AS UNSIGNED)), 0) FROM services";
    try(PreparedStatement ps = conn.prepareStatement(query)){
        ResultSet rs = ps.executeQuery();
        int maxNum = 0;
        if(rs.next()) maxNum = rs.getInt(1);
        return "SVC-" + String.format("%03d", maxNum + 1);
    }
}
}
