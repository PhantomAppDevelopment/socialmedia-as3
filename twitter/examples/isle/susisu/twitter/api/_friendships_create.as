package isle.susisu.twitter.api
{
	
	import flash.net.URLRequestMethod;
	
	import isle.susisu.twitter.TwitterRequest;
	import isle.susisu.twitter.TwitterTokenSet;
	
	public function _friendships_create(
		tokenSet:TwitterTokenSet,
		userId:String=null,
		screenName:String=null,
		follow:Boolean=false
	):TwitterRequest
	{
		//parameters
		var parameters:Object=new Object();
		if(userId!=null)
		{
			parameters["user_id"]=userId;
		}
		if(screenName!=null)
		{
			parameters["screen_name"]=screenName;
		}
		parameters["follow"]=follow?TRUE:FALSE;
		//make request
		var request:TwitterRequest=new TwitterRequest(tokenSet,TwitterURL.friendships_CREATE,URLRequestMethod.POST,parameters);
		
		return request;
	}
	
}