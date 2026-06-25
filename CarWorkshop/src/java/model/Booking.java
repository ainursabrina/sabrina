package model;

import java.sql.Timestamp;

public class Booking {

    private String bookingID;
    private String carPlate;
    private Timestamp bookingDate;
    private String bookingStatus;
    private String customerName;
    private String services;

    public String getBookingID() { 
        return bookingID; }
    public void setBookingID(String bookingID) { 
        this.bookingID = bookingID; }

    public String getCarPlate() { 
        return carPlate; }
    public void setCarPlate(String carPlate) { 
        this.carPlate = carPlate; }

    public Timestamp getBookingDate() {
        return bookingDate; }
    public void setBookingDate(Timestamp bookingDate) { 
        this.bookingDate = bookingDate; }

    public String getBookingStatus() { 
        return bookingStatus; }
    public void setBookingStatus(String bookingStatus) { 
        this.bookingStatus = bookingStatus; }

    public String getCustomerName() { 
        return customerName; }
    public void setCustomerName(String customerName) { 
        this.customerName = customerName; }

    public String getServices() { 
        return services; }
    public void setServices(String services) { 
        this.services = services; }
}