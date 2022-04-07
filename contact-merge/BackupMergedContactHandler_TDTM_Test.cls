/**
 * @description  BackupMergedContactHandler_TDTM_Test - Test class for the BackupMergedContactHandler_TDTM
 * @author Vinti Ajmera
 * @date - 6-12-2021
 */
@IsTest
public class BackupMergedContactHandler_TDTM_Test {

    @IsTest
    static void testContactMergeBackupTrigger() {

        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();
        // Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'BackupMergedContactHandler';
        th.npsp__Class__c = 'BackupMergedContactHandler_TDTM';
        th.npsp__Object__c = 'Opportunity';
        th.npsp__Trigger_Action__c = 'AfterDelete;';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 3;
        th.npsp__Asynchronous__c = false;
        triggerHandlers.add(th);

        // setup our test data...
        Test.startTest();
        Account Acc = new Account(Name = 'test household');
        insert acc;

        Account testAccount = [SELECT Id, Name FROM Account WHERE Name = 'test household' LIMIT 1];

        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact 2', Email = 'testcontact@test.com', AccountId = testAccount.Id);
        insert con;

        List<Contact> conList = new List<Contact>{
                new Contact(FirstName = 'Test', LastName = 'Contact 0', Email = 'testcontact@test.com', AccountId = testAccount.Id),
                new Contact(FirstName = 'Test', LastName = 'Contact 1', Email = 'testcontact@test.com', AccountId = testAccount.Id)
        };

        insert conList;

        Database.MergeResult[] results = Database.merge(con, conList, false);

        Boolean MergeResult = false;

        for (Database.MergeResult res : results) {
            if (res.isSuccess()) {
                MergeResult = res.isSuccess();
            } else {
                MergeResult = false;
            }
        }
        Test.stopTest();
        //stop test

        if (MergeResult == true) {
            List<Merge_Keys__c> getMergedKeysRecord = [SELECT Salesforce_ID__c FROM Merge_Keys__c WHERE Salesforce_ID__c != NULL];
            System.assertNotEquals(0, getMergedKeysRecord.size());
        }

    }
}