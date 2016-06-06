<?php
$postData = $_POST;
if($postData['email']) {
$to = "info@hobnobspace.com";
$subject = "Demo Request By ".$postData['name'];
$body = '<table cellpadding="0" cellspacing="0" border="0px" style="width:100%; text-align:center; font-family:Arial, Helvetica, sans-serif; line-height:20px; font-size:14px; background:#FFFFFF;">
        	<tr>
        	  <td colspan="2" align="left" valign="middle" style="font-weight:bold; font-size:18px; padding:10px;">Demo Request Details</td>
  </tr>
        
        <tr style="background:#eeeeef;">
          <td width="26%" align="left" style="padding:10px;">Name</td>
        	<td width="74%" align="left" style="padding:10px;">'.$postData['name'].'</td>
        </tr>
        <tr style="background:#eeeeef;">
          <td align="left" style="padding:10px;">Email</td>
          <td align="left" style="padding:10px;">'.$postData['email'].'</td>
        </tr>
        <tr style="background:#eeeeef;">
          <td align="left" style="padding:10px;">Phone</td>
          <td align="left" style="padding:10px;">'.$postData['phone'].'</td>
        </tr>
        <tr style="background:#eeeeef;">
          <td align="left" style="padding:10px;">Company</td>
          <td align="left" style="padding:10px;">'.$postData['organization'].'</td>
        </tr>
        <tr style="background:#eeeeef;">
          <td colspan="2" align="left" valign="middle" style="padding:10px;"><p>Regards,</p>
          <p>Webmaster</p></td>
          </tr>
        </table>';
$headers = "MIME-Version: 1.0" . "\r\n";
$headers .= "Content-type:text/html;charset=UTF-8" . "\r\n";
$headers .= 'From: <webmaster@hobnobspace.com>' . "\r\n";
$headers .= 'Cc: amit.pashte@shobizexperience.com' . "\r\n";
if(mail($to,$subject,$body,$headers))
{
  echo 'success';
}
else
{
  echo 'fail';
}
}
?>
