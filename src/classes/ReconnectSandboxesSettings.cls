/**
 * Simple example stub for Reconnect Sandbox project settings
 *
 * @author: Patlatus
 * @source: https://github.com/Patlatus/sfdc_reconnect_sandboxes/blob/master/src/classes/ReconnectSandboxesSettings.cls
 */
public class ReconnectSandboxesSettings {
    public static String login = 'login@to.thefirst.sandbox';
    public static String password = 'password';
    public static String email = 'my@email.com';
    public static String connectionId = '';
    public static String connId = '';
    public static Contact c;
    
    public static String un = 'login@to.thesecond.sandbox';
    public static String pw = 'Password';
    
    public static Map<String, List<String>> firstSandboxPublishMap = new Map<String, List<String>>{
        'Account' => new String[]{'Phone', 'Owner', 'BillingCity', 'BillingCountry'},
        '01IE0000000---X' => new String[]{'00NE000000----1', '00NE000000----2', '00NE000000----3'},
        'Contact' => new String[]{'Owner', '00NE00000----4', 'HomePhone', 'Phone'}
    };
        
    public static Map<String, ReconnectSandboxes.SubscribeModel> secondSandboxSubscribeMap = new Map<String, ReconnectSandboxes.SubscribeModel>{
        'Account' => new ReconnectSandboxes.SubscribeModel('Account', true, new Map<String, String>{'Phone' => 'Phone', 'BillingCity' => '00NC000000----5', 'BillingCountry' => 'BillingCountry'}),
        'Contact' => new ReconnectSandboxes.SubscribeModel('Contact', true, new Map<String, String>{'Phone' => 'Phone', 'HomePhone' => 'HomePhone', 'OwnerId' => '', '00NE00000----4' => ''}),
        'Custom_Object__c' => new ReconnectSandboxes.SubscribeModel('01IC0000000---Y', true, new Map<String, String>{'Custom_Field1__c' => '00NC000000----1', 'Custom_Field2__c' => '00NC000000----2', 'Custom_Field3__c' => '00NC000000----3'})
    };
        
    public static Map<String, List<String>> secondSandboxPublishMap = new Map<String, List<String>>{
        'Account' => new String[]{'00NC000000----1', '00NC000000----2'},
        'Attachment' => new String[]{'Description'},
        '01IC0000000---1' => new String[]{'00NC000000----3', '00NC000000----4', '00NC000000----5'},
        'Contact' => new String[]{'Email', 'Account', '00NC000000----6'},
        '01IC0000000---2' => new String[]{'00NC000000----7', 'Owner'}
    };
        
    public static Map<String, ReconnectSandboxes.SubscribeModel> firstSandboxSubscribeMap = new Map<String, ReconnectSandboxes.SubscribeModel>{
        'Account' => new ReconnectSandboxes.SubscribeModel('Account', true, new Map<String, String>{'Custom_Field1__c' => '00NE000000___A', 'Custom_Field2__c' => '00NE000000___B'}),
        'Attachment' => new ReconnectSandboxes.SubscribeModel('Attachment', true, new Map<String, String>{'Description' => ''}),
        'Custom_Object_1__c' => new ReconnectSandboxes.SubscribeModel('01IE0000000___X', true, new Map<String, String>{'Custom_Field3__c' => '', 'Custom_Field4__c' => '00NE000000___C', 'Custom_Field5__c' => '00NE000000___D'}),
        'Contact' => new ReconnectSandboxes.SubscribeModel('Contact', true, new Map<String, String>{'AccountId' => '', 'Custom_Field6__c' => '00NE000000___E', 'Email' => 'Email'}),
        'package__CustomObject__c' => new ReconnectSandboxes.SubscribeModel('01IE0000000___Y', true, new Map<String, String>{'package__CustomField__c' => '', 'OwnerId' => ''})
    };
    
   

    // First Sandbox Stuff Start
    // 
    public static Contact updateContact() {
        c = ReconnectSandboxes.updateContact( email, false, '003E00000ContId' );
        return c;
    }
    
    public static String sendInvite() {
        connectionId = ReconnectSandboxes.sendInvite( login, password, new Contact(Id='003E00000ContIdAAA'), true );
        return connectionId;
    }
    
    public static void publishTheFirstSandbox() {
        ReconnectSandboxes.publish( login, password, connectionId, new List<String>( firstSandboxPublishMap.keySet() ), email, true );
    }
    
    public static void publishTheFirstSandboxFields() {
        ReconnectSandboxes.publishFields( login, password, connectionId, firstSandboxPublishMap, email, true );
    }
    
    // Second Sandbox Stuff 
    // 
    public static void subscribeTheSecondSandbox() {
        ReconnectSandboxes.subscribe( un, pw, connId, secondSandboxSubscribeMap, email, true);
    }
    
    public static void publishTheSecondSandbox() {
        ReconnectSandboxes.publish( un, pw, connId, new List<String>( secondSandboxPublishMap.keySet() ), email, true );
    }
    
    public static void publishTheSecondSandboxFields() {
        ReconnectSandboxes.publishFields( un, pw, connId, secondSandboxPublishMap, email, true );
    }
    
    public static void subscribeTheSecondSandboxFields() {
        ReconnectSandboxes.subscribeFields(un, pw, connId, secondSandboxSubscribeMap, email, true);
    }
    
    
    // First Sandbox Stuff Finish
    //
    public static void subscribeTheFirstSandbox() {
        ReconnectSandboxes.subscribe( login, password, connectionId, firstSandboxSubscribeMap, email, true);
    }

    public static void subscribeTheFirstSandboxFields() {
        ReconnectSandboxes.subscribeFields( login, password, connectionId, firstSandboxSubscribeMap, email, true);
    }

}