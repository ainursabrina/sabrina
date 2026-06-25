package model;

import java.io.Serializable;

public class User implements Serializable {


    private String userid;
    private String name;
    private String email;
    private String password;
    private String phone;
    private String role;
    private String ic;
    private String address;

  
    public User() {
    }

    public User(String userid,
                String name,
                String email,
                String password,
                String phone,
                String role,
                String ic,
                String address) {

        this.userid = userid;
        this.name = name;
        this.email = email;
        this.password = password;
        this.phone = phone;
        this.role = role;
        this.ic = ic;
        this.address = address;
    }

   
    public String getUserid() {
        return userid;
    }

    public String getName() {
        return name;
    }

    public String getEmail() {
        return email;
    }

    public String getPassword() {
        return password;
    }

    public String getPhone() {
        return phone;
    }

    public String getRole() {
        return role;
    }

    public String getIc() {
        return ic;
    }

    public String getAddress() {
        return address;
    }

 
    public void setUserid(String userid) {
        this.userid = userid;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public void setIc(String ic) {
        this.ic = ic;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    @Override
    public String toString() {
        return "User{" +
                "userid='" + userid + '\'' +
                ", name='" + name + '\'' +
                ", email='" + email + '\'' +
                ", phone='" + phone + '\'' +
                ", role='" + role + '\'' +
                ", ic='" + ic + '\'' +
                ", address='" + address + '\'' +
                '}';
    }
}