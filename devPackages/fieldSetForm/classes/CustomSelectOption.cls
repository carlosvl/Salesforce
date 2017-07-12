public class CustomSelectOption {
    public CustomSelectOption(String value, String label, Boolean isDefault) {
        this.value = value;
        this.label = label;
        this.disabled = false;
        this.isDefault = isDefault;
        this.escapeItem = false;
    }

    @AuraEnabled
    public String label { get;set; }
    @AuraEnabled
    public String value { get;set; }
    @AuraEnabled
    public Boolean disabled { get;set; }
    @AuraEnabled
    public Boolean escapeItem { get;set; }
    @AuraEnabled
    public Boolean isDefault { get; set; }

}