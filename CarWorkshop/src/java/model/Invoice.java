package model;

/**
 * Invoice.java — Plain Java model matching the invoices table.
 */
public class Invoice {

    private String id;
    private String customer;
    private String vehicle;
    private String services;
    private double amount;
    private double discount;
    private String status;   // Paid | Pending | Partial | Overdue
    private String invDate;
    private String method;
    private String woId;
    private String bkId;
    private String notes;
    private String customerUserid;

    public Invoice() {}

    public Invoice(String id, String customer, String vehicle, String services,
                   double amount, double discount, String status, String invDate,
                   String method, String woId, String bkId, String notes) {
        this.id        = id;
        this.customer  = customer;
        this.vehicle   = vehicle;
        this.services  = services;
        this.amount    = amount;
        this.discount  = discount;
        this.status    = status;
        this.invDate   = invDate;
        this.method    = method;
        this.woId      = woId;
        this.bkId      = bkId;
        this.notes     = notes;
    }

    public double getNet() { return amount - discount; }
    public boolean isLinked() { return (woId != null && !woId.isEmpty()) || (bkId != null && !bkId.isEmpty()); }

   
    public String getId(){
        return id; }
    public void   setId(String id){ 
        this.id = id; }
    public String getCustomer(){ 
        return customer; }
    public void   setCustomer(String v){ 
        this.customer = v; }
    public String getVehicle(){
        return vehicle; }
    public void   setVehicle(String v){
        this.vehicle = v; }
    public String getServices(){
        return services; }
    public void   setServices(String v){
        this.services = v; }
    public double getAmount(){ 
        return amount; }
    public void   setAmount(double v){
        this.amount = v; }
    public double getDiscount(){
        return discount; }
    public void   setDiscount(double v){
        this.discount = v; }
    public String getStatus(){
        return status; }
    public void   setStatus(String v){
        this.status = v; }
    public String getInvDate(){
        return invDate; }
    public void   setInvDate(String v){
        this.invDate = v; }
    public String getMethod(){
        return method; }
    public void   setMethod(String v){
        this.method = v; }
    public String getWoId(){
        return woId; }
    public void   setWoId(String v){
        this.woId = v; }
    public String getBkId(){
        return bkId; }
    public void   setBkId(String v){
        this.bkId = v; }
    public String getNotes(){
        return notes; }
    public void   setNotes(String v){
        this.notes = v; }
    
    public String getCustomerUserid(){
        return customerUserid; }
    public void   setCustomerUserid(String v){
        this.customerUserid = v; }
}