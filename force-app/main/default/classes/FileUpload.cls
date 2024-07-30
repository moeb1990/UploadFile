public  class FileUpload {
    
    // Create and attach file to record
    @AuraEnabled
    public static String fileCreate(String base64AfterComma, String fileName, String recordId) {
        ContentVersion cv = createContentVersion(base64AfterComma, fileName); // Create Content Version
        ContentDocumentLink cdl = createContentLink(cv.Id, recordId); // Create Content Document Link
        
        if (cv == null || cdl == null) { 
            
            // Create fails
            return null; 
        }
        
        // Create Successful
        return cdl.Id;
    }

    // Create Content Version
    private static ContentVersion createContentVersion(String base64AfterComma, String fileName) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64AfterComma);
        cv.Title = fileName;
        cv.PathOnClient = fileName;
        try {
          insert cv;
          return cv;
        } catch(DMLException e) {
          System.debug(e);
          return null;
        }
      }

      // Craate content document link
      private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        
        // Null Check
        if (contentVersionId == null || recordId == null) { 
            return null; 
        }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [ SELECT ContentDocumentId 
                                FROM ContentVersion 
                                WHERE Id =: contentVersionId
                                ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;       
        cdl.ShareType = 'V';  // V = Viewer, C = Collaborator, I = Inferred
        try {
            insert cdl;
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
}