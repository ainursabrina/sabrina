package dao;

import model.User;
import util.DBConnection;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * UserDAO — FIXED (MATCH TABLE: users)
 */
public class UserDAO {

    // =========================================================
    // REGISTER USER (CUSTOMER)
    // =========================================================
    public boolean registerCustomer(User user) {

        String sql =
            "INSERT INTO users " +
            "(userid, name, email, password, phone, role, ic, address) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, user.getUserid());
            ps.setString(2, user.getName());
            ps.setString(3, user.getEmail().toLowerCase().trim());
            ps.setString(4, hashSHA256(user.getPassword()));
            ps.setString(5, user.getPhone());
            ps.setString(6, user.getRole());
            ps.setString(7, user.getIc());
            ps.setString(8, user.getAddress());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.out.println("Register Error");
            e.printStackTrace();
        }

        return false;
    }

    // =========================================================
    // LOGIN USER (ALL ROLE: admin / customer / mechanic)
    // =========================================================
    public User login(String loginInput, String password) {

    String sql =
        "SELECT * FROM users " +
        "WHERE (email=? OR userid=?) AND password=?";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setString(1, loginInput.toLowerCase().trim());
        ps.setString(2, loginInput.trim());
        ps.setString(3, hashSHA256(password));

        ResultSet rs = ps.executeQuery();

        if (rs.next()) {

            User user = new User();

            user.setUserid(rs.getString("userid"));
            user.setName(rs.getString("name"));
            user.setEmail(rs.getString("email"));
            user.setPhone(rs.getString("phone"));
            user.setRole(rs.getString("role"));
            user.setIc(rs.getString("ic"));
            user.setAddress(rs.getString("address"));

            return user;
        }

    } catch (SQLException e) {
        System.out.println("Login Error");
        e.printStackTrace();
    }

    return null;
}
        

    // =========================================================
    // CHECK EMAIL EXISTS
    // =========================================================
    public boolean emailExists(String email) {

        String sql = "SELECT userid FROM users WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email.toLowerCase().trim());

            ResultSet rs = ps.executeQuery();

            return rs.next();

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // =========================================================
    // CHECK PHONE EXISTS
    // =========================================================
    public boolean phoneExists(String phone) {

        String sql = "SELECT userid FROM users WHERE phone = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, phone);

            ResultSet rs = ps.executeQuery();

            return rs.next();

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // =========================================================
    // GENERATE USER ID (U001, U002...)
    // =========================================================
    public String generateUserId() {

        String sql = "SELECT userid FROM users ORDER BY userid DESC LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {

                String lastId = rs.getString("userid"); // U001

                int num = Integer.parseInt(lastId.substring(1));
                num++;

                return String.format("U%03d", num);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return "U001";
    }

    // =========================================================
    // SHA-256 HASH
    // =========================================================
    public static String hashSHA256(String input) {

        try {

            MessageDigest md = MessageDigest.getInstance("SHA-256");

            byte[] bytes = md.digest(input.getBytes());

            StringBuilder sb = new StringBuilder();

            for (byte b : bytes) {
                sb.append(String.format("%02x", b));
            }

            return sb.toString();

        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }
    }
    
    // =========================================================
    // GET EMAIL BY CUSTOMER NAME (untuk hantar notification)
    // =========================================================
    public String getEmailByName(String name) {
        String sql = "SELECT email FROM users WHERE name = ? AND role = 'customer' LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("email");
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    public String getEmailByUserid(String userid) throws SQLException {
    String sql = "SELECT email FROM users WHERE userid = ?";
    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setString(1, userid);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getString("email");
        }
    }
    return null;
}
    // =========================================================
    // UPDATE PASSWORD
    // =========================================================
    public boolean updatePassword(String userid, String currentPassword, String newPassword) {

        // Verify current password dulu
        String checkSql = "SELECT userid FROM users WHERE userid = ? AND password = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(checkSql)) {

            ps.setString(1, userid);
            ps.setString(2, hashSHA256(currentPassword));
            ResultSet rs = ps.executeQuery();

            if (!rs.next()) return false; // current password salah

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }

        // Update password baru
        String updateSql = "UPDATE users SET password = ? WHERE userid = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(updateSql)) {

            ps.setString(1, hashSHA256(newPassword));
            ps.setString(2, userid);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}