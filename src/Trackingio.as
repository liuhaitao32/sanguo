package
{
    import laya.utils.Browser;
    import sg.cfg.ConfigApp;
    import sg.net.NetHttp;
    import laya.utils.Handler;
    import sg.utils.SaveLocal;

    public class Trackingio
    {
        public static var mTrackingIO:Object;
        public static var orderData:Object = {};
        public function Trackingio()
        {
            
        }
        // public static function func(method:Number,id:String,obj:* = null,other:* = null):void{
        //     Trace.log("==>>Trackingio func==>>>",method,id,obj,other);
        //     if(ConfigApp.pf != ConfigApp.PF_ios_meng52_mjm1){
        //         return;
        //     }
            // return;
            // if(!mTrackingIO && Browser.window.getTrackingIO){
            //     mTrackingIO = Browser.window.getTrackingIO();
            // }
            // if(!mTrackingIO){
            //     return;
            // }
            // if(method == 1){
            //     mTrackingIO.init("862754bec8ffdb539c47cd16b05110df");
            // }
            // else if(method == 2){
            //     mTrackingIO.register(id);
            // }
            // else if(method == 3){
            //     mTrackingIO.loggedin(id);
            // }
            // else if(method == 4){
            //     // var orderId:String = obj.pid+"|"+obj.zone+"|"+obj.uid+"|"+ConfigServer.getServerTimer();
            //     // orderData[orderId] = obj
            //     mTrackingIO.order(id);
            // }
            // else if(method == 5){
            //     var arr:Array = obj.pay_ids?obj.pay_ids:[0];
			// 	var pt:String = (Trackingio.orderData && Trackingio.orderData.wx_pay)?"weixinpay":"alipay";
            //     // {"amoun":money,"type":"CNY","payType":pt}
            //     mTrackingIO.payment(arr[arr.length-1],other,"CNY",pt);
            // }  
            // else if(method == 6){
            //     mTrackingIO.download(obj);
            // }          
        // }
        public static function postReport(type:Number,sd:Object=null):void{
            if(
                ConfigApp.pf == ConfigApp.PF_ios_meng52_mjm1 || 
                ConfigApp.pf == ConfigApp.PF_ios_jj_cn_mj1 || 
                ConfigApp.pf == ConfigApp.PF_ios_jj_cn || 
                ConfigApp.pf == ConfigApp.PF_and_jj_meng52
            ){
            
                var appKeys:Object = {};
                appKeys[ConfigApp.PF_ios_meng52_mjm1] = "d840eb9a6018b070b4a423cd3abe4dd6";
                appKeys[ConfigApp.PF_ios_jj_cn_mj1] = "2d40c1b970ebc41785911699ba511b39";
                appKeys[ConfigApp.PF_ios_jj_cn] = "92cef84ad74ada100a175d6e6d1c719f";
                appKeys[ConfigApp.PF_and_jj_meng52] = "aa4c9bc2983ab0ac968e7b825f4b7831";
                var method:String = "";
                var param:Object = {};
                var idfa:String = ConfigApp.midfa?ConfigApp.midfa:(ConfigApp.mdevice?ConfigApp.mdevice:"");
                var ip:String = Browser.window.gameuserzoneip?Browser.window.gameuserzoneip:"0.0.0.0";
                var ipv6:String = "00000000-0000-0000-0000-000000000000";
                var tz:String = "+8";
                var data:Object = {"appid":appKeys[ConfigApp.pf],"context":param};
                var osType:String = "iphone";
                if(type==2){
                    var isInstall:* = SaveLocal.getValue(SaveLocal.KEY_INSTALL_REPORT);
                    if(isInstall && isInstall!=""){
                        method = "/receive/tkio/startup";
                        param["_deviceid"] = idfa;
                        param["_idfa"] = idfa;
                        param["_ip"] = ip;
                        param["_ipv6"] = ipv6;
                        param["_tz"] = tz;
                    }
                    else{
                        SaveLocal.save(SaveLocal.KEY_INSTALL_REPORT,idfa);
                        method = "/receive/tkio/install";
                        param["_campaignid"] = "_default_";
                        param["_deviceid"] = idfa;
                        param["_idfa"] = idfa;
                        param["_ip"] = ip;
                        param["_ipv6"] = ipv6;
                        param["_tz"] = tz;
                        param["_manufacturer"] = "iphone";
                        param["_rydevicetype"] = "iphone";
                        param["_network"] = "WIFI";
                        param["_resolution"] = "";
                        param["_op"] = "";
                    }
                }
                else if(type==3){
                    method = "/receive/tkio/register";
                    param["_deviceid"] = idfa;
                    param["_idfa"] = idfa;
                    param["_ip"] = ip;
                    param["_ipv6"] = ipv6;
                    param["_tz"] = tz;
                    param["_rydevicetype"] = osType;
                    // 
                    data["who"] = sd.uid;
                }
                else if(type==4){
                    method = "/receive/tkio/loggedin";
                    param["_deviceid"] = idfa;
                    param["_idfa"] = idfa;
                    param["_ip"] = ip;
                    param["_ipv6"] = ipv6;
                    param["_tz"] = tz;
                    // 
                    data["who"] = sd.uid;
                }
                else if(type==5){
                    method = "/receive/tkio/payment";
                    param["_deviceid"] = idfa;
                    param["_idfa"] = idfa;
                    param["_ip"] = ip;
                    param["_ipv6"] = ipv6;
                    param["_tz"] = tz;
                    param["_rydevicetype"] = osType;
                    // 
                    var arr:Array = sd.pay_ids?sd.pay_ids:[0];
                    var pt:String = (Trackingio.orderData && Trackingio.orderData.wx_pay)?"weixinpay":"alipay";
                    param["_transactionid"] = arr[arr.length-1];
                    param["_paymenttype"] = pt;
                    param["_currencytype"] = "CNY";
                    param["_currencyamount"] = Number(sd.money);
                    // 
                    data["who"] = sd.uid;
                }
                if((ConfigApp.pf == ConfigApp.PF_and_jj_meng52) && param){//ConfigApp.pf == ConfigApp.PF_ios_jj_cn || 
                    
                    if(type==3){
                        param["reyunType"] = "0";
                    }
                    else if(type==4){
                        param["reyunType"] = "1";
                    }
                    else if(type==5){
                        param["reyunType"] = "5";
                        param["_paymenttype"] = "iospay";
                    }
                    else{
                        param = null;
                    }
                    if(param && data.who){
                        param["uid"] = data.who;
                        if(ConfigApp.pf == ConfigApp.PF_and_jj_meng52){
                            ToJava.callMethod("trackingInfo",param,null);
                        }
                        else{
                            ToIOS.callFunc("trackingInfo",null,param);
                        }
                    }
                }
                else{
                    NetHttp.instance.postOther(method,data,Handler.create(null,function(re:*):void{
                        // trace(re);
                    }));
                }
            }
        }
    }
}