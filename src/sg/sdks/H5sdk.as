package sg.sdks
{
	import laya.utils.Handler;
	import sg.model.ModelUser;
	import laya.utils.Browser;
	import sg.cfg.ConfigServer;

	/**
	 * H5sdk H5 SDK的基类，其方法用于处理登录，支付数据上报等逻辑。
	 * @author jiaxuyang
	 */
    public class H5sdk {
        private var _sdk:Object = null;         // 平台SDK
        protected var pf:String = '';           // 浏览器查询参数
        protected var params:Object = null;     // 浏览器查询参数
        protected var userInfo:Object = null;   // 平台用户数据
        public var haveLogin:Boolean = true;    // SDK有自己的登录
        protected var user:ModelUser = null;    // 用户数据
        public function H5sdk(pf:String, params:Object) {
            this.pf = pf;
            this.params = params;
        }

        protected function get sdk():Object {
            _sdk === null && (_sdk = Browser.window.initSDK());
            return _sdk;
        }

        /**
         * 登录
         */
        public function login(handler:Handler):void {
            handler && handler.runWith([0, params]);
        }

        /**
         * 支付
         */
        public function pay(orderId:String, payObj:Object, serverName:String):void {}

        /**
         * 数据上报
		 * @param	type 
         *     1000: choose_country 选服
         *     0: choose_country 	创角 (首次选服时触发)
         *     1: enter_game		进入游戏 
         *     2: building_lv_up	升级 
         *     3: change_uname		改名 
         *     4: change_coin		黄金数量变化 
         *     5: get_coin			获得黄金
		 * @param	serverName  区服名 
         */
        public function log(type:int, serverName:String = ''):void {}

        /**
         * 是否开启分享
         */
        public function get shareOpen():Boolean {
            return false;
        }

        /**
         * 获取分享数据
         */
        public function get shareData():Array {
            return ConfigServer.system_simple.share_pf[pf];
        }

        /**
         * 分享
         */
        public function share():void {}

        /**
         * 分享成功回调
         */
        public function shareSuccessCB(re:*):void {
            Platform.eventListener.event(Platform.EVENT_SHARE_OK);
        }

        /**
         * 分享失败回调
         */
        public function shareFailCB(re:*):void {
            console.log(re);
        }

        /**
         * 是否支持关注功能
         */
        public function get focusSupport():Boolean {
            return false;
        }

        /**
         * 是否已关注
         */
        public function get focused():Boolean {
            return false;
        }

        /**
         * 关注
         */
        public function focus():void {}

        /**
         * 实名认证
         */
        public function verify():void {}

        /**
         * 是否支持切换账号
         */
        public function get switchSupport():Boolean {
            return false;
        }

        /**
         * 切换账号
         */
        public function switchAccount():void {}
    }
}