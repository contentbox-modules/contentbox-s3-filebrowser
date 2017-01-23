[![Build Status](https://travis-ci.org/contentbox-modules/contentbox-s3-filebrowser.svg?branch=development)](https://travis-ci.org/contentbox-modules/contentbox-s3-filebrowser)

<img src="https://www.contentboxcms.org/__media/ContentBox_300.png" class="img-thumbnail"/>


# Contentbox S3 Filebrowser

The Contentbox S3 filebrowser offers a drop-in replacement for the existing filebrowser module.  It is designed to use the existing filebrowser by simply replacing the data used to populate the view.  

##Installation

Forgebox installation:  `box install contentbox-s3-filebrowser

### Coldbox configuration
The file browser uses an extended version of the `s3sdk` settings.  To configure the filebrowser directly, add the following `s3sdk` settings to your Coldbox.cfc:

```
s3sdk = {
	// Your amazon access key
    accessKey = "",
    // Your amazon secret key
    secretKey = "",
    // The default encryption character set
    encryption_charset = "utf-8",
    // SSL mode or not on cfhttp calls.
    ssl = false,
    // The filebrowser uploads configuration
	"uploads" : {
		"bucket":"YOUR BUCKET NAME",
		"prefix":"YOUR BUCKET PATH PREFIX",
		//Enter the base url of your bucket. ( e.g. - Cloudflare distribution URL ) 
		//if blank will automatically create the default S3 url from your bucket name
		"url":""
	},
	"filebrowser":{
		//If false, the default filebrowser will be used
		"enabled":true
	}
}
```

The module also allows full configuration of your AWS settings from environment variables. This allows you to keep environmental secrets out of your source code respository.  If the following environmental variables are set, they will serve as your Coldbox configuration for S3 communication and uploads:

```
S3_ACCESS_KEY
S3_SECRET_KEY
S3_UPLOADS_BUCKET
S3_UPLOADS_PREFIX
S3_UPLOADS_URL
```

When using environment variables, only the following struct would need to be added to your Coldbox.cfc:

```
s3sdk = {
	"filebrowser":{
		"enabled":true
	}
}
```

## License
Apache License, Version 2.0.

## Important Links

Source Code
- https://github.com/contentbox-modules/contentbox-s3-filebrowser

## System Requirements
- Lucee 4.5+
- ColdFusion 10+


---
 
###THE DAILY BREAD
 > "I am the way, and the truth, and the life; no one comes to the Father, but by me (JESUS)" Jn 14:1-12