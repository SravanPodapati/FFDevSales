public with sharing class CCIOrderCancel {

  public String code;
  public String orderAmendmentTypeCode;
  public String reason;

  public CCIOrderCancel() {}
  public CCIOrderCancel(String code, String reason) {
    this.code = code;
    this.reason = reason;
    this.orderAmendmentTypeCode='CANCEL';
  }

  public String getReqJsonBody() {
    String retVal;
    retVal = Json.serialize(new CCIOrderCancel(code, reason));
    return retVal;
  }
}