# Instagram

Integrating Instagram functionality in your application doesn't require external libraries.

## Getting Started

1. Register in the [Instagram Developer Portal](https://www.instagram.com/developer/register/). You may be asked to provide a valid telephone number to complete your registration.

2. On the top menu click the button that says `Manage Clients`, then click the `Register a New Client` button.

3. Fill the form with your app information, make sure to fill every field since they are required for a later step. When you reach the `Valid redirect URIs`, you can provide an URI which contains a blank webpage.

4. Once you have submitted the form you will be presented with a box containing your app information. Copy down your `CLIENT ID`.

5. Click again on the `Manage Clients` button, you will see your newly created app in there. Click the `Manage` button and copy down your `App Secret`.

## Implementation

Open or create a new project.

Open the file where you want to implement the Sign-In feature.

Add the following constants and variables:

```actionscript
private static const CLIENT_ID:String = "Your own Client ID";
private static const CLIENT_SECRET:String = "Your own Client Secret";
private static const REDIRECT_URI:String = "Your own Redirect URI";
			
private var webView:StageWebView;
private var code:String;
private var accessTokenLoader:URLLoader;		
```

Add a button and assign an `EventListener` to it when it gets pressed. The code of the EventListener should be as follows:

```actionscript
private function initSignIn():void
{
	webView = new StageWebView(true);
	webView.addEventListener(LocationChangeEvent.LOCATION_CHANGE, changeLocation);
	webView.stage = this.stage;
	webView.viewPort = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
    webView.loadURL("https://api.instagram.com/oauth/authorize/?client_id="+CLIENT_ID+"&redirect_uri="+REDIRECT_URI+"&response_type=code");
}
```

We initialized a StageWebView instance, set its dimensions to match the stage size. We crafted a special URL that contains several parameters:

* `client_id`: Your Client ID.
* `redirect_uri`: Is the same `redirect_uri` we provided in the previous form.
* `response_type`: We only require a `code` as a response.

```actionscript
private function changeLocation(event:LocationChangeEvent):void
{
	var pageTitle:String = webView.title;
				
	if(pageTitle.indexOf("code=") != -1){
		webView.dispose();
		code = pageTitle.substr(pageTitle.indexOf("code=")+5, pageTitle.length);
					
		getAccessToken();
	}				
}
```

We start listening for a `LocationChange` event (every time the web browser changes its web page), once a web page contains the `code` parameter in its Title we dispose the StageWebView and extract the parameter to a variable.

Then we called a custom function `getAccessToken()` where we are going to create an `URLRequest` to exchange the `code` for an `access_token`.

```actionscript
private function getAccessToken():void
{				
	var urlVars:URLVariables = new URLVariables();
	urlVars.code = code;
	urlVars.client_id = CLIENT_ID;
	urlVars.client_secret = CLIENT_SECRET;
	urlVars.redirect_uri = REDIRECT_URI;
	urlVars.grant_type = "authorization_code";
				
	var request:URLRequest = new URLRequest("https://api.instagram.com/oauth/access_token");
	request.method = URLRequestMethod.POST;
	request.data = urlVars;
				
	accessTokenLoader = new URLLoader();
	accessTokenLoader.addEventListener(Event.COMPLETE, accessTokenReceived);
	accessTokenLoader.load(request);
}
```

We sent all the parameters in a `POST` request and added an `EventListener` which will contain the `access_token` and the basic logged in user profile information.

```actionscript
private function accessTokenReceived(event:Event):void
{
    trace(event.currentTarget.data);		
	var rawData:Object = JSON.parse(String(event.currentTarget.data));
}
```

You may have noticed that there is a message saying the app is in `Sandbox Mode`. This means only you and preselected users can make use of the Instagram API.

In order to make your app work with any Instagram user you must submit it for review.

