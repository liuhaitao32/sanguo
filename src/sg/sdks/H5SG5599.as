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

    public class H5SG5599 extends H5sdk {
        public function H5SG5599(pf:String, params:Object) {
            super(pf, params)
        }

        override public function login(handler:Handler):void {
            this.user = ModelManager.instance.modelUser;
            
            var data:Object = {
                r_token: params["r_token"]
            };

            NetHttp.instance.send('user_zone.get_jj_access_token', data, Handler.create(this, function(re:*):void {
                params.access_token = re.access_token,
                
                sdk.init({
                    login_type_5599:params["login_type_5599"],
                    AppID:'100051',
                    a_token:params.access_token
                });

                handler && handler.runWith([0, params]);
            }));
        }

        override public function pay(orderId:String, payObj:Object, serverName:String):void {
            var data:Object = {
                AppID:100051,
                AppOrder:orderId,
                AppReqTime:Math.floor(ConfigServer.getServerTimer() * 0.001),
                GoodsID:ConfigServer.system_simple.pay[ConfigApp.pf][payObj.pid],
                GoodsAmount:1,
                MoneyAmount:payObj.cfg[0] * 100
            };

            NetHttp.instance.send("user_zone.get_h5_5599_order_sign", data, Handler.create(this, function(re:*):void {
                var payData:Object = {
                    uid:user.accountId,
                    a_token:params.access_token,
                    gkey:params.gkey,
                    skey:user.zone,
                    AppID:data.AppID,
                    AppOrder:data.AppOrder,
                    AppReqTime:data.AppReqTime,
                    GoodsID:data.GoodsID,
                    GoodsAmount:data.GoodsAmount,
                    MoneyAmount:data.MoneyAmount,
                    AppOrderSign:re.sign,
                    AppExtendData:orderId
                };
                sdk.getPayMethod(payData);
            }));
        }
    }
}