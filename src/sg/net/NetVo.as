package sg.net
{


	import laya.utils.Utils;
	import sg.cfg.ConfigApp;
	import sg.utils.Tools;
	import laya.utils.Handler;
	import sg.cfg.ConfigServer;
	import laya.utils.Browser;
	import sg.utils.Base64;

	/**
	 * ...
	 * @author
	 */
	public class NetVo{
		public var id:String = "";
		public var method:String = "";
		public var data:Object = null;
		public var callback:Handler = null;
		public var timeout:int = 15;
		public var re:Object;
		public var mData:Object;
		public var send:String = "";
		
		public function NetVo(method:String,data:Object,callback:Handler = null,timeout:int = 15){
			this.method = method;
			this.data = data?data:{};
			this.callback = callback;
			this.id = Utils.getGID()+"";
			this.timeout = timeout;
			//
			var sendData:Object = {
				id:this.id,
				pf:ConfigApp.pf,
				method:this.method,
				params:this.data,
				cfg_version:ConfigApp.cfgVersion,
				app_version:ConfigApp.appVersion,
				phone_id:[Platform.getType(),Platform.getPhoneIDs()],
				app_id:Platform.getAppName()		
			};
			var sendStr:String = JSON.stringify(sendData);
			this.send = (NetHttp.encrypted>0) ? Base64.encode(sendStr): sendStr;
		}
		// public function reData(json:String):void{
		public function reData(jsonData:Object,code:Number = 0):void{
			this.re = jsonData;//JSON.parse(json);
			//
			ConfigServer.checkServerTime(Tools.getTimeStamp(this.re["server_now"]));
			//
			this.mData = this.re["data"];
			if(this.mData && this.mData is Array){

			}
			else if(this.mData && this.mData is String){

			}
			else if(this.mData && this.mData is Number){
				
			}
			else {
				if(!this.mData){
					this.mData = {};
				}
				this.mData["server_status"] = code;//服务器状态留存
				this.mData["re_params"] = this.re["params"];
			}
		}
		public function runCallBack():void{
			if(this.callback){
				if (this.mData && this.mData is Array){
					this.callback.runWith([this.mData]);
				}
				else{
					this.callback.runWith(this.mData);
				}
				
			}
		}
		public function clear():void{
			this.callback = null;
			this.send = null;
			this.re = null;
			this.data = null;
			this.mData = null;
		}
	}

}