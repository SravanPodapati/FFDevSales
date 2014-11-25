public with sharing class EmailController {
    public String address {
        public get;
        public set;
    }
    public String cc {
        public get;
        public set;
    }
    public String bcc {
        public get;
        public set;
    }
    public String subject {
        public get;
        public set;
    }
    public String body {
        public get;
        public set;
    }
    //public String relatedTo{public get; public set;}
    public String parentId {
        get;
        set;
    }
    public Attachment orderAttachment {
        get;
        set;
    }
    public Order order {
        public get;
        public set;
    }
    public boolean attachmentExists {
        public get;
        public set;
    }
    public String attachmentUrl {
        public get;
        public set;
    }
     public Boolean multiCts{
        public get;
        public set;
    }
    public String mutiCtsMsg{
        public get;
        public set;
    }

    public EmailController(ApexPages.StandardController controller) {
        this.orderAttachment = new Attachment();
        String orderNumber = apexpages.currentpage().getparameters().get('orderNo');
        List<Contact> contacts = new List<Contact>();
        String idToCompare;
        order = [Select id, Caller_Name__c,Caller_Phone__c,cciBookingAgencyId__c,CCI_Account_ID__c,Booking_Agency__r.Id,Agency__r.id,OrderNumber, Account.Name from Order where OrderNumber = : orderNumber limit 1];
        try{
         if(!String.IsBlank(order.Booking_Agency__c)&& (!String.IsBlank(order.Caller_Name__c)||!String.IsBlank(order.Caller_Phone__c))){
             idToCompare = order.Booking_Agency__r.id;
          //contacts = [Select id,AccountId,Account.CCIMailCustID__c,Account.CCIMetroCustID__c,email from Contact where name = :order.Caller_Name__c and Phone = :order.Caller_Phone__c and (Account.CCIMailCustID__c=:idToCompare or Account.CCIMetroCustID__c =:idToCompare)];
         }
         else if(!String.IsBlank(order.Caller_Name__c)||!String.IsBlank(order.Caller_Phone__c)){
            idToCompare = order.Agency__r.id;
            
         }
         contacts = [Select id,AccountId,email from Contact where name=:order.Caller_Name__c and Phone=:order.Caller_Phone__c and AccountId=:idToCompare];
               
        }catch(Exception e){
            System.debug('No contacts found matching the caller name and phone details in order');
         }
         
         if(contacts.size()==1){
              this.address = contacts[0].Email;
         }else if(contacts.size()>1){
             this.multiCts = true;
               this.mutiCtsMsg = ' *'+Label.Multiple_Contacts_Found+' '+order.Caller_Name__c+'.*';
             }
                  
        // this.order = (Order)controller.getRecord();
        parentId = order.id;
        this.attachOrder();
        string phone = [select id, phone From User Where Id =: system.UserInfo.getUserID() limit 1].phone;
        String bodyStr;
        if(phone != null && phone.trim() != ''){
            bodyStr = 'The attached represents confirmation for Order No.' + order.OrderNumber + ' for ' + order.Account.Name + '.' + '\n' + Label.ErrorOrderconfirmation+' '+phone+'.';
        }else{
            bodyStr = 'The attached represents confirmation for Order No.' + order.OrderNumber + ' for ' + order.Account.Name + '.' + '\n' + 'If you have any problems please contact me by email.';
        }
        
        this.body = bodyStr;
        //GAR-919
        this.subject = 'Order Confirmation';
        System.debug('Parent id is' + parentId);
    }

    public PageReference send() {
        if (address == null || address == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, system.Label.To_Field_exception));
        }
        if (subject == null || subject == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, system.Label.Subject_Field_exception));
        }
        if (address == null || address == '' || subject == null || subject == '') return null;
        // Define the email

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        // Create the email attachment
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(orderAttachment.name);
        blob temp = orderAttachment.body;
        efa.setBody(temp);

        list < String > toAddresses = new list < string > (address.split(':', 0));
        system.debug('***toAddress: ' + toAddresses);

        // Sets the paramaters of the email
        email.setSubject(subject);
        email.setToAddresses(toAddresses);

        if (bcc != null && bcc.trim() != '') {
            list < String > bccAddresses = new list < string > (bcc.split(':', 0));
            email.setBCCAddresses(bccAddresses);
        }

        if (cc != null && cc.trim() != '') {
            list < String > ccAddresses = new list < string > (cc.split(':', 0));
            email.setCCAddresses(ccAddresses);
        }
        //email.setPlainTextBody( body );
        email.setHTMLBody(body);
        if (orderAttachment.body != null) email.setFileAttachments(new Messaging.EmailFileAttachment[] {
            efa
        });

        Task t = new Task();
        t.Subject = subject;
        t.WhatId = parentId;
        t.ActivityDate = System.Today();
        t.OwnerId = Common.getUserInfo().id;
        t.Status = 'Completed';
        t.Description = 'CC:' + cc + '\n' + 'BCC:' + bcc + '\n' + 'Subject:' + subject + '\n' + 'Body:' + body;
        insert t;

        // Sends the email
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            email
        });
        return new PageReference('/' + parentId);
    }

    public PageReference remove() {
        orderAttachment = null;
        attachmentExists = false;
        return null;
    }

    public PageReference view() {
        String orderId = orderAttachment.id;
        PageReference p = new PageReference('/orderId');
        p.setRedirect(true);
        return p;
    }

    public PageReference cancel() {
        PageReference p = new PageReference('/' + parentId);
        p.setRedirect(true);
        return p;
    }

    public void attachOrder() {
        // create attachgment
        //set orderAttachment
        system.debug('*******');
        blob file;
        Pagereference BookingConfirmationPdf = Page.BookingConfirmationPdf;
        BookingConfirmationPdf.getParameters().put('id', parentId);
        if (!test.isRunningTest()) {
            file = BookingConfirmationPdf.getContentAsPDF();
        } else {
            file = Blob.valueOf('Running Tests');
        }
        this.orderAttachment = new Attachment();
        this.orderAttachment.Name = 'Booking Confirmation.pdf';
        this.orderAttachment.Body = file;
        //attachmentExists = true;
        this.attachmentExists = true;
        attachmentURL = '/apex/BookingConfirmationPdf?id={!parentID}';
    }

    /* public PageReference attach(){
    
    // create attachgment
    //set orderAttachment
    //
    system.debug('*******');
        blob file; 
        Pagereference BookingConfirmationPdf = Page.BookingConfirmationPdf;
        BookingConfirmationPdf.getParameters().put('id', parentId);
        file = BookingConfirmationPdf.getContentAsPDF();
        this.orderAttachment=new Attachment();
        this.orderAttachment.Name='Booking Conformation.pdf';
        this.orderAttachment.Body = file;
       //attachmentExists = true;
        this.attachmentExists = true;
        attachmentURL = '/apex/BookingConfirmationPdf?id={!parentID}';
            
    return null;
    
    }*/

}