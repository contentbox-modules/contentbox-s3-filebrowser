/**
* ---
* This simulates the onRequest start for the admin interface
*/
component extends="coldbox.system.Interceptor"{
	/**
	* Intercepts preEvent to ensure the s3filebrowser is displayed
	*/
	function preEvent( event, rc, prc, action, eventArguments ){
		scopeS3FileBrowser( event );
	}

	/**
	* Intercepts the FileBrowser Variables before the layout/view is rendered
	*/
	function preLayout( event, interceptData ){
		scopeS3FileBrowser( event );
	}

	function scopeS3FileBrowser( event ){
		var prc = event.getCollection( private=true );
		if( !settingExists( "s3sdk" ) ) {
			return;
		}
		var s3Settings = getSetting( "s3sdk" );
		if( 
			structKeyExists( s3Settings, "filebrowser" ) 
			&& 
			structKeyExists( s3Settings.filebrowser, "enabled" ) 
			&& 
			s3Settings.filebrowser.enabled
		){
			prc.xehFileBrowser = "contentbox-s3-filebrowser:home.index";
			prc.cbCKfileBrowserDefaultEvent = prc.xehFileBrowser;
		}
	}

}