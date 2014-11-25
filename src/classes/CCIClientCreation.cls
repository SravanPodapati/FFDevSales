public with sharing class CCIClientCreation {

	public Account acc;
	public String dbType;

	public CCIClientCreation() {}
	public CCIClientCreation(Account acc, String dbType) {
		this.acc = acc;
		this.dbType = dbType;
	}

	public String getReqJsonBody() {
		String retVal;
		retVal = Json.serialize(new CCICustomerWrapper(acc, dbType));
		return retVal;
	}
}