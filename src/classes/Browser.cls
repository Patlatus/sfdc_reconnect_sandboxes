/**
 * Browser class for Reconnect Sandbox project
 *
 * @author: Patlatus
 * @source: https://github.com/Patlatus/sfdc_reconnect_sandboxes/blob/master/src/classes/Browser.cls
 */
public class Browser {
    static List<String> cookies = new List<String>();
    public static String currentEndpoint;
    public static String history = '';
    
    static String subject;
    static String emailBody;
    static String attachmentFileName;
    static Blob attachmentContent;
    
    /**
     * @return : hypothetical base URL : last used domain or current Salesforce domain
     */
    public static String getBaseURL() {
        return ( currentEndpoint != null ) ? 'https://' + currentEndpoint.substringBetween('://', '/') : URL.getSalesforceBaseUrl().toExternalForm();
    }
    
    /**
     * Check response body for javascript redirects, if finds then returns link to redirect to
     * @param String source: source response body string
     * @return : hypothetical link to redirect to
     */
     static String getJSRedirect( String source ) {
        String s = source.substringBetween('window.location.href="','"');
        if ( s != null && s != '' ) {
            return s;
        }
        s = source.substringBetween('window.location.href= \'','\'');
        if ( s != null && s != '' ) {
            return s;
        }
        s = source.substringBetween('window.location.replace(\'','\'');
        if ( s != null && s != '' ) {
            return s;
        }
        return '';
    }
    
    /**
     * Browse using simple GET request for given endpoint.
     * If complete  URL is not specified, tries to use the last used domain or currect Salesforce domain to supplement.
     * @param String endpoint: target endpoint to browse ( complete or relative URL)
     * @return : HttpResponse for last redirection callout
     */
    public static HttpResponse browse(String endPoint) {
        endPoint = endPoint.contains('://') ? endPoint : getBaseURL() + endPoint;
        currentEndpoint = endPoint;
        history += 'Get ' + currentEndpoint + '<br/><br/>';
        HttpResponse r = makeHTTPGetCall( endPoint );
        String location = r.getHeader('Location');
        cookies.add( r.getHeader('Set-Cookie') );
        System.debug(LoggingLevel.ERROR, '@@@ cookies: ' + cookies );
        if ( location != null && location != '' ) {
            history += 'Redirected to ' + location + '<br/><br/>';
            return browse( location );
        }
        String s = r.getBody();
        System.debug(LoggingLevel.ERROR, '@@@ body ' + s);
        s = getJSRedirect( r.getBody() );
        if ( s != null && s != '' ) {
            history += 'Redirected by JS to ' + s + '<br/><br/>';
            return browse( s );
        }
        // don't rely on this logic, apparently it doesn't work
        if ( endPoint.contains('ChangePassword' ) ) {
            history += 'SF requested password change<br/><br/>';
            
            s = r.getBody();
            String token = s.substringBetween('<input type="hidden" name="_CONFIRMATIONTOKEN" id="_CONFIRMATIONTOKEN" value="', '" />');
            System.debug(LoggingLevel.ERROR, '@@@ token: ' + token);
             history += 'Trying to set password to Password<br/><br/>';
            r = Browser.browse(endPoint, '_CONFIRMATIONTOKEN=' + token  + '&cancelURL=%2Fhome%2Fhome.jsp&retURL=%2Fhome%2Fhome.jsp&save_new_url=%2F_ui%2Fsystem%2Fsecurity%2FChangePassword%3FfromFrontdoor%3D1%26retURL%3D%252Fhome%252Fhome.jsp%26setupid%3DChangePassword&setupid=ChangePassword&fromFrontdoor=1&newpassword=Password&confirmpassword=Password' );
            System.debug(LoggingLevel.ERROR, '@@@ password change try r.getBody(): ' + r.getBody());
            history += 'Trying to set password back to password<br/><br/>';
            r = Browser.browse(endPoint, '_CONFIRMATIONTOKEN=' + token  + '&cancelURL=%2Fhome%2Fhome.jsp&retURL=%2Fhome%2Fhome.jsp&save_new_url=%2F_ui%2Fsystem%2Fsecurity%2FChangePassword%3FfromFrontdoor%3D1%26retURL%3D%252Fhome%252Fhome.jsp%26setupid%3DChangePassword&setupid=ChangePassword&fromFrontdoor=1&currentpassword=Password&newpassword=password&confirmpassword=password' );
            System.debug(LoggingLevel.ERROR, '@@@ password change try 2 r.getBody(): ' + r.getBody());
             
            
        }
        return r;
    }
    
    /**
     * Browse using simple POST request for given endpoint.
     * If complete  URL is not specified, tries to use the last used domain or currect Salesforce domain to supplement.
     * @param String endpoint: target endpoint to browse ( complete or relative URL)
     * @param String params: post data parameters to transfer
     * @return : HttpResponse for last redirection callout
     */
    public static HttpResponse browse(String endPoint, String params) {
        endPoint = endPoint.contains('://') ? endPoint : getBaseURL() + endPoint;
        currentEndpoint = endPoint;
        history += 'Post: Browse started from ' + currentEndpoint + '<br/><br/>';
        history += 'Post: params:' + params + '<br/><br/>';
        System.debug(LoggingLevel.ERROR, '@@@ endPoint: ' + endPoint );
        System.debug(LoggingLevel.ERROR, '@@@ params: ' + params );
        HttpResponse r = makeHTTPPostCall( endPoint, params );
        String location = r.getHeader('Location');
        cookies.add( r.getHeader('Set-Cookie') );
        System.debug(LoggingLevel.ERROR, '@@@ cookies: ' + cookies );
        
        subject = 'Browser browse ' + endpoint + '?' + params + ' Status: ' + r.getStatusCode();
        
        attachmentFileName = 'Browse_' + DateTime.now() + '.html';
        attachmentContent = Blob.valueOf('start' + r.getBody());
        
        
        if ( location != null && location != '' ) {
            history += 'Redirected to ' + location + '<br/><br/>';
            emailBody += subject + ' Redirecting to : ' + location + ' <br/><br/>';
            return browse( location );
        }
        String s = r.getBody();
        System.debug(LoggingLevel.ERROR, '@@@ body ' + s);
        s = getJSRedirect( r.getBody() );
        if ( s != null && s != '' ) {
            history += 'Redirected by JS to ' + s + '<br/><br/>';
            emailBody += subject + ' Redirecting to (js): ' + s + ' <br/><br/>';
            return browse( s );
        }
        s = r.getBody().substringBetween('<div class="errorMsg"><strong>Error:</strong>','</div>');
        if ( String.isNotBlank(s)) {
            history += 'error ' + s + '<br/><br/>';
        }
        System.debug(LoggingLevel.ERROR, '@@@ error: ' + s );
        
        emailBody = subject + ' Errors? ' + s + '<br/><br/>';
        return r;
    }
    
    /**
     * @return : String joined of cookies
     */
    public static String getCookies() {
        return String.join(cookies, ';');
    }
    
    /**
     * @param String email: email to send cookies, history and other data to
     */
    public static void sendEmail( String email ) {
        Utils.sendEmail(new List<String>{email}, subject, 'cookies:c<br/><br/>' + getCookies() + ' <br/><br/>history:<br/><br/>' + history + ' <br/><br/>end of history <br/><br/>', '', null);
    }
    
    /**
     * low-level method for get request implementation
     */
    private static HttpResponse makeHTTPGetCall(String endPoint){
        Http hLLogin = new Http();
        HttpRequest reqLLogin = new HttpRequest();
        reqLLogin.setHeader('Cookie',String.join(cookies, ';'));
        reqLLogin.setTimeout(60000);
        reqLLogin.setEndpoint(endPoint);  
        reqLLogin.setMethod('GET');
        System.debug(LoggingLevel.ERROR, '@@@ makeHTTPGetCall @@@ callout: ' + endPoint );
        HttpResponse r = hLLogin.send(reqLLogin);
        
        System.debug(LoggingLevel.ERROR, '@@@ r.getHeaderKeys(): ' + r.getHeaderKeys() );
        System.debug(LoggingLevel.ERROR, '@@@ r.setCookie(): ' + r.getHeader('Set-Cookie') );
        return r; 
   
    }
    
    /**
     * low-level method for post request implementation
     */
    private static HttpResponse makeHTTPPostCall(String endPoint, String body){
        Http hLLogin = new Http();
        HttpRequest reqLLogin = new HttpRequest();
        reqLLogin.setTimeout(60000);
        reqLLogin.setEndpoint(endPoint);  
        reqLLogin.setMethod('POST');    
        System.debug(LoggingLevel.ERROR, '@@@ makeHTTPPostCall @@@ callout: ' + endPoint );
        reqLLogin.setHeader('Cookie',String.join(cookies, ';'));
        reqLLogin.setBody(body);    
        return  hLLogin.send(reqLLogin);
    }

    /**
     * High-level method to perform post using given credentials and given relative URL and data (first it makes get then post)
     */
    public static void post(String login, String password, String uri, String data) {
        String startURL = uri.replace('&', '%26');
        HttpResponse r = Browser.browse('https://test.salesforce.com/', 'un=' + login + '&pw=' + password + '&startURL=' + startURL );
        String s = r.getBody();
        String token = s.substringBetween('<input type="hidden" name="_CONFIRMATIONTOKEN" id="_CONFIRMATIONTOKEN" value="', '" />');
        System.debug(LoggingLevel.ERROR, '@@@ token: ' + token);
 
        r = Browser.browse(getBaseURL() + uri, '_CONFIRMATIONTOKEN=' + token  + '&' + data );
        s = r.getBody();
        System.debug(LoggingLevel.ERROR, '@@@ body ' + s);   
        System.debug(LoggingLevel.ERROR, '@@@ r ' + r);   
    }

}