@RestResource(urlMapping='/LeadService/*')
global class LeadRestService {
	
    //method get dont take any parameter
    @HttpGet
    global static List<Lead> getLeadInfo(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        System.debug(
            'req.requestURI: ' + req.requestURI
        );
        
        String requestURI = req.requestURI;
        String leadName = '%' + requestURI.substring(requestURI.lastIndexOf('=')+1) + '%';
        System.debug('leadName: ' + leadName);
        //String leadName = '%Adam%';
        List<Lead> leadList = [SELECT Id, Name, Email, Phone, Company, MobilePhone 
                               	FROM Lead 
                               	WHERE Name LIKE :leadName];
        
        return leadList;
    }
    
    //method delete dont take any parameter
    @HttpDelete
    global static String deleteMatchingLead(){
        Integer leadCount = 0;
        String responseMessage;
        
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            
            System.debug(
                'req.requestURI: ' + req.requestURI
            );
            
            String requestURI = req.requestURI;
            String leadName = '%' + requestURI.substring(requestURI.lastIndexOf('=')+1) + '%';
            System.debug('leadName: ' + leadName);
            //String leadName = '%Adam%';
            List<Lead> leadList = [SELECT Id, Name, Email, Phone, Company, MobilePhone 
                                    FROM Lead 
                                    WHERE Name LIKE :leadName];
            
            if(leadList!= null && leadList.size() > 0){
                leadCount = leadList.size();
            }
            
            delete leadList;
            responseMessage = 'Lead Deleted successfully => lead delete count: ' + leadCount;
            
        } catch(Exception e){
            responseMessage = 'Exception occured during Delete => ' + e.getMessage();
        }
        
        return responseMessage;
    }
    
    //method post can take parameters
    @HttpPost
    global static String createNewLead(String fname, String lname, String cname, String leademail, String leadphone){
        
        String responseMessage;
        
        try{
            Lead l = new Lead(
        		FirstName = fname,
                LastName = lname,
                Company = cname,
                Email = leademail,
                Phone = leadphone
        	);
            
            insert l;
            
            responseMessage = 'Lead create successfully: ' + l.Id;
            
        }catch(Exception e){
            responseMessage = 'Error occured during new lead cration =>  ' + e.getMessage();
        }
        
        return responseMessage;
    }
    
    //method path can take parameters
    @HttpPatch
    global static String updateLeadEmail(String newEmail){
     	String respMessage;
        
        try{
            RestRequest req = RestContext.request;
            String requestURI = req.requestURI;
            
            String leadId = requestURI.substring(requestURI.lastindexOf('=') + 1);
            
            Lead myLead = [SELECT Id, Email FROM Lead WHERE Id =:leadId];
            
            if(myLead != null && myLead.Email != newEmail){
                myLead.email = newEmail;
                update myLead;
                
                respMessage = 'Lead updated from old email successfully => ' + myLead.Id;
            }
            else{
                respMessage = 'Currentlt this lead is having same email address ' + newEmail;
            }
        }catch(Exception e){
            respMessage = 'Exception occured during lead update' + e.getmessage();
        }
         
        return respMessage;
    }
}