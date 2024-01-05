public with sharing class JWTIntegration {
    /*
    * This development should exist only in the client side
    * Here in this org for example purposes only
    */
    private JWTConfiguration config;

    public JWTIntegration(JWTConfiguration config){ this.config = config; }

    public string requestAccessToken(){
        Map<string,string> reqBodyMap = new Map<string,string>();
        reqBodyMap.put('grant_type','urn:ietf:params:oauth:grant-type:jwt-bearer');
        reqBodyMap.put('assertion',createToken());

		Http h = new Http();
        HttpRequest hreq = new HttpRequest();
        hreq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        hreq.setEndpoint('https://'+config.JWTHostName+'/services/oauth2/token');
        hreq.setMethod('POST');
        hreq.setTimeout(60*1000);
        hreq.setBody(formEncode(reqBodyMap));
        HttpResponse hres = h.send(hreq);

        if(hres.getStatusCode()>=200 && hres.getStatusCode()<300){
            //parse my response JSON to get access token
            return  extractJSONField(hres.getBody(),'access_token'); 
        }
        else{ throw new JWTException(hres.getBody()); }
    }
    
    private string extractJSONField(string body, string field){
    	JSONParser parser = JSON.createParser(body);

        while(parser.nextToken()!=NULL){
            if(parser.getCurrentToken()== JSONTOKEN.FIELD_NAME && parser.getText()==field){
                parser.nextToken();  
                return parser.getText();
            }   
        }
        throw new JWTException(field+' not found in response '+body);
    }

    private string formEncode(Map<string,string> reqBodyMap){
        string reqBody='';

        for(string key :reqBodyMap.keySet() ){
            if(reqBody.length()>0){ reqBody = reqBody+'&'; }
            
            reqBody = reqBody+ key+'='+EncodingUtil.urlEncode(reqBodyMap.get(key), 'UTF-8');
            //&grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=tokejfkasfaag
        }
        return reqBody;
    }

    public string createToken(){
        string alg ='RS256';
        string iss = config.JWTConnectedAppConsumerKey;
        string prn = config.jwtUserName;
        string aud = 'https://'+config.JWTHostName;
        string exp = string.valueOf((system.currentTimeMillis()+60*60*1000));

        //step 1- create token
        header jwtHeader = new Header(alg);
        string headerJSON = JSON.serialize(jwtHeader);//{"alg":"RS256"}
        system.debug('***headerJSON=>'+headerJSON);

        //step2- create JSON Claim set
        Body jsonClaim = new Body(iss,prn,aud,exp);
        string bodyJSON = JSON.serialize(jsonClaim);
        system.debug('***bodyJSON=>'+bodyJSON);

        //step 3- Base64 URL encode JWTHeader
        string encodedJWTHeader = base64URlSafe(blob.valueOf(headerJSON));
		system.debug('***encodedJWTHeader=>'+encodedJWTHeader);

        //step4- base64 URL encode for bodyJSON
        string encodedJWTBody =  base64URlSafe(blob.valueOf(bodyJSON));
        system.debug('***encodedJWTBody=>'+encodedJWTBody);

        //step5 - create a string of JWTHeader . Body
        string token = encodedJWTHeader+'.'+encodedJWTBody;
		system.debug('***token=>'+token);

        //step 6 - sign with certificate - RSA-SHA256
        string signature = base64URlSafe(Crypto.signWithCertificate('RSA-SHA256', blob.valueOf(token),config.JWTSignedCertificateName ));

        //step 7 - final token - token+'.'+ tokensignature
        token = token+'.'+signature;

         return token;
    }

    public string base64URlSafe(blob b){
    	return EncodingUtil.base64Encode(b).replace('+','-').replace('/','_');   
    }

    public class JWTConfiguration{
        public string jwtUserName{get;set;}
        public string JWTConnectedAppConsumerKey{get;set;}
        public string JWTSignedCertificateName {get;set;}
        public string JWTHostName {get;set;}
    }

    public class Header{
        string alg;

        Header(string alg){ this.alg = alg; }
    }

    public class Body{
        string iss;
        string prn;
        string aud;
        string exp;

        Body(string iss,string prn,string aud,string exp){
        	this.iss = iss;
            this.prn = prn;
            this.aud = aud;
            this.exp = exp;
        }       
    }

    public class JWTException extends Exception{}

    public class leadResponse{
        public string id{get;set;}
        public string Name{get;set;}
        public string Email{get;set;}
        public string Phone{get;set;}
        public string Company{get;set;}
        public string MobilePhone{get;set;}
    }
}