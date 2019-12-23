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

    public class H5SGWende extends H5sdk {
        public function H5SGWende(pf:String, params:Object) {
            super(pf, params)
        }

        override public function login(handler:Handler):void {
            this.user = ModelManager.instance.modelUser;

            sdk.init({
                user_id: params["user_id"],
                channel: params["channel"],
                game_id: params["game_id"],
                game_name: params["game_name"],
                userAccount: params["userAccount"],
                app_id: params["app_id"]
            });

            handler && handler.runWith([0, params]);
        }

        override public function pay(orderId:String, payObj:Object, serverName:String):void {
            var payData:Object = {
                "user_id":params["user_id"],
                "userAccount":params["userAccount"],
                "app_id":params["app_id"],
                "game_id":params["game_id"],
                "game_name":params["game_name"],
                "sdk_edition":'6',
                "sdk_version":2,
                "title":ConfigServer.system_simple.pay[ConfigApp.pf][payObj.pid] + "_" + params["game_name"],
                "body":Tools.getMsgById("coin_name"),
                "server_name":serverName,
                "game_player_id":user.mUID,
                "game_player_name":user.uname,
                "is_uc":'0',
                "ios_version":1,
                "price":payObj.cfg[0],
                "extend":orderId,
                "code":1
            };

            var data:Object = {
                "userAccount": payData.userAccount,
                "body": payData.body,
                "code": payData.code,
                "extend": payData.extend,
                "game_appid":payData.app_id,
                "game_id":payData.game_id,
                "game_name":payData.game_name,
                "game_player_id":payData.game_player_id,
                "game_player_name":payData.game_player_name,
                "ios_version":payData.ios_version,
                "is_uc":payData.is_uc,
                "price":payData.price,
                "sdk_edition":payData.sdk_edition,
                "sdk_version":payData.sdk_version,
                "server_name":payData.server_name,
                "title":payData.title,
                "user_id":payData.user_id,
                "access_token": params.access_token
            };

            NetHttp.instance.send(NetMethodCfg.HTTP_USER_SG_WENDE_PAY, data, Handler.create(this, function(re:*):void {
                payData.sign = re.sign;

                sdk.pay(payData, function (code:*, msg:*):void {
                    alert("支付 code="+code+",msg="+msg);        
                });
            }));
        }

        override public function log(type:int, serverName:String = ''):void {
            if (type === 1000) {
                var serverData:Object = {
                    "user_id":params["user_id"],
                    "server_id":user.zone,
                    "server_name":serverName
                    };
                    
                sdk.selectServer(serverData);
            } else if (type === 0) {
                var roleData:Object = {
                    "user_id":params["user_id"],
                    "server_id":user.zone,
                    "server_name":serverName,
                    "role_id":user.mUID,
                    "role_name":user.uname
                };
                sdk.createRole(roleData);
            }
        }
    }
}