/*******************************************************************************
* Test Suite
*******************************************************************************/
component extends="coldbox.system.testing.BaseTestCase" appMapping="/root" accessors=true{
	property name="Wirebox" inject="Wirebox";
	property name="AppSettings" inject="wirebox:properties";
	property name="CFMLFacade";
	//this.loadColdbox=true;
	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll();
		//super.setup();
		// expect( APPLICATION ).toHaveKey( "cbController" );
		// expect( APPLICATION.cbController ).toBeComponent();
		// APPLICATION.cbController.getWirebox().autowire( this );
		// APPLICATION.cbController.getModuleService().reloadAll();
		// setCFMLFacade( createObject("component","modules.s3sdk.CFMLFacade").init( "ortus-public" ) );
		// APPLICATION.cbController.getWirebox().autowire( VARIABLES.CFMLFacade );
		// expect( isNull( VARIABLES.Wirebox ) ).toBeFalse();
		// expect( isNull( VARIABLES.CFMLFacade ) ).toBeFalse();
		// expect( VARIABLES.CFMLFacade ).toBeComponent();

		// VARIABLES.tmpDirectory = VARIABLES.CFMLFacade.getTmpDir();

		// if( !directoryExists( VARIABLES.tmpDirectory ) ){

		// 	directoryCreate( VARIABLES.tmpDirectory );
		
		// }

	}

	function afterAll(){
		// do your own stuff here
		super.afterAll();

	}

	/*********************************** BDD SUITES ***********************************/
	
	function run(){

		describe( "Runs tests for CFML Facade functions", function(){

			xit("Tests the fileCopy() emulation", function(){
				fileWriteLine( VARIABLES.tmpDirectory & "/test.txt", "Testbox testing" );
				
				CFMLFacade.fileCopy( VARIABLES.tmpDirectory & "/test.txt", "test.txt" );

				var http = new Http( url="http:" & CFMLFacade.getBucketURL() & "/my.tests/contentbox-s3-filebrowser/test.txt" );
				var resp = http.send().getPrefix();
				expect( findNoCase( "Testbox testing", resp.filecontent ) ).toBeTrue();
				
			});

			it( "Tests the directoryList() emulation", function(){
				
			});
		
		});

	}

}
