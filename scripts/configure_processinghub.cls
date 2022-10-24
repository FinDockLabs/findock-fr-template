public static void createSepaTarget(String targetName ) {
    if ([select Id from cpm__Targets__c where Name = :targetName].size() == 0) {
        cpm__Targets__c target = new cpm__Targets__c(
            Name = targetName,
            cpm__Name__c = targetName,
            cpm__Sub_type__c = 'SEPA',
            cpm__Global_Target__c = 'PaymentHub-SEPA'
        );
        cpm__Target_Property__c[] tps = new List<cpm__Target_Property__c>();
        
        tps.add(new cpm__Target_Property__c(cpm__Target_Name__c = target.cpm__Name__c, cpm__Key__c = 'PAIN_008_CBI', cpm__Value__c = 'NO'));
        tps.add(new cpm__Target_Property__c(cpm__Target_Name__c = target.cpm__Name__c, cpm__Key__c = 'BANK_ACCOUNT_NUMBER', cpm__Value__c = 'NL79DJBO0897468244'));
        tps.add(new cpm__Target_Property__c(cpm__Target_Name__c = target.cpm__Name__c, cpm__Key__c = 'BANK_ACCOUNT_ADDITION', cpm__Value__c = 'RABONL2U'));
        tps.add(new cpm__Target_Property__c(cpm__Target_Name__c = target.cpm__Name__c, cpm__Key__c = 'COMPANY_NAME', cpm__Value__c = 'Demo NGO'));
        tps.add(new cpm__Target_Property__c(cpm__Target_Name__c = target.cpm__Name__c, cpm__Key__c = 'CREDITOR_ID', cpm__Value__c = 'be52zzz825d000000028'));
        tps.add(new cpm__Target_Property__c(cpm__Target_Name__c = target.cpm__Name__c, cpm__Key__c = 'RECORDS_PER_SEQUENCE_TYPE', cpm__Value__c = '9999'));
        tps.add(new cpm__Target_Property__c(cpm__Target_Name__c = target.cpm__Name__c, cpm__Key__c = 'RECORDS_PER_FILE', cpm__Value__c =  '99999'));
        tps.add(new cpm__Target_Property__c(cpm__Target_Name__c = target.cpm__Name__c, cpm__Key__c = 'DUPLICATE_CAMT_PROTECTION', cpm__Value__c = 'NO'));
        tps.add(new cpm__Target_Property__c(cpm__Target_Name__c = target.cpm__Name__c, cpm__Key__c = 'UPLOAD_SDD_TO_CHATTER', cpm__Value__c = 'YES'));
        tps.add(new cpm__Target_Property__c(cpm__Target_Name__c = target.cpm__Name__c, cpm__Key__c = 'PAIN00800102_VALIDATION', cpm__Value__c = 'NO'));
        tps.add(new cpm__Target_Property__c(cpm__Target_Name__c = target.cpm__Name__c, cpm__Key__c = 'HASH_ALGORITHM', cpm__Value__c = 'SHA-256'));
        tps.add(new cpm__Target_Property__c(cpm__Target_Name__c = target.cpm__Name__c, cpm__Key__c = 'BULK_PAYABLES_ENABLED', cpm__Value__c = 'NO'));
        tps.add(new cpm__Target_Property__c(cpm__Target_Name__c = target.cpm__Name__c, cpm__Key__c = 'CAMT_MESSAGE_TYPE', cpm__Value__c = 'CAMT.053'));
        tps.add(new cpm__Target_Property__c(cpm__Target_Name__c = target.cpm__Name__c, cpm__Key__c = 'CONTENT_VERSION_OPTION', cpm__Value__c = 'both'));
        tps.add(new cpm__Target_Property__c(cpm__Target_Name__c = target.cpm__Name__c, cpm__Key__c = 'BANK_IDENTIFICATION_NUMBER', cpm__Value__c = ''));
        tps.add(new cpm__Target_Property__c(cpm__Target_Name__c = target.cpm__Name__c, cpm__Key__c = 'ASSOCIATE_CHARGES_TO', cpm__Value__c = ''));
        tps.add(new cpm__Target_Property__c(cpm__Target_Name__c = target.cpm__Name__c, cpm__Key__c = 'GROUP_HEADER_ID', cpm__Value__c = ''));
        tps.add(new cpm__Target_Property__c(cpm__Target_Name__c = target.cpm__Name__c, cpm__Key__c = 'SCHEMA_NAME', cpm__Value__c = ''));
        tps.add(new cpm__Target_Property__c(cpm__Target_Name__c = target.cpm__Name__c, cpm__Key__c = 'CBI_CLEARING_SYSTEM_MEMBER_ID', cpm__Value__c = ''));
        insert target;
        insert tps;
    }
}
public static void configureProcessingHub() {
    if ([select Id from CollaborationGroup where Name = 'Finance'].size() == 0) {
        // Create Chatter Group
        CollaborationGroup financeGroup = new CollaborationGroup(
            Name = 'Finance', 
            CollaborationType = 'Private',
            IsAutoArchiveDisabled = true,
            OwnerId = UserInfo.getUserId()
        );
        insert financeGroup;

        // also set the environment value for ProcessingHub
        List<proh__Environment_Settings__c> phubSettingsList = [SELECT Id, Name, proh__Value__c FROM proh__Environment_Settings__c WHERE Name = 'CHATTER_GROUP_ID'];
        proh__Environment_Settings__c phubSettings;
        if(phubSettingsList.isEmpty()) {
            phubSettings = new proh__Environment_Settings__c(Name = 'CHATTER_GROUP_ID');
        } else {
            phubSettings = phubSettingsList[0];
        }
        phubSettings.proh__Value__c = financeGroup.Id;
        upsert phubSettings;
    }
}