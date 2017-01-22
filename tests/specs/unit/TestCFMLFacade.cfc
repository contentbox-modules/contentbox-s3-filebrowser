/*******************************************************************************
* Test Suite
*******************************************************************************/
component extends="coldbox.system.testing.BaseTestCase" appMapping="/root" accessors=true{
	property name="Wirebox" inject="Wirebox";
	property name="CFMLFacade" inject="CFMLFacade@s3sdk";
	this.loadColdbox=true;
	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		super.beforeAll();
		super.setup();
		expect( APPLICATION ).toHaveKey( "cbController" );
		expect( APPLICATION.cbController ).toBeComponent();
		APPLICATION.cbController.getWirebox().init().autowire( this );
		expect( isNull( getWirebox() ) ).toBeFalse();
		expect( isNull( getCFMLFacade() ) ).toBeFalse();
		expect( getCFMLFacade() ).toBeComponent();

		var tmpDirectory = expandPath( '/root/includes/tmp' );
		if( !directoryExists( tmpDirectory ) ){
			directoryCreate( tmpDirectory );
		}
		// do your own stuff here
	}

	function afterAll(){
		// do your own stuff here
		super.afterAll();

	}

	/*********************************** BDD SUITES ***********************************/
	
	function run(){

		describe( "Runs tests for CFML Facade functions", function(){

			it("Tests the fileCopy() emulation", function(){
				var txtFile = fileOpen( tmpDirectory & "/test.txt" );
				fileWriteLine( txtFile, "Testbox testing" );
				fileClose( txtFile );

				CFMLFacade.fileCopy( txtFile, "test.txt" );

				var http = new Http( CFMLFacade.getBucketURL() & "/test.txt" );
				var resp = http.send().getPrefix();
				expect( findNoCase( "Testbox testing", resp.filecontent ) ).toBeTrue();
				
			});

			it( "Tests the directoryList() emulation", function(){
				
			});
		
		});

	}

}
