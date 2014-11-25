public class AccountMappingInfo {
	public Id mappingId { get; set;}
	public Id accountId { get; set;}
	public String sourceKey { get; set; }
	public String sourceSystem { get; set; }
	public Boolean active { get; set; }

	public AccountMappingInfo(Id mappingId, Id accId, String sourceKey, String sourceSystem, Boolean active) {
		this.mappingId = mappingId;
		this.accountId = accId;
		this.sourceKey = sourceKey;
		this.sourceSystem = sourceSystem;
		this.active = active;

	}
}