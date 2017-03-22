# Google

Integrating Google Accounts (Gmail, Google+, Youtube, Google Apps) functionality in your application doesn't require external libraries.

The new OAuth requirements from Google don't allow the use of a `WebView` anymore. To solve this issue we are going to use one of their recommended methods, the `Loopback IP address`.

In this method, the user is presented with a login button, once the user clicks the button we open an authorization website in the default web browser and start a local server.
Once the user has finished authorizing our app, the OAuth server will connect to our server and send the `authorization_code` over a `Socket`.

In this step we need to write a message to the auth website telling the user that their authorization was successful and they need to go back to our application. 

This method can be achieved using the Adobe AIR `Socket` and `ServerSocket` classes.

## Getting Started

1. Register in the [Google Developer console](https://console.developers.google.com/). You may be asked to provide a valid telephone number to complete your registration.
  
2. Once registered, locate a drop-down list in the top and click on it. At the bottom it will be an option to Create a Project.
  
3. Type a name for your project and save it.

4. On the left side you will see a button with 3 lines, click it and then select `API Manager`.

5. Select `Credentials` and then click in the `OAuth Consent Screen` tab. Type a product name and save it.

![Correct Settings](./images/1.png)

6. Go to the `Credentials` tab, press the `Create Credentials` drop down list and select `OAuth client ID`. In Application Type select `Other`, type a name and save it.

7. A window will appear with your `Client ID` and `Client Secret`, copy them down and click Ok.

8. In the left side, click `Overview` and a list of APIs will appear in the right. Search the Google+ API and click it.

9. Click the `Enable` button and wait until the API is enabled.

![Enable Button](./images/2.png)

If you want to interact with other Google APIs in your application you will have to repeat the last two steps for each one.

## Implementation

Open or create a new project.

Open the file where you want to implement the Sign-In feature.

Add the following constants and variables:

```actionscript
private static const CLIENT_ID:String = "Your own Client ID";
private static const CLIENT_SECRET:String = "Your own Client Secret";

private var redirect_uri:String = "http://[::1]:9005";
private var serverSocket:ServerSocket;
private var clientSocket:Socket;
```

Add a button and assign an `EventListener` to it when it gets pressed. The code of the EventListener should be as follows:

```actionscript
private function initSignIn():void
{
	serverSocket = new ServerSocket();
	serverSocket.addEventListener( flash.events.Event.CONNECT, connectHandler);

	serverSocket.bind(9005, "::");
	serverSocket.listen();

	var request:URLRequest = new URLRequest("https://accounts.google.com/o/oauth2/v2/auth?scope=email%20profile&" +
			"response_type=code&redirect_uri=" + redirect_uri + "&client_id=" + CLIENT_ID);

	navigateToURL(request);
}
```

We instantiated a `ServerSocket` and bound it to the same `IP` and `Port` number as our `redirect_uri` variable. We also added an EventListener for when the ServerSocket gets an incoming connection.
The IPv6 address provided is a wildcard that will listen to all IPv6 connections.
We then opened the default web browser with a URL containing the following parameters:

Name | Description
---|---
`scope` | The permissions we need from Google, in this case `email` and `profile`
`response_type` | The type of response we want, in this case the value will be `code`
`redirect_uri` | The IP and Port we are going to listen, it can be any value but we are going to use `http://[::1]:9005`
`client_id` | The OAuth Client ID you copied from the Google API console.

Now, we add a `ServerSocketConnectEvent` which will listen when a client connection starts and add a `ProgressEvent.SOCKET_DATA` to each client it connects with. Since we expect only one client connection we will be using the `clientSocket` member variable we declared at the beginning.

```actionscript
private function connectHandler(event:ServerSocketConnectEvent):void
{
	clientSocket = event.socket;
	clientSocket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
}
```

Now we are going to listen to all the incoming traffic from the connected client. We are going to detect if the messages contain the `authorization_code`.

```actionscript
private function socketDataHandler(event:ProgressEvent):void
{
	clientSocket = event.currentTarget as Socket;

	var message:String = clientSocket.readUTFBytes(clientSocket.bytesAvailable);

	if(message.indexOf("GET /?code") == 0)
	{
		var startIndex:int = message.indexOf("?code=")+6;
		var endIndex:int = message.indexOf("HTTP/1.1")-12;
		var myCode:String = message.substr(startIndex, endIndex);

		exchangeCode(myCode);

		clientSocket.writeUTFBytes("<html><body><h1>You have been successfully authenticated. Please return back to the application.</h1></body></html>");
		clientSocket.flush();
		clientSocket.close();

	} else {
		//Code not found
	}
} 
```

If we find the `authorization_code` we parse it and terminate the socket connection with a success message. You can customize the success message with any HTML content you desire.

It's time to exchange the `authorization_code` for an `access_token` which will allow us to consume the Google APIs on behalf the user.
 
```actionscript
private function exchangeCode(code:String):void
{
	var urlVars:URLVariables = new URLVariables();
	urlVars.code = code;
	urlVars.client_id = CLIENT_ID;
	urlVars.client_secret = CLIENT_SECRET;
	urlVars.redirect_uri = redirect_uri;
	urlVars.grant_type = "authorization_code";

	var request:URLRequest = new URLRequest("https://www.googleapis.com/oauth2/v4/token");
	request.method = URLRequestMethod.POST;
	request.data = urlVars;

	var loader:URLLoader = new URLLoader();
	loader.addEventListener(flash.events.Event.COMPLETE, codeExchanged);
	loader.load(request);
}
```

We sent an `URLRequest` with the following parameters via `POST`:

Name | Description
---|---
`code` | The `authorization_code` parsed from the client Socket.
`client_id` | The OAuth Client ID you copied from the Google API console.
`client_secret` | The OAuth Client Secret you copied from the Google API console.
`redirect_uri` | We will reuse the same `redirect_uri` from the beginning.
`grant_type` | With the value `authorization_code`

We will receive a `JSON` response with several values. One of them will be the `access_token`. We are going to test it by retrieving the logged in user basic profile information.

```actionscript
private function codeExchanged(event:flash.events.Event):void
{
	var rawData:Object = JSON.parse(String(event.currentTarget.data));
	loadProfileInfo(rawData.access_token);
}

private function loadProfileInfo(access_token:String):void
{
	var loader:URLLoader = new URLLoader();
	loader.addEventListener(flash.events.Event.COMPLETE, profileLoaded);
	loader.load(new URLRequest("https://www.googleapis.com/plus/v1/people/me?access_token="+access_token));
}

private function profileLoaded(event:flash.events.Event):void
{
	trace(event.currentTarget.data);
}
```

You can check a list of all Scopes in the [OAuth 2.0 Scopes for Google APIs.](https://developers.google.com/identity/protocols/googlescopes#plusv1)

Remember to Enable the corresponding APIs in the [Google Developer console](https://console.developers.google.com/).


