package model;

import java.sql.Timestamp;

public class Notification {
    private int       id;
    private String    userid;
    private String    title;
    private String    message;
    private String    type;        // ready | overdue | progress | payment
    private boolean   isRead;
    private String    invoiceId;
    private String    workOrderId;
    private Timestamp createdAt;

    public Notification() {}

    public Notification(String userid, String title, String message,
                        String type, String invoiceId, String workOrderId) {
        this.userid      = userid;
        this.title       = title;
        this.message     = message;
        this.type        = type;
        this.invoiceId   = invoiceId;
        this.workOrderId = workOrderId;
        this.isRead      = false;
    }

   
    public int       getId(){
        return id; }
    public void      setId(int v){
        this.id = v; }

    public String    getUserid(){
        return userid; }
    public void      setUserid(String v){
        this.userid = v; }

    public String    getTitle(){
        return title; }
    public void      setTitle(String v){
        this.title = v; }

    public String    getMessage(){
        return message; }
    public void      setMessage(String v){
        this.message = v; }

    public String    getType(){
        return type; }
    public void      setType(String v){
        this.type = v; }

    public boolean   isRead(){
        return isRead; }
    public void      setRead(boolean v){
        this.isRead = v; }

    public String    getInvoiceId(){
        return invoiceId; }
    public void      setInvoiceId(String v){
        this.invoiceId = v; }

    public String    getWorkOrderId(){
        return workOrderId; }
    public void      setWorkOrderId(String v){
        this.workOrderId = v; }

    public Timestamp getCreatedAt(){
        return createdAt; }
    public void      setCreatedAt(Timestamp v){
        this.createdAt = v; }

    // ── Helper ────────────────────────────────────────────
    public String getTypeIcon() {
        switch (type != null ? type : "") {
            case "ready":    return "🔔";
            case "overdue":  return "⚠️";
            case "progress": return "🔧";
            case "payment":  return "✅";
            default:         return "📢";
        }
    }

    public String getTypeBadgeClass() {
        switch (type != null ? type : "") {
            case "ready":    return "badge-warning";
            case "overdue":  return "badge-danger";
            case "progress": return "badge-info";
            case "payment":  return "badge-success";
            default:         return "badge-secondary";
        }
    }
}