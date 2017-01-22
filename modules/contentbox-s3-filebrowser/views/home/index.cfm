<cfoutput>
#renderView(view="home/index",module=prc.fbModuleName)#

<script type="application/javascript">
var s3BaseURL = "#prc.s3BaseUrl#";

//re-declaration of the URL retrieval method
function fbUrl(){
	// check selection
	var sPath = $selectedItem.val();
	if( !sPath.length ){ alert( 'Please select a file-folder first.' ); return; }
	// get ID
	var thisID 		= $selectedItemID.val();
	var target 		= $( "##"+thisID);
	// prompt the URL
	var newName  = prompt( "URL:", s3BaseURL + "/" + target.attr( "data-fullurl" ) );
}

function fbRefresh(){
	$fileLoaderBar.slideDown();
	console.log( '#event.buildLink( prc.xehFBBrowser )#' );
	$fileBrowser.load( '#event.buildLink( prc.xehFBBrowser )#',
		{ path:'#rc.path#', sorting:$sorting.val(), listType: $listType.val() },
		function(){
			$fileLoaderBar.slideUp();
		} );
}

$( document ).ready( function(){
	$( "##FileBrowser-heading h3.panel-title" ).html( "<strong>S3 Remote File Browser</strong>" );
});

</script>
</cfoutput>
