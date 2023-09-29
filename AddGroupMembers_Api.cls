@RestResource(urlMapping='/AddMembers/*')
global class AddGroupMembers_Api {
    @HttpPost
    global static void AddMembers(String GroupId,List<String> MemberId) {
        Map<String, Object> response = new Map<String, Object>();

        try {  
            // Create a list to store group member records
            List<Group_Member__c> membersList = new List<Group_Member__c>();

            // Create a list to store ContentVersion records
            List<ContentVersion> contentVersions = new List<ContentVersion>();
            
            // Iterate through the provided data
            Customer__c cust = [Select Id, Name , Group__r.Id  From Customer__c Where Group__r.Id =:GroupId ];
            for (Integer i = 0; i < MemberId.size(); i++) {
               
                cust.Group__c=MemberId[i];
                Update Cust;

            }

            // Insert group members and content versions
            insert membersList;
            insert contentVersions;

            // Create ContentDocumentLink records to associate images with group members
            List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
            for (Integer i = 0; i < membersList.size(); i++) {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersions[i].Id].ContentDocumentId;
                cdl.LinkedEntityId = membersList[i].Id;
                cdl.ShareType = 'V'; // Set the appropriate sharing type
                cdl.Visibility = 'AllUsers'; // Set the appropriate visibility
                contentDocumentLinks.add(cdl);
            }

            // Insert content document links
            insert contentDocumentLinks;

            response.put('message', 'Your Group Members are Successfully Added.');
            response.put('Status', 'Success');
        
        } catch (Exception ex) {
            response.put('Status', 'Failed');
            response.put('message', ex.getMessage());
        }

        String jsonResponse = JSON.serialize(response);

        // Return the JSON response
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(jsonResponse);
    }
}