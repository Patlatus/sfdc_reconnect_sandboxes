/**
 * Utility class for Reconnect Sandbox project settings
 *
 * @author: Patlatus
 * @source: https://github.com/Patlatus/sfdc_reconnect_sandboxes/blob/master/src/classes/Utils.cls
 */
public class Utils{
    /**
     *  Method to send email
     *  If attachmentFileName or attachmentContent is empty or null it will not send an attachment
     */
    public static void sendEmail( List<String> recipients, String subject, String body, String attachmentFileName, Blob attachmentContent ) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses( recipients );
        mail.setSubject( subject );
        mail.setHtmlBody( body );
        if( String.isNotBlank( attachmentFileName ) && attachmentContent != null ){
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName( attachmentFileName );
            attachment.setBody( attachmentContent );
            mail.setFileAttachments( new Messaging.EmailFileAttachment[]{ attachment } );
        }
        Messaging.sendEmail( new Messaging.SingleEmailMessage[] { mail } );
    }
}