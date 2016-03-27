# Social Media in Adobe AIR

This repository contains guides that allow your Adobe AIR applications to interact with social media networks.

This can be accomplished by just using StageWebView and URLRequest, no need for ANE is required.

Some examples of what you can achieve are:

Send a tweet on behalf the user.
Allow the user to Like/Share your app.
Load a user profile information (name, profile picture, email address, friend list).

## Getting Started

Before you start you will require:

  - A valid cellphone number. Registration on the Facebook, Twitter and Google developer portals require a cellphone number where they can confirm your account by SMS.
  - The Adobe AIR SDK, preferably a recent version.
  - The [AS3 Crypto](http://crypto.hurlant.com/demo/as3crypto.swc) library.

These guides are compatible on the Apache Flex SDK, Starling Framework and pure AS3, you are free to choose the framework of your choice. The examples are provided for pure AS3 and are designed to be easily copied and pasted.

These guides do not work on the Flash Player because it doesn't support the StageWebView API. If you wish to integrate social media in your Flash Player file you can do it by using their JavaScript libraries and listening to ExternalInteface events.

## Introduction to OAuth

The OAuth protocol allows third party applications to interact securely with private resources without sharing the logged user credentials.

The standard workflow is as follows:

  1. The user wants to access some feature in your app that requires a log-in.
 
  2. The user is presented with a Sign-In button and presses it.
 
  3. A modal window appears (Pop-Up) with a web browser inside (StageWebView) where the user must enter their username and password and allow the permissions the app requested.
 
  4. Once the user has successfully logged in the web browser it will be redirected to a 'Success' page that will contain a token/code.
 
  5. The app will need to grab said code and perform an URLRequest to the server where the code will be exchanged for an Access Token.
 
  6. Once the app has gotten the Access Token it will be used to interact with private resources, such as fetching friends lists, user profile and more.

This workflow varies a bit on each social network, the differences will be cleared in their respective guides.

## Glossary

  - StageWebView: An Adobe AIR component that allows applications to show an embedded web browser.

  - URLRequest: An ActionScript 3 class for creating and sending requests to external resources, such as web servers.

  - App ID: A string unique to your application that identifies it to the OAuth server. Used as a parameter in a Request Token.

  - Redirect URI/URL: A location where the StageWebView will be redirected upon a successful authorization. This location will contain a code/token that muse be retrieved for creating a Token Request.

  - Request Token: A string containing several parameters which will be exchanged for an Access Token.

  - Access Token: An alphanumeric string that is used as a parameter in URLRequests to access private resources.

Each social network guide is separated into their own folder, feel free to read them in any order.