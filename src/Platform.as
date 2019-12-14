package
{
    import laya.utils.Browser;
    import sg.cfg.ConfigApp;
    import laya.renders.Render;
    import laya.wx.mini.MiniAdpter;
    import laya.utils.Handler;
    import sg.net.NetHttp;
    import sg.net.NetMethodCfg;
    import laya.net.URL;
    import sg.cfg.ConfigServer;
    import sg.utils.Tools;
    import sg.manager.AssetsManager;
    import sg.utils.MusicManager;
    import sg.manager.ModelManager;
    import sg.model.ModelGame;
    import laya.events.EventDispatcher;
    import sg.manager.ViewManager;
    import sg.model.ModelUser;
    import sg.utils.StringUtil;
    import sg.utils.ThirdRecording;
    import sg.utils.SaveLocal;
    import sg.model.ModelPlayer;
    import sg.model.ModelSalePay;
    import sg.net.NetSocket;
    import sg.zmPlatform.ConstantZM;
    import laya.qq.mini.QQMiniAdapter;
    import sg.model.ModelPf;
    import sg.view.map.ViewCountryInvadeMain;
    import laya.events.MouseManager;
    import sg.cfg.HelpConfig;
    import sg.utils.MD5;
    import sg.manager.FilterManager;
    import sg.utils.ObjectUtil;
    import sg.sdks.H5sdk;

    public class Platform
    {
        public static const EVENT_SHARE_OK:String = "event_share_ok";
        //
        public static var eventListener:EventDispatcher = new EventDispatcher();
        //
        public static var pf_login_data:Object;
        public static var login_type:String = "";
        public static var recodrd_pay_info:Array;
        public static var phoneID:String = "";   
        public static var appName:String = ""; 
        public static var phoneInfoOnCheck:Boolean = false;
        public static var share_wx_and_qq:Boolean = false;
        public static var h5_sdk_obj:Object = null;//h5 统一接口类(平台)
        public static var h5_sdk_url_data:Object = null;
        public static const TAG_LOGIN_TYPE_MENG52:String = "meng52";//特殊游客登录
        public static const TAG_LOGIN_TYPE_TUP:String = "meng52_temp_user_pwd";//本地缓存登录
        public static var pay_list_info:Object = null;
        public static var h5_sdk:H5sdk = null;//h5 统一接口类（自己）
        public function Platform()
        {
        }
        public static function getUserDataForIos(callback:Handler):void{
            if(ConfigApp.pf == ConfigApp.PF_ios_jj_cn){
                ToIOS.callFunc("getUserData",function(re:*):void{
                    // ToIOS.callFunc("logto",null,{logto:re})
                        callback && callback.runWith(re);
                    },{"userStandard":SaveLocal.KEY_USER_LIST})
            }
            else if(ConfigApp.pf == ConfigApp.PF_and_jj_meng52){
                ToJava.callMethod("getUserData",{"userStandard":SaveLocal.KEY_USER_LIST},callback);
            }
        }
        public static function setUserDataForIos(data:Object,callback:Handler = null):void{
            if(ConfigApp.pf == ConfigApp.PF_ios_jj_cn){
                ToIOS.callFunc("setUserData",function(re:*):void{
                        callback && callback.runWith(re);
                    },{"userStandard":SaveLocal.KEY_USER_LIST,"userStandardData":encodeURI(JSON.stringify(data))});
            }
            else if(ConfigApp.pf == ConfigApp.PF_and_jj_meng52){
                ToJava.callMethod("setUserData",{"userStandard":SaveLocal.KEY_USER_LIST,"userStandardData":encodeURI(JSON.stringify(data))},callback);
            }
        }
        public static function force_update():void{
            // trace("force_update"+ConfigApp.pf_channel);
            var cfg:Object = ConfigApp.getNetCfgOther(ConfigApp.pf_channel);
            if(cfg){
                if(ConfigApp.onAndroid()){
                    ToJava.callMethod("force_update_check",null,Handler.create(null,function(re:*,method:*):void{
                        Platform.force_update_link(cfg,re);
                    }));
                }
                else if(ConfigApp.onIOS()){
                    ToIOS.callFunc("force_update_check",function(re:*):void{
                        Platform.force_update_link(cfg,re);
                    },{});
                }
            }
        }
        public static function force_update_link(cfg:Object,re:*):void{
            var thisPackageVersion:String = re;
            var checkArr:Array = cfg["check"];
            var isUpdate:Boolean = false;
            if(!Tools.isNullString(thisPackageVersion) && checkArr){
                var len:int = checkArr.length;
                for(var i:int = 0; i < len; i++)
                {
                    if((checkArr[i]+"") == thisPackageVersion){
                        isUpdate = true;
                        break;
                    }
                }
            }
            if(isUpdate){
                var params:Object = {title:"更新提示",msg:"請您更新下載最新版",btn_ok:"更新",url:cfg["url"]};
                if(ConfigApp.onIOS()){
                    ToIOS.callFunc("force_update_link",function(re:*):void{
                    },params);
                }
                else if(ConfigApp.onAndroid()){
                    ToJava.callMethod("force_update_link",params,Handler.create(null,function(re:*,method:*):void{
                        Platform.force_update_link(cfg,re);
                    }));
                }
            }
        }            
        public static function initMiniGame():void {
            if (ConfigApp.releaseQQ()) {
                QQMiniAdapter.window.qq.onShow(function(res:Object):void{
                    MusicManager.miniGameShow();
                }); 
            }
            else if(ConfigApp.releaseWeiXin()){
                // MiniAdpter.window.wx.onShow(function(res:Object):void{
                //     // trace("wx.onShow",res);
                //     MusicManager.wxShow();
                // });     
                if(ConfigApp.pf == ConfigApp.PF_wx_changxiang){
                    MiniAdpter.window.qingjs.instance.onInit(function (initResult:*):void {
                        // initResult.code  // 200 为成功，其他则失败
                        // initResult.message  // 初始化结果描述
                        // trace("初始化结束回调数据");
                        // trace(initResult);
                    });
                }       
            }
        }  
        /**
         * 初始化分享,特殊平台才使用
         */
        public static function initShare():void{
            var share_cfg:Object = null;
            if (ConfigApp.releaseQQ()) {
                share_cfg = ConfigServer.system_simple['qq_share'];
                QQMiniAdapter.window.qq.showShareMenu({});
                QQMiniAdapter.window.qq.onShareAppMessage(function():Object{
                    return {title: Tools.getMsgById(share_cfg.title), imageUrl:share_cfg.imageUrl};
                });
            }
            else if(ConfigApp.releaseWeiXin()){
                share_cfg = ConfigServer.system_simple['wx_share'];
                if(ConfigApp.pf == ConfigApp.PF_wx_changxiang){
                    MiniAdpter.window.wx.onShareAppMessage(function():* {      
                        return {
                            "title":Tools.getMsgById(share_cfg.title),
                            "imageUrl":share_cfg.imageUrl,            
                            "query":MiniAdpter.window.qingjs.instance.getsharetoken(),            
                            "success":function(res:*):void {    
                                Platform.eventListener.event(Platform.EVENT_SHARE_OK);       
                            },
                            "fail": function(res:*):void {  
                            }
                        };
                    });
                }
                else{
                    // if(Browser.onMiniGame){
                    //     MiniAdpter.window.wx.showShareMenu({});
                    //     share_cfg = ConfigServer.system_simple['wx_share'];
                    //     MiniAdpter.window.wx.onShareAppMessage(function(res:Object):Object{
                    //         return {title:Tools.getMsgById(share_cfg.title),imageUrl:URL.formatURL(AssetsManager.getAssetsAD(share_cfg.imageUrl))};
                    //     });
                    // }
                }
            }

        }
        /**
         * 是否是最新分享功能
         */
        public static function shareFunCheck():void{
            Platform.share_wx_and_qq = false;
            if(ConfigApp.pf == ConfigApp.PF_and_1){
                ToJava.callMethod("isNewShare","",Handler.create(null,function(re:*,method:*):void{
                    Platform.share_wx_and_qq = true;
                }));
            }
        }
        /**
         * type = 0 朋友圈,
         */
        public static function share_on_off():Boolean{
            if (h5_sdk) {
                return h5_sdk.shareOpen;
            } else if(ConfigApp.pf == ConfigApp.PF_37_h5){
                return Platform.pf_login_data["shared_switch"];
            } else if (ConfigApp.pf === ConfigApp.PF_360_3_h5) {
                return Platform.h5_sdk_obj.isSupportMethod('share'); // 我们没有自己的分享 所以不判断setShareInfo
            }
            return true;
        }
        public static function share(type:Number = 0):void{
            var share_cfg:Object = null;
            if (h5_sdk) {
                h5_sdk.share();
            } else if(ConfigApp.releaseWeiXin()){
                share_cfg = ConfigServer.system_simple['wx_share'];
                MiniAdpter.window.wx.shareAppMessage({title:Tools.getMsgById(share_cfg.title),imageUrl:share_cfg.imageUrl});
                // Platform.eventListener.event(Platform.EVENT_SHARE_OK);
                // if(ConfigApp.pf == ConfigApp.PF_wx_changxiang){
                //     MiniAdpter.window.wx.onShareAppMessage(function():* {      
                //         return {
                //             "title":Tools.getMsgById(share_cfg.title),
                //             "imageUrl":URL.formatURL(share_cfg.imageUrl),            
                //             "query":MiniAdpter.window.qingjs.instance.getsharetoken(),            
                //             "success":function(res:*):void {    
                //                 Platform.eventListener.event(Platform.EVENT_SHARE_OK);       
                //             },
                //             "fail": function(res:*):void {  
                //             }
                //         };
                //     });
                // }
            } else if (ConfigApp.releaseQQ()) {
                share_cfg = ConfigServer.system_simple['qq_share'];
                QQMiniAdapter.window.qq.shareAppMessage({title:Tools.getMsgById(share_cfg.title),imageUrl:share_cfg.imageUrl});
                Platform.eventListener.event(Platform.EVENT_SHARE_OK);
            } else {
                var share_pf:Object = ConfigServer.system_simple.share_pf;
                var cfgArr:Array = share_pf[ConfigApp.pf];
                var sarr:Array = [];
                var sData:Object = {};
                sarr.push(Tools.getMsgById(cfgArr[0]));
                sarr.push(Tools.getMsgById(cfgArr[1]));
                sarr.push(cfgArr[2]);
                sarr.push(cfgArr[3]);
                sarr.push(type);
                //
                sData["linkURL"] = cfgArr[3];
                sData["imgURL"] = cfgArr[2];
                sData["title"] = Tools.getMsgById(cfgArr[0]);
                sData["des"] = Tools.getMsgById(cfgArr[1]);
                //
                if(ConfigApp.pf == ConfigApp.PF_and_1){
                    if(cfgArr){
                        ToJava.callMethod("share",sarr,Handler.create(null,function(re:*,method:*):void{
                            Platform.eventListener.event(Platform.EVENT_SHARE_OK);
                        }));
                    }
                } 
                // else if(ConfigApp.pf == ConfigApp.PF_efun_google){
                //     if(cfgArr){
                //         ToJava.callMethod("share",sData,Handler.create(null,function(re:*,method:*):void{
                //             Platform.eventListener.event(Platform.EVENT_SHARE_OK);
                //         }));
                //     }
                // } 
                else if(ConfigApp.pf == ConfigApp.PF_and_google){
                    if(cfgArr){
                        ToJava.callMethod("share",sData,Handler.create(null,function(re:*,method:*):void{
                            Platform.eventListener.event(Platform.EVENT_SHARE_OK);
                        }));
                    }
                
                } else if (ConfigApp.pf === ConfigApp.PF_360_3_h5 && sData["title"]) {
                    Platform.h5_sdk_obj.share({title: sData["title"], content: sData["des"], imgurl: sData["imgURL"]}, function(re:*):void{
                        re.success === 'ok' && Platform.eventListener.event(Platform.EVENT_SHARE_OK);
                    });
                } else if(ConfigApp.onIOS()){
                    if(cfgArr){
                        if(ConfigApp.pf == ConfigApp.PF_ios_meng52_tw || ConfigApp.pf == ConfigApp.PF_ios_meng52_hk){
                            ToIOS.callFunc("share_fb",function(re:*):void{
                                Platform.eventListener.event(Platform.EVENT_SHARE_OK);
                            },{arr:sarr});
                        }
                        else{
                            ToIOS.callFunc("share_wx",function(re:*):void{
                                Platform.eventListener.event(Platform.EVENT_SHARE_OK);
                            },{arr:sarr});
                        }
                    }
                }else if(ConfigApp.pf==ConfigApp.PF_test){
                    //开发调试
                    Platform.eventListener.event(Platform.EVENT_SHARE_OK);
                }
                else if(ConfigApp.pf == ConfigApp.PF_37_h5){
                    Platform.h5_sdk_obj.share(sData["des"],sData["title"],sData["imgURL"],function():void{
                        Platform.eventListener.event(Platform.EVENT_SHARE_OK);
                    },function():void{
                        // trace("分享失败");
                    });
                }
            }
        }
        public static function getAppName():String{
            if(appName!=""){
                return appName;
            }
            if(ConfigApp.releaseWeiXin()){
                appName = "minigame";
            }
            else if(ConfigApp.releaseQQ()){
                appName = "qqmini";
            }
            else if(Render.isConchApp){
                // if(Browser.onAndroid){
                //     appName = ToJava.getAppName();
                // }
                // else{
                //     appName = "com.djcy.game.ios.sg";
                // }
            }
            else{
                appName = "web";
            }    
            return appName;         
        }
        public static function getType():String{
            if(ConfigApp.releaseWeiXin()){
                return "minigame";
            }
            else if(ConfigApp.releaseQQ()){
                return "qqmini";
            }
            else if(ConfigApp.onAndroid()){
                return "and";
            }
            else if(Browser.onIOS){
                return "ios";
            }
            else{
                return "web";
            } 
        }
        public static function restart():void{
            if(ConfigApp.releaseWeiXin()){
                try
                {
                    // __JS__("wx.getUpdateManager().applyUpdate()");
                    // __JS__("wx.exitMiniProgram()");
                    // MiniAdpter.exitMiniProgram();
                }catch(e:*)
                {
                    
                }                
            }
            else{
                if(Browser.window && Browser.window.location){
                    // trace("---刷新重启游戏----");
                    Browser.window.location.reload();
                }
            }
        }
        public static function pay_re(re:Object):void{
            // trace("google支付结果---"+JSON.stringify(re));
            ToJava.savePlayerInfo({type:"pay_success_event",info:re.re_params.order},null);
        }
        public static function pay_callback(api:String):String{
            var str:String = ConfigApp.get_HTTP_URL();
            return str.replace("gateway",api);
        }
        public static function payHtml(payObj:Object):void{
            // ToIOS.log("zhifu:=="+JSON.stringify(payObj));  
            Laya.timer.clear(Platform,Platform.payHtmlEnd);
            Trackingio.orderData = payObj;
            if(payObj.wx_pay){
                NetHttp.instance.send(NetMethodCfg.HTTP_USER_SELF_H5_WX_PAY,payObj,Handler.create(null,function(re:Object):void{
                    // ToIOS.log("支付返回:"+re);
                    // Browser.window.openFrame("   ",re.toString());
                    // if(Browser.window && Browser.window["openHtml"]){
                        // ToIOS.log("支付返回2:"+re);
                        
                        Browser.window.openHtml(re.toString());
                        // Laya.timer.loop(1000,Platform,Platform.payHtmlEnd);
                    // }
                }));
            }else{
                NetHttp.instance.send(NetMethodCfg.HTTP_USER_H5_ZFB_PAY,payObj,Handler.create(null,function(re:Object):void{
                    
                    Browser.window.openHtml(re.toString());
                    // Laya.timer.loop(1000,Platform,Platform.payHtmlEnd);
                }));
            }
        }
        public static function payHtmlEnd():void{
            Laya.timer.clear(Platform,Platform.payHtmlEnd);
            // if(ConfigApp.pf == ConfigApp.PF_ios_meng52_mjm1){
                // Browser.window.openHtml("http://www.baidu.com");
            // }
        }
        public static function payCanShowUI():Boolean{
            var b:Boolean = true;
            if(ConfigApp.releaseWeiXin()){
                if(ConfigApp.pf == ConfigApp.PF_wx_changxiang){
					b = MiniAdpter.window.qingjs.instance.canPay();
				}
				else if(Browser.onIOS){
                    b = false;
				}
            }
            else if(ConfigApp.releaseQQ()){
                if(Browser.onIOS){
                    b = false;
                }
            }
            return b;
        }
        public static function pay(payObj:Object,isSelf:Boolean = false):void{     
            var user:ModelUser = ModelManager.instance.modelUser;
            var serverName:String = '';
            if (ConfigServer.zone[user.zone] && ConfigServer.zone[user.zone][0]) {
                serverName = ConfigServer.zone[user.zone][0];
            }
            var paramData:Object = null;
            var orderId:String = payObj.pid+"|"+payObj.zone+"|"+payObj.uid+"|"+ConfigServer.getServerTimer();
            var money:Number = payObj.cfg[0];
            var orderId_short:String = payObj.pid+"|"+payObj.zone+"|"+payObj.uid+"|"+Math.round(ConfigServer.getServerTimer() / 1000);
            var payArr:Array;
            var orderData:Object;
            var opName:String = "黄金";
            // 
            var ldt:Number = ConfigServer.getServerTimer();
            var zms:Number = new Date(ldt).getTimezoneOffset()*Tools.oneMinuteMilli;
            var z8ms:Number = -480*Tools.oneMinuteMilli;
            ldt = (ldt-zms)+z8ms;
            if(isSelf){
                recodrd_pay_info = [];
                recodrd_pay_info.push("coin");
                recodrd_pay_info.push(opName+ModelManager.instance.modelUser.mUID);
                recodrd_pay_info.push(payObj.pid);
                recodrd_pay_info.push(ModelSalePay.getCoinNumByPID(payObj.pid));
                recodrd_pay_info.push("CNY");
                recodrd_pay_info.push(payObj.cfg[0]);
                // 
                recodrd_pay_info.push(payObj.wx_pay?"weixin":"alipay");
                if(ConfigApp.payIsSelfH5() && isSelf){
                    Platform.payHtml(payObj);
                    return;
                }
                if(payObj.wx_pay){
                    // recodrd_pay_info.push("微信");
                    var wxPay:Object = {};
                    wxPay["nonce_str"] = ModelManager.instance.modelUser.mUID+"A"+ConfigServer.getServerTimer();
                    // 
                    NetHttp.instance.send(NetMethodCfg.HTTP_USER_WX_APP_PAY,payObj,Handler.create(null,function(re:Object):void{
                        // trace("--准备给微信支付的东西-- "+JSON.stringify(re));
                        var wxArr:Array = [];
                        wxArr.push(re.appid);
                        wxArr.push(re.partnerid);
                        wxArr.push(re.prepayid);
                        wxArr.push(re["package"]);
                        wxArr.push(re.noncestr);
                        wxArr.push(re.timestamp);
                        wxArr.push(re.sign);                               
                        //
                        if(ConfigApp.onIOS()){
                            ToIOS.callFunc("wx_pay",null,{arr:wxArr});//old
                            ToIOS.callFunc("wx_share2",null,{arr:wxArr});//new
                        }
                        else{
                            // if(ConfigApp.pf == ConfigApp.PF_yyb2){
                            //     ToJava.pay_wx(wxArr,null);
                            // }
                            // else{
                                ToJava.pay(wxArr,null);
                            // }
                        }
                    }));
                }
                else{
                    // recodrd_pay_info.push("支付宝");
                    if(ConfigApp.onIOS()){
                        NetHttp.instance.send(NetMethodCfg.HTTP_USER_PAY,payObj,Handler.create(null,function(re:Object):void{
                            // ToIOS.callFunc("ali",null,{url:re.toString()});
                            Browser.window.openFrame("   ",re.toString());
                        }));
                    }
                    else{
                        NetHttp.instance.send(NetMethodCfg.HTTP_USER_PAY,payObj,Handler.create(null,function(re:Object):void{
                            ToJava.openAlipay(re.toString());
                        }));
                    }
                }
            } else if(h5_sdk) {
                h5_sdk.pay(orderId, payObj, serverName);
            }
            else if(ConfigApp.releaseWeiXin()){
                if(ConfigApp.pf == ConfigApp.PF_wx_changxiang){
                    MiniAdpter.window.qingjs.instance.purchase(
                        {
                            productName: opName,// 商品名称 必填
                            productId: payObj.pid, // 商品ID 必填
                            productPrice: money*100, // 单位 分 人民币 必填
                            cpOrderId: orderId, // CP订单号 必填
                            extendsParam1: orderId,  // 服务器将此参数原封不动回传至CP服务器 可选
                            extendsParam2: orderId,  // 服务器将此参数原封不动回传至CP服务器 可选
                            roleId: ModelManager.instance.modelUser.mUID,// 可选 有的话尽量填写
                            roleName: ModelManager.instance.modelUser.uname,// 可选 有的话尽量填写
                            roleLevel: ModelManager.instance.modelUser.getLv()+"",// 可选 有的话尽量填写
                            serverId: ModelManager.instance.modelUser.zone+"",// 区服ID需要唯一标识玩家所在区服，如果同时有区ID和服务器ID，请用竖线 “|” 连接起来
                            serverName: ConfigServer.zone[ModelManager.instance.modelUser.zone+""][0],// 可选 有的话尽量填写
                            roleVip: "0"// 可选 有的话尽量填写                
                        }, function (result:*):void {          // 下单回调，非充值回调，可传null
                            // var isSuccess = result.isSuccess;
                            // var cpOrderId = result.cpOrderId;
                            trace(" 下单结果: " + result);
                        });
                }
                else{
                    var obj:Object = {  
                        mode:'game',
                        platform:'android',
                        currencyType:'CNY',
                        env:payObj.env,
                        offerId:'1450017659',
                        buyQuantity:payObj.buyQuantity,
                        zoneId:1,
                        success:function(res):void{
                            // trace("支付成功返回",res);
                            payObj["pf"]=payObj.pf;
                            NetHttp.instance.send(NetMethodCfg.HTTP_USER_PAY,payObj,Handler.create(null,function(re:Object):void{
                                // trace("通知服务器支付成功返回",re);
                            }));
                        },fail:function(res):void{
                            // trace("支付失败返回",res);
                        },complete:function(res):void{
                            // trace("支付返回",res);
                        }};
                    //
                    // MiniAdpter.window.wx.requestMidasPayment(obj);
                }
            } else if(ConfigApp.releaseQQ()){
                NetHttp.instance.send('user_zone.get_h5_qq_prepay_id', {
                    order_id:payObj.pid+"A"+payObj.zone+"A"+payObj.uid+"A"+ConfigServer.getServerTimer()
                }, Handler.create(null,function(obj:Object):void{
                    var prepayId:String = obj.prepay_id;
                    QQMiniAdapter.window.qq.requestMidasPayment({
                        prepayId: prepayId,
                        starCurrency: payObj.buyQuantity,
                        setEnv: 0, // 沙箱
                        success:function(re:*):void{ },
                        fail:function(re:*):void{ trace("支付失败返回", re); },
                        complete:function(re:*):void{ trace("支付完成返回", re); }
                    });
                }));
                
            } else if(ConfigApp.onAndroid()){

                if(ConfigApp.pf == ConfigApp.PF_huawei || ConfigApp.pf == ConfigApp.PF_huawei_tw){
                    var isTW:Boolean = (ConfigApp.pf == ConfigApp.PF_huawei_tw);
                    if(Platform.pf_login_data.hw_pay_new){
                        var hwPay2:Array = isTW?getPayByHuaWei_tw(payObj):getPayByHuaWei(payObj);
                        var hwToSdk:Object = hwPay2[0];

                        NetHttp.instance.send(isTW?NetMethodCfg.HTTP_USER_HW_TW_SIGN:NetMethodCfg.HTTP_USER_HW_SIGN,hwPay2[1],Handler.create(null,function(re:Object):void{
                            hwToSdk["sign"] = re.sign;
                            ToJava.pay(hwToSdk,Handler.create(null,function(status:Number,obj:Object):void{
                                // trace("--客户端调用ad方法,pay-- 返回2 -- "+status);
                            }));
                        }));                    
                    }
                    else{
                        var hwPay1:Array = getGameUserDataPay2(payObj,isTW);
                        var hwToSign1:Object = hwPay1[0];
                        payArr = hwPay1[1];
                        // trace("--客户端调用ad方法,pay--发送-- "+JSON.stringify(payReq));
                        NetHttp.instance.send(isTW?NetMethodCfg.HTTP_USER_HW_TW_SIGN:NetMethodCfg.HTTP_USER_HW_SIGN,hwToSign1,Handler.create(null,function(re:Object):void{
                            payArr.push(re.sign);
                            ToJava.pay(payArr,Handler.create(null,function(status:Number,obj:Object):void{
                                // trace("--客户端调用ad方法,pay-- 返回2 -- "+status);
                            }));
                        }));
                    }
                }
                else if(ConfigApp.onAndroidYYB()){
                    Platform.pay_yyb(payObj,isSelf);
                }
                // else if(ConfigApp.pf == ConfigApp.PF_yyb2){
                //     NetHttp.instance.send(NetMethodCfg.HTTP_USER_YYB_PAY_FROM,payObj,Handler.create(null,function(re:Object):void{
                //         if(re && re.pay_from && re.pay_from == "yyb"){
                //             Platform.pay_yyb(payObj,isSelf);
                //         }
                //         else{
                //             payObj["wx_pay"] = true;
                //             Platform.pay(payObj,true);
                //         }
                //     }));
                // }
                else if(ConfigApp.pf == ConfigApp.PF_juedi || ConfigApp.pf == ConfigApp.PF_juedi_ad){
                    var payJuedi1:Array = getPayByJUEDI(payObj);
                    ToJava.pay(payJuedi1[1],Handler.create(null,function(status:Number,obj:Object):void{
                        // trace("--sdk返回pay--- "+status);
                    }));
                }
                else if(ConfigApp.pf == ConfigApp.PF_wende){
                    orderData = {
                        "name":opName,
                        "des":opName+payObj.cfg[1],
                        "amount":payObj.cfg[0]*100,
                        "pid":orderId,
                        "sname":ModelManager.instance.modelUser.zone,
                        "uname":ModelManager.instance.modelUser.uname
                    }
                    ToJava.pay2(orderData,Handler.create(null,function(status:Number,obj:Object):void{
                        // trace("--sdk返回pay--- "+status);
                    }));
                }
                else if(ConfigApp.pf == ConfigApp.PF_vivo ){
                    NetHttp.instance.send(NetMethodCfg.HTTP_USER_VIVO_SIGN,payObj,Handler.create(null,function(re:Object):void{

                        // trace("vivo返回的"+JSON.stringify(re));
                        var vivoPay:Array = [];
                        vivoPay.push(Platform.pf_login_data.openid);
                        vivoPay.push(re.orderNumber);
                        vivoPay.push(re.accessKey);
                        vivoPay.push(re.orderTitle);
                        vivoPay.push(re.orderDesc);
                        vivoPay.push(re.orderAmount);
                        vivoPay.push(re.cpOrderNumber);
                        //
                        ToJava.pay(vivoPay,Handler.create(null,function(status:Number,obj:Object):void{
                            // trace("--sdk返回pay--- "+status);
                        }));                        
                    }));
                }
                else if(ConfigApp.pf == ConfigApp.PF_oppo){
                    NetHttp.instance.send(NetMethodCfg.HTTP_USER_OPPO_SIGN,payObj,Handler.create(null,function(re:Object):void{
                        // trace("oppo 返回的"+JSON.stringify(re));
                        // var oppoOrder:String = payObj.pid+";"+payObj.zone+";"+payObj.uid+";"+payObj.pf+";"+ConfigServer.getServerTimer();
                        var oppoPay:Array = [];
                        oppoPay.push(re.cpOrderNumber);
                        oppoPay.push(re.cpOrderNumber);
                        oppoPay.push(payObj.cfg[0]*100);
                        oppoPay.push(opName);
                        oppoPay.push(opName);
                        // oppoPay.push(ConfigApp.get_PAY_CALLBACK_URL());
                        oppoPay.push(re.notifyUrl);
                        //
                        ToJava.pay(oppoPay,Handler.create(null,function(status:Number,obj:Object):void{
                            // trace("--sdk返回pay--- "+status);
                        }));                        
                    }));
                }
                else if(ConfigApp.pf == ConfigApp.PF_yx7477 || ConfigApp.pf == ConfigApp.PF_yx7477_1){
                    orderData = {};
                    orderData["goodsName"] = opName;
                    orderData["orderNo"] = orderId;
                    orderData["ext"] = orderId;
                    orderData["tips"] = "1";
                    orderData["amount"] = payObj.cfg[0];
                    orderData["exchange"] = 10;
                    ToJava.pay(orderData,Handler.create(null,function(status:Number,obj:Object):void{
                        // trace("--sdk返回pay--- "+status);
                    })); 
                }
                // else if(ConfigApp.pf == ConfigApp.PF_yqwb){
                //     var yqwbPay:Array = [];
                //     yqwbPay.push(""+orderId);
                //     yqwbPay.push(opName);
                //     yqwbPay.push(payObj.cfg[0]*100);
                //     yqwbPay.push(1);
                //     yqwbPay.push(ModelManager.instance.modelUser.zone+"");
                //     ToJava.pay(yqwbPay,Handler.create(null,function(status:Number,obj:Object):void{
                //         trace("--yqwbPay call back--- "+status+" :: "+JSON.stringify(obj));
                //     })); 
                // }
                // else if(ConfigApp.pf == ConfigApp.PF_hf){
                //     orderData = {};
                //     orderData["cpTradeNo"] = payObj.uid+""+ConfigServer.getServerTimer();
                //     orderData["ext"] = orderId;
                //     orderData["userId"] = ModelManager.instance.modelUser.accountId;
                //     orderData["itemAmount"] = 1;
                //     orderData["pid"] = payObj.pid;
                //     orderData["coin"] = ModelManager.instance.modelUser.coin;
                //     orderData["uid"] = ModelManager.instance.modelUser.mUID;
                //     orderData["uname"] = ModelManager.instance.modelUser.uname;
                //     orderData["lv"] = ModelManager.instance.modelUser.getLv();
                //     orderData["sid"] = ModelManager.instance.modelUser.zone;
                //     orderData["sname"] = ModelManager.instance.modelUser.zone;
                //     orderData["money"] = payObj.cfg[0]*100;
                //     orderData["itemName"] = opName;
                //     // hfPay["callback"] = Platform.pay_callback("hf_callback");
                //     ToJava.pay(orderData,Handler.create(null,function(status:Number,obj:Object):void{
                //         // trace("--yqwbPay call back--- "+status+" :: "+JSON.stringify(obj));
                //     })); 
                // }
                else if(ConfigApp.pf == ConfigApp.PF_xiaomi){
                    var miPay:Array = [];
                    var miPayId:String = orderId;
                    miPay.push(miPayId);
                    miPay.push(payObj.pid);
                    miPay.push(1);
                    ToJava.pay(miPay,Handler.create(null,function(status:Number,obj:Object):void{
                       
                    })); 
                }
                // else if(ConfigApp.pf == ConfigApp.PF_samsung){
                // }
                else if(ConfigApp.pf == ConfigApp.PF_meizu){
                    var mzPay:Object = {};
                    var mzTimer:Number = ConfigServer.getServerTimer();
                    var mzOid:String = payObj.uid+"|"+mzTimer;
                    mzPay["app_id"]="3238111";
                    mzPay["cp_order_id"]=mzOid;
                    mzPay["uid"]=Platform.pf_login_data.uid;
                    mzPay["product_id"]="0";
                    mzPay["product_subject"]=ModelSalePay.getCoinNumByPID(payObj.pid)+opName;
                    mzPay["product_body"]="";//payObj.cfg[1]+opName;
                    mzPay["product_unit"]=ModelSalePay.getCoinNumByPID(payObj.pid);
                    mzPay["buy_amount"]=1;
                    mzPay["product_per_price"]=payObj.cfg[0];
                    mzPay["create_time"]=mzTimer;
                    mzPay["total_price"]=payObj.cfg[0];
                    mzPay["user_info"]=payObj.pid+"|"+payObj.zone+"|"+mzOid;
                    mzPay["pay_type"]="0";
                    
                    NetHttp.instance.send(NetMethodCfg.HTTP_USER_MEIZU_SIGN,mzPay,Handler.create(null,function(re:Object):void{
                        mzPay["sign_type"]="md5";
                        mzPay["sign"] = re.sign;
                        ToJava.pay(mzPay,Handler.create(null,function(status:Number,obj:Object):void{
                            // trace("--sdk返回pay--- "+status);
                        })); 
                    }));
                }
                else if(ConfigApp.pf == ConfigApp.PF_caohua || ConfigApp.pf == ConfigApp.PF_JJ_caohua_ad){
                    var caohuaPay:Object = {};
                    var caohuaTimer:Number = ConfigServer.getServerTimer();
                    var caohuaOid:String = payObj.pid+"|"+payObj.zone+"|"+payObj.uid+"|"+caohuaTimer;
                    caohuaPay["ProductId"] = payObj.pid;
                    caohuaPay["ProductName"] = opName;
                    caohuaPay["ProductDesc"] = opName;
                    caohuaPay["BuyNum"] = 1;
                    caohuaPay["Balance"] = ModelManager.instance.modelUser.coin;
                    caohuaPay["Extension"] = caohuaOid;
                    caohuaPay["Price"] = payObj.cfg[0];
                    caohuaPay["Ratio"] = 10;
                    caohuaPay["ServerId"] = payObj.zone;
                    caohuaPay["ServerName"] = payObj.zone;
                    caohuaPay["RoleId"] = ModelManager.instance.modelUser.mUID;
                    caohuaPay["RoleName"] = ModelManager.instance.modelUser.uname;
                    caohuaPay["RoleLevel"] = ModelManager.instance.modelUser.getLv();
                    caohuaPay["Vip"] = "0";
                    caohuaPay["PayNotifyUrl"] = "";//Platform.pay_callback("caohua_callback");
                    caohuaPay["OrderID"] = caohuaOid;
                    // 
                    ToJava.pay(caohuaPay,Handler.create(null,function(status:Number,obj:Object):void{
                        // trace("--sdk返回pay--- "+status);
                    })); 
                }
                else if(ConfigApp.pf == ConfigApp.PF_uc){
                    var ucPay:Object = {};
                    var ucTimer:Number = ConfigServer.getServerTimer();
                    var ucOid:String = payObj.pid+"|"+payObj.zone+"|"+payObj.uid+"|"+ucTimer;
                    //
                    ucPay["callbackInfo"]=ucOid;
                    ucPay["amount"]=payObj.cfg[0]+"";
                    ucPay["cpOrderId"]=payObj.uid+"|"+ucTimer;
                    ucPay["accountId"]=ModelManager.instance.modelUser.accountId;
                    NetHttp.instance.send(NetMethodCfg.HTTP_USER_UC_SIGN,ucPay,Handler.create(null,function(re:Object):void{
                        ucPay["sign"] = re.sign;
                        ToJava.pay(ucPay,Handler.create(null,function(status:Number,obj:Object):void{
                            // trace("--sdk返回pay--- "+status);
                            
                        })); 
                    }));
                }
                // else if(ConfigApp.pf == ConfigApp.PF_efun_google || ConfigApp.pf == ConfigApp.PF_efun_one){

                // }
                else if(ConfigApp.pf == ConfigApp.PF_and_google){
                    var ggPay:Object = {};
                    ggPay["google_pid"] = ConfigServer.system_simple.pay[payObj.pf][payObj.pid];
                    ggPay["pid"] = payObj.pid;
                    ToJava.pay(ggPay,Handler.create(null,function(obj:Object,method:String):void{
                        // trace("google支付返回--- "+obj);
                        obj["order"] = obj.pid+"|"+payObj.zone+"|"+payObj.uid+"|"+ConfigServer.getServerTimer();
                        NetHttp.instance.send(NetMethodCfg.HTTP_GG_CALLBACK,obj,Handler.create(Platform,Platform.pay_re));
                    })); 
                }
                else if(ConfigApp.pf == ConfigApp.PF_r2game_xm_ad || ConfigApp.pf == ConfigApp.PF_r2game_kr_ad || ConfigApp.pf == ConfigApp.PF_r2game_kr_onestore){
                    var r2pay:Object = {};
                    r2pay["ggpid"] = ConfigServer.system_simple.pay[ConfigApp.pf][payObj.pid];
                    r2pay["sid"] = ModelManager.instance.modelUser.zone;
                    r2pay["r2uid"] = Platform.pf_login_data.uid;
                    r2pay["uid"] = ModelManager.instance.modelUser.mUID;
                    r2pay["pid"] = orderId;
                    r2pay["adjust_pay_event"] = "";
                    r2pay["adjust_pay_money"] = 0;
                    r2pay["content_id"] = "1";
                    r2pay["content_type"] = "pay";
                    r2pay["currency"] = (ConfigApp.pf == ConfigApp.PF_r2game_xm_ad)?"USD":"KRW";
                    r2pay["revenue"] = ConfigServer.system_simple.pay_money[ConfigApp.pf][payObj.pid];
                    ToJava.pay(r2pay,Handler.create(null,function(obj:Object,method:String):void{

                    }));
                }
                else if(ConfigApp.pf == ConfigApp.PF_77you_ad_jp || ConfigApp.pf == ConfigApp.PF_77you_ad_tw){
                    var seventPay:Object = {};
                    seventPay["goods_name"] = ConfigServer.system_simple.pay[ConfigApp.pf][payObj.pid];
                    seventPay["cporder"] = orderId;
                    seventPay["fee"] = ConfigServer.system_simple.pay_money[ConfigApp.pf][payObj.pid];
                    seventPay["ext"] = orderId;

                    // 币种:货币类型（RMB，THB, VND, IDR, USD, TWD, HKD）
                    if(ConfigApp.pf == ConfigApp.PF_77you_ad_tw) {
                        seventPay["currency"] = "USD";
                    } else if (ConfigApp.pf == ConfigApp.PF_77you_ad_jp) {
                        seventPay["currency"] = "USD";
                    }

                    ToJava.pay(seventPay,Handler.create(null,function(obj:Object,method:String):void{

                    }));
                }
                else if(ConfigApp.pf == ConfigApp.PF_360_ad) {
                    var ad360Pay:Object = {};
                    ad360Pay["qihoo_user_id"] = ModelManager.instance.modelUser.accountId;
                    ad360Pay["money_amount"] = payObj.cfg[0]*100;
                    ad360Pay["product_name"] = opName;
                    ad360Pay["product_id"] = payObj.pid;
                    ad360Pay["url"] = "http://qh.ptkill.com/ad_360_callback/";
                    ad360Pay["app_name"] = "天下纷争";
                    ad360Pay["app_user_name"] = ModelManager.instance.modelUser.uname;
                    ad360Pay["app_user_id"] = ModelManager.instance.modelUser.mUID;
                    ad360Pay["ext"] = orderId;
                    ad360Pay["order_id"] = orderId;
                    ad360Pay["pay_code"] = 1025;    //1025(360收银台支付);1036(微信支付);1035(支付宝支付)
                    ad360Pay["exchange_rate"] = "10";

                    ToJava.pay(ad360Pay,Handler.create(null,function(obj:Object,method:String):void{
                    }));
                }
                else if(ConfigApp.pf == ConfigApp.PF_6kw_ad) {

                    var ad6KWPay:Object = {};
                    var umd:ModelUser = ModelManager.instance.modelUser;

                    ad6KWPay["product_id"] = payObj.pid;
                    ad6KWPay["product_name"] = opName;
                    ad6KWPay["product_desc"] = opName;
                    ad6KWPay["price"] = payObj.cfg[0] + "";
                    ad6KWPay["ratio"] = "10";
                    ad6KWPay["buy_num"] = "1";
                    ad6KWPay["coin_num"] = payObj.cfg[1] + "";
                    ad6KWPay["server_id"] = umd.zone+"";
                    ad6KWPay["server_name"] = ConfigServer.zone[umd.zone][0]+"";
                    ad6KWPay["role_id"] = umd.mUID + "";
                    ad6KWPay["role_name"] = umd.uname;
                    ad6KWPay["role_level"] = umd.getLv() + "";
                    ad6KWPay["pay_notify_url"] = "http://qh.ptkill.com/ad_6kw_callback/";
                    ad6KWPay["vip"] = "0";
                    ad6KWPay["order_id"] = orderId;
                    ad6KWPay["extension"] = orderId;

                    ToJava.pay(ad6KWPay,Handler.create(null,function(obj:Object,method:String):void{
                    }));
                }
                // else if(ConfigApp.pf == ConfigApp.PF_panbao_ad) {
                //     var adPanBaoPay:Object = {};
                //     var user_panbao:ModelUser = ModelManager.instance.modelUser;
                    
                //     adPanBaoPay["product_id"] = payObj.pid;
                //     adPanBaoPay["product_name"] = opName;
                //     adPanBaoPay["product_desc"] = opName;
                //     adPanBaoPay["price"] = payObj.cfg[0] * 100;
                //     adPanBaoPay["server_id"] = user_panbao.zone+"";
                //     adPanBaoPay["server_name"] = ConfigServer.zone[user_panbao.zone][0]+"";
                //     adPanBaoPay["role_id"] = user_panbao.mUID + "";
                //     adPanBaoPay["role_name"] = user_panbao.uname;
                //     adPanBaoPay["role_level"] = user_panbao.getLv() + "";
                //     adPanBaoPay["vip"] = "0";
                //     adPanBaoPay["extension"] = orderId;
                    
                //     ToJava.pay(adPanBaoPay,Handler.create(null,function(obj:Object,method:String):void{
                //     }));
                // }
                else{

                }
            }
            else if(ConfigApp.onIOS()){
                // if(ConfigApp.pf == ConfigApp.PF_juedi_ios){
                //     recodrd_pay_info = [];
                //     //
                //     var payJuedi2:Array = getPayByJUEDI(payObj);
                //     var payJuedi2Obj:Object = payJuedi2[0];
                //     recodrd_pay_info.push(payJuedi2Obj["GameTradeNo"]);
                //     recodrd_pay_info.push(payJuedi2Obj["ProductId"]);
                //     recodrd_pay_info.push(payObj.cfg[0]);
                //     recodrd_pay_info.push("CNY");
                //     recodrd_pay_info.push(ModelSalePay.getCoinNumByPID(payObj.pid));
                //     recodrd_pay_info.push("Apple");
                //     //
                //     ToIOS.callFunc("pay",function(re:*):void{
                //     },payJuedi2Obj);
                // }
                // if(ConfigApp.pf == ConfigApp.PF_37_ios){
                    
                //     var pay37:Object = {};
                //     pay37["order_no"] = orderId;
                //     pay37["game_id"] = Platform.pf_login_data["game_id"];
                    
                //     pay37["user_id"] = ModelManager.instance.modelUser.accountId;
                    
                //     pay37["sid"] = ModelManager.instance.modelUser.zone;
                //     pay37["actor_id"] = ModelManager.instance.modelUser.mUID;
                    
                //     pay37["product_id"] = ConfigServer.system_simple.pay[payObj.pf][payObj.pid];
                //     pay37["subject"] = encodeURI(opName);
                //     pay37["money"] = payObj.cfg[0];//+".00";
                //     pay37["time"] = Math.floor(ConfigServer.getServerTimer()*0.001);
                //     pay37["ext"] = pay37["order_no"];
                //     //
                //     // Browser.window.traceIOS("pay37 == "+JSON.stringify(pay37));
                //     NetHttp.instance.send(NetMethodCfg.HTTP_USER_37_IOS_SIGN,pay37,Handler.create(null,function(re:Object):void{
                //         // Browser.window.traceIOS("pay37sign == "+JSON.stringify(re));
                //         pay37["sign"] = re.sign;
                //         ToIOS.callFunc("pay",function(re:*):void{
                //         },pay37);
                //     }));
                // }
                if(ConfigApp.pf == ConfigApp.PF_wende_ios){
                    orderData = {
                        "name":opName,
                        "des":opName+payObj.cfg[1],
                        "amount":payObj.cfg[0]*100,
                        "pid":orderId,
                        "productId":ConfigServer.system_simple.pay[ConfigApp.pf][payObj.pid],
                        "sname":ModelManager.instance.modelUser.zone,
                        "uname":ModelManager.instance.modelUser.uname,
                        "uid":ModelManager.instance.modelUser.mUID+""
                    }
                    ToIOS.callFunc("pay",function(re:*):void{
                        
                    },orderData);
                }
                else if(ConfigApp.pf == ConfigApp.PF_ios_37){
                    orderData = {};
                    orderData["game_id"] = "617";
                    orderData["order_no"] = orderId;
                    orderData["uid"] = ModelManager.instance.modelUser.accountId;
                    orderData["sid"] = ModelManager.instance.modelUser.zone;
                    orderData["actor_id"] = ModelManager.instance.modelUser.mUID;
                    orderData["money"] = payObj.cfg[0];
                    orderData["subject"] = opName;
                    orderData["time"] = Math.floor(ldt*0.001);
                    // 
                    NetHttp.instance.send(NetMethodCfg.HTTP_USER_IOS_37_SIGN,orderData,Handler.create(null,function(re:Object):void{
                        orderData["order_ip"] = re.ip;
                        orderData["sign"] = re.sign;
                        orderData["product_id"] = payObj.pid;//ConfigServer.system_simple.pay[ConfigApp.pf][payObj.pid];
                        //
                        ToIOS.callFunc("nice_sq",function(re:*):void{
                            
                        },orderData);
                    }));
                }
                else if(ConfigApp.pf == ConfigApp.PF_r2game_xm_ios || ConfigApp.pf == ConfigApp.PF_r2game_kr_ios){
                    orderData = {};
                    orderData["ggpid"] = ConfigServer.system_simple.pay[ConfigApp.pf][payObj.pid];
                    orderData["sid"] = ModelManager.instance.modelUser.zone+"";
                    orderData["r2uid"] = Platform.pf_login_data.uid+"";
                    orderData["uid"] = ModelManager.instance.modelUser.mUID+"";
                    orderData["pid"] = orderId;
                    orderData["adjust_pay_event"] = "";
                    orderData["adjust_pay_money"] = 0;
                    orderData["content_id"] = "1";
                    orderData["content_type"] = "pay";
                    orderData["currency"] = (ConfigApp.pf == ConfigApp.PF_r2game_xm_ios)?"USD":"KRW";
                    orderData["revenue"] = ConfigServer.system_simple.pay_money[ConfigApp.pf][payObj.pid]+"";
                    orderData["revenue2"] = ConfigServer.system_simple.pay_money[ConfigApp.pf][payObj.pid];
                    ToIOS.callFunc("pay",function(re:*):void{
                        
                    },orderData);
                }
                // else if(ConfigApp.pf == ConfigApp.PF_panbao_ios) {
                //     orderData = {};

                //     var user_panbao_ios:ModelUser = ModelManager.instance.modelUser;
                    
                //     orderData["product_id"] = payObj.pid;
                //     orderData["product_name"] = opName;
                //     orderData["product_desc"] = opName;
                //     orderData["price"] = payObj.cfg[0] * 100 + "";
                //     orderData["server_id"] = user_panbao_ios.zone + "";
                //     orderData["server_name"] = ConfigServer.zone[user_panbao_ios.zone][0] + "";
                //     orderData["role_id"] = user_panbao_ios.mUID + "";
                //     orderData["role_name"] = user_panbao_ios.uname;
                //     orderData["role_level"] = user_panbao_ios.getLv() + "";
                //     orderData["vip"] = "0";
                //     orderData["extra"] = orderId;
                    
                //     ToIOS.callFunc("pay",function(re:*):void{},orderData);
                // }
                else if(ConfigApp.pf == ConfigApp.PF_77you_ios_tw || ConfigApp.pf == ConfigApp.PF_77you_ios_jp){
                    orderData = {
                        "goods_name": ConfigServer.system_simple.pay[ConfigApp.pf][payObj.pid],
                        "cporder": orderId,
                        "fee": ConfigServer.system_simple.pay_money[ConfigApp.pf][payObj.pid],
                        "ext": orderId
                    }
                    
                    // 币种:货币类型（RMB，THB, VND, IDR, USD, TWD, HKD）
                    if(ConfigApp.pf == ConfigApp.PF_77you_ios_tw) {
                        orderData["currency"] = "USD";
                    } else if (ConfigApp.pf == ConfigApp.PF_77you_ios_jp) {
                        orderData["currency"] = "USD";
                    }
                    
                    ToIOS.callFunc("pay",function(re:*):void{
                        // ToIOS.callFunc("mobilePrint", null, re);
                    },orderData);
                }
                else if(ConfigApp.pf == ConfigApp.PF_caohua_ios){
                    orderData = {};
                    orderData["Name"] = opName;
                    orderData["Detail"] = payObj.cfg[1];
                    orderData["Amt"] = payObj.cfg[0]*100;
                    orderData["RoleId"] = ModelManager.instance.modelUser.mUID;
                    orderData["RoleName"] = ModelManager.instance.modelUser.uname;
                    orderData["RoleLevel"] = ModelManager.instance.modelUser.getLv();
                    orderData["extraInfo"] = orderId;
                    orderData["orderNo"] = orderId;
                    // 
                    ToIOS.callFunc("pay",function(re:*):void{
                        
                    },orderData);
                }
                else if(ConfigApp.pf == ConfigApp.PF_ios_meng52_mj1 || ConfigApp.pf == ConfigApp.PF_ios_meng52_mj2){
                    var mjpid:String = null//;payObj.cfg[7];
                    if(ConfigServer.system_simple.pay[payObj.pf]){
                        mjpid = ConfigServer.system_simple.pay[payObj.pf][payObj.pid];
                    }
                    if(mjpid){
                        ToIOS.pay(function(re:*):void{
                        },{pid:mjpid,url:ConfigApp.get_HTTP_URL(),ext:payObj.pid+";"+payObj.zone+";"+payObj.uid+";"+payObj.pf});
                    }
                }
                else{
                    //ios自己的支付
                    var iosPid:String = null//;payObj.cfg[7];
                    if(ConfigServer.system_simple.pay[payObj.pf]){
                        iosPid = ConfigServer.system_simple.pay[payObj.pf][payObj.pid];
                    }
                    if(iosPid){
                        ToIOS.pay(function(re:*):void{
                        },{pid:iosPid,url:ConfigApp.get_HTTP_URL(),ext:payObj.pid+";"+payObj.zone+";"+payObj.uid+";"+payObj.pf});
                    }
                    else{
                        // Browser.window.openHtml("weixin://abc");
                    }
                }
            }else{
                // __JS__("pay_alipay()");
                // if(ConfigApp.pf == ConfigApp.PF_xh_h5){
                //     var payData:Object = {};
                //     payData["tm"] = Math.floor(ConfigServer.getServerTimer()*0.001)+"";
                //     payData["cch_id"] = pf_login_data.cch_id+"";
                //     payData["app_id"] = pf_login_data.app_id+"";
                //     payData["md_id"] = pf_login_data.md_id+"";
                //     payData["access_token"] = pf_login_data.access_token;
                    
                //     var umd:ModelUser = ModelManager.instance.modelUser;
                //     payData["role_id"] = umd.mUID+"";
                //     payData["role_name"] = umd.uname+"";
                //     payData["role_level"] = umd.getLv()+"";
                //     payData["server_id"] = umd.zone+"";
                //     payData["server_name"] = ConfigServer.zone[umd.zone][0]+"";
                //     payData["app_subject_id"] = payObj.pid+"";
                //     payData["app_subject"] = ModelSalePay.getCoinNumByPID(payObj.pid)+Tools.getMsgById(190005);
                //     payData["app_order_no"] = payObj.uid+";"+payData["tm"];//payObj.pid+";"+payObj.zone+";"+payObj.uid+";"+payObj.pf;
                //     payData["app_ext"] = payObj.pid+";"+payObj.zone+";"+payObj.uid+";"+payObj.pf;
                //     payData["amt"] = payObj.cfg[0]+"";
                //     //
                //     NetHttp.instance.send(NetMethodCfg.HTTP_USER_XH_SIGN,payData,Handler.create(null,function(re:Object):void{
                //         payData["sign"] = re.sign;
                //         Browser.window.xh_pay(getGameUserDataPay(payData));
                //     }));
                // }
                // if(ConfigApp.pf == ConfigApp.PF_wx_h5){
                //     if(Browser.window && Browser.window["wx_web_pay"]){
                //         Browser.window["wx_web_pay"]({method:NetMethodCfg.HTTP_USER_WX_h5_PAY,url:ConfigApp.get_PAY_CALLBACK_URL(),"payObj":payObj});
                //     }
                // }            
                // if(ConfigApp.pf == ConfigApp.PF_bugu_h5){
                //     Platform.h5_sdk_url_data = Tools.getURLexpToObj(ConfigApp.url_params);
                //     orderData = {
                //         "amount":payObj.cfg[0]*100,
                //         "channelExt":Platform.h5_sdk_url_data.channelExt,
                //         "game_appid":Platform.h5_sdk_url_data.game_appid,
                //         "props_name":opName,
                //         "trade_no":payObj.pid+";"+payObj.zone+";"+payObj.uid+";"+ConfigServer.getServerTimer(),
                //         "user_id":Platform.h5_sdk_url_data.user_id,
                //         "sdkloginmodel":Platform.h5_sdk_url_data.sdkloginmodel
                //     };
                //     NetHttp.instance.send(NetMethodCfg.HTTP_USER_H5_BG_SIGN,orderData,Handler.create(null,function(re:Object):void{
                //         orderData["sign"] = re.sign;
                //         Platform.h5_sdk_obj.h5paySdk(orderData,function(re:*):void{
                //             // trace(re);
                //         });
                //     }));
                // }  
                if(ConfigApp.pf == ConfigApp.PF_37_h5){
                    var data37:Object = {};
                    // 
                    data37["appid"] = Platform.pf_login_data["appid"];
                    data37["game_id"] = Platform.pf_login_data["game_id"];
                    data37["uid"] = Platform.pf_login_data["uid"];
                    data37["sid"] = ModelManager.instance.modelUser.zone;
                    data37["actor_id"] = ModelManager.instance.modelUser.mUID;
                    data37["order_no"] = orderId;
                    data37["money"] = payObj.cfg[0];
                    data37["game_coin"] = ModelSalePay.getCoinNumByPID(payObj.pid);
                    data37["product_id"] = payObj.pid;
                    data37["subject"] = "Gold";
                    data37["time"] = Math.floor(ldt*0.001);
                    data37["ext"] = "";
                    // 
                    NetHttp.instance.send(NetMethodCfg.HTTP_USER_37_SIGN,data37,Handler.create(null,function(re:Object):void{
                        data37["referer"] = Platform.pf_login_data["referer"];
                        data37["order_ip"] = re.ip;
                        data37["sign"] = re.sign;
                        //
                        Platform.h5_sdk_obj.pay(data37);
                    }));
                } 
                else if(ConfigApp.pf == ConfigApp.PF_kuku_h5){
                    var kukuOrder:String = orderId;
                    Platform.h5_sdk_obj.pay(payObj.cfg[0]*100,payObj.pid,"GOLD",payObj.uid,kukuOrder);
                }
                // else if(ConfigApp.pf == ConfigApp.PF_9130_h5){
                //     var order9130:Object = {};
                //     order9130["cpbill"] = orderId;
                //     order9130["productid"] = payObj.pid;
                //     order9130["productname"] = opName;
                //     order9130["productdesc"] = opName;
                //     order9130["serverid"] = ModelManager.instance.modelUser.zone;
                //     order9130["servername"] = ModelManager.instance.modelUser.zone;
                //     order9130["roleid"] = ModelManager.instance.modelUser.mUID;
                //     order9130["rolename"] = ModelManager.instance.modelUser.uname;
                //     order9130["rolelevel"] = ModelManager.instance.modelUser.getLv();
                //     order9130["price"] = payObj.cfg[0];
                //     order9130["extension"] = order9130["cpbill"];
                //     Platform.h5_sdk_obj.pay(order9130,function(status:*,data:*):void{

                //     });
                // } 
                else if(ConfigApp.pf == ConfigApp.PF_yyjh_h5 || ConfigApp.pf == ConfigApp.PF_yyjh2_h5 || ConfigApp.pf == ConfigApp.PF_JJ_yyjh_h5){
                    var dataYYJH:Object = {};
                    var yyjhObj:Object = Tools.getURLexpToObj(ConfigApp.url_params);
                    var index_yyjh:int= [ConfigApp.PF_yyjh_h5, ConfigApp.PF_yyjh2_h5, ConfigApp.PF_JJ_yyjh_h5].indexOf(ConfigApp.pf);
                    var yyjh_appkey:String = ["3866c245e0791eaabc84a49efe2d0ef2", "09fe331c3dc8a3d5a10d05345f1b7e17", "f3c9a6e058f9e6b12f380366583a96b1"][index_yyjh];
                    var yyjh_sign:String = [NetMethodCfg.HTTP_USER_YYJH_SIGN, NetMethodCfg.HTTP_USER_YYJH2_SIGN, NetMethodCfg.HTTP_USER_JJ_YYJH_SIGN][index_yyjh];
                    dataYYJH["cporder"] = orderId;
                    dataYYJH["userid"] = yyjhObj.userid;
                    dataYYJH["server_id"] = ModelManager.instance.modelUser.zone;
                    dataYYJH["roleid"] = ModelManager.instance.modelUser.mUID;
                    dataYYJH["amt"] = payObj.cfg[0];
                    dataYYJH["goodsid"] = payObj.pid;
                    dataYYJH["appkey"] = yyjh_appkey;
                    dataYYJH["time"] = Math.floor(ConfigServer.getServerTimer()*0.001);
                    dataYYJH["custom"] = "";
                    NetHttp.instance.send(yyjh_sign,dataYYJH,Handler.create(null,function(re:Object):void{
                        Platform.h5_sdk_obj.Pay({
                            safeCode:re.code.toString()
                        });
                    }));
                } else if(ConfigApp.pf == ConfigApp.PF_caohua1_h5){
                    var chPayCfg:Object = ConfigServer.system_simple.pay[ConfigApp.pf+ConfigApp.chmj];
                    Platform.h5_sdk_obj.pay({
                        "cpOrderNo":orderId,
                        "extraInfo":ConfigApp.chmj,
                        "productIdentifier":chPayCfg?chPayCfg[payObj.pid]:"",
                        "orderAmt":payObj.cfg[0]*100,
                        "orderDetail":ModelSalePay.getCoinNumByPID(payObj.pid)+opName,
                        "callBackUrl":"",
                        "roleLevel":ModelManager.instance.modelUser.getLv(),
                        "roleId":ModelManager.instance.modelUser.mUID,
                        "roleName":ModelManager.instance.modelUser.uname,
                        "mhtOrderName":opName
                    },function(res:*):void{

                    });
                } else if (ConfigApp.pf == ConfigApp.PF_caohua2_h5) {
                    // 金额是分 所以乘以100
                    Platform.h5_sdk_obj.pay_v(orderId, user.getLv(), money * 100, ConfigApp.chmj, '');
                } else if (ConfigApp.pf == ConfigApp.PF_JJ_tanwan_h5 || ConfigApp.pf == ConfigApp.PF_tanwan_h5 || ConfigApp.pf == ConfigApp.PF_tanwan2_h5 || ConfigApp.pf == ConfigApp.PF_tanwan3_h5) {
                    paramData = Platform.h5_sdk_url_data = Tools.getURLexpToObj(ConfigApp.url_params);
                    Platform.h5_sdk_obj.pay({
                        buyNum      : 1,                    // 固定值1
                        coin        : 100,                  // 固定值100
                        game_id     : paramData.appid,      // 固定值(平台游戏标示)
                        server_id   : user.zone,            // 游戏服ID
                        server_name : String(user.zone),    // 游戏服名称
                        uid         : paramData.uid,        // 平台用户ID(由3.1 接口传入的uid)
                        role_name   : user.uname,           // 游戏角色名
                        role_level  : user.getLv(),         // 游戏角色等级
                        vip         : '',                   // 游戏角色vip
                        money       : money,        // 充值金额
                        game_gold   : ModelSalePay.getCoinNumByPID(payObj.pid),        // 充值游戏币
                        role_id     : user.mUID,            // 游戏角色ID
                        product_id  : orderId,              // 产品ID
                        product_name: '黄金',               // 产品名
                        product_desc: '黄金',               // 产品描述
                        ext         : orderId               // 游戏方透传参数，支付回调接口原样返回（例如：游戏方订单ID）
                    });
                } else if (ConfigApp.pf == ConfigApp.PF_tanwan4_h5) {
                    paramData = Platform.h5_sdk_url_data = Tools.getURLexpToObj(ConfigApp.url_params);
                    Platform.h5_sdk_obj.pay({
                        buyNum      : 1,                    // 固定值1
                        coinNum     : 100,                  // 固定值100
                        gameId      : paramData.appid,      // 固定值(平台游戏标示)
                        serverId    : user.zone,            // 游戏服ID
                        serverName  : String(user.zone),    // 游戏服名称
                        uid         : paramData.uid,        // 平台用户ID(由3.1 接口传入的uid)
                        roleName    : user.uname,           // 游戏角色名
                        roleLevel   : user.getLv(),         // 游戏角色等级
                        vip         : '',                   // 游戏角色vip
                        money       : money,        // 充值金额
                        gameGold    : ModelSalePay.getCoinNumByPID(payObj.pid),        // 充值游戏币
                        roleId      : user.mUID,            // 游戏角色ID
                        productId   : orderId,              // 产品ID
                        productName : '黄金',               // 产品名
                        productDesc : '黄金',               // 产品描述
                        ext         : orderId               // 游戏方透传参数，支付回调接口原样返回（例如：游戏方订单ID）
                    });
                } 
                // else if (ConfigApp.pf == ConfigApp.PF_yuncai_h5) {
                //     Platform.h5_sdk_obj. placeOrder({
                //         gameId: 'qmXr4l7ToWEWcZEdEk',
                //         token: null,
                //         orderId: orderId,
                //         coins: ModelSalePay.getCoinNumByPID(payObj.pid),
                //         gameGoods: '黄金',               // 商品名称
                //         gameData: '',
                //         ts: ConfigServer.getServerTimer()
                //     });
                // } 
                else if (ConfigApp.pf == ConfigApp.PF_7k_h5 || ConfigApp.pf === ConfigApp.PF_JJ_7k_h5) {
                    var sign_7k:String = ConfigApp.pf == ConfigApp.PF_7k_h5 ? NetMethodCfg.HTTP_USER_7K_SIGN : NetMethodCfg.HTTP_USER_JJ_7K_SIGN;
                    NetHttp.instance.send(sign_7k, {userid: Tools.getURLexpToObj(ConfigApp.url_params).userid, order_id: orderId_short},Handler.create(null,function(re:Object):void {
                        Platform.h5_sdk_obj.Pay({ safeCode: re.code });
                    }));
                } else if (ConfigApp.pf == ConfigApp.PF_leyou_h5) {
                    var leyouData:Object = Platform.h5_sdk_url_data = Tools.getURLexpToObj(ConfigApp.url_params);
                    Platform.h5_sdk_obj.getinfo(leyouData.userid, user.zone, user.mUID, money, payObj.pid, orderId, '', leyouData.appkey, leyouData.banid, leyouData.token);
                } else if (ConfigApp.pf == ConfigApp.PF_360_h5) {
                    var id360:String = Tools.getURLexpToObj(ConfigApp.url_params).qid;
                    // console.log(id360);
                    // console.log(orderId);

                    NetHttp.instance.send(NetMethodCfg.HTTP_USER_360_SIGN,{item_id:orderId, amount:money,qid:id360},Handler.create(null,function(re:Object):void {
                        // console.log(re.exts);
                        var params:Object = {
                            goods: {
                                goods_name: '黄金',
                                rate: 0.1
                            },
                            game: {
                                gkey: 'zqwzh5',
                                gname: '最强王者'
                            },
                            order: {
                                amount: money,
                                timestamp: Math.floor(ConfigServer.getServerTimer()*0.001)
                            },
                            checkin: {
                                qid: id360,
                                exts: re.exts
                                //orderId.replace(/\|/g, 'A')
                            }
                        }
                        // console.log(JSON.stringify(params));
                        Platform.h5_sdk_obj.h5Game.emit(Platform.h5_sdk_obj.CONST.EVENT.BUY.START, params); 
                    }));
                    
                } else if (ConfigApp.pf == ConfigApp.PF_360_2_h5) {
                    paramData = Platform.h5_sdk_url_data = Tools.getURLexpToObj(ConfigApp.url_params);
                    NetHttp.instance.send(NetMethodCfg.HTTP_USER_360_2_SIGN, {order_id: orderId}, Handler.create(null,function(re:Object):void {
                        var tid:String = re.tid;
                        Platform.h5_sdk_obj.pay(tid)
                        .then(function(result:Object):void {
                            // console.log(result);
                        })
                        .catch(function(err:Object):void {
                            // console.log(err);
                        });
                    }));
                } else if (ConfigApp.pf == ConfigApp.PF_360_3_h5) {
                    NetHttp.instance.send(NetMethodCfg.HTTP_USER_360_3_SIGN, {fee: money * 100, feeid: payObj.pid}, Handler.create(null,function(re:Object):void {
                        var check:String = re.check;
                        Platform.h5_sdk_obj.pay({
                            check: check,
                            feeid: payObj.pid,
                            fee: money * 100,
                            feename: '黄金',
                            extradata: orderId,
                            serverid: user.zone,
                            servername: String(user.zone),
                            roleid: String(user.mUID),
                            rolename: user.uname,
                            rolelevel: String(user.getLv())
                        }, function(data:Object):void {
                            if (data.retcode === '1' || data.retcode === '2') {
                                data.msg && ViewManager.instance.showTipsTxt(data.msg);
                            }
                        });
                    }));
                } else if (ConfigApp.pf == ConfigApp.PF_r2game_kr_h5) {
                    var data_r2game_kr_h5:Object = Platform.h5_sdk_url_data = Tools.getURLexpToObj(ConfigApp.url_params);
                    Browser.window.parent.postMessage({action:'callPay', server: user.zone}, '*');
                    
                } else if (ConfigApp.pf == ConfigApp.PF_1377_h5) {
                    var data_1377:Object = Platform.h5_sdk_url_data = Tools.getURLexpToObj(ConfigApp.url_params);
                    Platform.h5_sdk_obj.pay({
                        buyNum: 1,      // 购买数量(默认1)
                        ext: orderId,   // 游戏方订单ID
                        coin: ModelSalePay.getCoinNumByPID(payObj.pid),     // 充值游戏币
                        game_gold: ModelSalePay.getCoinNumByPID(payObj.pid),// 充值游戏币
                        game_id: data_1377.appid,   // 赞钛平台游戏ID
                        money: money,               // 充值金额 (整数，单位元)
                        product_desc: '黄金',       // 商品描述
                        product_id: payObj.pid,     // 商品ID
                        product_name: '黄金',       // 商品描述
                        server_id   : user.zone,        // 游戏服ID
                        server_name : String(user.zone),// 游戏服名称
                        role_id     : user.mUID,        // 游戏角色ID
                        role_name   : user.uname,       // 游戏角色名
                        role_level  : user.getLv(),     // 游戏角色名
                        uid: data_1377.uid,             // 赞钛平台帐号ID
                        vip: 0                          // 游戏角色vip等级
                    });
                } else if (ConfigApp.pf == ConfigApp.PF_muzhi_h5 || ConfigApp.pf === ConfigApp.PF_muzhi2_h5) {
                    var data_muzhi:Object = Platform.h5_sdk_url_data = Tools.getURLexpToObj(ConfigApp.url_params);
                    NetHttp.instance.send(ConfigApp.pf == ConfigApp.PF_muzhi_h5 ? NetMethodCfg.HTTP_USER_MUZHI_SIGN : NetMethodCfg.HTTP_USER_MUZHI2_SIGN, {
                        game_id: data_muzhi.gameId,
                        cp_order_id: orderId,
                        amount: money * 100,
                        userId: data_muzhi.userId,
                        server_id: user.zone,
                        level: user.getLv()

                    }, Handler.create(null,function(sign:String):void{
                        Platform.h5_sdk_obj.placeOrder({
                            game_id: data_muzhi.gameId,
                            cp_order_id: orderId,
                            amount: money * 100,
                            userId: data_muzhi.userId,
                            pay_type: data_muzhi.h5Type === 'h5_ios_on_line' ? 'iospay' : '',
                            coin_name: '黄金',
                            server_id: user.zone,
                            role_id: user.mUID,
                            transData: orderId,
                            packetId: data_muzhi.packet_id,
                            level: user.getLv(),
                            sign: sign,
                            product_id: payObj.pid
                        });
                    }));
                } else if (ConfigApp.pf == ConfigApp.PF_hutao_h5 || ConfigApp.pf === ConfigApp.PF_hutao2_h5) {
                    var data_hutao:Object = Platform.h5_sdk_url_data = Tools.getURLexpToObj(ConfigApp.url_params);
				    var accountId:Array = ModelManager.instance.modelUser.accountId as Array;
                    Platform.h5_sdk_obj.pay({
                        uid: accountId[0],
                        server_id: String(user.zone),
                        role_id: String(user.mUID),
                        role_name: user.uname,
                        role_level: user.getLv(),
                        cp_order_num: orderId,
                        total_fee: money * 100,
                        ext: orderId,
                        appstore_id: ''
                    });
                } else if (ConfigApp.pf == ConfigApp.PF_changxiang_h5) {
                    Platform.h5_sdk_obj.purchase({
                        productName: '黄金',
                        productId: payObj.pid,
                        productPrice: money * 100,
                        cpOrderId: orderId,
                        roleId: String(user.mUID),
                        roleName: user.uname,
                        roleLevel: user.getLv(),
                        serverId: String(user.zone),
                        serverName: String(user.zone),
                        roleVip: 0
                    });
                } else if (ConfigApp.pf == ConfigApp.PF_changwan_h5) {
                    Platform.h5_sdk_obj.pay_v(
                        orderId,
                        String(user.getLv()),
                        money * 100,
                        '',
                        ''
                    );
                } 
                // else if (ConfigApp.pf == ConfigApp.PF_panbao_h5) {
                //     Platform.h5_sdk_obj.callHandler( "pay", {
                //         appId: 'lbmeMN0oqwDOYi',
                //         cpOrderId: orderId,
                //         amount: money * 100,
                //         productName: '黄金',
                //         productDesc: '',
                //         callbackUrl: 'http://qh.ptkill.com/h5_panbao_callback/'
                //     }, function(ret:*):void {});
                // } 
                else if (ConfigApp.pf == ConfigApp.PF_qqdt_h5) {
                    Platform.h5_sdk_obj.BuyBox.show();
                } else if (ConfigApp.pf == ConfigApp.PF_shouqu_h5) {
                    Platform.h5_sdk_obj.pay({
                        cp_order_id: orderId,
                        money: money * 100, 
                        coin_unit: '黄金',
                        ratio: 10, 
                        server_id: String(user.zone),
                        server_name: serverName,
                        role_id: user.mUID,
                        role_name: user.uname,
                        level: user.getLv(),
                        cb_pay: function(result:*):void{
                            console.log(result);
                        }
                    });
                } else if (ConfigApp.pf == ConfigApp.PF_6kw_h5) {
                    Platform.h5_sdk_obj.CallParentMethods('pay', {
                        cpOrder: orderId,
                        serverId: user.zone,    	    // 区服ID
                        serverName: String(user.zone),  // 区服名
                        roleID: user.mUID,      	    // 角色ID
                        roleName: user.uname,   	    // 角色名
                        roleLevel: user.getLv(),        // 角色等级
                        goodsName: '黄金',
                        goodsID: payObj.pid,
                        cost: money,    // 充值金额 元
                        desc: '', // 拓展字段
                        notifyURL: ''
                    });
                } else {
                    NetHttp.instance.send(NetMethodCfg.HTTP_USER_PAY,payObj,Handler.create(null,function(re:Object):void{

                    }));
                }
            }
        }
        public static function bindOther():void{
            if(ConfigApp.pf == ConfigApp.PF_r2game_xm_ad || ConfigApp.pf == ConfigApp.PF_r2game_kr_ad ||  ConfigApp.pf == ConfigApp.PF_r2game_kr_onestore){
                ToJava.callMethod("toBind",null,null);
            }
            else if(ConfigApp.pf == ConfigApp.PF_r2game_xm_ios || ConfigApp.pf == ConfigApp.PF_r2game_kr_ios){
                ToIOS.callFunc("toBind",null,null);
            }          
        }
        public static function unBindOther():void{
            if(ConfigApp.pf == ConfigApp.PF_r2game_xm_ad || ConfigApp.pf == ConfigApp.PF_r2game_kr_ad || ConfigApp.pf == ConfigApp.PF_r2game_kr_onestore){
                ToJava.callMethod("toUnBind",null,null);
            }
            else if(ConfigApp.pf == ConfigApp.PF_r2game_xm_ios || ConfigApp.pf == ConfigApp.PF_r2game_kr_ios){
                ToIOS.callFunc("toUnBind",null,null);
            }          
        }        
        public static function helpOther():void{
            var data:Object = {};
            data["rolename"] = ModelManager.instance.modelUser.uname;
            data["rolelevel"] = ModelManager.instance.modelUser.getLv();
            data["serverid"] = ModelManager.instance.modelUser.zone;
            if(ConfigApp.pf == ConfigApp.PF_r2game_xm_ad || ConfigApp.pf == ConfigApp.PF_r2game_kr_ad || ConfigApp.pf == ConfigApp.PF_r2game_kr_onestore){
                ToJava.callMethod("toHelp",data,null);
            }
            else if(ConfigApp.pf == ConfigApp.PF_r2game_xm_ios || ConfigApp.pf == ConfigApp.PF_r2game_kr_ios){
                ToIOS.callFunc("toHelp",null,data);
            }        
            else if(ConfigApp.pf == ConfigApp.PF_wx_changxiang){
                MiniAdpter.window.qingjs.instance.goCustomerService();
            }              
        }
        public static function bbsOther():void{
            if(ConfigApp.pf == ConfigApp.PF_r2game_kr_ad || ConfigApp.pf == ConfigApp.PF_r2game_kr_onestore){
                ToJava.callMethod("toBBS",{},null);
            }
            else if(ConfigApp.pf == ConfigApp.PF_r2game_kr_ios){
                ToIOS.callFunc("toBBS",null,{});
            } 
        }
        public static function helpService():void{
            if(
                ConfigApp.pf == ConfigApp.PF_r2game_xm_ad || 
                ConfigApp.pf == ConfigApp.PF_r2game_kr_ad || 
                ConfigApp.pf == ConfigApp.PF_r2game_kr_onestore ||
                ConfigApp.pf == ConfigApp.PF_r2game_xm_ios || 
                ConfigApp.pf == ConfigApp.PF_r2game_kr_ios){
                Platform.helpOther();
            }
            else{
                
            }
        }
        public static function payClose():void{
            ModelManager.instance.modelGame.event(ModelGame.EVENT_PAY_END);
            if(ConfigApp.releaseWeiXin()){

            }
            else if(ConfigApp.onAndroid){
            }
            else if(Render.isConchApp){
				// var conch:* = Browser.window["conch"];
				// conch.closeExternalLink();  
            }else{

            }
        } 
        /**
         * 应用宝自己的支付、特殊处理
         */
        public static function pay_yyb(payObj:Object,isSelf:Boolean = false):void{
            var coinNum:Number = payObj.cfg[0]*10;//ModelSalePay.getCoinNumByPID(payObj.pid,true)*10;
            var extOrder:String = payObj.pid+";"+payObj.zone+";"+payObj.uid+";"+payObj.pf;
            var oArr:Array =[coinNum,extOrder,Platform.login_type];
            ToJava.pay2(oArr,Handler.create(null,function(status:Number,obj:Object):void{
                //
                var yybPayRe:Object = obj;
                yybPayRe["pf"] = ConfigApp.pf;
                //
                yybPayRe["zoneId"] = 1;
                yybPayRe["amt"] = coinNum;
                yybPayRe["ext"] = extOrder;
                yybPayRe["billno"] = ModelManager.instance.modelUser.mUID+"A"+ConfigServer.getServerTimer();
                //
                NetHttp.instance.send(NetMethodCfg.HTTP_USER_YYB_PAY,yybPayRe,Handler.create(null,function(re:Object):void{
                    // trace("通知服务器支付成功返回",re);
                }));
                // trace("--yyb支付发起给服务器 -- "+JSON.stringify(yybPayRe));
            }));
        }     
        public static function initSDK():void{
            if(ConfigApp.pf_channel==""){
                //渠道没有,就是自己的pf
                ConfigApp.pf_channel = ConfigApp.pf;
            }
            if(ConfigApp.onAndroid()){
                ToJava.initSDK(ConfigApp.pf,Handler.create(null,function(re:*,obj:*):void{
                    Platform.initSDKback(re,(ConfigApp.pf == ConfigApp.PF_and_jj_meng52)?ConfigApp.PF_and_jj_meng52:ConfigApp.PF_and_1);
                }));
                //
                // MusicManager
                ToJava.callMethod("music_play",null,Handler.create(null,function():void{
                    MusicManager.resume();
                },null,false));
                ToJava.callMethod("music_stop",null,Handler.create(null,function():void{
                    MusicManager.pause();
                },null,false));
            }
            else if(ConfigApp.onIOS()){
                if(ConfigApp.pf == ConfigApp.PF_ios_meng52){//只有自己的ios才使用分包机制
                    ToIOS.callFunc("initSDK",function(channel:String):void{
                        // ToIOS.log(channel+" --channel-- " +ConfigApp.pf);
                        Platform.initSDKback(channel,ConfigApp.PF_ios_meng52);
                    },{package_type:ConfigApp.thisPackageType});
                }
                else{
                    
                    Platform.initSDKback(0,ConfigApp.pf);
                }
            }
            else{
                if(ConfigApp.pf == ConfigApp.PF_37_h5){
                    Platform.h5_sdk_obj = Browser.window.initSDK();
                }
                // else if(ConfigApp.pf == ConfigApp.PF_9130_h5){
                //     Platform.h5_sdk_obj = Browser.window.initSDK();
                // }
                else if(ConfigApp.pf == ConfigApp.PF_kuku_h5){
                    Platform.h5_sdk_obj = Browser.window.initSDK();
                    Platform.h5_sdk_obj.config(
                        "GK-20190327111838-1927",//KUKU平台分配游戏方的游戏标识
                        function (args:*):void {},//微信分享的状态回调函数
                        null
                    );
                } 
                else if(ConfigApp.pf == ConfigApp.PF_yyjh_h5 || ConfigApp.pf == ConfigApp.PF_yyjh2_h5 || ConfigApp.pf == ConfigApp.PF_JJ_yyjh_h5){
                    Platform.h5_sdk_obj = Browser.window.initSDK();
                    var yyjhObj:Object = Tools.getURLexpToObj(ConfigApp.url_params);
                    var index_yyjh:int= [ConfigApp.PF_yyjh_h5, ConfigApp.PF_yyjh2_h5, ConfigApp.PF_JJ_yyjh_h5].indexOf(ConfigApp.pf);
                    var yyjh_appkey:String = ["3866c245e0791eaabc84a49efe2d0ef2", "09fe331c3dc8a3d5a10d05345f1b7e17", "f3c9a6e058f9e6b12f380366583a96b1"][index_yyjh];
                    Platform.h5_sdk_obj.Init(
                        {
                            "account":yyjhObj.userid,
                            "appkey": yyjh_appkey,
                            "vaildCode":yyjhObj.vaildCode
                        }
                    );
                } else if(ConfigApp.pf == ConfigApp.PF_caohua1_h5){
                    var caohuaType:String = ConfigApp.chmj?ConfigApp.chmj:"1";
                    Platform.h5_sdk_obj = Browser.window.initSDK(caohuaType);
                    Platform.h5_sdk_obj.ready(function(response:*):void{
                        // trace("初始化后会执行"+response);

                    });
                } else if (ConfigApp.pf == ConfigApp.PF_caohua2_h5){
                    Platform.h5_sdk_obj = Browser.window.initSDK();
                } 
                // else if (ConfigApp.pf == ConfigApp.PF_bugu_h5){
                //     Platform.h5_sdk_obj = Browser.window.initSDK();
                //     Platform.h5_sdk_obj.ready();
                // } 
                else if (
                    ConfigApp.pf == ConfigApp.PF_JJ_tanwan_h5 ||
                    ConfigApp.pf == ConfigApp.PF_tanwan_h5 ||
                    ConfigApp.pf == ConfigApp.PF_tanwan2_h5 ||
                    ConfigApp.pf == ConfigApp.PF_tanwan3_h5 ||
                    ConfigApp.pf == ConfigApp.PF_tanwan4_h5 ||
                    // ConfigApp.pf == ConfigApp.PF_yuncai_h5 ||
                    ConfigApp.pf == ConfigApp.PF_7k_h5 ||
                    ConfigApp.pf == ConfigApp.PF_JJ_7k_h5 ||
                    ConfigApp.pf == ConfigApp.PF_leyou_h5 ||
                    ConfigApp.pf == ConfigApp.PF_360_h5 ||
                    ConfigApp.pf == ConfigApp.PF_360_2_h5 ||
                    ConfigApp.pf == ConfigApp.PF_360_3_h5 ||
                    ConfigApp.pf == ConfigApp.PF_1377_h5 ||
                    ConfigApp.pf == ConfigApp.PF_muzhi_h5 ||
                    ConfigApp.pf === ConfigApp.PF_muzhi2_h5 ||
                    ConfigApp.pf === ConfigApp.PF_hutao_h5 ||
                    ConfigApp.pf === ConfigApp.PF_hutao2_h5 ||
                    ConfigApp.pf === ConfigApp.PF_changxiang_h5 ||
                    ConfigApp.pf === ConfigApp.PF_changwan_h5 ||
                    // ConfigApp.pf === ConfigApp.PF_panbao_h5 ||
                    ConfigApp.pf === ConfigApp.PF_shouqu_h5 ||
                    ConfigApp.pf === ConfigApp.PF_qqdt_h5 ||
                    ConfigApp.pf === ConfigApp.PF_6kw_h5
                ){
                    Platform.h5_sdk_obj = Browser.window.initSDK();
                } else if (ConfigApp.pf == ConfigApp.PF_r2game_kr_h5){
                    Platform.h5_sdk_obj = {};
                } else {
                    Platform.initSDKback(0,ConfigApp.pf);
                }
            }
        }
        public static function initSDKback(re:*,pf:String):void{
            // trace("-- initSDKback --"+re+pf);
            if(re && (re is String)){
                var rpf:String = re;
                if(rpf && rpf.indexOf(pf)>-1){
                    ConfigApp.pf_channel = rpf;
                }
            }   
            
            Platform.force_update();
        }
        public static function logout(callback:Handler):void{
            if (h5_sdk) {
                h5_sdk.switchAccount();
            } else  if(ConfigApp.onAndroid()){
                ToJava.logout(callback);
            } else if(ConfigApp.onIOS()){

                if(ConfigApp.pf == ConfigApp.PF_ios_37){
                    ToIOS.callFunc("logout_sq",null,ConfigApp.pf);
                }
                else{
                    ToIOS.callFunc("logout",function(re:Object):void{
                        if(callback){
                            callback.runWith([0,re]);
                        }
                    },ConfigApp.pf);
                }
            } 
            // else if(ConfigApp.pf == ConfigApp.PF_9130_h5){
            //     Platform.h5_sdk_obj.logout(function(status:*,data:*):void{
            //         if(status == 0){
            //             callback.runWith([0,data]);
            //         }else{

            //         }
            //     });
            // } 
            else if( ConfigApp.pf == ConfigApp.PF_caohua1_h5){
                Platform.h5_sdk_obj.logout(function(res:*):void{
                    callback && callback.runWith([0, res]);
                });
            } else if (ConfigApp.pf == ConfigApp.PF_hutao_h5 || ConfigApp.pf === ConfigApp.PF_hutao2_h5){
                Platform.h5_sdk_obj.logout();
                Platform.restart();
            } else if (ConfigApp.pf == ConfigApp.PF_changwan_h5){
                Platform.h5_sdk_obj.loginout();
                Platform.restart();
            } else if(
                ConfigApp.pf == ConfigApp.PF_JJ_tanwan_h5 ||
                ConfigApp.pf == ConfigApp.PF_tanwan_h5 ||
                ConfigApp.pf == ConfigApp.PF_tanwan2_h5 ||
                ConfigApp.pf == ConfigApp.PF_tanwan3_h5 ||
                ConfigApp.pf == ConfigApp.PF_tanwan4_h5 ||
                ConfigApp.pf == ConfigApp.PF_1377_h5
            ){
                Platform.h5_sdk_obj.switchUser();
            } else if(ConfigApp.pf == ConfigApp.PF_360_3_h5){
                if (Platform.h5_sdk_obj.isSupportMethod('spChangeAccount')) {
                    Platform.h5_sdk_obj.spChangeAccount();
                }
            }
        }
        public static function login_cancel(callback:Handler):void{
            if(ConfigApp.onAndroid()){
                ToJava.callMethod("login_cancel",null,callback);
            }
            else if(ConfigApp.onIOS()){
                ToIOS.callFunc("login_cancel",function(re:Object):void{
                    if(callback){
                        callback.runWith([0,re]);
                    }
                },null);
            }
        }
        public static function login(callback:Handler,ext:String = ""):void{
            // trace("----系统类型判断------",Browser.onWeiXin,Browser.onMiniGame,Browser.onMobile);
            if (h5_sdk) {
                h5_sdk.login(callback)
            } else if(ConfigApp.releaseWeiXin()){
                if(ConfigApp.pf == ConfigApp.PF_wx_changxiang){
                    MiniAdpter.window.qingjs.instance.login({}, function (loginResult:*):void {
                        // loginResult.code // 200 为成功，其他则失败
                        // loginResult.uid // 用来标记唯一用户
                        // loginResult.token // 用户token
                        // loginResult.message // 登录结果描述
                        // trace("登录结束回调数据");
                        // trace(loginResult);
                        // if(loginResult.code==200){
                            callback && callback.runWith([loginResult.code, loginResult]);
                        // }
                    });
                }
                // MiniAdpter.window.wx.login({success:function(code:*):void{
                //     // trace("--微信登录-1---",code);
                //     if(callback){
                //         callback.runWith([0,code]);
                //     }
                // },fail:function():void{
                //     // trace("--微信登录-2---");
                //     if(callback){
                //         callback.runWith([500,null]);
                //     }
                // }});
            } else if (ConfigApp.releaseQQ()) {
                QQMiniAdapter.window.qq.login({
                    success: function(res:*):void {
                        callback && callback.runWith([0, res]);
                    },
                    fail: function():void {
                        callback && callback.runWith([500, {}]);
                    }
                });
            } else if (ConfigApp.onAndroid()){
                if(
                    ConfigApp.pf == ConfigApp.PF_huawei ||
                    ConfigApp.pf == ConfigApp.PF_huawei_tw ||
                    ConfigApp.pf == ConfigApp.PF_juedi || 
                    // ConfigApp.pf == ConfigApp.PF_juedi_ad ||
                    ConfigApp.pf == ConfigApp.PF_wende ||
                    ConfigApp.pf == ConfigApp.PF_vivo ||
                    // ConfigApp.pf == ConfigApp.PF_vivo_ad1 ||
                    // ConfigApp.pf == ConfigApp.PF_vivo_ad2 ||
                    ConfigApp.pf == ConfigApp.PF_oppo ||
                    ConfigApp.pf == ConfigApp.PF_yx7477 ||
                    ConfigApp.pf == ConfigApp.PF_yx7477_1 ||
                    ConfigApp.pf == ConfigApp.PF_xiaomi ||
                    ConfigApp.pf == ConfigApp.PF_uc ||
                    ConfigApp.pf == ConfigApp.PF_meizu ||
                    ConfigApp.pf == ConfigApp.PF_caohua ||
                    ConfigApp.pf == ConfigApp.PF_JJ_caohua_ad ||
                    // ConfigApp.pf == ConfigApp.PF_yqwb ||
                    // ConfigApp.pf == ConfigApp.PF_efun_google ||
                    // ConfigApp.pf == ConfigApp.PF_hf ||
                    ConfigApp.pf == ConfigApp.PF_r2game_xm_ad ||
                    ConfigApp.pf == ConfigApp.PF_r2game_kr_ad ||
                    ConfigApp.pf == ConfigApp.PF_r2game_kr_onestore || 
                    ConfigApp.pf == ConfigApp.PF_77you_ad_jp ||
                    ConfigApp.pf == ConfigApp.PF_77you_ad_tw ||
                    ConfigApp.pf == ConfigApp.PF_360_ad ||
                    ConfigApp.pf == ConfigApp.PF_6kw_ad 
                    // ConfigApp.pf == ConfigApp.PF_panbao_ad
                    // ConfigApp.pf == ConfigApp.PF_samsung ||
				    // ConfigApp.pf == ConfigApp.PF_efun_one
                ){
                    ToJava.login(ConfigApp.pf,callback);
                    //
                    Platform.getPayListInfo();
                }
                else if(
                    ConfigApp.onAndroidYYB() ||
                    ConfigApp.pf == ConfigApp.PF_and_google){
                    if(ext==TAG_LOGIN_TYPE_MENG52){
                        ModelPlayer.instance.getVisitorData(ConfigApp.pf,callback);
                    }
                    else if(ext == Platform.TAG_LOGIN_TYPE_TUP){
                        ModelPlayer.instance.getVisitorDataTemp(ConfigApp.pf,callback);
                    }
                    else{
                        ToJava.login(ext,callback);
                    }
                }                             
                else{
                    if(callback){
                        callback.runWith([0,null]);
                    }
                }
            }
            else{
                
                // if(ConfigApp.pf == ConfigApp.PF_xh_h5){
                //     Browser.window.xh_login();
                //     Laya.timer.once(1000,null,function():void{
                //         var loginData:* = Browser.window.xh_getLoginData();
                //         // trace(loginData);
                //         pf_login_data = loginData;
                //         //
                //         if(callback){
                //             callback.runWith([0,loginData]);
                //         }
                //     });
                // }
                // if(ConfigApp.pf == ConfigApp.PF_wx_h5){
                //     var wx_web_code:String = Tools.getURLexp("wx_web_oid");
                //     if(wx_web_code){
                //         if(callback){
                //             callback.runWith([0,wx_web_code]);
                //         }
                //     }
                // }
                // if(ConfigApp.pf == ConfigApp.PF_bugu_h5){
                //     Platform.h5_sdk_url_data = Tools.getURLexpToObj(ConfigApp.url_params);
                //     Platform.h5_sdk_obj.loginSdk({
                //         game_appid:Platform.h5_sdk_url_data.game_appid,sdkloginmodel:Platform.h5_sdk_url_data.sdkloginmodel,channelExt:Platform.h5_sdk_url_data.channelExt},function(re:*):void{
                //         if(callback){
                //             // "{"email":"","game_appid":"1870EF5BB448EF3B3","new_time":1560940776,"user_id":"29811","sign":"05592415cf0d1e382750381f75cfc638","icon":"","nickname":"liuhaitao1","sdkloginmodel":"media2.php"}"
                //             var d:Object = JSON.parse(re);
                //             var c:Object = {email:d.email,game_appid:d.game_appid,new_time:d.new_time,user_id:d.user_id,sign:d.sign};
                //             callback.runWith([0,c]);
                //         }
                //     });
                // }
                if(
                        // ConfigApp.pf == ConfigApp.PF_37_ios 
                        // || ConfigApp.pf == ConfigApp.PF_juedi_ios
                        ConfigApp.pf == ConfigApp.PF_wende_ios
                        || ConfigApp.pf == ConfigApp.PF_r2game_xm_ios 
                        || ConfigApp.pf == ConfigApp.PF_r2game_kr_ios
                        // || ConfigApp.pf == ConfigApp.PF_panbao_ios
                        || ConfigApp.pf == ConfigApp.PF_77you_ios_tw
                        || ConfigApp.pf == ConfigApp.PF_77you_ios_jp
                        || ConfigApp.pf == ConfigApp.PF_caohua_ios
                        // || ConfigApp.pf == ConfigApp.PF_ios_meng52_mj1
                        || ConfigApp.pf == ConfigApp.PF_ios_meng52_tw
                ){
                    var diff:Boolean = false;
                    if(ConfigApp.pf == ConfigApp.PF_ios_meng52_tw){
                        diff = true;
                    }
                    if((ext==TAG_LOGIN_TYPE_MENG52) && diff){
                        ModelPlayer.instance.getVisitorData(ConfigApp.pf,callback);
                    }
                    else if((ext == Platform.TAG_LOGIN_TYPE_TUP) && diff){
                        ModelPlayer.instance.getVisitorDataTemp(ConfigApp.pf,callback);
                    }
                    else{
                        // Browser.window.alert("--"+diff);
                        ToIOS.callFunc("login",function(re:Object):void{
                            // ToIOS.callFunc("mobilePrint", null, re);       //调试用，随时可删

                            if(callback){
                                callback.runWith([0,re]);
                            }
                        },diff?{type:ext}:ConfigApp.pf);
                    }
                }
                else if(ConfigApp.pf == ConfigApp.PF_ios_37){
                    var tempUser:Object = SaveLocal.getValue(SaveLocal.KEY_USER);
                    var tempName:String = "";
                    var tempPwd:String = "";
                    if(tempUser){
                        tempName = tempUser.name;
                        tempPwd = tempUser.pwd_s;
                    }
                    if(tempName && tempName.indexOf(ConfigApp.PF_ios_37)>-1){
                        tempName = ""
                        tempPwd = "";
                    }
                    // trace("PF_ios_37 ==>>",tempName,tempPwd);
                    var toUpdate:Boolean = true;
                    var userList:Object = SaveLocal.getValue(SaveLocal.KEY_USER_LIST);
                    var lists:Object = {};
                    for(var u:String in userList){
                        lists[userList[u]["name"]] = userList[u]["pwd_s"];
                    }
                    ToIOS.callFunc("is_ios_sq",function(re:*):void{
                        toUpdate = false;
                        ToIOS.callFunc("login_sq",function(re:*):void{
                            callback && callback.runWith([0,re]);
                        },{"name":tempName,"pwd":tempPwd});
                    },lists);
                    Laya.timer.once(2000,null,function():void{
                        if(toUpdate){
                            ViewManager.instance.showWarnAlert("请前往苹果商店更新APP到最新版本",Handler.create(null,function():void{
                                Browser.window.openHtml("https://apps.apple.com/app/id1435453697");
                            }));
                        }
                    });
                }
                else if(ConfigApp.pf == ConfigApp.PF_37_h5){
                    if(callback){
                        var data37:Object = Tools.getURLexpToObj(ConfigApp.url_params);
                        //
                        callback.runWith([0,data37]);
                    }
                }
                // else if(ConfigApp.pf == ConfigApp.PF_9130_h5){
                //     Platform.h5_sdk_obj.login(function(status:*,data:*):void{
                //         if(status == 0){
                //             callback.runWith([0,data]);
                //         }else{

                //         }
                //     });
                // }
                else if(ConfigApp.pf == ConfigApp.PF_kuku_h5){
                    Platform.h5_sdk_obj.getUserInfo(function(data:*):void{
                        // console.log('游戏调用了用户信息获取，结果=',data)                        
                        callback.runWith([0,data]);
                    });
                }
                else if(ConfigApp.pf == ConfigApp.PF_yyjh_h5 || ConfigApp.pf === ConfigApp.PF_yyjh2_h5 || ConfigApp.pf == ConfigApp.PF_JJ_yyjh_h5){
                    if(callback){
                        var dataYYJH:Object = Tools.getURLexpToObj(ConfigApp.url_params);
                        callback.runWith([0,dataYYJH]);
                    }
                } else if(ConfigApp.pf == ConfigApp.PF_caohua1_h5){
                    Platform.h5_sdk_obj.login(function(response:*):void{
                    // console.log(“登陆返回”);
                        if(response.code == 200){
                            var s:Object = response.data;
                            s["config_type"] = ConfigApp.chmj;
                            callback.runWith([0,response.data]);
                        }
                    });
                } else if (ConfigApp.pf === ConfigApp.PF_caohua2_h5) {
                    Platform.h5_sdk_obj.login_v(function(token:String, userid:String):void{
                        callback && callback.runWith([0, { config_type: ConfigApp.chmj, token: token, userid: userid }]);
                    });

                } else if (
                    ConfigApp.pf == ConfigApp.PF_JJ_tanwan_h5 ||
                    ConfigApp.pf == ConfigApp.PF_tanwan_h5 ||
                    ConfigApp.pf == ConfigApp.PF_tanwan2_h5 ||
                    ConfigApp.pf == ConfigApp.PF_tanwan3_h5 ||
                    ConfigApp.pf == ConfigApp.PF_tanwan4_h5
                ) {
                    Platform.h5_sdk_url_data = Tools.getURLexpToObj(ConfigApp.url_params);
                    callback && callback.runWith([0, Platform.h5_sdk_url_data]);
                } else if (ConfigApp.pf == ConfigApp.PF_7k_h5 || ConfigApp.pf === ConfigApp.PF_JJ_7k_h5) {
                    callback && callback.runWith([0, Tools.getURLexpToObj(ConfigApp.url_params)]);
                } 
                // else if (ConfigApp.pf == ConfigApp.PF_yuncai_h5) {
                //     Browser.window.giveToken = function(token):String {
                //         // console.log(token); // 这就是要获取的 token
                //         Platform.h5_sdk_obj.getUserInfo({token: token});
                //         callback && callback.runWith([0, Tools.getURLexpToObj(ConfigApp.url_params)]);
                //     }
                //     Platform.h5_sdk_obj.login();
                // } 
                else if (ConfigApp.pf === ConfigApp.PF_r2game_kr_h5){
                    var params:Object = Tools.getURLexpToObj(ConfigApp.url_params);
                    params[ConfigApp.PF_r2game_kr_h5] = 1;
                    callback && callback.runWith([0, params]);
                } else if (
                    ConfigApp.pf === ConfigApp.PF_leyou_h5 ||
                    ConfigApp.pf === ConfigApp.PF_360_h5 ||
                    ConfigApp.pf === ConfigApp.PF_1377_h5 ||
                    ConfigApp.pf === ConfigApp.PF_muzhi_h5 ||
                    ConfigApp.pf === ConfigApp.PF_muzhi2_h5
                ){
                    callback && callback.runWith([0, Tools.getURLexpToObj(ConfigApp.url_params)]);
                } else if (ConfigApp.pf === ConfigApp.PF_360_2_h5){
                    Platform.h5_sdk_obj.getUserInfo().then(function(userInfo:Object):void {
                        ConstantZM.initPlatform({
                            userInfo: userInfo,
                            params: Tools.getURLexpToObj(ConfigApp.url_params)
                        });
                        callback && callback.runWith([0, userInfo]);
                    }).catch(function(err):void {
                        // console.log(err);
                    });
                } else if (ConfigApp.pf === ConfigApp.PF_360_3_h5){
                    var userInfo_360:Object = Platform.h5_sdk_obj.getUserInfo();
                    ConstantZM.initPlatform({
                        userInfo: userInfo_360,
                        params: Tools.getURLexpToObj(ConfigApp.url_params)
                    });
                    callback && callback.runWith([0, userInfo_360]);
                    
                    if (Platform.h5_sdk_obj.isSupportMethod('setShareInfo')) {
                        var share_pf:Object = ConfigServer.system_simple.share_pf;
                        var cfgArr:Array = share_pf[ConfigApp.pf];
                        cfgArr && Platform.h5_sdk_obj.setShareInfo({title: Tools.getMsgById(cfgArr[0]), content: Tools.getMsgById(cfgArr[1]), imgurl: cfgArr[2]}, function(re:*):void{
                            re.success === 'ok' && Platform.eventListener.event(Platform.EVENT_SHARE_OK);
                        });
                    }
                } else if (ConfigApp.pf === ConfigApp.PF_hutao_h5 || ConfigApp.pf === ConfigApp.PF_hutao2_h5){
                    Platform.h5_sdk_obj.login(function(code:String, verify_url:String, sign:String):void{
                        callback && callback.runWith([0, {code: code, verify_url: verify_url , sign: sign}]);
                    });
                } else if (ConfigApp.pf === ConfigApp.PF_changwan_h5) {
                    Platform.h5_sdk_obj.login_v(function(login_result:Object):void{
                        var data_changwan:Object = SaveLocal.getValue('my_h5_args');
                        data_changwan = ObjectUtil.mergeObjects([data_changwan, Tools.getURLexpToObj(ConfigApp.url_params)]);
                        callback && callback.runWith([0, data_changwan]);
                    });
                } 
                // else if (ConfigApp.pf === ConfigApp.PF_panbao_h5) {
                //     var panbao_params:Object = Tools.getURLexpToObj(ConfigApp.url_params);
                //     callback && callback.runWith([0, panbao_params]);
                // } 
                else if (ConfigApp.pf === ConfigApp.PF_changxiang_h5){
                    Platform.h5_sdk_obj.login(function(login_result:Object):void{
                        callback && callback.runWith([0, login_result]);
                    });
                } else if (ConfigApp.pf == ConfigApp.PF_qqdt_h5){
                    console.log('QQ大厅登录');
                    // callback && callback.runWith([0, Tools.getURLexpToObj(ConfigApp.url_params)]);
                } else if (ConfigApp.pf == ConfigApp.PF_6kw_h5){
                    callback && callback.runWith([0, Tools.getURLexpToObj(ConfigApp.url_params)]);
                } else if (ConfigApp.pf == ConfigApp.PF_shouqu_h5){
                    Platform.h5_sdk_obj.getUser(function(login_result:Object):void{
                        callback && callback.runWith([0, login_result]);
                    });
                } else if(callback){
                    callback.runWith([0,null]);
                }
            }            
        }
        public static function isNet():Boolean{
            if(ConfigApp.releaseWeiXin() || ConfigApp.releaseQQ()){
                return true;
            }
            else if(Render.isConchApp){
                return Browser.window["conch"].config.getNetworkType()!=0;
            }else{
                return __JS__("navigator.onLine");
            }             
            return false;
        }
        /**
         * 设备 imei
         *  */   
        public static function getPhoneID():void{
            if(ConfigApp.onAndroid()){
                ToJava.getPhoneID(ConfigApp.pf,Handler.create(null,function(status:*,obj:*):void{
                    // trace("获取安卓设备:"+obj);
                    Platform.phoneID = obj;//866716035783137
                }));
            }
            else if(ConfigApp.onIOS()){
                ToIOS.callFunc("getPhoneID",function(idfa:String):void{
                    Platform.phoneID = idfa;//866716035783137
                    // ToIOS.log("000:::=="+idfa);
                },{});
            }
        }
        public static function getPhoneIDs():String{
            if(Platform.phoneID && Platform.phoneID!=""){
                return Platform.phoneID;
            }  
            else if(ConfigApp.midfa && ConfigApp.midfa!=""){
                Platform.phoneID = ConfigApp.midfa;
            }
            else if(ConfigApp.mdevice && ConfigApp.mdevice!=""){
                Platform.phoneID = ConfigApp.mdevice;
            }
            if(ConfigApp.pf == ConfigApp.PF_360_2_h5){
                Platform.phoneID = "";
            }
            return Platform.phoneID;
        }
        public static function showGameIndex():void{
            if(Browser.window["clearLoadingDiv"]){
				Browser.window["clearLoadingDiv"]();
			}
            if(Browser.window["clearLoadingDivClip"]){
				Browser.window["clearLoadingDivClip"]();
			}
            if(ConfigApp.onIOS()){
                ToIOS.callFunc("clearIndexLogo",null,null);
            }
            // else if(ConfigApp.pf == ConfigApp.PF_ios_meng52_mjm3){
            //     Browser.window.location.href="unitywebviewapp://game-msg?jstr="+JSON.stringify({"method":"abc","prama":"9980"});
            // }
        }
        public static function checkPackage():void{
            if(ConfigApp.onAndroid()){
                ToJava.callMethod("checkPackage",ConfigApp.pf,Handler.create(null,function(rst:*,method:String):void{
                    // trace("---检查安装包更新机制AAA---"+rst);
                    // if(rst==1){
                        ConfigApp.isUpdateApp = 1;
                    // }
                }));
            }
        }
        public static function checkPackageAlert():Boolean{
            return false;//临时不开启这个功能
            if(ConfigServer.system_simple.update_app && ConfigServer.system_simple.update_app[ConfigApp.pf] && ConfigApp.isUpdateApp<0){
                ConfigApp.updateAppURL = ConfigServer.system_simple.update_app[ConfigApp.pf];
                // trace("---检查安装包更新机制BBB---"+ConfigApp.updateAppURL);
                return true;
            }
            else{
                return false;
            }
        }
               
        /**
         * 数据统计
         */
        public static function uploadUserData(type:Number,params:Array = null):void{
            var infoData:Object = null;
            var user:ModelUser = ModelManager.instance.modelUser; // 用户数据
            var serverName:String = '';
            if (ConfigServer.zone[user.zone] && ConfigServer.zone[user.zone][0]) {
                serverName = ConfigServer.zone[user.zone][0];
            }
            var paramData:Object = Tools.getURLexpToObj(ConfigApp.url_params); // 参数字典
            if (h5_sdk) {
                h5_sdk.log(type, serverName);
            } else if(ConfigApp.releaseWeiXin()){
                if(ConfigApp.pf == ConfigApp.PF_wx_changxiang){
                    if(type==1000 || type==1 || type==2){
                        // 
                        // 上报角色信息
                        //
                        infoData = {
                            "roleId":ModelManager.instance.modelUser.mUID,           // string
                            "roleName": ModelManager.instance.modelUser.uname,     // string
                            "roleLevel": ModelManager.instance.modelUser.getLv(),               // int 角色等级
                            "serverId": ModelManager.instance.modelUser.zone,     // string 区服ID需要唯一标识玩家所在区服，如果同时有区ID和服务器ID，请用竖线 “|” 连接起来
                            "serverName": ConfigServer.zone[ModelManager.instance.modelUser.zone][0],  // string
                            "roleVip": 0,                   // int 角色vip等级
                            "rolePower":type==2?ModelManager.instance.modelUser.getPower():0,              // int 战力、武力之类角色的核心数值   
                            "reportType":type==1?"entergame":(type==2?"roleupgrade":"createrole")   // string 上报类型 "entergame" , "createrole", "roleupgrade"
                        };
                        MiniAdpter.window.qingjs.instance.reportRoleInfo(infoData, function(result:*):void{

                            // trace(MiniAdpter.window.qingjs.instance.instance.canPay());
                            // trace("上报数据",infoData,MiniAdpter.window.qingjs.instance.canPay());

                        });
                    }
                }
            }
            else if(ConfigApp.onAndroid()){
                //  if(
                //         ConfigApp.pf == ConfigApp.PF_efun_google ||
                //         ConfigApp.pf == ConfigApp.PF_efun_one ||
                //         ConfigApp.pf == ConfigApp.PF_efun_ios
                // ){
                //     infoData = Platform.getGameUserEfun(type);
                //     // trace("---uploadUserData---"+JSON.stringify(efunData));
                //     if(infoData){
                //         ToJava.savePlayerInfo(infoData,null);
                //     }
                // }
                if(ConfigApp.pf == ConfigApp.PF_juedi || ConfigApp.pf == ConfigApp.PF_juedi_ad){
                    ToJava.savePlayerInfo(getGameUserDataJUEDI(type,params),null);
                }
                else if(ConfigApp.pf == ConfigApp.PF_wende){
                    infoData = {
                        "uid":ModelManager.instance.modelUser.mUID+"",
                        "sid":ModelManager.instance.modelUser.zone+'',
                        "sname":ModelManager.instance.modelUser.zone+'',
                        "uname":ModelManager.instance.modelUser.uname+'',
                        "lv":ModelManager.instance.modelUser.getLv()+''
                    }
                    ToJava.savePlayerInfo(infoData,null);
                }
                else if(ConfigApp.pf == ConfigApp.PF_and_google){
                    infoData = Platform.toFacebook(type,params);
                    if(infoData){
                        ToJava.savePlayerInfo(infoData,null);
                    }
                }
                else if(ConfigApp.pf == ConfigApp.PF_r2game_xm_ad || ConfigApp.pf == ConfigApp.PF_r2game_kr_ad || ConfigApp.pf == ConfigApp.PF_r2game_kr_onestore){
                    infoData = Platform.toR2GameAppsFlyer(type,params);
                    if(infoData){
                        ToJava.savePlayerInfo(infoData,null);
                    }
                }
                else if(ConfigApp.pf == ConfigApp.PF_77you_ad_jp || ConfigApp.pf == ConfigApp.PF_77you_ad_tw) {
                    infoData = Platform.toYou77(type,params);
                    if(infoData){
                        ToJava.savePlayerInfo(infoData,null);
                    }
                }
                else if(ConfigApp.pf == ConfigApp.PF_6kw_ad) {
                    infoData = Platform.to6KW(type,params);
                    if(infoData){
                        ToJava.savePlayerInfo(infoData,null);
                    }
                }
                // else if(ConfigApp.pf == ConfigApp.PF_panbao_ad) {
                //     infoData = Platform.toPanbao(type,params);
                //     if(infoData){
                //         ToJava.savePlayerInfo(infoData,null);
                //     }
                // }
                // else if(ConfigApp.pf == ConfigApp.PF_hf){
                //     // TYPE_SELECT_SERVER 角色进入游戏前
                //     // TYPE_CREATE_ROLE 创建角色后 角色登录 
                //     // TYPE_ENTER_GAME 角色进入游戏后 等级提升
                //     // TYPE_LEVEL_UP 角色等级提升
                //     // TYPE_EXIT_GAME 
                //     infoData = Platform.toHanfeng(type);
                //     ToJava.savePlayerInfo(infoData,null);
                //     if(type==1){
                //         infoData.type = 100;
                //         ToJava.savePlayerInfo(infoData,null);
                //     }
                // }
                else if(ConfigApp.pf == ConfigApp.PF_caohua || ConfigApp.pf == ConfigApp.PF_JJ_caohua_ad){
                    if(type == 0 || type==1 || type==2){
                        ToJava.savePlayerInfo(Platform.toChaohua(type),null);
                    }
                }
                else if(ConfigApp.pf == ConfigApp.PF_yx7477 || ConfigApp.pf == ConfigApp.PF_yx7477_1){
                    if(type==1000 || type==1 || type == 2){
                        ToJava.savePlayerInfo({"role":ModelManager.instance.modelUser.uname,"lv":ModelManager.instance.modelUser.getLv()},null);
                    }
                }
                else{
                    if(type==1){
                        if(ConfigApp.pf == ConfigApp.PF_oppo){
                            ToJava.savePlayerInfo(getGameUserDataOPPO(),null);
                        }
                        else if(ConfigApp.pf == ConfigApp.PF_uc){
                            ToJava.savePlayerInfo(getGameUserDataUC(),null);
                        }
                        else{
                            ToJava.savePlayerInfo(getGameUserData3(),null);
                        }
                    }
                }
                
            }else{
                if(ConfigApp.pf == ConfigApp.PF_37_h5){
                    infoData = Platform.getGameUserData37(type,params);
                    if(infoData){
                        Platform.h5_sdk_obj.log(infoData,infoData.method);
                        if(infoData.method == "entergame"){
                            infoData.method = "server";
                            Platform.h5_sdk_obj.log(infoData,infoData.method);
                        }
                    }
                }
                else if(ConfigApp.pf == ConfigApp.PF_ios_37){
                    if(type==1000 || type == 1){
                        ToIOS.callFunc("report_sq",function(re:*):void{
                        },{"sid":ModelManager.instance.modelUser.zone+"","sname":serverName,"type":type+""});
                    }
                }
                // else if(ConfigApp.pf == ConfigApp.PF_37_ios){
                //     if(type == 0 || type == 1){
                //         ToIOS.callFunc("info"+type,function(re:*):void{
                //         },{sid:user.zone,sname:user.zone});
                //     }
                // }
                else if(ConfigApp.pf == ConfigApp.PF_caohua_ios){
                    if(type == 0 || type==1 || type==2){
                        ToIOS.callFunc("info",function(re:*):void{
                        },Platform.toChaohua(type));
                    }
                }
                else if(ConfigApp.pf == ConfigApp.PF_77you_ios_tw || ConfigApp.pf == ConfigApp.PF_77you_ios_jp) {
                    infoData = toYou77(type,params);
                    if (!infoData) {
                        return;
                    }

                    ToIOS.callFunc("info",function(re:*):void{
                    },infoData);
                }
                else if(ConfigApp.pf == ConfigApp.PF_wende_ios){
                    infoData = {
                        "uid":ModelManager.instance.modelUser.mUID+"",
                        "type":type+"",
                        "sid":ModelManager.instance.modelUser.zone+'',
                        "sname":ModelManager.instance.modelUser.zone+'',
                        "uname":ModelManager.instance.modelUser.uname+'',
                        "lv":ModelManager.instance.modelUser.getLv()+'',
                        "vip":0+'',
                        "money":ModelManager.instance.modelUser.coin+''
                    }
                    ToIOS.callFunc("info",function(re:*):void{
                    },infoData);
                }
                else if(ConfigApp.pf == ConfigApp.PF_ios_meng52_tw || ConfigApp.pf == ConfigApp.PF_ios_meng52 || ConfigApp.pf == ConfigApp.PF_ios_meng52_hk){
                    infoData = Platform.toFacebook(type,params);
                    if(infoData){
                        ToIOS.callFunc("savePlayerInfo",function(re:*):void{
                        },infoData);
                    }
                }
                // else if(ConfigApp.pf == ConfigApp.PF_9130_h5){
                //     Platform.to9130(type);
                // }
                else if(ConfigApp.pf == ConfigApp.PF_yyjh_h5 || ConfigApp.pf == ConfigApp.PF_yyjh2_h5 || ConfigApp.pf == ConfigApp.PF_JJ_yyjh_h5){
                    infoData = Platform.toYYJH(type);
                    if(infoData){
                        Platform.h5_sdk_obj.RoleInfo(infoData);
                    }
                } else if (ConfigApp.pf == ConfigApp.PF_caohua1_h5){
                    if(type==1){
                        Platform.h5_sdk_obj.enterGame({
                            "serverName":user.zone,
                            "serverId":user.zone,
                            "roleLevel":user.getLv(),
                            "roleName":user.uname,
                            "roleId":user.mUID
                        });
                    }
                    else if(type==2){
                        Platform.h5_sdk_obj.roleLevel({
                            "roleLevel":user.getLv()
                        });
                    }
                } else if(ConfigApp.pf == ConfigApp.PF_caohua2_h5) {
                    Platform.h5_sdk_obj.sdk_enterGame(user.zone, user.zone, user.mUID, user.uname);
                } else if(ConfigApp.pf == ConfigApp.PF_r2game_xm_ios || ConfigApp.pf == ConfigApp.PF_r2game_kr_ios) {
                    infoData = Platform.toR2GameAppsFlyer(type,params);
                    if(infoData){
                        ToIOS.callFunc("savePlayerInfo",null,infoData);
                    }
                } 
                // else if(ConfigApp.pf == ConfigApp.PF_panbao_ios) {
                //     infoData = Platform.toPanbao(type,params);
                //     if(infoData){
                //         ToIOS.callFunc("savePlayerInfo",null,infoData);
                //     }
                // } 
                else if (
                    ConfigApp.pf == ConfigApp.PF_JJ_tanwan_h5 ||
                    ConfigApp.pf == ConfigApp.PF_tanwan_h5 ||
                    ConfigApp.pf == ConfigApp.PF_tanwan2_h5 ||
                    ConfigApp.pf == ConfigApp.PF_tanwan3_h5 ||
                    ConfigApp.pf == ConfigApp.PF_tanwan4_h5
                ) {
                    Platform.h5_sdk_url_data = paramData;
                    var map_tanwan:Object = {
                        '0': 1, // 选择服务器
                        '1': 3, // 进入游戏
                        '2': 4, // 等级提升 
                        '6': 5  // 注销 
                    };
                    var dataType:int = map_tanwan[type];
                    dataType && Platform.h5_sdk_obj.reportUserInfo({
                        dataType : dataType,   	        // 上报类型,1(选择服务器)，2(创建角色)，3(进入游戏)、4(等级提升)、5(退出游戏)
                        appid : paramData.appid,        // 固定值(平台游戏标示)
                        serverID : user.zone,    	    // 区服ID
                        serverName : String(user.zone), // 区服名,
                        userId : paramData.uid,         // 平台用户ID
                        roleID : user.mUID,      	    // 角色ID,
                        roleName : user.uname,   	    // 角色名,
                        roleLevel : user.getLv(),       // 角色等级,
                        moneyNum : user.coin  		    // 角色元宝数
                    });
                    if (type == 0) {
                        Platform.h5_sdk_obj.reportUserInfo({
                            dataType : 2,   	            // 上报类型,1(选择服务器)，2(创建角色)，3(进入游戏)、4(等级提升)、5(退出游戏)
                            appid : paramData.appid,        // 固定值(平台游戏标示)
                            serverID : user.zone,    	    // 区服ID
                            serverName : String(user.zone), // 区服名,
                            userId : paramData.uid,         // 平台用户ID
                            roleID : user.mUID,      	    // 角色ID,
                            roleName : user.uname,   	    // 角色名,
                            roleLevel : user.getLv(),       // 角色等级,
                            moneyNum : user.coin  		    // 角色元宝数
                        });
                    }
                } else if (ConfigApp.pf === ConfigApp.PF_7k_h5 || ConfigApp.pf === ConfigApp.PF_JJ_7k_h5) {
                    Platform.h5_sdk_url_data = paramData;
                    type === 1 && Platform.h5_sdk_obj.RoleInfo({
                        "serverid": user.zone,
                        "servername": user.zone+"",
                        "roleid": user.mUID,
                        "rolename": user.uname,
                        "rolelevel": user.getLv(),
                        "appkey": ConfigApp.pf === ConfigApp.PF_7k_h5? "f0cab6ba16c0436702f896fe3c6632dc" : "46fc1a6626a6d2317893b8cb8ebde833",
                        "account": paramData.userid
                    });
                } else if (ConfigApp.pf === ConfigApp.PF_leyou_h5) { // 创角上报
                    Platform.h5_sdk_url_data = paramData;
                    var url:String = ConfigApp.get_data_report();
                    if (type == 0) {
                        url += StringUtil.substitute('user/role?userid={0}&username={1}&appkey={2}&banid={3}&servername={4}&roleid={5}&rolename={6}', [
                            paramData.userid, paramData.username, paramData.appkey, paramData.banid, String(user.zone), user.mUID, user.uname
                        ]);
                        NetHttp.instance.getRequest(url);
                    } else if (type === 2) {
                        url += StringUtil.substitute('user/level?userid={0}&username={1}&appkey={2}&banid={3}&servername={4}&roleid={5}&rolename={6}&level={7}', [
                            paramData.userid, paramData.username, paramData.appkey, paramData.banid, String(user.zone), user.mUID, user.uname, user.getLv()
                        ]);
                        NetHttp.instance.getRequest(url);
                    }
                } else if (ConfigApp.pf === ConfigApp.PF_1377_h5) {
                    Platform.h5_sdk_url_data = paramData;
                    var map_1377:Object = {
                        '0': 1, // 选择服务器
                        '1': 3, // 进入游戏
                        '2': 4, // 等级提升 
                        '6': 5  // 注销 
                    };
                    var reportType:int = map_1377[type];
                    reportType && Platform.h5_sdk_obj.report_user_action({
                        type: reportType,   	        // 上报类型,1(选择服务器)，2(创建角色)，3(进入游戏)、4(等级提升)、5(退出游戏)
                        gameId : paramData.appid,       // 赞钛平台游戏ID
                        serverId : user.zone,    	    // 区服ID
                        serverName : String(user.zone), // 区服名,
                        uid : paramData.uid,            // 平台用户ID
                        roleId : user.mUID,      	    // 角色ID,
                        roleName : user.uname,   	    // 角色名,
                        roleLevel : user.getLv(),       // 角色等级,
                        money : user.coin  		        // 角色元宝数
                    });
                    if (type == 0) {
                        Platform.h5_sdk_obj.report_user_action({
                            type: 2,   	        // 上报类型,1(选择服务器)，2(创建角色)，3(进入游戏)、4(等级提升)、5(退出游戏)
                            gameId : paramData.appid,       // 赞钛平台游戏ID
                            serverId : user.zone,    	    // 区服ID
                            serverName : String(user.zone), // 区服名,
                            uid : paramData.uid,            // 平台用户ID
                            roleId : user.mUID,      	    // 角色ID,
                            roleName : user.uname,   	    // 角色名,
                            roleLevel : user.getLv(),       // 角色等级,
                            money : user.coin  		        // 角色元宝数
                        });
                    }                   
                } else if (ConfigApp.pf === ConfigApp.PF_360_2_h5) {
                    Platform.h5_sdk_obj.getUserInfo().then(function(userInfo:Object):void {
                        var createTime:int = Tools.getTimeStamp(user.add_time);
                        if (type === 1) { // 登录
                            Platform.h5_sdk_obj.logRoleLogin(userInfo.plat_user_id, user.mUID, user.zone, user.uname, user.getLv());
                        } else if (type === 0) { // 创角
                            Platform.h5_sdk_obj.logRoleCreation(userInfo.plat_user_id, user.mUID, user.zone, user.uname, user.getLv(), createTime);
                        }
                        var roleInfo_ald:Object = {
                            plat_user_id: userInfo.plat_user_id,// 平台用户id
                            roleid: user.mUID,              // 游戏角色id
                            server_id: user.zone,           // 区服ID
                            server_name: String(user.zone), // 区服名称
                            level: user.getLv(),            // 角色等级
                            power: 0,                       // 角色战力
                            rolename: user.uname,           // 角色名字
                            createTime: createTime          // 创角时间
                        }
                        if (type === 0 || type === 2 || type === 3) { // 创角 或 角色信息发生变化
                            Platform.h5_sdk_obj.logRoleInfo(roleInfo_ald);
                        }
                        var map_ald:Object = {
                            '0': 'role_create', // 创建角色
                            '1': 'role_login', // 进入游戏
                            '2': 'role_update' // 等级提升 
                        };
                        map_ald[type] && Platform.h5_sdk_obj.pushRoleInfo(map_ald[type], roleInfo_ald);
                    }).catch(function(err:*):void {
                        console.warn && console.warn(err);
                    });
                } else if (ConfigApp.pf === ConfigApp.PF_360_3_h5) {
                    var map_360:Object = {
                        '0': 1, // 选择服务器
                        '1': 3, // 进入游戏
                        '2': 4, // 等级提升 
                        '6': 5  // 注销 
                    };
                    map_360[type] && Platform.h5_sdk_obj.reportRoleStatus({
                        datatype: map_360[type],        // 上报类型,1(选择服务器)，2(创建角色)，3(进入游戏)、4(等级提升)、5(退出游戏)
                        serverid : user.zone,    	    // 区服ID
                        servername : String(user.zone), // 区服名,
                        roleid : user.mUID,      	    // 角色ID,
                        rolename : user.uname,   	    // 角色名,
                        rolelevel : user.getLv(),       // 角色等级,
                        fightvalue: 0,                  // 战力
                        moneynum : user.coin  		    // 角色元宝数
                    });
                    if (type == 0) {
                        Platform.h5_sdk_obj.reportRoleStatus({
                            datatype: 2,   	                // 上报类型,1(选择服务器)，2(创建角色)，3(进入游戏)、4(等级提升)、5(退出游戏)
                            serverid : user.zone,    	    // 区服ID
                            servername : String(user.zone), // 区服名,
                            roleid : user.mUID,      	    // 角色ID,
                            rolename : user.uname,   	    // 角色名,
                            rolelevel : user.getLv(),       // 角色等级,
                            fightvalue: 0,                  // 战力
                            moneynum : user.coin  		    // 角色元宝数
                        });

                        // 需要服务端签名的创角上报
                        ConstantZM.reportCreateRole();
                    } 
                } else if (ConfigApp.pf === ConfigApp.PF_muzhi_h5 || ConfigApp.pf === ConfigApp.PF_muzhi2_h5) {
                    Platform.h5_sdk_obj.uploadRole({
                        u : paramData.userId,
                        g : paramData.gameId,
                        s : user.zone,
                        sn : String(user.zone),
                        r : user.mUID,
                        rn : user.uname,
                        rl : user.getLv(),
                        cn : user.pay_money,
                        rvl : '0'
                    });
                } else if (ConfigApp.pf === ConfigApp.PF_r2game_kr_h5) {
                    type === 0 && Browser.window.parent.postMessage({action:'createRole', server: user.zone, role: user.uname, roleid: user.mUID, level: user.getLv()}, '*');
                    type === 1 && Browser.window.parent.postMessage({action:'gameLogin', server: user.zone, role: user.uname, roleid: user.mUID, level: user.getLv()}, '*');
                } else if (ConfigApp.pf === ConfigApp.PF_hutao_h5 || ConfigApp.pf === ConfigApp.PF_hutao2_h5) {
                    var map_hutao:Object = {
                        '0': 1, // 创建角色
                        '1': user.country === -1 ? 0 : 2, // 进入游戏
                        '2': 3, // 等级提升 
                        '6': 4  // 注销 
                    };
				    var accountId:Array = ModelManager.instance.modelUser.accountId as Array;
                    accountId.length && map_hutao[type] && Platform.h5_sdk_obj.role({
                        uid: accountId[0],
                        server_id: String(user.zone),
                        server_name: String(user.zone),
                        role_id: String(user.mUID),
                        role_name: user.uname,
                        role_level: user.getLv(),
                        update_time: Math.floor(ConfigServer.getServerTimer() / 1000),
                        type: map_hutao[type]
                    });
                    type == 1 && Platform.h5_sdk_obj.selectServer({
                        uid: accountId[0],
                        server_id: String(user.zone),
                        server_name: String(user.zone),
                        timestamp: Math.round(ConfigServer.getServerTimer() / 1000)                        
                    });
                } else if (ConfigApp.pf === ConfigApp.PF_6kw_h5) {
                    var map_6kw:Object = {
                        '0': '1', // 创建角色
                        '1': '1', // 进入游戏
                        '2': '1' // 等级提升 
                    };
                    map_6kw[type] &&Platform.h5_sdk_obj.CallParentMethods('role', {
                        serverId: user.zone,    	    // 区服ID
                        serverName: String(user.zone), // 区服名
                        roleID: user.mUID,      	    // 角色ID
                        roleName: user.uname,   	    // 角色名
                        roleLevel: user.getLv(),       // 角色等级
                        payLevel: '1',
                        desc: ''
                    });
                } else if (ConfigApp.pf === ConfigApp.PF_changwan_h5) {
                    var map_changwan:Object = {
                        '1': '1' // 进入游戏
                    };
                    map_changwan[type] &&Platform.h5_sdk_obj.sdk_enterGame(
                        String(user.zone),  // 区服ID
                        String(user.zone),  // 区服名
                        String(user.mUID),  // 角色ID
                        user.uname  	    // 角色名
                    );
                } else if (ConfigApp.pf === ConfigApp.PF_shouqu_h5) {
                    type === 0 && Platform.h5_sdk_obj.roleCreated({ // 创角
                        server_id: String(user.zone),
                        server_name: serverName,
                        role_id: user.mUID,
                        role_name: user.uname
                    });
                    if (type === 1) {
                        Platform.h5_sdk_obj.gameLoad('finish'); // 进入游戏
                        Platform.h5_sdk_obj.serverSelected ({ // 选服
                            server_id: String(user.zone),
                            server_name: serverName
                        });
                    }
                    type === 2 && Platform.h5_sdk_obj.roleLevelUp({ // 角色升级
                        server_id: String(user.zone),
                        server_name: serverName,
                        role_id: user.mUID,
                        role_name: user.uname,
                        level: user.getLv()
                    });
                } else if (ConfigApp.pf === ConfigApp.PF_changxiang_h5) {
                    var map_cx:Object = {
                        '0': 'createrole', // 创建角色
                        '1': 'entergame', // 进入游戏
                        '2': 'roleupgrade' // 等级提升 
                    };
                    map_cx[type] && Platform.h5_sdk_obj.reportRoleInfo({
                        roleId: String(user.mUID),
                        roleName: user.uname,
                        roleLevel: user.getLv(),
                        serverId: String(user.zone),
                        serverName: serverName,
                        roleVip: 0,
                        rolePower: 0,
                        roleGold: 0,
                        roleDiamond: user.coin,
                        reportType: map_cx[type]
                    });
                }
            }            
        }
        public static function toChaohua(type:Number):Object{
            var data:Object = {};
            var umd:ModelUser = ModelManager.instance.modelUser;
            var now:Number = Math.floor(ConfigServer.getServerTimer()*0.001);
            //
            data["type"]=type;
            data["ServerID"]=umd.zone;
            data["ServerName"]=umd.zone;
            data["RoleID"]=umd.mUID;
            data["RoleName"]=umd.uname;
            data["RoleLevel"]=umd.getLv();
            data["GameBalance"]=umd.coin;
            data["VipLevel"]="0";
            data["PartyName"]="无";
            data["RoleCreateTime"]=now;
            data["PartyId"]="";
            data["GameRoleGender"]=Platform.pf_login_data.channelId;
            data["GameRolePower"]="";
            data["PartyRoleId"]="";
            data["PartyRoleName"]="";
            data["ProfessionId"]="";
            data["Profession"]="";
            data["Friendlist"]="";
            //
            return data;
        }
        // public static function to9130(type:Number):void{
        //     var data:Object = {};
        //     var umd:ModelUser = ModelManager.instance.modelUser;
        //     var now:Number = ConfigServer.getServerTimer();
        //     data["serverId"] = umd.zone;
        //     data["serverName"] = umd.zone;
        //     data["roleId"] = umd.mUID;
        //     data["roleName"] = umd.uname;
        //     data["roleLevel"] = umd.getLv();
        //     if(type == 0){
        //         Platform.h5_sdk_obj.logCreateRole(data["serverId"],data["serverName"],data["roleId"],data["roleName"],data["roleLevel"]);
        //     }
        //     else if(type == 1){
        //         Platform.h5_sdk_obj.logEnterGame(data["serverId"],data["serverName"],data["roleId"],data["roleName"],data["roleLevel"]);
        //     }
        //     else if(type == 2){
        //         Platform.h5_sdk_obj.logRoleUpLevel(data["serverId"],data["serverName"],data["roleId"],data["roleName"],data["roleLevel"]);
        //     }
        // }
        public static function toYYJH(type:Number):Object{
            var data:Object = null;
            if(type==1){
                data = {};
                var umd:ModelUser = ModelManager.instance.modelUser;
                var now:Number = ConfigServer.getServerTimer();
                var yyjhObj:Object = Tools.getURLexpToObj(ConfigApp.url_params);
                var index_yyjh:int= [ConfigApp.PF_yyjh_h5, ConfigApp.PF_yyjh2_h5, ConfigApp.PF_JJ_yyjh_h5].indexOf(ConfigApp.pf);
                var yyjh_appkey:String = ["3866c245e0791eaabc84a49efe2d0ef2", "09fe331c3dc8a3d5a10d05345f1b7e17", "f3c9a6e058f9e6b12f380366583a96b1"][index_yyjh];
                // 
                data["serverid"] = umd.zone;
                data["servername"] = umd.zone;
                data["roleid"] = umd.mUID;
                data["rolename"] = umd.uname;
                data["rolelevel"] = umd.getLv();
                data["appkey"] = yyjh_appkey;
                data["account"] = yyjhObj.userid;
            }
            return data;
        }
        public static function getGameUserData37(type:Number,params:Array=null):Object{
            var data:Object = {};
            var umd:ModelUser = ModelManager.instance.modelUser;
            var now:Number = ConfigServer.getServerTimer();
            var zoneCfg:Object = ConfigServer.zone[umd.zone];
            //
            data["appid"] = Platform.pf_login_data["appid"];
            data["game_id"] = Platform.pf_login_data["game_id"];
            data["uid"] = Platform.pf_login_data["uid"];
            data["serverid"] = umd.zone;
            data["servername"] = zoneCfg[0];
            data["rolename"] = umd.uname;
            data["roleid"] = umd.mUID;
            // 
            if(type==1000){
                //
                data["timestamp"] = Tools.getTimeStamp(umd.add_time);
                data["method"] = "create";
            }
            else if(type==1 || type==2){
                //
                data["rolelevel"] = umd.getLv();
                data["viplevel"] = 0;
                data["fightvalue"] = umd.getLv();
                data["balance"] = umd.coin;
                data["country"] = umd.country;
                data["countryid"] = umd.country;
                data["countryrolename"] = "";
                data["timestamp"] = now;
                data["rolecreatetime"] = Tools.getTimeStamp(umd.add_time);
                if(type==1){
                    data["method"] = "entergame";
                    data["isnewrole"] = params?(params[0]==0):false;
                }
                else{
                    data["method"] = "levelup";
                    data["eventname"] = "level_" +umd.getLv() + "_city";
                    data["guid"] = Tools.getURLexpToObj(ConfigApp.url_params)['guid'];
                }
                data["roles"] = [];
            }
            else{
                data = null;
            }
            return data;
        }
        /**
         * 平台特殊数据集合
         */
        public static function getGameUserData1():Object{
            var user:Object = {};
            var umd:ModelUser = ModelManager.instance.modelUser;
            user["roleId"] = umd.mUID+"";
            user["roleName"] = umd.uname+"";
            user["roleLevel"] = umd.getLv()+"";
            user["serverId"] = umd.zone+"";
            user["serverName"] = ConfigServer.zone[umd.zone][0]+"";
            user["balance"] = umd.coin+"";
            user["vipLevel"] = "0";
            user["partyName"] = (umd.guild_id?umd.guild_id:"无")+"";
            user["extra"] = "0";
            user["timeRoleCreate"] = "-1";
            user["timeRoleUpgrade"] = "-1";
            return user;
        }
        public static function getGameUserData2():Object{
            var user:Object = {};
            var umd:ModelUser = ModelManager.instance.modelUser;
            user["roleId"] = umd.mUID+"";
            user["roleName"] = "";//umd.uname+"";
            user["roleLevel"] = umd.getLv()+"";
            user["serverId"] = umd.zone+"";
            user["serverName"] = "";//ConfigServer.zone[umd.zone][0]+"";
            user["vipLevel"] = "0";
            user["roleFightValue"] = Tools.getDictLength(umd.hero)+"";
            user["roleProfession"] = "";
            user["rolePayTotal"] = "";
            user["roleCoin1"] = umd.coin+"";
            user["roleCoin2"] = "";
            return user;
        }  
        // public static function getGameUserEfun(type:Number):Object{
        //     var method:String = "";
        //     var umd:ModelUser = ModelManager.instance.modelUser;
        //     var data:Object = {};
        //     //
        //     if(type==0){
        //         method = "createdRole";
        //     }
        //     else if(type==1){
        //         var nt:Number = 0;
        //         var ct:Number = 0;
        //         var ntd:Date = new Date(Tools.getTimeStamp(umd.login_time));
        //         ntd.setHours(1);
        //         nt =  ntd.getTime();
        //         var ctd:Date = new Date(Tools.getTimeStamp(umd.add_time));
        //         ctd.setHours(1);
        //         ct = ctd.getTime();
        //         var dt:Number = nt - ct;
        //         if(dt>= Tools.oneDayMilli*2 && dt<Tools.oneDayMilli*3){
        //             method = "thirdday_login";
        //         }
        //     }
        //     else if(type==2){
        //         method = "upgradeRole";
        //     }
        //     if(method!=""){
        //         data["uid"] = umd.mUID;
        //         data["uname"] = umd.uname;
        //         data["lv"] = umd.getLv();
        //         data["sid"] = umd.zone;
        //         data["sname"] = umd.zone;
        //         data["type"] = method;
        //         data["efunUser"] = Platform.pf_login_data.userId;
        //         return data;
        //     }
        //     return null;
        // }
        public static function getGameUserData3():Array{
            var user:Array = [];
            var umd:ModelUser = ModelManager.instance.modelUser;
            user.push(umd.zone+"");
            user.push(umd.getLv()+"");
            user.push(umd.uname+"");
            return user;
        } 
        public static function getGameUserDataOPPO():Array{
            var user:Array = [];
            var umd:ModelUser = ModelManager.instance.modelUser;
            user.push(umd.mUID+"");
            user.push(umd.uname+"");
            user.push(umd.getLv());
            user.push(umd.zone+"");
            user.push("1");
            return user;
        }    
        public static function getGameUserDataUC():Object{
            var user:Object = {};
            var umd:ModelUser = ModelManager.instance.modelUser;
            user["id"] = umd.mUID;
            user["name"] = umd.uname;
            user["lv"] = umd.getLv();
            user["time"] = Math.floor(Tools.getTimeStamp(umd.add_time)*0.001);
            user["zid"] = umd.zone;
            user["zname"] = umd.zone;
            return user;
        }                    
        public static function getGameUserDataPay(payData:Object):Object{
            var user:Object = {};
            var umd:ModelUser = ModelManager.instance.modelUser;
            user["orderInfo"] = payData;//payData.orderInfo;
            user["amt"] = payData.amt+"";
            user["roleName"] = payData.role_name+"";
            user["roleLevel"] = payData.role_level+"";
            user["roleId"] = payData.role_id+"";
            user["channel"] = payData.server_id+"";
            user["channelName"] = payData.server_name+"";
            user["subject"] = payData.app_subject+"";
            user["orderNo"] = payData.app_order_no+"";
            user["extra"] = payData.app_ext+"";
            return user;
        }          
        public static function getGameUserDataPay2(payData:Object,isTW:Boolean = false):Array{
            var user:Array = [];
            var umd:ModelUser = ModelManager.instance.modelUser;
            var cfg:Array = payData.cfg;
            var pay:Object = {};
            var hwPayCfg:Object = ConfigServer.system_simple.pay[ConfigApp.pf];
            //
            pay["productNo"] = hwPayCfg[payData.pid];
            user.push(hwPayCfg[payData.pid]);
            //
            pay["applicationID"] = isTW?"100719911":"100483749";
            user.push(isTW?"100719911":"100483749");
            // 
            var oid:String = payData.uid+"A"+ConfigServer.getServerTimer()+"";
            pay["requestId"] = oid;
            user.push(oid);
            //    
            pay["merchantId"] = "900086000026237415";
            user.push("900086000026237415");   
            //
            user.push("X6");  //serviceCatalog 
            //
            user.push("北京萌我爱网络技术有限公司");  //merchantName
            //
            pay["sdkChannel"] = 3;
            user.push("3"); 
            //
            pay["url"] = isTW?ConfigApp.getURLType("http://hk.ptkill.com/hw_tw_callback"):ConfigApp.getURLType("http://sg3.ptkill.com/hw_callback");
            user.push(isTW?ConfigApp.getURLType("http://hk.ptkill.com/hw_tw_callback"):ConfigApp.getURLType("http://sg3.ptkill.com/hw_callback"));
            // 
            pay["urlver"] = "2";
            user.push("2");   
            //
            user.push(payData.pid+"|"+payData.zone+"|"+payData.uid+"|"+payData.pf);//extReserved 

            return [pay,user];
        } 
        public static function getPayByHuaWei(payData:Object):Array{
            var toSign:Object = {};
            var obj:Object = {};
            var cfg:Array = payData.cfg;
            var oid:String = payData.uid+"A"+ConfigServer.getServerTimer()+"";
            //
            obj["productName"] = toSign["productName"]= "黄金";
            obj["productDesc"] = toSign["productDesc"]= "游戏内使用";
            obj["applicationID"] = toSign["applicationID"]= "100483749";
            obj["requestId"]= toSign["requestId"] = oid;
            obj["amount"]= toSign["amount"] = cfg[0]+".00";
            obj["merchantId"]= toSign["merchantId"] = "900086000026237415";
            obj["serviceCatalog"] = "X6";
            obj["merchantName"] = "北京萌我爱网络技术有限公司";
            obj["sdkChannel"]= toSign["sdkChannel"] = 3;
            obj["url"]= toSign["url"] = ConfigApp.getURLType("http://sg3.ptkill.com/hw_callback");
            obj["currency"]= toSign["currency"] = "CNY";
            obj["country"]= toSign["country"] = "CN";
            obj["urlver"]= toSign["urlver"] = "2";
            obj["extReserved"]= payData.pid+"|"+payData.zone+"|"+payData.uid+"|"+payData.pf;
            //
            return [obj,toSign];
        }
        public static function getPayByHuaWei_tw(payData:Object):Array{
            var toSign:Object = {};
            var obj:Object = {};
            var cfg:Array = payData.cfg;
            var oid:String = payData.uid+"A"+ConfigServer.getServerTimer()+"";
            //
            obj["productName"] = toSign["productName"]= "黄金";
            obj["productDesc"] = toSign["productDesc"]= "游戏内使用";
            obj["applicationID"] = toSign["applicationID"]= "100719911";
            obj["requestId"]= toSign["requestId"] = oid;
            obj["amount"]= toSign["amount"] = cfg[0]+".00";
            obj["merchantId"]= toSign["merchantId"] = "900086000026237415";
            obj["serviceCatalog"] = "X6";
            obj["merchantName"] = "北京萌我爱网络技术有限公司";
            obj["sdkChannel"]= toSign["sdkChannel"] = 3;
            obj["url"]= toSign["url"] = ConfigApp.getURLType("http://hk.ptkill.com/hw_tw_callback");
            obj["currency"]= toSign["currency"] = "CNY";
            obj["country"]= toSign["country"] = "CN";
            obj["urlver"]= toSign["urlver"] = "2";
            obj["extReserved"]= payData.pid+"|"+payData.zone+"|"+payData.uid+"|"+payData.pf;
            //
            return [obj,toSign];
        }   
        public static function getPayListInfo():void{
            if(ConfigApp.pf == ConfigApp.PF_huawei_tw){
                var sd:Object = {};
                sd["applicationID"] = "100719911";
                sd["merchantId"] = "900086000026237415";
                sd["requestId"] = ConfigServer.getServerTimer()+"";

                var pic:Object = ConfigServer.system_simple.pay[ConfigApp.pf];
                var ss:String = "";
                for(var pi:String in pic){
                    ss += pic[pi]+"|";
                }
                sd["productNos"] = ss.substr(0,ss.length-1);
                ToJava.callMethod("getPayList",sd,Handler.create(null,function(re:*,str:*):void{
                    // trace("------ :: "+JSON.stringify(re));
                    Platform.pay_list_info = re;
                }));
            }
        }     
        public static function getPayByJUEDI(payData:Object):Array{
            var arr:Array = [];
            var obj:Object = {};
            var cfg:Array = payData.cfg;
            var result:Object = null;
    //    
            if(Platform.pf_login_data && Platform.pf_login_data.data){
                result = JSON.parse(Platform.pf_login_data.data);
            }
            else{
                result = Platform.pf_login_data;
            }
            if(result && result.channel_openid){
                //
                obj["channel_openid"] = result.channel_openid;
                arr.push(result.channel_openid);
            }
            //
            obj["GoodsName"] = "黄金";
            arr.push("黄金");
            //
            var pid:String = payData.pid+"|"+payData.zone+"|"+payData.uid+"|"+payData.pf;
            obj["pay_goods_id"] = pid;
            arr.push(pid);
            //
            obj["Amount"] = cfg[0]+".00";
            arr.push(cfg[0]+".00");
            //
            var oid:String = pid+"|"+ConfigServer.getServerTimer();
            obj["GameTradeNo"] = oid;
            arr.push(oid);
            //
            obj["ServerId"] = ModelManager.instance.modelUser.zone+"";
            arr.push(ModelManager.instance.modelUser.zone+"");
            //
            obj["ServerName"] = "1";
            arr.push("1");   
            //
            obj["RoleId"] = ModelManager.instance.modelUser.mUID+"";
            arr.push(ModelManager.instance.modelUser.mUID+""); 
            //
            obj["RoleName"] = ModelManager.instance.modelUser.uname+"";
            arr.push(ModelManager.instance.modelUser.uname+"");  
            //
            obj["RoleLevel"] = ModelManager.instance.modelUser.getLv()+"";
            arr.push(ModelManager.instance.modelUser.getLv());  
            //
            if(ConfigServer.system_simple.pay[payData.pf]){
                obj["ProductId"] = ConfigServer.system_simple.pay[payData.pf][payData.pid];
            }
            //
            arr.push(cfg[0]);                                   
            return [obj,arr];
        }
        public static function toR2GameAppsFlyer(type:Number,params:Array = null):Object{
            var data:Object = {};
            var upR2g:Boolean = false;
            var isnew:Boolean = false;
            if(type == 0){
                data["event"] = "event_create";
            }
            else if(type==1){
                data["event"] = "event_login";
                upR2g = true;
                var arr:Array = ModelManager.instance.modelUser.getMyHeroArr();
                isnew = (arr.length<1);
            }
            else if(type==2){
                var lv:Number = params[0];
                data["event"] = "event_update";
                data["lv"] = lv;
            }       
            else {
                data = null;
            }    
            if(upR2g){
                data["uid"] = Platform.pf_login_data.uid+"";
                data["roleid"] = ModelManager.instance.modelUser.mUID+"";
                data["rolename"] = ModelManager.instance.modelUser.uname;
                data["rolelv"] = ModelManager.instance.modelUser.getLv()+"";
                data["sid"] = ModelManager.instance.modelUser.zone+"";
                data["isnew"] = isnew;
            }
            return data;
        }
        public static function toYou77(type:Number,params:Array = null):Object{
            var data:Object = {};
            var umd:ModelUser = ModelManager.instance.modelUser;
            /**
             * type==0 choose_country   注册/创角
             * type==1 enter_game       登录/进入游戏
             * type==2 building_lv_up   升级
             * type==3 change_uname     改名
             * type==4 change_coin      黄金数量变化
             * type==5 get_coin         获得黄金
             */
            if(type==1){
                data["server_id"] = umd.zone;
                data["server_name"] = umd.zone;
                data["role_id"] = umd.mUID+"";
                data["role_name"] = umd.uname;
                data["level"] = umd.getLv()+"";
                data["vip"] = "0";
                data["token"] = Platform.pf_login_data["token_string"];
            } else {
                data = null;
            }
            
            return data;
        }
        public static function to6KW(type:Number,params:Array = null):Object{
            var data:Object = {};
            var umd:ModelUser = ModelManager.instance.modelUser;

            if (type == 0 || type == 1 || type == 2) {
                if (type == 0) {
                    data["data_type"] = "2";
                } else if (type == 1) {
                    data["data_type"] = "3";
                } else if (type == 2) {
                    data["data_type"] = "4";
                }

                data["user_id"] = Platform.pf_login_data.user_id+"";
                data["user_name"] = Platform.pf_login_data.user_name;
                data["role_id"] = umd.mUID+"";
                data["role_name"] = umd.uname;
                data["role_level"] = umd.getLv()+"";
                data["role_ctime"] = Math.floor(Tools.getTimeStamp(umd.add_time)*0.001);
                data["pay_level"] = "0";
                data["server_id"] = umd.zone;
                data["server_name"] = ConfigServer.zone[umd.zone][0]+"";
                data["extension"] = "";
            } else {
                data = null;
            }
            
            return data;
        }
        public static function toPanbao(type:Number,params:Array = null):Object{
            var data:Object = {};
            var umd:ModelUser = ModelManager.instance.modelUser;

            if (type == 0 || type == 1 || type == 2) {
                if (type == 0) {
                    data["op_type"] = "1";
                } else if (type == 1) {
                    data["op_type"] = "2";
                } else if (type == 2) {
                    data["op_type"] = "3";
                }

                data["role_id"] = umd.mUID+"";
                data["role_name"] = umd.uname;
                data["role_level"] = umd.getLv()+"";
                data["server_id"] = umd.zone;
                data["server_name"] = ConfigServer.zone[umd.zone][0]+"";
                data["vip"] = "0";
            } else {
                data = null;
            }
            
            return data;
        }
        public static function toFacebook(type:Number,params:Array = null):Object{
            var data:Object = {};
            var umd:ModelUser = ModelManager.instance.modelUser;
            data["testV"] = 2019;
            if(type==0){
                data["eventId"] = "6u2cny";
                data["type"] = "create";
                data["uid"] = umd.mUID;
                data["sid"] = umd.zone;
                data["ms"] = ConfigServer.getServerTimer();
                data["pf"] = ConfigApp.pf_channel;
                data["upload_pf"] = ConfigApp.pf;
            }
            else if(type==1){
                data["eventId"] = "413fx8";
                data["type"] = "login";
                data["uid"] = umd.mUID;
                data["sid"] = umd.zone;
                data["ms"] = ConfigServer.getServerTimer();
                data["pf"] = ConfigApp.pf_channel;
                data["upload_pf"] = ConfigApp.pf;
            }
            else if(type==2){
                data["type"] = "update";
                data["uid"] = umd.mUID;
                data["sid"] = umd.zone;
                data["ms"] = ConfigServer.getServerTimer();
                data["pf"] = ConfigApp.pf_channel;
                data["upload_pf"] = ConfigApp.pf;
                var lv:Number = params?params[0]:0;
                if(lv==3){
                    data["eventId"] = "7af5ck";
                }
                else if(lv==5){
                    data["eventId"] = "ge4h0z";
                }
                else if(lv==10){
                    data["eventId"] = "4gew71";
                }
                else if(lv==15){
                    data["eventId"] = "ldp60l";
                }         
                else{
                    data = null;
                }       
            }
            else if(type==5){
                data["eventId"] = "5spd5s";
                data["type"] = "pay_success_event";
                data["money"] = params?params[0]:0;
                data["moneyType"] = "CNY";
                data["uid"] = umd.mUID;
                data["sid"] = umd.zone;
                data["ms"] = ConfigServer.getServerTimer();
                data["pf"] = ConfigApp.pf_channel;
                data["upload_pf"] = ConfigApp.pf;
            }
            else{
                data = null;
            }
            return data;
        }
        // public static function toHanfeng(type:Number):Object{
        //     var data:Object = {};
        //     var umd:ModelUser = ModelManager.instance.modelUser;
        //     var now:Number = Math.floor(ConfigServer.getServerTimer()*0.001);
        //     data["accountId"] = umd.accountId;
        //     data["uid"] = umd.mUID;
        //     data["uname"] = umd.uname;
        //     data["sid"] = umd.zone;
        //     data["sname"] = umd.zone;
        //     data["coin"] = umd.coin;
        //     data["lv"] = umd.getLv();
        //     //
        //     data["ms"] = now;
        //     // 
        //     data["type"] = type;
        //     //
        //     data["createTime"] = Math.floor(Tools.getTimeStamp(umd.add_time)*0.001);
        //     return data;
        // }
        public static function getGameUserDataJUEDI(type:Number,params:Array = null):Array{
            var user:Array = [];
            var umd:ModelUser = ModelManager.instance.modelUser;
            var result:Object = null;
            var now:Number = Math.floor(ConfigServer.getServerTimer()*0.001);
            var rt:Number = Math.floor(Tools.getTimeStamp(umd.add_time)*0.001);
            if(Platform.pf_login_data.data){
                result = JSON.parse(Platform.pf_login_data.data);
            }
            else{
                result = Platform.pf_login_data;
            }
            if(result && result.channel_openid){
                user.push(result.channel_openid);
                user.push(result.user_id);
            }
            var lv:Number = umd.getLv();
            user.push(umd.mUID);
            user.push(umd.uname);
            user.push(lv+"");
            user.push(umd.zone+"");
            user.push(umd.zone+"");
            user.push(0);
            user.push(umd.coin);
            user.push(rt);
            /** 以下注意需要区分开 **/
            var jdType:Number = 0;
            if(type == 0){
                jdType = 1;
            }
            else if(type==1){
                jdType = 2;
            }
            else if(type==2){
                jdType = 3;
            }
            else if(type==4){
                jdType = 4;
            }
            user.push(jdType);
            user.push(now);//[11]
            //
            if(jdType==3){
                user.push(lv-1);
                user.push(lv);
                user.push(now);
            }
            else if(jdType==4 && params){
                user.push(now);
                user.push(params[0]);
                var d:Number = params[0]-params[1];
                user.push(Math.abs(d));
                user.push(d>0?2:1);
                user.push("");
            }
            return user;
        }
        public static function checkGameStatus(index:Number):void{
            // Trace.log("--游戏状态观察打点--",index);
            // if(index==103){
            //     var sendIDFA:Boolean = false;
            //     if(
            //         ConfigApp.pf == ConfigApp.PF_ios_meng52 || 
            //         ConfigApp.pf == ConfigApp.PF_and_1 ||
            //         ConfigApp.pf == ConfigApp.PF_ios_meng52_mjm3 || 
            //         ConfigApp.pf == ConfigApp.PF_ios_meng52_mjm2 || 
            //         ConfigApp.pf == ConfigApp.PF_ios_meng52_mjm4 || 
            //         ConfigApp.pf == ConfigApp.PF_ios_meng52_mjm1
            //     )
            //     {
            //         sendIDFA = true;
            //     }
                
            //     if(sendIDFA){
            //         var did:* = SaveLocal.getValue(SaveLocal.KEY_LOCAL_APP_IDFA);
            //         if(did!="yes"){
            //             NetHttp.instance.send("user_zone.install_code",{code:index});
            //             SaveLocal.save(SaveLocal.KEY_LOCAL_APP_IDFA,"yes");
            //         }
            //     }
            // }
            // else {
            //     if(ConfigApp.pf == ConfigApp.PF_and_google){
            //         if(Platform.phoneInfoOnCheck){
            //             ToJava.callMethod("checkGameStatus",index,null);
            //         }
            //     }
            // }
        }
        public static function other_fun(str:String):void{
            if(ConfigApp.onAndroid()){
                ToJava.other_fun(str,null);
            }
            else{
                
            }
        }
        public static function shieldFont(input:String,handler:Handler,isName:Boolean = true):void{
            var third_ban:Boolean = ConfigServer.system_simple.third_ban && ConfigServer.system_simple.third_ban.indexOf(ConfigApp.pf) !== -1;
            if(ConfigApp.releaseWeiXin() && third_ban){
                var tt:String = ConfigServer.getServerTimer()+"";
                var key:String = Browser.onAndroid?"ofGkJuxkoLYlgRVt":"CjquiLFFggZKrRSH";
                // 
                var obj:Object = {"game_key":key,"nonce":tt,"timestamp":tt};
                var so:String = sortObjkeyToString(obj)+"ovtgJVHdaDqUXwgBvlKFANBdYpIhdHSi";
                var md5:String = MD5.md5(so);
                obj["sign"] = md5.toLowerCase()
                NetHttp.instance.postRequest("https://api.cxgame.net/app/sdk/v1/wx/get-wx-token",sortObjkeyToString(obj),Handler.create(null,function(re:*):void{
                    // trace(re);
                    // NetHttp.instance.postRequest("https://api.weixin.qq.com/wxa/msg_sec_check?access_token="+re.access_token,{"content":input},Handler.create(null,function(re2:*):void{
                    Platform.checkMsg("https://qh.ptkill.com/wx_ban/", {"token":re.access_token,"content":input}, handler, isName);
                }));
            } else if (ConfigApp.releaseQQ() && third_ban) {
                Platform.checkMsg("https://sg3.ptkill.com/qq_ban/", {content: input}, handler, isName);
            } else {
                if(isName){
                    input = FilterManager.instance.nameBan(input);
                    input = FilterManager.instance.wordBan(input);
                    if(input.indexOf('*')!=-1) { // 含有非法字符
                        ViewManager.instance.showTipsTxt(Tools.getMsgById("193005"));
                        return;
                    }
                    var limitArr:Array = Tools.langData;
                    var maxLen:int = 0;
                    var sumLen:int = 0;
                    var numChar:int = 0;
                    var langs:Array = [];
                    limitArr.forEach(function(arr:Array):void {
                        var lang:String = arr[0];
                        var restrict:String = arr[1];
                        var charLen:int = arr[2];
                        var maxChars:int = arr[3];
                        var len:int = maxChars * charLen;
                        maxLen = len > maxLen ? len : maxLen;
                        var reg:RegExp = new RegExp('[' + restrict + ']', 'gm');
                        if (restrict.length === 0) {
                            reg = /\S/gm;
                        }
                        var num:int = (input.match(reg) || []).length;
                        sumLen += num * charLen;
                        numChar += num;
                        langs.push(lang);
                    });
                    if (sumLen > maxLen) { // 名字过长
                        ViewManager.instance.showTipsTxt(Tools.getMsgById("_lan_3"));
                        return;
                    } else if (numChar < input.length) { // 与要求输入的语言不符
                        var s:String = langs.map(function(lang:String):String {
                            return Tools.getMsgById('_lan_'+lang);
                        }).join(Tools.getMsgById('_lan2'));
                        ViewManager.instance.showTipsTxt(Tools.getMsgById('_lan1',[s]));
                        return;
                    }
                }else{

                }
                handler && handler.runWith(input);
            }
        }

        private static function checkMsg(url:String, params:Object, handler:Handler, isName:Boolean = true):void {
            NetHttp.instance.postRequest(url, params, Handler.create(null,function(re:*):void{
                var errCode:int = re && (re.errcode || re.errCode);
                if(errCode === 87014){
                    isName && ViewManager.instance.showTipsTxt(Tools.getMsgById("193005"));
                } else {
                    handler && handler.runWith(params.content);
                }
            }));
        }

        public static function sortObjkeyToString(obj:Object):String{
            var p:Array = [];
            for(var key:String in obj){
                p.push(key);

            }
            p.sort();
            var len:int = p.length;
            var str:String = ""
            for(var i:int = 0; i < len; i++)
            {
                str+="&"+p[i]+"="+obj[p[i]]+"";
            }
            str = str.substring(1);
            return str;
        }
    }
}