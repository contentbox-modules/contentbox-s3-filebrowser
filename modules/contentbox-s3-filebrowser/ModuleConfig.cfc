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
	this.dependencies		= [ ];

	/**
	* Configure module
	*/
	function configure(){
		// SES Routes
		routes = [
			// re-route the standard media manager route
			{ pattern="/mediamanager", handler="home",action="index" },
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
	}

	/**
	* Fired when the module is unregistered and unloaded
	*/
	function onUnload(){
		
	}

}
