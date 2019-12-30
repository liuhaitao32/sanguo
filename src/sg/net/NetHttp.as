package sg.net
{
	import laya.net.HttpRequest;
	import laya.events.EventDispatcher;
	import laya.events.Event;
	import sg.net.NetVo;
	import laya.utils.Handler;
	import sg.cfg.ConfigApp;
	import sg.utils.Tools;
	import laya.utils.Browser;
	import sg.utils.Base64;

	/**
	 * ...
	 * @author aaa
	 */
	public class NetHttp extends EventDispatcher{
		private static var sNetHttp:NetHttp = null;
		public  static function get instance():NetHttp{
			return sNetHttp ||= new NetHttp();
		}
		public function NetHttp(){
			
		}
		public static var encrypted:int = 0; // 1 加密
		public static var encrypted_key:String = "1234567890123456"; // 1 加密key
		public static var POST_GET:Number = 0;//共用
		public static const STATUS_SERVER_CLOSE:Number = 2000;//服务器维护
		public static const STATUS_SERVER_OK:Number = 0;
		public static const HTTP_POST:String = "post";
		public static const HTTP_GET:String = "get";
		public static const HTTP_TYPE:String = "json";
		public static const HTTP_TEXT:String = "text";

		public static const EVENT_NET_ERROR:String = "event_net_error";
		//
		private var isSending:Boolean = false;
		private var mHttp:HttpRequest;
		private var mSendList:Array;
		private var mSendListDic:Object;
		/**
		 * 发送消息请求
		 */
		public function send(method:String,data:Object,callback:Handler = null,timeout:int = 60):void{
			if(!this.mHttp){
				this.init();
			}
			var vo:NetVo = new NetVo(method,data,callback,timeout);
			// this.mSendList.unshift(vo);
			this.mSendListDic[method] = vo;
			//
			if(!this.isSending){
				this.exe(method);
			}
		}
		public function checkArea():void{
			var areaURL:String = ConfigApp.get_area_check();
			// trace(areaURL);
			Trace.log("====>>>> mip地址URL ",areaURL);
			if(areaURL && areaURL!=""){
				var area:HttpRequest = new HttpRequest();
				area.on(Event.COMPLETE,null,function(data:*):void{
					ConfigApp.isChina = data;
					Trace.log("====>>>> mip地址 == ",data);
					// var isCN:Boolean = (ConfigApp.isChina && (ConfigApp.isChina == "1"));
					// trace("==1=checkArea==",isCN);
				});
				area.on(Event.PROGRESS,null,function(data:*):void{
					// trace("==2=checkArea==",ConfigApp.isChina);
				});
				area.on(Event.ERROR,null,function(data:*):void{
					// trace("==3=checkArea==",ConfigApp.isChina);
				});
				area.send(areaURL);
			}
		}
		public function postOther(method:String,sd:Object = null,callback:Handler = null):void{
			var url:String = ConfigApp.get_data_report();//"http://log.trackingio.com";
			if(url && url!=""){
				var report:HttpRequest = new HttpRequest();
				report.on(Event.COMPLETE,null,function(re:*):void{
					// if(callback){
					// 	callback.runWith(re);
					// }
					// trace(Event.COMPLETE,re);
					Trace.log("====>>>> postOther res ==>> ",url,re);
				});
				report.on(Event.PROGRESS,null,function(re:*):void{
					// trace("==2=checkArea==",ConfigApp.isChina);
					// trace(Event.PROGRESS,re);
				});
				report.on(Event.ERROR,null,function(re:*):void{
					// trace("==3=checkArea==",ConfigApp.isChina);
					// trace(Event.ERROR,re);
				});
				// trace(sd);
				report.send(url+method,JSON.stringify(sd),HTTP_POST,HTTP_TYPE);
			}
		}

		/**
		 * 请求接口 GET
		 */
		public function getRequest(url:String, callback:Handler = null):void {
			if (url) {
				var request:HttpRequest = new HttpRequest();
				request.on(Event.COMPLETE, this, function(re:*):void {
					callback && callback.runWith(re);
				});
				request.on(Event.PROGRESS, this, function(re:*):void {
					// trace("==2=checkArea==",ConfigApp.isChina);
					// trace(Event.PROGRESS,re);
				});
				request.on(Event.ERROR, this, function(re:*):void {
					// trace("==3=checkArea==",ConfigApp.isChina);
					// trace(Event.ERROR,re);
				});
				request.send(url, null, HTTP_GET, '');
			}
		}

		/**
		 * 请求接口 POST
		 */
		public function postRequest(url:String, data:Object = null, callback:Handler = null):void {
			if (url && data) {
				var report:HttpRequest = new HttpRequest();
				report.on(Event.COMPLETE, this, function(re:*):void {
					// trace(Event.COMPLETE,re);
					callback && callback.runWith(re);
				});
				report.on(Event.PROGRESS, this, function(re:*):void {
					// trace("==2=checkArea==",ConfigApp.isChina);
					// trace(Event.PROGRESS,re);
				});
				report.on(Event.ERROR, this, function(re:*):void {
					// trace("==3=checkArea==",ConfigApp.isChina);
					// trace(Event.ERROR,re);
				});
				report.send(url, (data is String ? data : JSON.stringify(data)), HTTP_POST, HTTP_TYPE);
			}
		}

		public function downLoad(url:String):void{
			// trace("开始下载"+url);
			var down:HttpRequest = new HttpRequest();
			down.on(Event.COMPLETE,this,this.onCompleteDown);
			down.on(Event.PROGRESS,this,this.onProcessDown);
			down.on(Event.ERROR,this,this.onErrorDwon);
			down.send(url,null,"get","",null);
		}
		private function onErrorDwon(err:*):void{
			// trace("下载错误");
		}
		private function onProcessDown(data:*):void{
			// trace("下载中"+data);
		}
		private function onCompleteDown(data:*):void{
			// trace("下载完成");
		}
		private function init():void{
			this.mHttp = new HttpRequest();
			//
			this.mHttp.on(Event.COMPLETE,this,this.onComplete);
			this.mHttp.on(Event.PROGRESS,this,this.onProcess);
			this.mHttp.on(Event.ERROR,this,this.onError);
			//
			this.mSendList = [];
			this.mSendListDic = {};
		}
		private function exe(method:String):void{
			this.isSending = true;
			// var vo:NetVo = this.mSendList[0];
			var vo:NetVo = this.mSendListDic[method];
			// this.mHttp.http.timeout = vo.timeout*Tools.oneMillis; // ie不支持
			//
			Trace.log("====>>>> Http发送数据 ====>>>>",vo.send);
			var ext:String = (NetHttp.POST_GET>0)?"&data="+vo.send:"";
			// trace("====>>>> Http发送数据 ====>>>>",ConfigApp.get_HTTP_URL())
			this.mHttp.send(ConfigApp.get_HTTP_URL() + '?e=' + NetHttp.encrypted+ext, vo.send,HTTP_POST, (NetHttp.encrypted>0) ? HTTP_TEXT: HTTP_TYPE);
		}
		// private function next():void{
		// 	this.mSendList.shift();
		// 	if(this.mSendList.length>0){
		// 		this.exe();
		// 	}
		// }
		private function format(data:Object,type:int = 0):void{
			this.isSending = false;
			// var vo:NetVo = this.mSendList[0];
			var vo:NetVo = this.mSendListDic[data.method];
			var code:Number = Number(data["return_code"]);
			Trace.log("<<<<==== Http返回数据 ",data);
			if(code==STATUS_SERVER_OK || code == STATUS_SERVER_CLOSE){				
				vo.reData(data,code);
				vo.runCallBack();
				vo.clear();
			}
			else{
				Trace.log("<<<<==== Http返回format格式化后code异常 ",vo.re);
			}
		}
		private function onComplete(data:Object):void{
			// var reJson:Object = JSON.parse(data+"");
			if (NetHttp.encrypted>0) {
				data = JSON.parse(Base64.decode(data as String));
			}
			this.format(data,1);
		}
		private function onProcess(data:Object):void{
			this.isSending = true;
		}
		private function onError(err:Object):void{
			this.isSending = false;
			Trace.log("<<<<==== Http返回错误error ",err);
			//
			this.event(EVENT_NET_ERROR);
		}
		/**
		 * 检查,服务器返回的是否是错误提示类型
		 */
		public static function checkReIsError(re:Object):Boolean{
			var b:Boolean = false;
			if(re && re.status && re.status == "error"){
				b = true;
			}
			return b;
		}

	}

}