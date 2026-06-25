package model;

public class Inventory {

    private int partID;
    private String partName;
    private String description;
    private int stockQty;
    private double unitPrice;

    public Inventory() {
    }

    public Inventory(int partID, String partName, String description,
                     int stockQty, double unitPrice) {
        this.partID = partID;
        this.partName = partName;
        this.description = description;
        this.stockQty = stockQty;
        this.unitPrice = unitPrice;
    }

    public int getPartID() {
        return partID;
    }

    public void setPartID(int partID) {
        this.partID = partID;
    }

    public String getPartName() {
        return partName;
    }

    public void setPartName(String partName) {
        this.partName = partName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getStockQty() {
        return stockQty;
    }

    public void setStockQty(int stockQty) {
        this.stockQty = stockQty;
    }

    public double getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(double unitPrice) {
        this.unitPrice = unitPrice;
    }
}