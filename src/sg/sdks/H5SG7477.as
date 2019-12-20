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

    public class H5SG7477 extends H5sdk {
        public function H5SG7477(pf:String, params:Object) {
            super(pf, params)
        }

        override public function login(handler:Handler):void {
            var data:Object = ObjectUtil.clone(params);
            // delete data.sign;
            handler && handler.runWith([0, data]);
            this.user = ModelManager.instance.modelUser;
        }

        override public function pay(orderId:String, payObj:Object, serverName:String):void {
            var data:Object = {
                uid: params.uid,
                username: params.username,
                paymoney: payObj.cfg[0] + "",
                appid: params.appid,
                serverid: params.serverid,
                platform: params.platform,
                time: params.time,
                out_orderid: orderId
            };

            var reqData:Object = {
                sign_type: "order",
                data: data
            };

            NetHttp.instance.send(NetMethodCfg.HTTP_USER_SG_7477_SIGN, reqData, Handler.create(this, function(re:*):void {
                var payData:Object = {
                    uid: data.uid,
                    username: data.username,
                    paymoney: data.paymoney,
                    appid: data.appid,
                    serverid: data.serverid,
                    platform: data.platform,
                    time: data.time,
                    out_orderid: data.out_orderid,
                    sign: re.sign,
                    goods_name: encodeURI("黄金"),
                    param: orderId
                };

                var baseURL:String = 'http://m.7477.com/wap/pay?';
                var URL:String = baseURL + Platform.sortObjkeyToString(payData);
                Browser.window.tc_iframe(URL);
            }));
        }

        override public function log(type:int, serverName:String = ''):void {
            if (type === 2) {
                var data:Object = {
                    appid: params.appid,
                    level: user.getLv(),
                    platform: params.platform,
                    time: params.time,
                    uid: params.uid,
                    username: params.username
                };

                var reqData:Object = {
                    sign_type: "update_role",
                    data: data
                };

                NetHttp.instance.send(NetMethodCfg.HTTP_USER_SG_7477_SIGN, reqData, Handler.create(this, function(re:*):void {
                    var logData:Object = {
                        uid: data.uid,
                        username: data.username,
                        role: user.uname,
                        platform: data.platform,
                        appid: data.appid,
                        sid: user.zone,
                        level: data.level,
                        time: data.time,
                        sign: re.sign
                    };
                    var baseURL:String = 'http://m.7477.com/wap/openapi/update_role?';
                    console.log(baseURL + Platform.sortObjkeyToString(logData));
                    baseURL && NetHttp.instance.getRequest(baseURL + Platform.sortObjkeyToString(logData), Handler.create(null, function(re:*):void {
                        console.log(re);
                    }));
                }));
            }
        }
    }
}