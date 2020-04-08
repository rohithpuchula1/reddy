public with sharing class AccountDataloadUtility {
    
    //Constants
    public static final String ACCOUNT_SOURCE_SS='SS';
    public static final String ACCOUNT_SOURCE_V21='V21';
    public static final String ACCOUNT_SOURCE_Admin3='Admin3';
    public static final String ACCOUNT_SOURCE_ISeries='ISeries';
    /**Method to validate the business account data changes
* Input : SObject is the interface object
* Output:Returns a map for returnValues.        
*/
    public static List<Data_Dominion__c> processBusinessAccountDataChanges(List<Account> businessAccounts,SObject obj){
        List<Data_Dominion__c> dataDominion=new List<Data_Dominion__c>();
        String R1DUNS=(String)obj.get('R1DUNS__c');
        String LDUNS=(String)obj.get('LDUNS__c');
        String childAccount=(String)obj.get('IsChildAccount__c');
        String accountNumber=('Y'==childAccount)?LDUNS:R1DUNS;
        if(!String.isBlank(accountNumber)){
            Account businessAccount;
            for(Account account:businessAccounts){
                if(!String.isBlank(account.R1DUNS__c) && accountNumber==account.R1DUNS__c){
                    businessAccount=account;
                    System.debug('Business account Id:'+businessAccount.Id);
                    break;
                }
            }
            if(businessAccount!=null && businessAccount.New_RB_Id__c!=null){
                dataDominion=reviewMerge(businessAccount,obj);
            }
        }
        return dataDominion;
    }
    /**Method to validate if the parent business account exists
    * Input : SObject is the interface object
    * Output:Returns a map for returnValues.        
    */
    public static List<Data_Dominion__c> validateIfParentExists(List<Account> businessAccounts,SObject obj){
        List<Data_Dominion__c> dataDominion=new List<Data_Dominion__c>();
        String R1DUNS=(String)obj.get('R1DUNS__c');
        String LDUNS=(String)obj.get('LDUNS__c');
        Account parentAccount;
        for(Account account:businessAccounts){
            if(!String.isBlank(account.R1DUNS__c) && account.R1DUNS__c==R1DUNS){
                parentAccount=account;
                break;
            }
        }
        if(!String.isBlank(R1DUNS) && parentAccount == null){
            System.debug('Parent account not found in the system:'+R1DUNS);
            String DUNS=String.isBlank(LDUNS)?R1DUNS:LDUNS;
            
            Data_Dominion__c dataVal = new Data_Dominion__C();
            dataVal.Reference_Field_Name__c='R1DUNS';
            dataVal.Reference_Field_API_Name__c='Parent Id';
            dataVal.Account_Name__c=(String)obj.get('Account_Name__c');
            if(!String.isBlank((String)obj.get('Account_Number__c')))
                dataVal.Description__c='Parent customer account not found for: '+(String)obj.get('Account_Name__c')+'Account Number:'+(String)obj.get('Account_Number__c')+'Account Source:'+(String)obj.get('Account_Source__c')+' with R1DUNS:'+DUNS;
            else
                dataVal.Description__c='Parent customer account not found for: '+(String)obj.get('Account_Name__c')+' and R1DUNS:'+DUNS;
            dataVal.Reference_Field_Value__c=R1DUNS;
            dataVal.Status__c='New';
            dataVal.Type__c='Parent Customer Account Error';
            dataDominion.add(dataVal);
        }else{
            //Set parent account id for the child business account
            if(parentAccount!=null){
                System.debug('Parent Business account ID:'+parentAccount.Id);
                obj.put('ParentId__c',parentAccount.Id);
            }
        }
        
        
        
        return dataDominion;
    }
    
        /**Method to validate if the parent business account exists
    * Input : SObject is the interface object
    * Output:Returns a map for returnValues.        
    */
    public static List<Data_Dominion__c> createDataDominion(SObject obj){
        List<Data_Dominion__c> dataDominion=new List<Data_Dominion__c>();
        String R1DUNS=(String)obj.get('R1DUNS__c');
        String LDUNS=(String)obj.get('LDUNS__c');

        String DUNS=String.isBlank(LDUNS)?R1DUNS:LDUNS;
        
        Data_Dominion__c dataVal = new Data_Dominion__C();
        dataVal.Reference_Field_Name__c='R1DUNS';
        dataVal.Reference_Field_API_Name__c='Parent Id';
        dataVal.Account_Name__c=(String)obj.get('Account_Name__c');
        if(!String.isBlank((String)obj.get('Account_Number__c')))
            dataVal.Description__c='Parent customer account not found for: '+(String)obj.get('Account_Name__c')+'Account Number:'+(String)obj.get('Account_Number__c')+'Account Source:'+(String)obj.get('Account_Source__c')+' with R1DUNS:'+DUNS;
        else
            dataVal.Description__c='Parent customer account not found for: '+(String)obj.get('Account_Name__c')+' and R1DUNS:'+DUNS;
        dataVal.Reference_Field_Value__c=R1DUNS;
        dataVal.Status__c='New';
        dataVal.Type__c='Parent Customer Account Error';
        dataDominion.add(dataVal);

        return dataDominion;
    }

    /**Method to review merge of business account
* Input : Account object,SObject is the interface object
*/
    public static List<Data_Dominion__c> reviewMerge(Account accountObj,SObject obj){
        List<Data_Dominion__c> dataDominion=new List<Data_Dominion__c>();
        System.debug('Review merge for account Name:'+accountObj.Name);
        String accountName=(String)obj.get('Account_Name__c');
        if(!String.isBlank(accountName) && accountObj.Name != accountName){
            System.debug('Account Name is changed:'+accountName);
            Data_Dominion__c dataVal = new Data_Dominion__C();
            dataVal.Reference_Account__c=accountObj.Id;
            dataVal.Reference_Field_Name__c='Name';
            dataVal.Reference_Field_API_Name__c='Name';
            dataVal.Reference_Field_Value__c=accountName;
            dataVal.Old_Field_Value__c=accountObj.Name;
            dataVal.Status__c='New';
            dataVal.Type__c='Merge Review';
            dataDominion.add(dataVal);
            
        }
        String billingCity=(String)obj.get('Billing_City__c');
        String billingState=(String)obj.get('Billing_State__c');
        String billingCountry=(String)obj.get('Billing_Country__c');
        String billingStreet=(String)obj.get('Billing_Street__c');
        String billingPostalCode=(String)obj.get('Billing_Postal_Code__c');
        
        if((!String.isBlank(billingCity) && accountObj.BillingCity != billingCity) || (!String.isBlank(billingState) && accountObj.BillingState != billingState) || (!String.isBlank(billingCountry) && accountObj.BillingCountry !=billingCountry) || (!String.isBlank(billingStreet) && accountObj.BillingStreet != billingStreet) ||(!String.isBlank(billingPostalCode) && accountObj.BillingPostalCode!=billingPostalCode)){
            System.debug('Account Billing address is changed');
            Data_Dominion__c dataVal = new Data_Dominion__C();
            dataVal.Reference_Account__c=accountObj.Id;
            dataVal.Reference_Field_Name__c='Billing Address';
            dataVal.Reference_Field_API_Name__c='BillingAddress';
            dataVal.Reference_Field_Value__c=billingCity+','+billingStreet+','+billingState+','+billingCountry+','+billingPostalCode;
            dataVal.Old_Field_Value__c=accountObj.BillingCity+','+accountObj.BillingStreet+','+accountObj.BillingState+','+accountObj.BillingCountry+','+accountObj.BillingPostalCode;
            dataVal.Status__c='New';
            dataVal.Type__c='Merge Review';
            dataDominion.add(dataVal);
        }
        return dataDominion;
        
    }
    /**Method to create shell customer account for unmatching billing Account
* Input- AccountName,SObject with billing address details
*/
    public static Account createShellCustomerAccount(SObject sobj,ID businessrecordtypeId){
        Account customerShellAccount;
        if(sobj!=null){
            System.debug('createShellCustomerAccount:'+sobj+'recordTypeId:'+businessrecordtypeId);
            customerShellAccount=new Account();
            if(!String.isBlank((String)sobj.get('DUNS__c'))){
                customerShellAccount.Name=(String)sobj.get('Business_Name__c');
            }else{
            customerShellAccount.Name=(String)sobj.get('Account_Name__c');
            }
            customerShellAccount.AccountSource=(String)sobj.get('Account_Source__c');
            customerShellAccount.AccountNumber=(String)sobj.get('Account_Number__c');
            customerShellAccount.BillingCity=(String)sobj.get('Billing_City__c');
            customerShellAccount.BillingCountry=(String)sobj.get('Billing_Country__c');
            customerShellAccount.BillingPostalCode=(String)sobj.get('Billing_Postal_Code__c');
            customerShellAccount.BillingState=(String)sobj.get('Billing_State__c');
            customerShellAccount.BillingStreet=(String)sobj.get('Billing_Street__c');
            //customerShellAccount.MSD_Code__c=(String)sobj.get('MSD_Code__c'); //As per direction from Alex this is Billing Account MSD.
            customerShellAccount.DUNS__c=(String)sobj.get('DUNS__c');
            customerShellAccount.OwnerId=(String)sobj.get('OwnerId');
            customerShellAccount.Root_BAN__c=(String)sobj.get('Root_BAN__c');
            customerShellAccount.ShippingCity=(String)sobj.get('Shipping_City__c');
            customerShellAccount.ShippingCountry=(String)sobj.get('Shipping_Country__c');
            customerShellAccount.ShippingPostalCode=(String)sobj.get('Shipping_Postal_Code__c');
            customerShellAccount.ShippingState=(String)sobj.get('Shipping_State__c');
            customerShellAccount.ShippingStreet=(String)sobj.get('Shipping_Street__c');
            customerShellAccount.vlocity_cmt__Status__c='Active';
            customerShellAccount.RecordTypeId=businessrecordtypeId;
            customerShellAccount.Unique_Index__c=(String)sobj.get('Unique_Index__c');
            customerShellAccount.Match_Confidence__c=(String)sobj.get('Match_Confidence__c');
            customerShellAccount.Match_Code__c=(String)sobj.get('Match_Code__c');
            customerShellAccount.Domestic_DUNS__c=(String)sobj.get('Domestic_DUNS__c');
            customerShellAccount.R1DUNS__c=(String)sobj.get('R1DUNS__c'); //Add R1DUNS for Mapping
            System.debug('createShellCustomerAccount:'+customerShellAccount);
            
        }
        
        
        return customerShellAccount;
    }

    public static Account createParentShellCustomerAccount(SObject sobj,ID businessrecordtypeId){
        Account customerShellAccount;
        if(sobj!=null){
            System.debug('createShellCustomerAccount:'+sobj+'recordTypeId:'+businessrecordtypeId);
            customerShellAccount=new Account();
            if(!String.isBlank((String)sobj.get('DUNS__c'))){
                customerShellAccount.Name=(String)sobj.get('Business_Name__c');
            }else{
                customerShellAccount.Name=(String)sobj.get('Account_Name__c');
            }
            customerShellAccount.AccountSource=(String)sobj.get('Account_Source__c');
            customerShellAccount.AccountNumber=(String)sobj.get('Account_Number__c');
            customerShellAccount.BillingCity=(String)sobj.get('Billing_City__c');
            customerShellAccount.BillingCountry=(String)sobj.get('Billing_Country__c');
            customerShellAccount.BillingPostalCode=(String)sobj.get('Billing_Postal_Code__c');
            customerShellAccount.BillingState=(String)sobj.get('Billing_State__c');
            customerShellAccount.BillingStreet=(String)sobj.get('Billing_Street__c');
            //customerShellAccount.MSD_Code__c=(String)sobj.get('MSD_Code__c'); //As per direction from Alex this is Billing Account MSD.
            customerShellAccount.DUNS__c=(String)sobj.get('DUNS__c');
            customerShellAccount.OwnerId=(String)sobj.get('OwnerId');
            customerShellAccount.Root_BAN__c=(String)sobj.get('Parent_BAN__c');
            customerShellAccount.ShippingCity=(String)sobj.get('Shipping_City__c');
            customerShellAccount.ShippingCountry=(String)sobj.get('Shipping_Country__c');
            customerShellAccount.ShippingPostalCode=(String)sobj.get('Shipping_Postal_Code__c');
            customerShellAccount.ShippingState=(String)sobj.get('Shipping_State__c');
            customerShellAccount.ShippingStreet=(String)sobj.get('Shipping_Street__c');
            customerShellAccount.vlocity_cmt__Status__c='Active';
            customerShellAccount.RecordTypeId=businessrecordtypeId;
            customerShellAccount.Unique_Index__c=(String)sobj.get('Unique_Index__c');
            customerShellAccount.Match_Confidence__c=(String)sobj.get('Match_Confidence__c');
            customerShellAccount.Match_Code__c=(String)sobj.get('Match_Code__c');
            customerShellAccount.Domestic_DUNS__c=(String)sobj.get('Domestic_DUNS__c');
            customerShellAccount.R1DUNS__c=(String)sobj.get('R1DUNS__c'); //Add R1DUNS for Mapping
            customerShellAccount.vlocity_cmt__SLA__c = 'Gold'; //Map SLA as a place holder for finding records created with R1DUNS
            System.debug('createShellCustomerAccount:'+customerShellAccount);
        }
        
        
        return customerShellAccount;
    }
    
    
    /**Description - Method to create service account
*Input - SObject (Billing Account)
*/
    public static Service_Account_IO__c createServiceAccount(SObject sobj){
        Service_Account_IO__c serviceAccount=new Service_Account_IO__c();
        serviceAccount.Account_Source__c=(String)sobj.get('Account_Source__c');
        serviceAccount.Account_Number__c=(String)sobj.get('Account_Number__c');
        serviceAccount.Account_Name__c=(String)sobj.get('Account_Name__c');
        serviceAccount.Billing_City__c=(String)sobj.get('Billing_City__c');
        serviceAccount.Billing_Country__c=(String)sobj.get('Billing_Country__c');
        serviceAccount.Billing_Latitude__c=(String)sobj.get('Billing_Latitude__c');
        serviceAccount.Billing_Longitude__c=(String)sobj.get('Billing_Longitude__c');
        serviceAccount.Billing_Postal_Code__c=(String)sobj.get('Billing_Postal_Code__c');
        serviceAccount.Billing_State__c=(String)sobj.get('Billing_State__c');
        serviceAccount.Billing_Street__c=(String)sobj.get('Billing_Street__c');
        serviceAccount.MSD_Code__c=(String)sobj.get('MSD_Code__c');
        serviceAccount.OwnerId=(String)sobj.get('OwnerId');
        serviceAccount.Root_BAN__c=(String)sobj.get('Root_BAN__c');
        serviceAccount.Name=(String)sobj.get('Name');
        serviceAccount.Shipping_City__c=(String)sobj.get('Shipping_City__c');
        serviceAccount.Shipping_Country__c=(String)sobj.get('Shipping_Country__c');
        serviceAccount.Shipping_Latitude__c=(String)sobj.get('Shipping_Latitude__c');
        serviceAccount.Shipping_Longitude__c=(String)sobj.get('Shipping_Longitude__c');
        serviceAccount.Shipping_Postal_Code__c=(String)sobj.get('Shipping_Postal_Code__c');
        serviceAccount.Shipping_State__c=(String)sobj.get('Shipping_State__c');
        serviceAccount.Shipping_Street__c=(String)sobj.get('Shipping_Street__c');
        serviceAccount.Status__c=(String)sobj.get('Status__c');
        serviceAccount.ParentID__c=(String)sobj.get('ParentID__c');
        serviceAccount.DUNS__c=(String)sobj.get('DUNS__c');
        serviceAccount.Unique_Index__c=(String)sobj.get('Unique_Index__c');
        return serviceAccount;
        
    }
     /**Description - Method to create consolidated billing account
*Input - SObject (Billing Account)
*/
    public static Account createConsolidatedBillingAccount(SObject sobj,ID billingrecordtypeId){
        Account billingAccount;
        if(sobj!=null){
             System.debug('createConsolidatedBillingAccount:'+sobj+'recordTypeId:'+billingrecordtypeId);
            billingAccount=new Account();
            billingAccount.Name=(String)sobj.get('BAN_Name__c') == null ? (String)sobj.get('Account_Name__c') : (String)sobj.get('BAN_Name__c');
            billingAccount.AccountSource= (String)sobj.get('Account_Source__c') == 'SS' ? ACCOUNT_SOURCE_V21 : ACCOUNT_SOURCE_ISeries;
            billingAccount.AccountNumber=(String)sobj.get('BAN__c');
            billingAccount.BillingCity=(String)sobj.get('BAN_City__c');
            billingAccount.BillingCountry=(String)sobj.get('BAN_Country__c');
            billingAccount.BillingPostalCode=(String)sobj.get('BAN_Postal_Code__c');
            billingAccount.BillingState=(String)sobj.get('BAN_State__c');
            billingAccount.BillingStreet=(String)sobj.get('BAN_Street__c');
            billingAccount.MSD_Code__c=(String)sobj.get('MSD_Code__c');
            billingAccount.OwnerId=(String)sobj.get('OwnerId');
            billingAccount.Root_BAN__c=(String)sobj.get('Root_BAN__c');
            billingAccount.vlocity_cmt__Status__c='Active';
            billingAccount.ParentId=(String)sobj.get('ParentID__c');
            billingAccount.RecordTypeId=billingrecordtypeId;
            System.debug('consolidateBillingAccount:'+billingAccount);
            
        }
        
        
        return billingAccount;
        
    }

    public static Account createParentBillingAccount(SObject sobj,ID billingrecordtypeId){
        Account billingAccount;
        if(sobj!=null){
             System.debug('createConsolidatedBillingAccount:'+sobj+'recordTypeId:'+billingrecordtypeId);
            billingAccount=new Account();
            billingAccount.Name=(String)sobj.get('BAN_Name__c') == null ? (String)sobj.get('Account_Name__c') : (String)sobj.get('BAN_Name__c');
            billingAccount.AccountSource=(String)sobj.get('Account_Source__c');
            billingAccount.AccountNumber=(String)sobj.get('Parent_BAN__c');
            billingAccount.BillingCity=(String)sobj.get('BAN_City__c');
            billingAccount.BillingCountry=(String)sobj.get('BAN_Country__c');
            billingAccount.BillingPostalCode=(String)sobj.get('BAN_Postal_Code__c');
            billingAccount.BillingState=(String)sobj.get('BAN_State__c');
            billingAccount.BillingStreet=(String)sobj.get('BAN_Street__c');
            billingAccount.MSD_Code__c=(String)sobj.get('MSD_Code__c');
            billingAccount.OwnerId=(String)sobj.get('OwnerId');
            billingAccount.Root_BAN__c=(String)sobj.get('Root_BAN__c');
            billingAccount.vlocity_cmt__Status__c='Active';
            billingAccount.ParentId=(String)sobj.get('ParentID__c');
            billingAccount.RecordTypeId=billingrecordtypeId;
            System.debug('consolidateBillingAccount:'+billingAccount);
            
        }
        
        
        return billingAccount;
        
    }
    
}