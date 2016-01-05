/**
 * Main method containing methods to reconnect sandboxes
 *
 * @author: Patlatus
 * @source: https://github.com/Patlatus/sfdc_reconnect_sandboxes/blob/master/src/classes/ReconnectSandboxes.cls
 */
public class ReconnectSandboxes {
    
    public static Contact updateContact(String email, Boolean random, String cId) {
        Contact c;
        if ( random ) {
            c = [ SELECT Id, Email FROM Contact LIMIT 1 ];
        } else {
            c = [ SELECT Id, Email FROM Contact WHERE Id =: cId ];
        }
        c.Email = email;
        update c;
        return c;
    }
    
    public static String sendInvite(String login, String password, Contact c, Boolean doSendEmail) {
        Browser.post( login, password, '/_ui/s2s/ui/InvitePartner/e', 'cancelURL=%2F0BM&retURL=%2F0BM&save_new_url=%2F_ui%2Fs2s%2Fui%2FInvitePartner%2Fe%3FretURL%3D%252F0BM&Contact_lkid=' + c.Id + '&Contact_lkold=x&Contact_lktp=003&Contact_lspf=0&Contact_lspfsub=0&Contact_mod=1&Contact=x&cas4_lkid=000000000000000&cas4_lkold=&cas4_lktp=001&cas4_lspf=0&cas4_lspfsub=0&cas4_mod=0&cas4=&PrimaryContact_lkid=005E0000003O5fv&PrimaryContact_lkold=Bohdan+Dovhan&PrimaryContact_lktp=StandardUserLookup&PrimaryContact_lspf=0&PrimaryContact_lspfsub=0&PrimaryContact_mod=0&PrimaryContact=Bohdan+Dovhan&PartnerNetworkTemplate_lkid=000000000000000&PartnerNetworkTemplate_lkold=&PartnerNetworkTemplate_lktp=0BM&PartnerNetworkTemplate_lspf=0&PartnerNetworkTemplate_lspfsub=0&PartnerNetworkTemplate_mod=0&PartnerNetworkTemplate=&save=Save+%26+Send+Invite' );
        if (doSendEmail)
            Browser.sendEmail(c.Email);
        String connectionId = Browser.currentEndpoint.contains('=') ? Browser.currentEndpoint.split('=')[1] : null;
        return connectionId;
    } 
    
    public static void publish(String login, String password, Id connectionId, List<String> objects, String email, Boolean doSendEmail) {
        String data = '&save=+Save+&' + String.join(objects, '=1&') + '=1&cancelURL=%2F_ui%2Fs2s%2Fui%2FResponse%2Fd%3Fid%3D' + connectionId + '%26retURL%3D%252F0BM&id=' + connectionId + '&retURL=%2F_ui%2Fs2s%2Fui%2FResponse%2Fd%3Fid%3D' + connectionId + '%26retURL%3D%252F0BM&save_new_url=%2F_ui%2Fs2s%2Fui%2FPublishObjectsUi%2Fe%3FeditPage%3D1%26retURL%3D%252F_ui%252Fs2s%252Fui%252FResponse%252Fd%253Fid%253D' + connectionId + '%2526retURL%253D%25252F0BM';
        Browser.post( login, password, '/_ui/s2s/ui/PublishObjectsUi/e?id=' + connectionId, data );
        if (doSendEmail)
            Browser.sendEmail(email);
    } 
    
    public static void publishFields(
        String login, String password, Id connectionId,
        Map<String, List<String>> objectToFieldsMap, String email, Boolean doSendEmail
    ) {
        for (String objectName: objectToFieldsMap.keySet() ) {
            List<String> fields = objectToFieldsMap.get( objectName );
            
            Browser.post(
                login,
                password,
                '/_ui/s2s/ui/PublishFieldsUi/e?id=' + connectionId + '&type=' + objectName,
                'cancelURL=%2F_ui%2Fs2s%2Fui%2FResponse%2Fd%3Fid%3D' + connectionId + '%26retURL%3D%252F0BM&id=' + connectionId + '&retURL=%2F_ui%2Fs2s%2Fui%2FResponse%2Fd%3Fid%3D' + connectionId + '%26retURL%3D%252F0BM&save_new_url=%2F_ui%2Fs2s%2Fui%2FPublishFieldsUi%2Fe%3FeditPage%3D1%26retURL%3D%252F_ui%252Fs2s%252Fui%252FResponse%252Fd%253Fid%253D' + connectionId + '%2526retURL%253D%25252F0BM%26type%3D' + objectName + '&type=' + objectName + '&save=+Save+&' + String.join(fields, '=1&') + '=1'
            );  
        }
            
        if (doSendEmail) Browser.sendEmail( email );  
    } 
    
    public static void subscribe(String login, String password, Id connectionId, Map<String, SubscribeModel> subscribeMap, String email, Boolean doSendEmail) {
        List<String> params = new List<String>();
        for ( String key: subscribeMap.keySet() ) {
            SubscribeModel model = subscribeMap.get( key );
            params.add( key + '=' + model.name + '&' + key + '_auto_accept_key_' + model.name + '=' + ( model.autoAccept ? '1' : '0' ) );
        }

        Browser.post(
            login,
            password,
            '/_ui/s2s/ui/SubscribeObjectsUi/e?id=' + connectionId,
            'cancelURL=%2F_ui%2Fs2s%2Fui%2FResponse%2Fd%3Fid%3D' + connectionId + '%26retURL%3D%252F0BM&id=' + connectionId + '&retURL=%2F_ui%2Fs2s%2Fui%2FResponse%2Fd%3Fid%3D' + connectionId + '%26retURL%3D%252F0BM&save_new_url=%2F_ui%2Fs2s%2Fui%2FSubscribeObjectsUi%2Fe%3FeditPage%3D1%26retURL%3D%252F_ui%252Fs2s%252Fui%252FResponse%252Fd%253Fid%253D' + connectionId + '%2526retURL%253D%25252F0BM&save=+Save+&' + String.join(params, '&')
        );
        if (doSendEmail) Browser.sendEmail(email);
    } 
    
    public static void subscribeFields(String login, String password, Id connectionId, Map<String, SubscribeModel> subscribeMap, String email, Boolean doSendEmail) {
        for ( SubscribeModel model: subscribeMap.values() ) {
            List<String> params = new List<String>();
            for ( String key: model.fieldsMap.keySet() ) {
                String value = model.fieldsMap.get( key );
                params.add( key + '=' + value );
            }
            Browser.post(
                login,
                password,
                '/_ui/s2s/ui/SubscribeFieldsUi/e?id=' + connectionId + '&type=' + model.name,
                'cancelURL=%2F_ui%2Fs2s%2Fui%2FResponse%2Fd%3Fid%3D' + connectionId + '%26retURL%3D%252F0BM&id=' + connectionId + '&retURL=%2F_ui%2Fs2s%2Fui%2FResponse%2Fd%3Fid%3D' + connectionId + '%26retURL%3D%252F0BM&save_new_url=%2F_ui%2Fs2s%2Fui%2FSubscribeFieldsUi%2Fe%3FeditPage%3D1%26retURL%3D%252F_ui%252Fs2s%252Fui%252FResponse%252Fd%253Fid%253D' + connectionId + '%2526retURL%253D%25252F0BM%26type%3D' + model.name + '&type=' + model.name + '&save=+Save+&' + String.join(params, '&')
            ); 
        }
        if (doSendEmail) Browser.sendEmail(email);
    } 
    
    public class SubscribeModel{
        public String name;
        public Boolean autoAccept;
        public Map<String, String> fieldsMap;
        public SubscribeModel( String n, Boolean a, Map<String, String> fm ) {
            name = n;
            autoAccept = a;
            fieldsMap = fm;
        }
    }
}