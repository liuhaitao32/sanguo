package sg.net
{
    import laya.events.EventDispatcher;
    import laya.net.Socket;
    import laya.events.Event;
    import laya.utils.Byte;
    import laya.utils.Handler;
    import sg.manager.ModelManager;
    import sg.cfg.ConfigServer;
	import sg.map.utils.ArrayUtils;
	import sg.scene.view.TestButton;
	import sg.test.testpakcage.TestPackage;
    import sg.utils.Tools;
    import sg.guide.model.ModelGuide;
    import sg.manager.ViewManager;
    import sg.model.ModelGame;
    import laya.utils.Browser;

    public class NetSocket extends EventDispatcher{
        public static const EVENT_SOCKET_CLOSE:String = "event_socket_close";
        public static const EVENT_SOCKET_ERROR:String = "event_socket_error";
        public static const EVENT_SOCKET_OPENED:String = "event_socket_opened";
		public static const EVENT_SOCKET_RELOAD:String = "event_socket_reload";
        public static const EVENT_SOCKET_RE_CODE_ERROR:String = "event_socket_re_code_error";
        public static const EVENT_SOCKET_SEND_TO:String = "event_socket_send_to";
        public static const EVENT_SOCKET_RECEIVE_FROM:String = "event_socket_receive_from";
        //
        public static const EVENT_SOCKET_RECEIVE_TO:String = "event_socket_receive_to";
        //
        public static var timeOutTimer:Number = 15000;//超时时间ms
        public var timeoutPkg:Object = {};//超时包记录
        public var self_send_ing_pid:String = "";
        public var service_force_close:Boolean = false;//服务器强制关闭
        //
        private static var sNetSocket:NetSocket = null;

        public static var sMethodName:String="";
        public static var sSendData:Object;
		
		public var sleepTime:Array = [0, 0, 0];
		
		public  static function get instance():NetSocket{
			return sNetSocket ||= new NetSocket();
		}
		public function NetSocket(){
			
		}
        public static var HTTP_URL:String = "";
        public static function setURLtoConnect(ip:String,c:String,isSSL:Boolean):void{
            var protocol:String = isSSL?"wss:":"ws:";//协议
            HTTP_URL = protocol+"//"+ip+":"+c+"/gateway/";
            // HTTP_URL = protocol+"//192.168.1.66/";
            Trace.log("=====>>socket net=====>>",HTTP_URL);
            // trace("=====>>socket net=====>>",HTTP_URL);
            NetSocket.instance.clear();
            NetSocket.instance.init();
        }
        private var mSocket:Socket;
        private var closeTimes:int = 0;
        //
        public function init():void{
            this.mSocket = new Socket();
            this.service_force_close = false;
            this.closeTimes = 0;
            // this.mSocket.endian = Byte.LITTLE_ENDIAN;//这里我们采用小端；
            this.requestPkg = {};
            // this.mSocket.connect("192.168.1.118",8000);
            this.mSocket.on(Event.OPEN,this,openHandler);
            this.mSocket.on(Event.MESSAGE,this,receiveHandler);
            this.mSocket.on(Event.CLOSE,this,closeHandler);
            this.mSocket.on(Event.ERROR,this,errorHandler);
            //
            this.mSocket.connectByUrl(HTTP_URL);
			
			Laya.stage.on(Event.VISIBILITY_CHANGE,this,this.visibility_change);
            //
            Trace.log("====>>>> socket 初始化 init 第一次连接",HTTP_URL);
        }
		
		private function visibility_change(e:Event):void {
			TestButton.log("隐藏与显示" + Laya.stage.isVisibility);
			this.sleepTime[Laya.stage.isVisibility ? 0 : 1] = Browser.now();
		}
        public function clear():void{
            this.service_force_close = true;
            if(this.mSocket){
                this.mSocket.offAll(Event.OPEN);
                this.mSocket.offAll(Event.MESSAGE);
                this.mSocket.offAll(Event.CLOSE);
                this.mSocket.offAll(Event.ERROR);
                this.mSocket.close();
                // this.mSocket.cleanSocket();
            }
            this.mSocket = null;
        }
        public function testClose():void{
            this.mSocket.close();
        }
        public function reConnet():void{
            this.closeTimes ++;
            this.service_force_close = false;
            
            if(this.closeTimes>9){
                this.closeTimes = 0;
                //
                this.closeSocket({msg:Tools.getMsgById("_lht57")});
                return;
            }
            // this.mSocket.cleanSocket();
            this.mSocket.connectByUrl(HTTP_URL);
            Trace.log("====>>>> socket 重新连接 reConnet ",HTTP_URL,this.closeTimes);
        }
        private function openHandler(event:Object = null):void
        {
			TestButton.log("socketOpen");
			//关闭太久之后。 再重新打开。 很多包都会接收不到。这里我直接就给他退到主界面了。防止内容错误			
			var now:Number = Browser.now();
			if (Laya.stage.isVisibility && now - this.sleepTime[0] < 1000 * 30) {//舞台打开，并且允许有30秒卡主连接时间
				var sleepTime:Number = (this.sleepTime[0] - this.sleepTime[1]);
				var receiveTime:Number = now - this.sleepTime[2];
				if (sleepTime > 90 * 1000 && receiveTime > 60 * 1000) {// 关闭一分半钟以上。 并且有一分钟没接收到信息。网络重新打开的话。就认为是这一分钟没有收到包了。就可以踢了！
					this.event(NetSocket.EVENT_SOCKET_RELOAD, sleepTime);					
					return
				}
			}
			
			
            Trace.log("<<<<==== socket 连接成功打开 openHandler <<<<====",event);
            this.event(EVENT_SOCKET_OPENED);
            this.closeTimes = 0;
            this.checkConnected();
        }
        private function checkConnected():void
        {
            if(this.mSocket){
                // Trace.log("$$$$$$$ socket 是否还在连接 $$$$$$$",Platform.isNet());
            }
            var b:Boolean = Platform.isNet();
            if (!b){
				TestButton.log("socketClosed");
				// trace("socket5秒关闭！！！！");
                this.closeSocket({msg:Tools.getMsgById("msg_NetSocket_0")});
                return;
            }
            Laya.timer.clear(this,this.checkConnected);
            Laya.timer.once(5000,this,this.checkConnected);
        }
        private function receiveHandler(msg:Object = null):void
        {
			if (TestButton.test) {
				// trace("略过" + '【' + (reData?reData.method:'xxx') + '】' + reData);
				return;
			}
            var reData:Object = JSON.parse(msg + "");
			this.sleepTime[2] = Browser.now();
			Trace.log("<<<<==== socket 接收数据 receive <<<<====", '【' + (reData?reData.method:'xxx') + '】', reData);
			
			TestButton.log(reData?reData.method:"xxx");
            
            if(this.isSpecail(reData)){
                this.closeSocket(reData);
                return;
            }
            this.recevie(reData);
        }
        public function closeSocket(data:Object):void
        {
            this.service_force_close = true;
            this.event(EVENT_SOCKET_CLOSE,[this.service_force_close,data]);         
            if(this.mSocket){
                this.mSocket.close();
                // this.mSocket.cleanSocket();
                // this.mSocket = null;
            }           
        }
        private function closeHandler(e:Object= null):void
        {
            Trace.log("<<<<==== socket 关闭 closeHandler <<<<====",e);
            if(this.service_force_close){
                return;
            }
            Laya.timer.clear(this,this.reConnet);
            Laya.timer.once(2000,this,this.reConnet);
            //
            this.event(EVENT_SOCKET_CLOSE,[false,null]);
        }
        private function errorHandler(e:Object = null):void
        {
            Trace.log("<<<<==== socket 错误 errorHandler <<<<====",e);
            var restar:Boolean = false;
            if(Browser.window){
                restar = true;
            }
            this.event(EVENT_SOCKET_ERROR,[true,{msg:Tools.getMsgById("_lht56")},restar]);
        }
        //
        /**
		 * 等待接收服务器的包的字典。 下标是pid 不停的向上增长。接收方法名pid键值，内容是数组。数组每一项是pkg
		 */
		private var requestPkg : Object = {};
		/**
		 * 通过存储class的键值来找寻对应执行者的实现Inotify的接口 接收方法名string的键值，内容是数组。数组每一项是pkg
		 */
		private var notificationMap : Object = {};
 //————————————————————————————————————————————————以下是方法————————————————————————————————————————
		
		private function isSpecail(re:Object):Boolean
        {
            if(re["method"]== "close"){
                return true;
            }        
            return false;    
        }
		public function send(method:String, sendData:Object, handler:Handler = null, otherData:* = null):NetPackage {
			/**************************记录当前需要返回的包******************************/
            //
            sMethodName=method;
            sSendData=sendData;
            TestPackage.addPackage(method, sendData, true);
            this.checkRequestPkg();
            //
			var pkg:NetPackage = NetPackage.createPkg(0);
			pkg.sendMethod = method;
			pkg.sendData = sendData;
			pkg.otherData = otherData;
            pkg.sendTime = new Date().getTime();
            pkg.receiveHandler = handler;
            pkg.guideData = ModelGuide.checkNewPlayerGuideData(method);
			return sendPkg(pkg, handler);
		}
		
		
		/**
		 * 
		 * @param	pkg
		 * @param	handler
		 * @return
		 */
		private function sendPkg(pkg : NetPackage, handler:Handler = null):NetPackage {
			/**************************记录当前需要返回的包******************************/
			//放到requestPkg下面 进行存储 包括超过时长 也要检测。
            
            this.requestPkg[pkg.pid]=pkg;
            // trace("-----11111-----",pkg.pid,pkg.sendMethod);
            //
            if(this.mSocket && this.mSocket.connected){
                this.event(EVENT_SOCKET_SEND_TO,[pkg.sendMethod,true]);
                pkg.setTimeOut(NetSocket.timeOutTimer);
                this.mSocket.send(pkg.getSendDataJson());
            }
			return pkg;
		}
		public function selfSendPackageIsOver(pkg:NetPackage,isTimeout:Boolean):void{
            var method:String = "";
            if(pkg){
                // trace("-----2222222-----",pkg.pid,pkg.sendMethod);
                var pid:* = pkg.pid;
                method = pkg.sendMethod;
                pkg.clear();
                if(isTimeout){
                    this.removeRequest(pid,method);
                }
            } 
            this.event(EVENT_SOCKET_RECEIVE_FROM,[method,false, isTimeout]);       
        }
		private function recevie(obj:Object):void {
            if(obj == null){
                return;
            }
			var pkg:NetPackage = null;
            if(obj.hasOwnProperty("time")){
                ConfigServer.checkServerTime(Tools.getTimeStamp(obj["time"]), true);
            }
            var code:Number = -1;
            if(obj.hasOwnProperty("code")){
                code = Number(obj.code);
            }
			
			TestPackage.addPackage(obj.method, obj.data, false)
			
            var isMe:Boolean = false;
			if(obj["pid"]){
                var pid:Number = obj.pid;
                if(pid > 0) {
                    //从request里取。
                    pkg = this.requestPkg[pid];
                    if (pkg){
                        //
                        this.checkTimeoutPkg(pid,obj.method);
                        //
                        if(pkg.sendMethod == obj.method){
                            isMe = true;
                            pkg.receiveMethod = obj.method;
                            pkg.receiveData = obj.data;
                            pkg.reTime = new Date().getTime();
                            if(pkg.isTimeout(NetSocket.timeOutTimer)){
                                Trace.log("<<<<==== socket 超时",obj);
                            }
                            if(code == 0){//正常返回
                                pkg.notify();
                            }
                            else{
                                this.checkErrorCode(code,obj);
                            }
                        }
                        this.selfSendPackageIsOver(pkg,false);
                    }
                }
            }
            if (code == -1 || code == 0) {
				this.notifyOnlyListeners(obj);
			}
            //
            this.event(EVENT_SOCKET_RECEIVE_TO,[obj,isMe]);
            //这里要再次检查 requestPkg 里面有 死包，用发送时间和检查时间做 超时
		}
        private function checkErrorCode(code:Number,obj:Object):void
        {
            if(code == 1000){//数据配置有更新
                this.closeSocket({msg:Tools.getMsgById("msg_NetSocket_1")});
            }else if(code == 500){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("msg_NetSocket_2")+code);
            }else if(code >= 2000 && code <= 3000){//特殊错误
                this.closeSocket(obj.data);
            }
            else if(code == 0){
                
            }else{
                this.event(EVENT_SOCKET_RE_CODE_ERROR,obj);
            }
        }
        private function notifyOnlyListeners(obj:Object):void{
            var observers : Array = notificationMap[obj.method];
            var pkg:NetPackage = null;
            if (observers) {
                Trace.log("**** 服务器主动通知过来的消息 ***",obj.method,obj);
                if(obj.hasOwnProperty("code")){              
                    this.checkErrorCode(Number(obj.code),obj);
                }                
                for (var i:int = 0, len:int = observers.length; i < len; i++) {
                    pkg = (observers[i] as NetPackage);
                    pkg.receiveData = obj.data;
                    pkg.notify();
                    // pkg.clear();
                }
            }
        }
		
		private function checkRequestPkg():void{
            //var pkg:NetPackage = null;
            //for(var key:String in this.requestPkg)
            //{
                //pkg = this.requestPkg[key];
                //if(pkg.isDel(NetSocket.timeOutTimer)){
                    //this.removeRequest(key,pkg.sendMethod);
                    //pkg.clear();
                //}
            //}
        }
// ————————————————————————————————————————————————————接收 注册包————————————————————————————————————————————————————————————————

		
		
		/**
		 * 注册观察者， 这个一般用于长连接的时候， 后台主动发起的！ 如果是那种一来一回的话 就直接通过sendRequest发起即可。
		 * @param	type
		 * @param	handler
		 * @return
		 */
		public function registerHandler(type : String, handler : Handler) : Boolean {	
            if(hasRegisterHandler(type,handler)){return false}
            notificationMap[type] ||= [];
            var observers : Array = notificationMap[type];
            var pkg:NetPackage = NetPackage.createPkg();
            pkg.sendMethod = type;
            pkg.receiveMethod = type;
            pkg.receiveHandler = handler;
            observers.push(pkg);
			return true;
		}
		
		/**
		 * 注册观察者， 这个一般用于长连接的时候， 后台主动发起的！ 如果是那种一来一回的话 就直接通过sendRequest发起即可。
		 * @param	cls
		 * @param	handler
		 * @return
		 */
		public function removeAllHandler() : void {
			notificationMap = {};
		}
		
		public function hasRegisterHandler(type:String, handler : Handler,del:Boolean = false):Boolean {
			if (!notificationMap[type]) return false;
			// return notificationMap[cls].some(function(p:NetPackage, i:int, arr:Array):Boolean{return p.receiveHandler == handler});
            var arr:Array = notificationMap[type];
            var len:int = arr.length;
            var b:Boolean = false;
            var delIndex:int = -1;
            for(var index:int = 0; index < len; index++)
            {
               if(arr[index] == handler)
               {
                   b = true;
                   delIndex = index;
                   break;
               }
                
            }
            if(del && delIndex>=0){
                arr.splice(delIndex,1);
            }
            return b;
		}

		/**
		 * 移出对应 registerHandler注册的观察者。
		 * @param	cls
		 * @param	handler
		 * @return
		 */
		public function removeHandler(cls : String, handler : Handler) : Boolean {
			//找到对应的pkg 移除掉。

			return hasRegisterHandler(cls,handler,true);
		}
		
		/**
		 * 如果中途发送 想要取消的话 那么就调用此方法。 就可以移出了！
		 * @param	id
		 */
		public function removeRequest(id : *,method:String) : void {
            if(this.requestPkg.hasOwnProperty(id)){
                if(!this.timeoutPkg.hasOwnProperty(id)){
                    this.timeoutPkg[id] = [method];
                    Trace.log("---新的超时net包---",id,method,this.timeoutPkg);
                }
			    // delete this.requestPkg[id];
            }
		}  
        public function checkTimeoutPkg(id : *,method:String):void{
            if(this.timeoutPkg.hasOwnProperty(id)){
                this.timeoutPkg[id].push(method);
                Trace.log("---超时过的net包又返回了---",id,method,this.timeoutPkg);
            }
        }     
    }
}