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

    public class H5SGMengyou extends H5sdk {
        public function H5SGMengyou(pf:String, params:Object) {
            super(pf, params)
        }

        override public function login(handler:Handler):void {
            sdk.init();
            handler && handler.runWith([0, params]);
            this.user = ModelManager.instance.modelUser;
        }

        override public function pay(orderId:String, payObj:Object, serverName:String):void {
            var payData:Object = {
                dsn: orderId,
                dsid: user.zone,
                dsname: serverName,
                drid: user.mUID,
                drname: user.uname,
                drlevel: user.getLv(),
                money: payObj.cfg[0] * 100,
                dext: orderId,
                time: Math.floor(ConfigServer.getServerTimer() * 0.001)
            };
            var data:Object = {
                dsn: payData.dsn,
                dsid: payData.dsid,
                dsname: payData.dsname,
                money: payData.money,
                dext: payData.dext,
                drid: payData.drid,                
                time: payData.time
            };
            NetHttp.instance.send("user_zone.get_h5_mengyou_sign", data, Handler.create(this, function(re:*):void {
                payData.sign = re.sign;
                sdk.pay(payData, function (re1:*):void{
                    console.log(re1);
                });
            }));
        }

        override public function log(type:int, serverName:String = ''):void {
            var data:Object = {
                dsn: user.zone,
                dsname: ConfigServer.zone[user.zone][0],
                drid: user.mUID,
                drname: user.uname,
                drlevel: user.getLv(),
                drbalance: user.coin,
                drvip: "1",
                dparty: "",         //公会。玩家自己创建(必传)
                dext: ""
            };

            if(user.country === 0){
                data.dcountry = "魏";
            }else if(user.country === 1){
                data.dcountry = "蜀";
            }else if(user.country === 2){
                data.dcountry = "吴";
            }

            if(type === 0){
                data.eid = 31;
                sdk.event(data);
            }else if(type === 1){
                data.eid = 32;
                sdk.event(data);
            }else if(type === 2){
                data.eid = 35;
                sdk.event(data);
            }
        }
    }
}