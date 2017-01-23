/**
*********************************************************************************
* Your Copyright
********************************************************************************
*/
component{

	// Module Properties
	this.title 				= "contentbox-s3-filebrowser";
	this.author 			= "Jon Clausen <jclausen@ortussolutions.com>";
	this.webURL 			= "";
	this.description 		= "s3 Filebrowser for Contentbox CMS";
	this.version			= "@build.version@+@build.number@";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= true;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = true;
	// Module Entry Point
	this.entryPoint			= "contentbox-s3-filebrowser";
	// Model Namespace
	this.modelNamespace		= "contentbox-s3-filebrowser";
	// CF Mapping
	this.cfmapping			= "contentbox-s3-filebrowser";
	// Auto-map models
	this.autoMapModels		= true;
	// Module Dependencies That Must Be Loaded First, use internal names or aliases
	this.dependencies		= ["contentbox","contentbox-admin"];

	/**
	* Configure module
	*/
	function configure(){

		// Interceptors
		interceptors = [
			// Rate Limiter
			{ class="contentbox-s3-filebrowser.interceptors.S3Filebrowser", name="S3FileBrowser@cb" }
		];

		// Settings - s3SDK settings are merged in later
		settings = {
			"uploads" : {
				"bucket":"",
				"prefix":"",
				"url":""
			},
			"filebrowser":{
				"enabled":false
			}
		};

		// SES Routes
		routes = [
			// create folder
			{ pattern="/createFolder", handler="home",action="createfolder" },
			// remove stuff
			{ pattern="/remove", handler="home",action="remove" },
			// download
			{ pattern="/download", handler="home",action="download" },
			// rename
			{ pattern="/rename", handler="home",action="rename" },
			// upload
			{ pattern="/upload", handler="home",action="upload" },
			// traversal paths
			{ pattern="/d/:path", handler="home",action="index" },
			// Module Entry Point
			{ pattern="/", handler="home",action="index" },
			// Convention Route
			{ pattern="/:handler/:action?" }
		];
	}

	/**
	* Fired when the module is registered and activated.
	*/
	function onLoad(){

		parseParentSettings();

	}

	/**
	* Fired when the module is unregistered and unloaded
	*/
	function onUnload(){
		
	}

	/**
	* parse parent settings
	*/
	private function parseParentSettings(){

		var oConfig 		= controller.getSetting( "ColdBoxConfig" );
		var configStruct 	= controller.getConfigSettings();
		var coldBoxSettings = controller.getSettingStructure();
		var s3Settings 		= oConfig.getPropertyMixin( "s3sdk", "variables", structnew() );
		
		//defaults
		configStruct[ "s3sdk" ] = variables.settings;			
		
		// incorporate environment settings
		detectS3EnvironmentSettings( s3Settings );

		//Set our URL to the bucket path, if it's not defined
		if( structKeyExists( s3Settings, "uploads" ) && !len( s3Settings.uploads.url ) ){
			s3Settings.uploads.url = "//" & s3Settings.uploads.bucket & ".s3.amazonaws.com";
		}
		//strip trailing slashes
		if( structKeyExists( s3Settings, "uploads" ) && right( s3Settings.uploads.url, 1 ) == "/" ){
			s3Settings.uploads.url = left( s3Settings.uploads.url, len( s3Settings.uploads.url )-1 );
		}

		structAppend( configStruct.s3sdk, s3Settings, true );

	}

	/**
	* Detects Environment Variables and overrides the default settings for the SDK if they exist
	**/
	private function detectS3EnvironmentSettings( s3Settings ){
		var system = createObject( "java", "java.lang.System" );
		environment = system.getenv();

		if( structKeyExists( environment, "S3_ACCESS_KEY" ) ){
			s3Settings["accessKey"] = environment[ "S3_ACCESS_KEY" ];
		}

		if( structKeyExists( environment, "S3_SECRET_KEY" ) ){
			s3Settings["secretKey"] = environment[ "S3_SECRET_KEY" ];
		}

		if( structKeyExists( environment, "S3_UPLOADS_BUCKET" ) ){
			s3Settings.uploads.bucket = environment[ "S3_UPLOADS_BUCKET" ];
		}

		if( structKeyExists( environment, "S3_UPLOADS_PREFIX" ) ){
			s3Settings.uploads.prefix = environment[ "S3_UPLOADS_PREFIX" ];
		}

		if( structKeyExists( environment, "S3_UPLOADS_URL" ) ){
			s3Settings.uploads.url = environment[ "S3_UPLOADS_URL" ];
		}



	}

}
