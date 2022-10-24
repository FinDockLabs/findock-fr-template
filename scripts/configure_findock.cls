public static void activatePackages() {
    List<cpm__Setup_Record__c> setupRecords = [
        select Name, cpm__Apex_Installation_Class__c, cpm__Namespace__c
        from cpm__Setup_Record__c 
        where cpm__Category__c = 'Source' 
        and cpm__IsActive__c = false
        ];
    
    for (cpm__Setup_Record__c setupRecord : setupRecords) {
        String className = (setupRecord.cpm__Namespace__c != null) ? setupRecord.cpm__Namespace__c + '.' + setupRecord.cpm__Apex_Installation_Class__c : 'cpm.' + setupRecord.cpm__Apex_Installation_Class__c; 
        
        Type classType = Type.forName(className);
        cpm.SetupService.activateSourceExtension((cpm.ISetupBase)classType.newInstance());

        if (setupRecord.cpm__Namespace__c != null && setupRecord.cpm__Namespace__c != 'gaid') {
            setupRecord.cpm__IsDefault__c = true;
            update setupRecord;
        } else {
            setupRecord.cpm__IsDefault__c = false;
            update setupRecord;
        }
    } 

    // Activate all psp packagess
    setupRecords = [
        select Name, cpm__Apex_Installation_Class__c, cpm__Namespace__c
        from cpm__Setup_Record__c 
        where cpm__Category__c = 'PSP' and cpm__Namespace__c != null
        and cpm__IsActive__c = false
    ];
    for (cpm__Setup_Record__c setupRecord : setupRecords) {
        String className = setupRecord.cpm__Namespace__c + '.' + setupRecord.cpm__Apex_Installation_Class__c; 
        cpm.SetupService.activatePSPExtension((cpm.ISetupBase)Type.forName(className).newInstance());
    }

    // Activate all system packagess
    setupRecords = [
        select Name, cpm__Apex_Installation_Class__c, cpm__Namespace__c
        from cpm__Setup_Record__c 
        where cpm__Category__c = 'System' and cpm__Namespace__c != null
        and cpm__IsActive__c = false
        ];
    
    for (cpm__Setup_Record__c setupRecord : setupRecords) {
        setupRecord.cpm__IsActive__c = true;
    }
    update setupRecords;
}

public static void activatePaymentMethods() {
    cpm__Payment_Method__c[] paymentMethods = cpm__Payment_Method__c.getAll().values();
    cpm__Payment_Method__c[] updateMethods = new List<cpm__Payment_Method__c>();
        for ( cpm__Payment_Method__c pm : paymentMethods ) {
            if ( !pm.cpm__IsActive__c ) {
                pm.cpm__IsActive__c = true;
                updateMethods.add (pm);
            }
        }
    update updateMethods;
}
public static void setDefaultConfig() {
    List<cpm__PaymentHub_Settings__c> settingsList = [select Id, Name from cpm__PaymentHub_Settings__c where Name = 'main' limit 1];
    cpm__PaymentHub_Settings__c settings; 
    settings = new cpm__PaymentHub_Settings__c(
        Name = 'main'
    );
    settings.cpm__Re_use_existing_mandate__c = true;
    settings.cpm__Mandate_Reference__c = 'DEMO';
    settings.cpm__Auto_Create_Mandate_Recurring_Payment_DD__c = true;
    settings.cpm__Enforce_Payment_Profile_Uniqueness__c = true;
    upsert settings Name;
}
public static void setDefaultSourceConnector(String connectorName) {
    cpm__Setup_Record__c[] sourceSetupRecords = [SELECT Id, Name, cpm__IsDefault__c, cpm__IsActive__c FROM cpm__Setup_Record__c WHERE cpm__Category__c = 'Source' AND (cpm__IsDefault__c = true OR Name = :connectorName)];
    for(cpm__Setup_Record__c sr : sourceSetupRecords) {
        sr.cpm__IsDefault__c = (sr.Name == connectorName ) ? true : false;
    }
    update sourceSetupRecords;
}

public static void assignPermissionSets() {
    String[] nameSpaces = new List<String>(); 
    for(cpm__Setup_Record__c sr : [SELECT cpm__Namespace__c FROM cpm__Setup_Record__c]) {
        if(String.isNotBlank(sr.cpm__Namespace__c)) {
            nameSpaces.add(sr.cpm__Namespace__c);
        }
    }
    nameSpaces.add('cpm');
    
    //load all permission sets associated with those namespaces
    Map<Id, PermissionSet> allFinDockPermissionSetsMap = new Map<Id, PermissionSet>([SELECT Id, Label FROM PermissionSet WHERE IsOwnedByProfile = false AND NameSpacePrefix IN :nameSpaces]);
    PermissionSet FinDockAddditionalPermission = [select Id, Label from PermissionSet where Name = 'FinDock_Additional_Setup'][0];
    //add findockDemoUser to the list
    allFinDockPermissionSetsMap.put(FinDockAddditionalPermission.Id, FinDockAddditionalPermission);

    //get a list permission sets already assigned to this user that are in the list of FinDock associated permissionsets.
    Set<Id> assignedPermissionSets = new Set<Id>();
    for(PermissionSetAssignment psa : [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId IN :allFinDockPermissionSetsMap.keySet() AND AssigneeId = :UserInfo.getUserId()]) {
        assignedPermissionSets.add(psa.PermissionSetId);
    }
    
    //now we are ready to assign the missing permission sets
    Set<PermissionSetAssignment> psaInsertList = new Set<PermissionSetAssignment>();
    for(Id psId : allFinDockPermissionSetsMap.keySet()) {
        PermissionSet currentPermissionSet = allFinDockPermissionSetsMap.get(psId);
        if(!assignedPermissionSets.contains(currentPermissionSet.Id)) {
            psaInsertList.add(new PermissionSetAssignment(
                PermissionSetId = currentPermissionSet.Id,
                AssigneeId = UserInfo.getUserId()
            ));
        }
    }
    insert new List<PermissionSetAssignment>(psaInsertList);
}