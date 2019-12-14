package sg.net
{
	import laya.utils.Pool;
	import interfaces.IClear;
	import sg.cfg.ConfigApp;
	import laya.utils.Handler;
	import sg.manager.ModelManager;

   public class NetPackage implements IClear {
		public var sendMethod:String;//发送方法
		
		public var receiveMethod:String;//接收方法
		
		public var pid:int = -1;
		
		public var otherData:* = null;//额外临时变量。不需要全局纪录的。
		public var sendData:*;//记录发送的数据
		public var guideData:*;//
		public var receiveData:*;//接收服务器的数据。
		public var sendTime:Number = 0;//发送的时间 用来防止超时
		public var reTime:Number = 0;//
		
		public var receiveHandler:Handler;//接收的函数。
		
		public function isTimeout(ruler:Number = 15000):Boolean{
			var d:Number = reTime - sendTime;
			return  (d >= ruler);
		}
		public function isDel(ruler:Number = 15000):Boolean{
			var now:Number = new Date().getTime();
			var b:Boolean = false;
			if(sendTime>0 && (now-sendTime)>ruler){
				b = true;
			}
			return b;
		}
		public function setTimeOut(ruler:Number = 15000):void{
			Laya.timer.clear(this,this.timeOut);
			Laya.timer.once(ruler,this,this.timeOut);
		}
		private function timeOut():void
		{
			NetSocket.instance.selfSendPackageIsOver(this,true);
		}
		public function notify():void {
			// if (null != this.receiveHandler) this.receiveHandler(this);
			if (null != this.receiveHandler) this.receiveHandler.runWith(this);
		}
		public function getSendDataJson():String{
			var s:Object = {
				pid:this.pid,
				method:this.sendMethod,
				params:this.sendData || {},
				cfg_version:ConfigApp.cfgVersion,
				app_version:ConfigApp.appVersion,
				phone_id:[Platform.getType(),Platform.getPhoneIDs()],
				app_id:Platform.getAppName()
			};
			Trace.log("====>>>> socket 发送请求 send ====>>>>",this.sendMethod,s);
			if (guideData) {
				s['guide'] = guideData;
			}
			var json:String = JSON.stringify(s);
			return json;
		}
		//是否被清理过。
		public function get cleared():Boolean {
			return true;
		}
		
		//所有东西重置  置空
		internal function reset():void {
			otherData = null;
			sendData = null;
			// guideData = null;
			pid = -1;
			receiveData = null;
			receiveHandler = null;
			sendTime = 0;
			reTime = 0;
		}
		
		//回收到对象池里去。
		public function clear():void {
			Laya.timer.clear(this,this.timeOut);
			this.reset();
			Pool.recover("net_vo",this);
		}
		
		/**
		 * 当前客户端发包的进行的数量。
		 */
		public static var pid : int = 1;
		
		/**
		 * 这种采用对象池管理。 每次生成的时候用这个。 不能直接new出来。
		 * @param	id send的 走默认的 注册长连的用-1
		 * @return
		 */
		public static function createPkg(id:int = -1):NetPackage {
			
			var result:NetPackage = Pool.getItemByClass("net_vo",NetPackage);//从池里取得。
			if(id != -1) {
				pid++;		
				result.pid = pid;	
			}
			
			return result;
		}
   }
}