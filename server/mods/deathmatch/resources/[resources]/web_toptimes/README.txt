Add the 'web_toptimes' resource to the Admin group in acl.xml if it doesn't work at first.

If you're greeted by a login prompt each time you try to open the resource from the web go to your acl.xml file and under the
Default user group add this line: <right name="general.http" access="true"></right>

If you want to show player country go through all files and uncomment everything related to countries in order to show them as well.
