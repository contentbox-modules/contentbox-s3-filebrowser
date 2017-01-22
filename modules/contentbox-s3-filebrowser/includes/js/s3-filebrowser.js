//re-declaration of the URL method
function fbUrl(){
	// check selection
	var sPath = $selectedItem.val();
	if( !sPath.length ){ alert( 'Please select a file-folder first.' ); return; }
	// get ID
	var thisID 		= $selectedItemID.val();
	var target 		= $( "#"+thisID);
	// prompt the URL
	var newName  = prompt( "URL:", s3BaseURL + "/" + target.attr( "data-fullurl" ) );
}