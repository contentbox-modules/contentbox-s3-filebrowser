/**
* Copyright Since 2005 Ortus Solutions, Corp
* www.coldbox.org | www.luismajano.com | www.ortussolutions.com | www.gocontentbox.org
**************************************************************************************
*/
component{
	this.name = "A TestBox Runner Suite " & hash( getCurrentTemplatePath() );
	// any other application.cfc stuff goes below:
	this.sessionManagement = true;

	// any mappings go here, we create one that points to the root called test.
	this.mappings[ "/tests" ] = getDirectoryFromPath( getCurrentTemplatePath() );
	// THE LOCATION OF EMBEDDED COLDBOX & MODULES
	rootPath = REReplaceNoCase( this.mappings[ "/tests" ], "tests(\\|/)", "" );
	this.mappings[ "/root" ]   = rootPath;
	this.mappings[ "/coldbox" ] 	= rootPath & "coldbox";
	this.mappings[ "/contentbox" ] 	= rootPath & "modules/contentbox";
	this.mappings[ "/cborm" ]   = this.mappings[ "/coldbox" ] & "/system/modules/cborm";

	// any orm definitions go here.
	// THE DATASOURCE FOR CONTENTBOX MANDATORY
	// this.datasource = "contentbox";
	// // ORM SETTINGS
	// this.ormEnabled = true;
	// this.ormSettings = {
	// 	// ENTITY LOCATIONS, ADD MORE LOCATIONS AS YOU SEE FIT
	// 	cfclocation=[ "/root/models", "/root/modules" ],
	// 	// THE DIALECT OF YOUR DATABASE OR LET HIBERNATE FIGURE IT OUT, UP TO YOU TO CONFIGURE
	// 	//dialect 			= "MySQLwithInnoDB",
	// 	// DO NOT REMOVE THE FOLLOWING LINE OR AUTO-UPDATES MIGHT FAIL.
	// 	dbcreate = "update",
	// 	// FILL OUT: IF YOU WANT CHANGE SECONDARY CACHE, PLEASE UPDATE HERE
	// 	secondarycacheenabled = false,
	// 	cacheprovider		= "ehCache",
	// 	// ORM SESSION MANAGEMENT SETTINGS, DO NOT CHANGE
	// 	logSQL 				= false,
	// 	flushAtRequestEnd 	= false,
	// 	autoManageSession	= false,
	// 	// ORM EVENTS MUST BE TURNED ON FOR CONTENTBOX TO WORK
	// 	eventHandling 		= true,
	// 	eventHandler		= "cborm.models.EventHandler",
	// 	// THIS IS ADDED SO OTHER CFML ENGINES CAN WORK WITH CONTENTBOX
	// 	skipCFCWithError	= true
	// };

	// request start
	public boolean function onRequestStart( String targetPage ){
		return true;
	}
}