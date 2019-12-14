package sg.zmPlatform
{
    import laya.utils.Browser;
    import sg.cfg.ConfigApp;
    import sg.utils.StringUtil;
    import sg.net.NetHttp;
    import sg.model.ModelUser;
    import sg.manager.ModelManager;
    import laya.utils.Handler;
    import sg.activities.model.ModelPhone;

    public class ConstantZM {
		public static const PLAT_IWEIYOU:String	= 'sy_311';     // 速易 爱微游
		public static const PLAT_CRAZY:String	= 'sy_10213';   // 速易 疯狂

		public static var platform:String = ''; // 属于速易的哪个平台
		public static var sdkURL:Object = {};   // 平台sdk地址
		public static var sdk:Object = null;    // 平台sdk
		public static var userInfo:Object = null;   // 用户数据
		public static var params:Object = null;     // 透传参数

        /**
         * 初始化360具体渠道的sdk
         */
		public static function initPlatform(data:Object):void {
            sdkURL[PLAT_CRAZY] = 'https://cdn.hortor.net/sdk/sdk_agent.min.js';
            sdkURL[PLAT_IWEIYOU] = 'https://cdn.11h5.com/static/js/sdk.min.js';
            // console.log(data);
            userInfo = data.userInfo;
            params = data.params;
            if (ConfigApp.pf === ConfigApp.PF_360_2_h5) { // 阿拉丁
                platform = 'ald_' + params.achannel;
            } else if (ConfigApp.pf === ConfigApp.PF_360_3_h5 && userInfo.common) { // 速易
                platform = 'sy_' + userInfo.common.sdkindx;
                sdkURL[platform] && Browser.window.loadPlatformSDKFile(sdkURL[platform], initSDKCB());
            }

            // 初始化认证、关注等数据
            if (params.verify === '1') {
                ModelVerify.instance.verified = 1;
            }
            if (params.focus === '1' || params.isSubscribe === 'true' || (userInfo.userdata && userInfo.userdata.isSubscribe === 'true')) {
                ModelFocus.instance.focused = 1;
            }
        }

        /**
         * 初始化SDK的回调
         */
		public static function initSDKCB():void {
            switch(platform) {
                case PLAT_IWEIYOU:
                    sdk = Browser.window['AWY_SDK'];
                    break;
                case PLAT_CRAZY:
                    sdk = Browser.window['HORTOR_AGENT'];
                    initCrazySDK();
                    break;
            }
            if (Platform.h5_sdk_obj.isSupportMethod('isbindPhone')) {
                Platform.h5_sdk_obj.isbindPhone(function(data:Object):void {
                    ModelPhone.instance.binded = data.retcode === '0' ? 1 : 0;
                });
            }
        }

        /**
         * 需要服务端签名的创角上报
         */
		public static function reportCreateRole():void {
            var user:ModelUser = ModelManager.instance.modelUser;
            switch(platform) {
                case PLAT_IWEIYOU:
                    NetHttp.instance.send('user_zone.get_awy_bi_url', {uid: user.mUID}, Handler.create(null, function(url:*):void{
                        NetHttp.instance.getRequest(url, Handler.create(null, function(re:*):void {
                            // console.log(re);
                        }));
                    }));
                    break;
                case PLAT_CRAZY:
                    NetHttp.instance.send('user_zone.get_fengkuang_bi_url', {uid: user.mUID}, Handler.create(null, function(data:*):void{
                        NetHttp.instance.postRequest('https://wxstat.hortor.net/gc/game/player/create', StringUtil.substitute('gameId={0}&openId={1}&playerName={2}&serverId={3}&sign={4}&time={5}', [
                            data.gameId,
                            data.openId,
                            data.playerName,
                            data.serverId,
                            data.sign,
                            data.time
                        ]));
                    }));
                    break;
            }
        }

        /**
         * 初始化疯狂SDK
         */
		public static function initCrazySDK():void {

            // 检查实名认证情况
            sdk.realnameAuthentication(function(origin:String, data:Object):void {
                ModelVerify.instance.verified  = data.errCode === 0 ? 1 : 0;
            });
        }
    }
}