package model;

/**
 * PaymentHistory.java — Plain Java model matching the payment_history table.
 */
public class PaymentHistory {

    private int    id;
    private String invoiceId;
    private String receiptNo;
    private String customer;
    private String vehicle;
    private String services;
    private double amount;
    private double discount;
    private String method;
    private String payDate;
    private String recordedBy;
    private String recordedAt;
    private String woId;
    private String bkId;
    private String notes;

    public PaymentHistory() {}

    public double getNet() { return amount - discount; }
    public boolean isLinked() { return (woId != null && !woId.isEmpty()) || (bkId != null && !bkId.isEmpty()); }

  
    public int    getId(){ 
        return id; }
    public void   setId(int v){
        this.id = v; }
    public String getInvoiceId(){
        return invoiceId; }
    public void   setInvoiceId(String v){
        this.invoiceId = v; }
    public String getReceiptNo(){
        return receiptNo; }
    public void   setReceiptNo(String v){
        this.receiptNo = v; }
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
    public String getMethod(){
        return method; }
    public void   setMethod(String v){
        this.method = v; }
    public String getPayDate(){
        return payDate; }
    public void   setPayDate(String v){
        this.payDate = v; }
    public String getRecordedBy(){
        return recordedBy; }
    public void   setRecordedBy(String v){
        this.recordedBy = v; }
    public String getRecordedAt(){
        return recordedAt; }
    public void   setRecordedAt(String v){
        this.recordedAt = v; }
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
}