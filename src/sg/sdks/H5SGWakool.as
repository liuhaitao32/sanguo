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
    import laya.debug.tools.JsonTool;

    public class H5SGWakool extends H5sdk {
        private var _currency_amount:String = "";           //支付回调所需参数 

        public function H5SGWakool(pf:String, params:Object) {
            super(pf, params)
        }

        override public function login(handler:Handler):void {
            this.user = ModelManager.instance.modelUser;

            sdk.addEventListener(sdk.EVENT_BROWSER_PURCHASE_VERIFY_VALID, function (event:*):void {
                Browser.window.fbq('track', 'Purchase', {value:_currency_amount, currency:'TWD'});
                Browser.window.TDGA.onChargeSuccess(Browser.window.TDGA.info);
            })
            
            sdk.addEventListener(sdk.EVENT_BROWSER_PURCHASE_VERIFY_INVALID, function (event:*):void {})

            sdk.login(function (result:*):void {
                if (result) {
                    if(pf == ConfigApp.PF_wakool_h5){
                        result.login_key = params.login_key;
                        result.app_id = params.app_id;
                        result.user_id = params.user_id;
                        result.sign = params.sign;
                    }
                    
                    handler && handler.runWith([0, result]);
                } else {
                    console.log('Login failed')
                }
            });
        }
        
        override public function pay(orderId:String, payObj:Object, serverName:String):void {
            var product_id:String = ConfigServer.system_simple.pay[ConfigApp.pf][payObj.pid];
            var currency_amount:String = ConfigServer.system_simple.pay_money[ConfigApp.pf][payObj.pid];
            var payParams:Object = {
                orderId: orderId,
                currency_amount: currency_amount
            };
            _currency_amount = currency_amount;
            sdk.purchase(product_id, user.zone, user.mUID, JSON.stringify(payParams));

            Browser.window.TDGA.onChargeRequest({
                orderId: orderId,
                iapId : Tools.getMsgById("coin_name"),
                currencyAmount : currency_amount,
                currencyType : 'TWD',
                virtualCurrencyAmount : 1,
                paymentType : 'Pay'
            });
        }

        override public function log(type:int, serverName:String = ''):void {
            if(type===0){
                Browser.window.fbq('track', 'CompleteRegistration');
            }

            Browser.window.TDGA.Account({
                accountId : user.mUID,
                level : user.getLv(),
                gameServer : serverName,
                accountName : user.uname
            });
        }
    }
}