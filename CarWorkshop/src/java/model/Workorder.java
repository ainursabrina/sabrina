package model;

import java.sql.Date;

public class Workorder {

    private String workOrderId;
    private String bookingID;
    private String serviceStatus;
    private String notes;
    private Date createdDate;
    private String mechanicId;

    public Workorder() {
    }

 
    public Workorder(String workOrderId, String bookingID, String serviceStatus,
                     String notes, Date createdDate, String mechanicId) {
        this.workOrderId = workOrderId;
        this.bookingID = bookingID;
        this.serviceStatus = serviceStatus;
        this.notes = notes;
        this.createdDate = createdDate;
        this.mechanicId = mechanicId;
    }

 
    public String getWorkOrderId() {
        return workOrderId;
    }

    public void setWorkOrderId(String workOrderId) {
        this.workOrderId = workOrderId;
    }

    public String getBookingID() {
        return bookingID;
    }

    public void setBookingID(String bookingID) {
        this.bookingID = bookingID;
    }

    public String getServiceStatus() {
        return serviceStatus;
    }

    public void setServiceStatus(String serviceStatus) {
        this.serviceStatus = serviceStatus;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public Date getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Date createdDate) {
        this.createdDate = createdDate;
    }

    public String getMechanicId() {
        return mechanicId;
    }

    public void setMechanicId(String mechanicId) {
        this.mechanicId = mechanicId;
    }

    @Override
    public String toString() {
        return "WorkOrder{" +
                "workOrderId='" + workOrderId + '\'' +
                ", bookingID='" + bookingID + '\'' +
                ", serviceStatus='" + serviceStatus + '\'' +
                ", notes='" + notes + '\'' +
                ", createdDate=" + createdDate +
                ", mechanicId='" + mechanicId + '\'' +
                '}';
    }
}