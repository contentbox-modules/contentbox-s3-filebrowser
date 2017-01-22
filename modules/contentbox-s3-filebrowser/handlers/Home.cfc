/**
* ContentBox - A Modular Content Platform
* Copyright since 2012 by Ortus Solutions, Corp
* www.ortussolutions.com/products/contentbox
* ---
* This is the main controller of events for the filebrowser
*/
component hint="S3 filebrowser module handler"{

	// DI
	property name="fileUtils"		inject="FileUtils@cb";
	property name="cookieStorage"	inject="cookieStorage@cbStorages";
	property name="S3Settings"		inject="coldbox:setting:s3sdk";
	property name="S3Provider"		inject="CFMLFacade@s3sdk";

	/**
	* Pre handler
	*/
	function preHandler( event, currentAction, rc, prc ){
		//run our standard filebrowser pre-handler
		runEvent( "contentbox-filebrowser:home.preHandler" );

		S3Provider.init( s3Settings.uploads.bucket );
		prc.s3ModEntryPoint = "contentbox-s3-filebrowser/home";
		prc.s3fbModuleName = "contentbox-s3-filebrowser";
		prc.s3fbModRoot = getModuleConfig( prc.s3fbModuleName ).mapping;
		prc.s3BaseURL = getSetting( "s3sdk" ).uploads.url;
		if( left( prc.s3BaseURL, 4 ) != 'http' ){
			prc.s3BaseURL = ( CGI.SERVER_PORT_SECURE ? "https:" : "http:" ) & prc.s3BaseURL;
		}
	}

	/**
	* @widget Determines if this will run as a viewlet or normal MVC
	* @settings A structure of settings for the filebrowser to be overriden with in the viewlet most likely.
	*/
	function index(
		event,
		rc,
		prc ,
		boolean widget=false,
		struct settings={}
	){
		//pass through to the core filebrowser if not dealing with content
		if( event.getValue( "library", "Content" ) != "Content" ){
			prc.xehFileBrowser = "contentbox-filebrowser:home.index";
			writeOutput( runEvent(event=prc.xehFileBrowser,eventArguments=prc.fbArgs) );
		} else {
			return s3Index( argumentCollection=arguments );
		}
	}


	/**
	* @widget Determines if this will run as a viewlet or normal MVC
	* @settings A structure of settings for the filebrowser to be overriden with in the viewlet most likely.
	*/
	function s3Index(
		event,
		rc,
		prc ,
		boolean widget=false,
		struct settings={}
	){

		// params
		event.paramValue( "path","" );
		event.paramValue( "callback","" );
		event.paramValue( "cancelCallback","" );
		event.paramValue( "filterType","" );

		// exit handlers
		prc.xehFBBrowser 	= "#prc.s3ModEntryPoint#/";
		prc.xehFBNewFolder 	= "#prc.s3ModEntryPoint#/createfolder";
		prc.xehFBRemove 	= "#prc.s3ModEntryPoint#/remove";
		prc.xehFBDownload	= "#prc.s3ModEntryPoint#/download";
		prc.xehFBUpload		= "#prc.s3ModEntryPoint#/upload";
		prc.xehFBRename		= "#prc.s3ModEntryPoint#/rename";

		// Detect Widget Mode.
		if(arguments.widget) {
			// merge the settings structs if defined
			if( !structIsEmpty( arguments.settings ) ){
				mergeSettings( prc.fbSettings, arguments.settings );
				// clean out the stored settings for this version as we will use passed in settings.
				flash.remove( "filebrowser" );
			}
		}

		// Detect sorting changes
		detectPreferences( event, rc, prc );

		// load Assets for filebrowser
		loadAssets( event, rc, prc );

		// Inflate flash params
		inflateFlashParams( event, rc, prc );

		// Store directory roots and web root
		prc.fbDirRoot 		= prc.fbSettings.directoryRoot;
		prc.fbWebRootPath 	= expandPath( "./" );

		// clean incoming path and decode it.
		rc.path = cleanIncomingPath( URLDecode( trim( rc.path ) ) );
		// Check if the incoming path does not exist so we default to the configuration directory root.
		if( !len(rc.path) ){
			prc.fbCurrentRoot = s3Settings.uploads.prefix;
		}
		else{
			prc.fbCurrentRoot = rc.path;
		}
		// Web root cleanups
		prc.fbwebRootPath = cleanIncomingPath(prc.fbwebRootPath);
		// Do a safe current root for JS
		prc.fbSafeCurrentRoot = URLEncodedFormat( prc.fbCurrentRoot );

		// Get storage preferences
		prc.fbPreferences = getPreferences();
		prc.fbNameFilter  = prc.fbSettings.nameFilter;
		if ( rc.filterType == "Image" ) { prc.fbNameFilter = prc.fbSettings.imgNameFilter; }
		if ( rc.filterType == "Flash" ) { prc.fbNameFilter = prc.fbSettings.flashNameFilter; }

		
		// get directory listing.
		prc.fbqListing = S3Provider.directoryList( prc.fbCurrentRoot, prc.fbSettings.extensionFilter, "#prc.fbPreferences.sorting#" );


		var iData = {
			directory = prc.fbCurrentRoot,
			listing = prc.fbqListing
		};

		announceInterception( "fb_postDirectoryRead",iData);

		// set view or render widget?
		if( arguments.widget ){
			return renderView(view="home/index",module=prc.s3fbModuleName);
		}
		else{
			event.setView(view="home/index",noLayout=event.isAjax());
		}
	}


	/**
	* Creates folders asynchrounsly return json information:
	*/
	function createfolder( event, rc, prc ){
		var data = {
			errors = false,
			messages = ""
		};

		// param value
		event.paramValue( "path", "" );
		event.paramValue( "dName", "" );

		// Verify credentials else return invalid
		if( !prc.fbSettings.createFolders ){
			data.errors = true;
			data.messages = $r( "messages.create_folder_disabled@fb" );
			event.renderData( data=data, type="json" );
			return;
		}

		// clean incoming path and names
		rc.path = cleanIncomingPath( URLDecode( trim( rc.path ) ) );
		rc.dName = URLDecode( trim( rc.dName ) );
		if( !len( rc.path ) OR !len( rc.dName ) ){
			data.errors = true;
			data.messages = $r( "messages.invalid_path_name@fb" );
			event.renderData( data=data, type="json" );
			return;
		}

		// creation
		try{
			// Announce it
			var iData = {
				path = rc.path,
				directoryName = rc.dName
			};
			announceInterception( "fb_preFolderCreation", iData );

			s3Provider.directoryCreate( rc.path & "/" & rc.dName );
			data.errors = false;
			data.messages = $r( resource="messages.folder_created@fb", values="#rc.path#/#rc.dName#" );

			// Announce it
			announceInterception( "fb_postFolderCreation", iData );
		} catch( Any e ){
			data.errors = true;
			data.messages = $r( resource="messages.error_creating_folder@fb", values="#e.message# #e.detail#" );
			log.error( data.messages, e );
		}
		// render stuff out
		event.renderData( data=data, type="json" );
	}

	/**
	* Removes folders + files asynchrounsly return json information:
	*/
	function remove( event, rc, prc ){
		var data = {
			errors = false,
			messages = ""
		};
		// param value
		event.paramValue( "path", "" );

		// Verify credentials else return invalid
		if( !prc.fbSettings.deleteStuff ){
			data.errors = true;
			data.messages = $r( "messages.delete_disabled@fb" );
			event.renderData( data=data, type="json" );
			return;
		}

		// clean incoming path and names
		rc.path = cleanIncomingPath( URLDecode( trim( rc.path ) ) );
		if( !len( rc.path ) ){
			data.errors = true;
			data.messages = $r( "messages.invalid_path@fb" );
			event.renderData( data=data, type="json" );
			return;
		}

		// removal
		//try{
			// Announce it
			var iData = {
				path = rc.path
			};

			//announceInterception( "fb_preFileRemoval", iData );

			if( S3Provider.fileExists( rc.path ) ){

				s3Provider.fileDelete( rc.path );

			}

			else if( S3Provider.directoryExists( rc.path ) ){

				S3Provider.directoryDelete( path=rc.path, recurse=true );
			
			}

			data.errors = false;
			data.messages = $r( resource="messages.removed@fb", values="#rc.path#" );

			// Announce it
			announceInterception( "fb_postFileRemoval", iData );
		// } catch( Any e ) {
		// 	data.errors = true;
		// 	data.messages = $r( resource="messages.error_removing@fb", values="#e.message# #e.detail#" );
		// 	log.error( data.messages, e );
		// }
		// render stuff out
		event.renderData( data=data, type="json" );
	}

	/**
	* download file
	*/
	function download( event, rc, prc ){
		var data = {
			errors = false,
			messages = ""
		};
		// param value
		event.paramValue( "path","" );

		// Verify credentials else return invalid
		if( !prc.fbSettings.allowDownload ){
			data.errors = true;
			data.messages = $r( "messages.download_disabled@fb" );
			event.renderData( data=data, type="json" );
			return;
		}

		// clean incoming path and names
		rc.path = cleanIncomingPath( URLDecode( trim( rc.path ) ) );
		if( !len( rc.path ) ){
			data.errors = true;
			data.messages = $r( "messages.invalid_path@fb" );
			event.renderData( data=data, type="json" );
			return;
		}

		// download
		try{
			// Announce it
			var iData = {
				path = rc.path
			};
			announceInterception( "fb_preFileDownload", iData );

			fileUtils.sendFile( file=prc.s3BaseURL & "/" & rc.path );
			data.errors = false;
			data.messages = $r( resource="messages.downloaded@fb", values='#rc.path#' );

			// Announce it
			announceInterception( "fb_postFileDownload", iData );
		}
		catch(Any e){
			data.errors = true;
			data.messages = $r( resource="messages.error_downloading@fb", values="#e.message# #e.detail#" );
			log.error( data.messages, e );
		}
		// render stuff out
		event.renderData( data=data, type="json" );
	}

	/**
	* rename
	*/
	function rename( event, rc, prc ){
		var data = {
			errors = false,
			messages = ""
		};
		// param value
		event.paramValue( "path", "" );
		event.paramValue( "name", "" );

		// clean incoming path and names
		rc.path = cleanIncomingPath( URLDecode( trim( rc.path ) ) );
		rc.name = URLDecode( trim( rc.name ) );
		if( !len( rc.path ) OR !len( rc.name ) ){
			data.errors = true;
			data.messages = $r( "messages.invalid_path_name@fb" );
			event.renderData( data=data, type="json" );
			return;
		}

		// rename
		try{
			// Announce it
			var iData = {
				original = rc.path,
				newName = rc.name
			};
			announceInterception( "fb_preFileRename", iData );

			if( s3Provider.fileExists( rc.path ) ){
			
				s3Provider.fileMove( rc.path, replaceNoCase( rc.path, listLast( rc.path, "/" ), rc.name ) );
			
			} else if( s3Provider.directoryExists( rc.path ) ){
			
				s3Provider.fileMove( rc.path & "/", replaceNoCase( rc.path, listLast( rc.path, "/" ), rc.name & "/" ) );
			
			}
			data.errors = false;
			data.messages = $r( resource="messages.renamed@fb", values='#rc.path#' );

			// Announce it
			announceInterception( "fb_postFileRename", iData );

		}
		catch(Any e){
			data.errors = true;
			data.messages = $r( resource="messages.error_renaming@fb", values="#e.message# #e.detail#" );
			log.error( data.messages, e );
		}
		// render stuff out
		event.renderData( data=data, type="json" );
	}

	/**
	* Upload File
	*/
	function upload( event, rc, prc ){
		// param values
		event.paramValue( "path", "" )
			.paramValue( "manual", false );

		// clean incoming path for destination directory
		rc.path = cleanIncomingPath( URLDecode( trim( rc.path ) ) );

		// Verify credentials else return invalid
		if( !prc.fbSettings.allowUploads ){
			data.errors = false;
			data.messages = $r( "messages.upload_disabled@fb" );
			event.renderData( data=data, type="json" );
			return;
		}

		// upload
		try{
			// Announce it
			var iData = {
				fileField = "FILEDATA",
				path = rc.path
			};

			announceInterception( "fb_preFileUpload", iData );

			//upload file to a temporary directory
			var tmpDir = expandPath( event.getModuleRoot( 'contentbox-s3-filebrowser' ) ) & "/tmp";

			if( !directoryExists( tmpDir ) ) directoryCreate( tmpDir );

			tmpUpload = fileUtils.uploadFile( 
				fileField		= "FILEDATA",
				destination		= tmpDir,
				nameConflict	= "Overwrite",
				accept			= prc.fbSettings.acceptMimeTypes 
			);

			var tmpFile = tmpUpload.serverDirectory & "/" & tmpUpload.serverFile;

			var upload = VARIABLES.S3Provider.fileWrite( tmpFile, rc.path & "/" & tmpUpload.serverfile );

			fileDelete( tmpFile );

			iData.results ={
				"serverdirectory":rc.path,
				"serverfile":tmpUpload.serverfile
			} 

			// debug log file
			if( log.canDebug() ){
				log.debug( "File Uploaded!", iData.results);
			}
			data.errors = false;
			data.messages = $r( "messages.uploaded@fb" );
			log.info( data.messages, iData.results );

			// Announce it
			announceInterception( "fb_postFileUpload", iData );
		}
		catch(Any e){
			data.errors = true;
			data.messages = $r( resource="messages.error_uploading@fb", values="#e.message# #e.detail#" );
			log.error( data.messages, e );
			// Announce exception
			var iData = {
				fileField = "FILEDATA",
				path = rc.path,
				exception = e
			};
			announceInterception( "fb_onFileUploadError", iData );
		}
		// Manual uploader?
		if( rc.manual ) {
			event.renderData( data="<textarea id='data_result'='upload'>#serializeJSON( data )#</textarea>", type="text" );
		} else {
			// render stuff out
			event.renderData( data=data, type="json" );
		}
	}

	/************************************** PRIVATE *********************************************/

	/**
	* Cleanup of incoming path
	*/
	private function cleanIncomingPath( required inPath ){
		// Do some cleanup just in case on incoming path
		inPath = REReplace( inPath, "(/|\\){1,}$", "", "all" );
		inPath = REReplace( inPath, "\\", "/", "all" );
		return inPath;
	}

	/**
	* Load Assets for FileBrowser
	* @force Force the loading of assets on demand
	* @settings A structure of settings for the filebrowser to be overriden with in the viewlet most likely.
	*/
	private function loadAssets( event, rc, prc, boolean force=false, struct settings={} ){
		
		// merge the settings structs if passed
		if( !structIsEmpty( arguments.settings ) ){
			mergeSettings( prc.fbSettings, arguments.settings );
		}

		// Load CSS and JS only if not in Ajax Mode or forced
		if( NOT event.isAjax() OR arguments.force ){
			// load parent assets if needed
			if( prc.fbSettings.loadJquery ){
				// Add Main Styles
				var adminRoot = event.getModuleRoot( 'contentbox-admin' );
				addAsset( "#adminRoot#/includes/css/contentbox.min.css" );
				addAsset( "#adminRoot#/includes/js/jquery.min.js" );
			}

			// LOAD Assets

			//injector:css//
			addAsset( "#prc.fbModRoot#/includes/css/86901492.fb.min.css ");
			//endinjector//
			//injector:js//
			addAsset( "#prc.fbModRoot#/includes/js/fd8ff33d.fb.min.js ");
			addAsset( "#prc.s3fbModRoot#/includes/js/s3-filebrowser.js ");
			//endinjector//
		}
	}

	/**
	* Get preferences
	*/
	private function getPreferences(){
		// Get preferences
		var prefs = cookieStorage.getVar( "fileBrowserPrefs", "" );

		// not found or not JSON setup defaults
		if( !len( prefs ) OR NOT isJSON( prefs ) ){
			prefs = {
				sorting = "name", listType = "listing"
			};
			cookieStorage.setVar( "fileBrowserPrefs", serializeJSON( prefs ) );
		}
		else{
			prefs = deserializeJSON( prefs );
			if( !structKeyExists( prefs, "sorting" ) ){
				prefs.sorting = "name";
				cookieStorage.setVar( "fileBrowserPrefs", serializeJSON( prefs ) );
			}
			if( !structKeyExists( prefs, "listType" ) ){
				prefs.listType = "listing";
				cookieStorage.setVar( "fileBrowserPrefs", serializeJSON( prefs ) );
			}
		}
		return prefs;
	}

	/**
	* Detect Preferences: Sorting and List Types
	*/
	private function detectPreferences( event, rc, prc ){
		runEvent( event="contentbox-filebrowser:Home.detectPreferences",eventArguments=ARGUMENTS );
	}

	/**
	* Merge module settings and custom settings
	*/
	private struct function mergeSettings( struct oldSettings, struct settings={} ){
		// Mrege Settings
		structAppend( arguments.oldSettings, arguments.settings, true );
		// clean directory root
		if( structKeyExists( arguments.settings, "directoryRoot" ) ) {
			arguments.oldSettings.directoryRoot = REReplace( arguments.settings.directoryRoot,"\\","/","all" );
			if ( right( arguments.oldSettings.directoryRoot, 1 ) EQ "/" ) {
				arguments.oldSettings.directoryRoot = left( arguments.oldSettings.directoryRoot, len( arguments.oldSettings.directoryRoot ) - 1 );
			}
		}
		return oldSettings;
	}

	/**
	* Inflate flash params if they exist into the appropriate function variables.
	*/
	private function inflateFlashParams( event, rc, prc ){
		// Check if callbacks stored in flash.
		if( structKeyExists( flash.get( "fileBrowser", {} ), "callback" ) and len( flash.get( "fileBrowser" ).callback ) ){
			rc.callback = flash.get( "fileBrowser" ).callback;
		}
		// cancel callback
		if( structKeyExists( flash.get( "fileBrowser", {} ), "cancelCallback" ) and len( flash.get( "fileBrowser" ).cancelCallback ) ){
			rc.cancelCallback = flash.get( "fileBrowser" ).cancelCallback;
		}
		// filterType
		if( structKeyExists( flash.get( "fileBrowser", {} ), "filterType" ) and len( flash.get( "fileBrowser" ).filterType ) ){
			rc.filterType = flash.get( "fileBrowser" ).filterType;
		}
		// settings
		if( structKeyExists( flash.get( "fileBrowser", {} ), "settings" ) ){
			prc.fbsettings = flash.get( "fileBrowser" ).settings;
		}

		if( !flash.exists( "filebrowser" ) ){
			var filebrowser = { 
				callback		= rc.callback, 
				cancelCallback	= rc.cancelCallback, 
				filterType		= rc.filterType, 
				settings		= prc.fbsettings 
			};
			flash.put( name="filebrowser", value=filebrowser, autoPurge=false );
		}
	}
}