@isTest
private class FileUpload_Test {
    
    @isTest
    static void testFileCreate_Success() {
        // Setup test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Base64 encoded string for the file content
        String base64Content = EncodingUtil.base64Encode(Blob.valueOf('Test Content'));
        String fileName = 'TestFile.txt';
        
        Test.startTest();
        
        // Call the fileCreate method
        Map<String, String> result = FileUpload.fileCreate(base64Content, fileName, testAccount.Id);
        String resultContentDocumentLinkId = result.get('contentDocumentLinkId');
        
        Test.stopTest();
        
        // Verify the result
        System.assertNotEquals(null, resultContentDocumentLinkId, 'ContentDocumentLink Id should not be null');
        
        ContentDocumentLink createdLink = [SELECT Id, ContentDocumentId, LinkedEntityId, ShareType 
                                           FROM ContentDocumentLink 
                                           WHERE Id = :resultContentDocumentLinkId];
        ContentVersion createdVersion = [SELECT Id, Title, PathOnClient, ContentDocumentId 
                                         FROM ContentVersion 
                                         WHERE ContentDocumentId = :createdLink.ContentDocumentId];
        
        System.assertEquals(testAccount.Id, createdLink.LinkedEntityId, 'The LinkedEntityId should match the Account Id');
        System.assertEquals('V', createdLink.ShareType, 'The ShareType should be Viewer');
        System.assertEquals(fileName, createdVersion.Title, 'The file name should match');
        System.assertEquals(fileName, createdVersion.PathOnClient, 'The PathOnClient should match');
    }
}
