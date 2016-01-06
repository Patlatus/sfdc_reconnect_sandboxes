# sfdc_reconnect_sandboxes
Code for reconnecting sandboxes through s2s connection 

This project is basically designed for Salesforce only.
To solve one problem of automatization of reconnection of full sandboxes after their refresh.

This project contains four classes:
 * Utils = basic utility class for sending emails 
 * Browser = basic browser implementation used in following classes
 * ReconnectSandboxes = basic class containing main functionality
 * ReconnectSandboxesSettings = class containing org-specific settings, may be avoided

Hereafter by 'the first sandbox' meant sandbox from which invitation to S2S connection is sent, and by 'the second sandbox' meant sandbox where invitation to S2S connection is received and accepted.

====================================

Usage instruction.

How to reconnect sandboxes after refresh.

0 . Before you start. 
 
 You may specify your credentials in your copy of ReconnectSandboxesSettings class
 
 Just update the following lines with your settings in your copy of this class.
 
        public static String login = <your login to the first sandbox>;
        public static String password = <your password to the first sandbox>;
        public static String email = <your email>;
        public static String un = <your login to the second sandbox>;
        public static String pw = <your password to the second sandbox>; 
    
 You may also edit your publish and subscribe maps in the following lines
 
        public static Map<String, List<String>> firstSandboxPublishMap = new Map<String, List<String>>{
        //<object name for standard object or object id for custom object> => new List<String>{
        //list of fields: fields names for standard fields or field ids for custom ones like following:
        'Account' => new String[]{'Phone', 'Owner', 'BillingCity', 'BillingCountry'},
        '01IE0000000---X' => new String[]{'00NE000000----1', '00NE000000----2', '00NE000000----3'},
        'Contact' => new String[]{'Owner', '00NE00000----4', 'HomePhone', 'Phone'}
        };
        
        public static Map<String, ReconnectSandboxes.SubscribeModel> secondSandboxSubscribeMap = new Map<String, ReconnectSandboxes.SubscribeModel>{
        //<object name for standard or custom objects in your published org sandbox> =>  new ReconnectSandboxes.SubscribeModel(
        //String:  <object name for standard object or object id for custom object in your subscribed org sandbox>
        //Boolean: <autoaccept checkbox value>
        //map of fields: <field name for standard or custom fields in your published org sandbox>  =>
        //<fields names for standard fields or field ids for custom ones in your subscribed org sandbox> like following:
        
        'Account' => new ReconnectSandboxes.SubscribeModel('Account', true, new Map<String, String>{'Phone' => 'Phone', 'BillingCity' => '00NC000000----5', 'BillingCountry' => 'BillingCountry'}),
        'Contact' => new ReconnectSandboxes.SubscribeModel('Contact', true, new Map<String, String>{'Phone' => 'Phone', 'HomePhone' => 'HomePhone', 'OwnerId' => '', '00NE00000----4' => ''}),
        'Custom_Object__c' => new ReconnectSandboxes.SubscribeModel('01IC0000000---Y', true, new Map<String, String>{'Custom_Field1__c' => '00NC000000----1', 'Custom_Field2__c' => '00NC000000----2', 'Custom_Field3__c' => '00NC000000----3'})
        };
        
The same rules apply to the secondSandboxPublishMap and firstSandboxSubscribeMap


1 . Step first. Update contact.
 
First of all, you need some contact to send invitation
You may select some or random to update its email to yours

        Contact c = ReconnectSandboxesSettings.updateContact();
        System.debug(LoggingLevel.ERROR, '@@@ c: ' + c ); 
        System.debug(LoggingLevel.ERROR, '@@@ c.Id: ' + c.Id ); 
    
Remember its id since it will be needed later

2 . Step second. Send invitation.

Before proceeding, make sure the following URLS are present at 
Remote sites test.salesforce.com/0rp

https://test.salesforce.com/

https://[custom--domain].[instance].my.salesforce.com/

https://[instance].salesforce.com/

https://[custom--domain--c].[instance].content.force.com/

And access to send email is set to All Email here

test.salesforce.com/email-admin/editOrgEmailSettings.apexp

If you need to update your password, do it before running this

I was trying to run the code to automatically update password but it doesn't work

You may also want to change company name temporarily at your company profile settings if you want the target connection to have specific name.

You have to send invitation to given selected contact.

Copy and paste contact id into parameter and remember connection Id

        ReconnectSandboxesSettings.connectionId = ReconnectSandboxesSettings.sendInvite(<pasted contact id>);
        System.debug(LoggingLevel.ERROR, '@@@ connectionId: ' + ReconnectSandboxesSettings.connectionId ); 

3 . Step third. Publish objects and fields from the first sandbox
  
  Copy and paste connection id here and run following line one by one
  
        ReconnectSandboxesSettings.connectionId = '04P<your connection id pasted here>';

        uncomment the following lines one per a run from anonymous execution window
        //ReconnectSandboxesSettings.publishTheFirstSandbox();
        //ReconnectSandboxesSettings.publishTheFirstSandboxFields();
        // Then go to your second sandbox and subscribe and publish there
        
4 . Step fourth. Publish and subscribe your second sandbox

Before proceeding, make sure the following URLS are present at 
Remote sites 

test.salesforce.com/0rp

https://test.salesforce.com/

https://[custom--domain].[instance].my.salesforce.com/

https://[instance].salesforce.com/

https://[custom--domain--c].[instance].content.force.com/

[custom-domain] and [instance] refer to your second sandbox here while in step 0 they refer to your first sandbox.

And access to send email is set to All Email here

test.salesforce.com/email-admin/editOrgEmailSettings.apexp

You may execute code to subscribe your second sandbox from your first sandbox or from your second sandbox.

I have faced some errors on sandbox on cs7 instance like  Verify your identity in Salesforce
and I couldn't  find ip in list of login history, so then I just decided to run this from sandbox on another instance where everything is ok having whitelisted public Salesforce IP list in  network access tab

test.salesforce.com/05G

On the second sandbox you need accept invitation first (from the email you should have received after 2. Step second.
If you didn't receive the email then check your spam folder or check if email administration is set to all emails.

After you have found the email, clicked the link and accepted invitation, you may run this code, each action has to be executed separately, so you can uncomment following lines one by one in your anonymous execution window

        ReconnectSandboxesSettings.connId = '04P<insert here your connection id on the second sandbox>';
        //ReconnectSandboxesSettings.subscribeTheSecondSandbox();
        //ReconnectSandboxesSettings.publishTheSecondSandbox();
        //ReconnectSandboxesSettings.publishTheSecondSandboxFields();
        //ReconnectSandboxesSettings.subscribeTheSecondSandboxFields();
        
if you have many objects\fields you may need to separate your subscribe map into pieces and run subscribe fields method several times with different objects\fields

        //ReconnectSandboxesSettings.subscribeTheSecondSandboxFields1();
        
5 . Step fifth. Subscribe your first sandbox

After you completed fourth step you can now subscribe your first sandbox

        //ReconnectSandboxesSettings.subscribeTheFirstSandbox();
        //ReconnectSandboxesSettings.subscribeTheFirstSandboxFields();

If you have too many fields or object you may split your map into several calls like

        //ReconnectSandboxesSettings.subscribeTheFirstSandboxFields1();
        //ReconnectSandboxesSettings.subscribeTheFirstSandboxFields2();
