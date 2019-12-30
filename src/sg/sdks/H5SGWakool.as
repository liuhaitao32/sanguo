package sg.sdks
{
    import laya.utils.Handler;
    import sg.net.NetHttp;
    import sg.net.NetMethodCfg;
    import sg.model.ModelSalePay;
    import sg.cfg.ConfigServer;
    import sg.manager.ModelManager;
    import sg.model.ModelUser;
    import sg.utils.Tools;
    import sg.utils.MD5;
    import sg.utils.ObjectUtil;
    import laya.utils.Browser;
    import sg.zmPlatform.ModelFocus;
    import sg.cfg.ConfigApp;

    public class H5SGWakool extends H5sdk {
        public function H5SGWakool(pf:String, params:Object) {
            super(pf, params)
        }

        override public function login(handler:Handler):void {
            this.user = ModelManager.instance.modelUser;

            sdk.login(function (result:*):void {
                if (result) {
                    result.login_key = params.login_key;
                    result.app_id = params.app_id;
                    result.user_id = params.user_id;
                    result.sign = params.sign;

                    handler && handler.runWith([0, result]);
                } else {
                    console.log('Login failed')
                }
            });
        }
        
        override public function pay(orderId:String, payObj:Object, serverName:String):void {
            var product_id:String = ConfigServer.system_simple.pay[ConfigApp.pf][payObj.pid];
            sdk.purchase(product_id, user.zone, user.mUID, orderId);

            var TDGA:* = Browser.window.TDGA;
            TDGA.onChargeRequest({
                orderId: orderId,
                iapId : Tools.getMsgById("coin_name"),
                currencyAmount : ConfigServer.system_simple.pay_money[ConfigApp.pf][payObj.pid],
                currencyType : 'TWD',
                virtualCurrencyAmount : 1,
                paymentType : 'Pay'
            });
        }

        override public function log(type:int, serverName:String = ''):void {
            var TDGA:* = Browser.window.TDGA;
            TDGA.Account({
                accountId : user.mUID,
                level : user.getLv(),
                gameServer : serverName,
                accountName : user.uname
            });
        }
    }
}