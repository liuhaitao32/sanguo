package sg.model
{
    import sg.cfg.ConfigApp;
    import laya.utils.Handler;
    import sg.manager.ViewManager;
    import sg.utils.Tools;
    import laya.utils.Browser;
    import sg.utils.SaveLocal;
    import sg.cfg.ConfigServer;
    import sg.cfg.ConfigClass;
    import sg.activities.model.ModelPhone;

    public class ModelPf
    {
        public function ModelPf()
        {
            
        }
        public static function login_success(view:*,pf:String,status:Number,obj:Object):void{
            Platform.pf_login_data = obj;//登录返回数据,其他地方使用
            // 
            var loginData:Object = obj;
            //
            var isChange:Boolean = false;
            var isLogin:Boolean = false;
            if(pf == ConfigApp.PF_huawei || pf == ConfigApp.PF_huawei_tw){
                if(obj.hasOwnProperty("re")){
                    isLogin = true;
                }
                else if(obj.hasOwnProperty("change")){
                    isChange = true;
                }
            }
            else if(pf == ConfigApp.PF_juedi){
                if(obj.hasOwnProperty("result") && obj["result"] == "0"){
                    loginData = JSON.parse(obj.data);
                }
                isLogin = true;
            }
            else{
                isLogin = true;
            }
            // if(pf == ConfigApp.PF_ios_meng52_mj1){
            //     ModelPlayer.instance.loginName = obj.uname;
            //     ModelPlayer.instance.loginPwd = obj.pwd;
            //     view.loginPaOtherPf = {};
            //     view.loginByPf(true);
            //     view.initSocket(false);
                
            //     return;
            // }
            if(!isChange && isLogin){
                if(pf == ConfigApp.PF_r2game_xm_ad || pf == ConfigApp.PF_r2game_xm_ios){
                    ConfigApp.pf_channel = ConfigApp.PF_r2game_xm;
                    view.loginPaOtherPf[ConfigApp.pf_channel] = loginData;
                }
                else if(
                    pf == ConfigApp.PF_r2game_kr_ad || 
                    pf == ConfigApp.PF_r2game_kr_onestore || 
                    pf == ConfigApp.PF_r2game_kr_h5 ||
                    pf == ConfigApp.PF_r2game_kr_ios){
                    ConfigApp.pf_channel = ConfigApp.PF_r2game_kr;
                    view.loginPaOtherPf[ConfigApp.pf_channel] = loginData;
                }
                else if(
                    pf == ConfigApp.PF_77you_ios_tw ||
                    pf == ConfigApp.PF_77you_ios_jp ||
                    pf == ConfigApp.PF_77you_ad_tw ||
                    pf == ConfigApp.PF_77you_ad_jp){
                    ConfigApp.pf_channel = ConfigApp.PF_77you;
                    view.loginPaOtherPf[ConfigApp.pf_channel] = loginData;
                }
                else{
                    view.loginPaOtherPf[pf] = loginData;
                }
                view.loginByPf();
                view.initSocket(false);
            }
            else if(!isLogin && isChange){
                Platform.restart();
            }
            else{

            }
        }
        public static function pf_login(view:*,pf:String,other:* = null):void{
            var isLoginNow:Boolean = false;
            var _this:* = view;
            _this.btn_server.visible = false;
            _this.btn_login.visible = false;
            _this.yybOut.visible = ModelPf.pf_use_logout(pf);
            _this.loginStatus = 1;
            // 
			if(ConfigApp.releaseWeiXin()){	
				Platform.login(Handler.create(_this,function(status:Number,obj:Object):void{
                    if(ConfigApp.pf == ConfigApp.PF_wx_changxiang){
                        if(status==200 && obj){
                            _this.loginPaOtherPf[ConfigApp.pf] = obj;
                            _this.loginByPf();
                            _this.initSocket(false);
                        }
                        else{
                            ViewManager.instance.showTipsTxt(Tools.getMsgById("_lht48"));
                        }
                    }
					// if(status==0 && obj){
					// 	//{errMsg: "login:ok", code: "071Y24030gvzjD1HsR230u1WZ20Y2403"}
					// 	_this.loginPaOtherPf["wx_code"] = obj.code;
					// 	_this.loginByPf();
					// 	_this.initSocket(false);
					// }
					// else{
					// 	//'_lht48':unicode('登录异常,请检查账号名或密码重新登录', 'utf-8'),
					// 	if(status==500){
					// 		ViewManager.instance.showTipsTxt(Tools.getMsgById("_lht48"));
					// 	}
					// }
				}));
			} else if (ConfigApp.releaseQQ()) {
                
                Platform.login(Handler.create(_this, function(status:Number, obj:Object):void {
                    var pf:String = ConfigApp.pf  + (Browser.onIOS ? '_ios' : '_ad');
                    _this.loginPaOtherPf[pf] = obj;
                    _this.loginByPf();
                    _this.initSocket(false);
                }))
            } else if(pf == ConfigApp.PF_and_google || pf == ConfigApp.PF_ios_meng52_tw){
                var gg_fb:String = "";
                // _this.googleBox.visible = (pf == ConfigApp.PF_and_google);//
                // _this.twBox.visible = (pf == ConfigApp.PF_ios_meng52_tw);
                switch(other)
                {
                    case 3:
                        //facebook
                        gg_fb = "fb";
                        break;	
                    case 4:
                        //google
                        gg_fb = "gg";
                        break;
                    case 5:
                        //meng52 self
                        gg_fb = Platform.TAG_LOGIN_TYPE_MENG52;
                        break;                        							
                    default:
                        break;
                }
                var loginTo:Boolean = false;
                if(gg_fb==""){
                    if(ModelPlayer.instance.loginName && ModelPlayer.instance.loginPwd){
                        gg_fb = Platform.TAG_LOGIN_TYPE_TUP;
                        // ToIOS.log("从本地缓存登录:"+gg_fb);
                    }
                    else{
                        gg_fb = Platform.TAG_LOGIN_TYPE_MENG52;
                        // ToIOS.log("新玩家创建新游客登录:"+gg_fb);
                    }
                }
                Platform.login(Handler.create(_this,function(status:Number,obj:Object):void{
                    if(obj){
                        _this.yybOut.visible = true;
                        // 
                        Platform.login_type = obj.login_type;
                        //
                        var isMeng52:Boolean = (obj.login_type == Platform.TAG_LOGIN_TYPE_MENG52 || obj.login_type == Platform.TAG_LOGIN_TYPE_TUP);
                        ModelPlayer.instance.loginName = obj.uid;
                        ModelPlayer.instance.loginPwd = obj.token;
                        // 
                        // ToIOS.log(isMeng52+" :登录信息准备: "+JSON.stringify(obj));
                        if(!isMeng52){
                            _this.loginPaOtherPf[pf] = obj;
                        }
                        _this.loginByPf(isMeng52);
                        _this.initSocket(false);
                    }
                }),gg_fb);
                
            }
            else if(ConfigApp.onAndroidYYB(pf)){
                var yybPf:String = "";
                var yybLoginCfg:Object = SaveLocal.getValue(SaveLocal.KEY_YYB_LOGIN);
                var nowTimer:Number = ConfigServer.getServerTimer();
                // if(yybLoginCfg){
                //     if((nowTimer - yybLoginCfg.get_time)>=(Tools.oneDayMilli*7)){
                //         _this.yybBox.visible = true;//yyb
                //     }
                //     else{
                //         Platform.login_type = yybPf = yybLoginCfg.login_type;
                //         isLoginNow = true;
                //     }
                // }
                // else{
                    _this.yybBox.visible = true;//yyb
                // }                
                switch(other)
                {
                    case 0:

                        break;
                    case 1:
                        //qq
                        yybPf = "qq";
                        break;	
                    case 2:
                        //wx
                        yybPf = "wx";
                        break;							
                    default:
                        break;
                }
                if(yybPf!=""){
                    // 
                    if(isLoginNow){
                        ToJava.callMethod("loginAuto","",Handler.create(_this,function(obj:Object,methed:String):void{
                            if(obj.hasOwnProperty("re")){
                                _this.yybOut.visible = true;
                                var yybRe:Object = obj;
                                yybRe["login_type"] = yybPf;
                                Platform.login_type = yybPf;
                                //
                                _this.loginPaOtherPf[pf] = yybRe;
                                _this.loginByPf();
                                _this.initSocket(false);
                            }
                        }));
                    }
                    else{
                        Platform.login(Handler.create(_this,function(status:Number,obj:Object):void{
                            if(status==0 && obj){
                                if(obj.hasOwnProperty("re")){
                                    _this.yybOut.visible = true;
                                    var yybRe:Object = obj;
                                    yybRe["login_type"] = yybPf;
                                    yybRe["get_time"] = ConfigServer.getServerTimer();
                                    Platform.login_type = yybPf;
                                    SaveLocal.save(SaveLocal.KEY_YYB_LOGIN,yybRe);
                                    //
                                    _this.loginPaOtherPf[pf] = yybRe;
                                    _this.loginByPf();
                                    _this.initSocket(false);
                                }
                                else if(obj.hasOwnProperty("un")){
                                    var s1:String = (obj["un"] == "qq")?"QQ":"微信";
                                    var s2:String = (obj["un"] == "qq")?"微信":"QQ";
                                    ViewManager.instance.showTipsTxt("没有安装"+s1+",请您选择"+s2+"登录游戏");
                                }
                            }
                        }),yybPf);
                    }
                }
            }
            else{
                Platform.login(Handler.create(_this,ModelPf.login_success,[_this,pf]));
            }            	
        }
        public static function pf_logout(view:*,pf:String):void{
			var _this:* = view;
			if(ModelPf.pf_use_logout(pf)){
				Platform.logout(Handler.create(_this,function(status:Number,obj:Object):void{
					if(obj && status == 0){
						_this.yybOut.visible = false;
						_this.btn_server.visible = false;
						_this.btn_login.visible = false;	
						_this.loginStatus = 1;
                        var loginAgin:Boolean = true;
                        if(pf == ConfigApp.PF_and_google){
                            _this.googleBox.visible = true;//
                            loginAgin = false;
                            // SaveLocal.deleteObj(SaveLocal.KEY_GG_FB_LOGIN);
                        }else if(pf == ConfigApp.PF_ios_meng52_tw){
                            _this.twBox.visible = true;
                            loginAgin = false;
                        }
                        if(loginAgin){
						    _this.checkPFLoginBySDK();
                        }
					}
				}));
			}
            else{
                //out
                Platform.logout(null);
                //
                _this.yybOut.visible = false;
                _this.btn_server.visible = false;
                _this.btn_login.visible = false;
                _this.loginStatus = 1; 
                //  
                if(ConfigApp.onAndroidYYB(pf)){
                    _this.yybBox.visible = true;
                    SaveLocal.deleteObj(SaveLocal.KEY_YYB_LOGIN);
                }            
            }
        }
        public static function pf_use_logout(pf:String):Boolean{
            if(
                pf == ConfigApp.PF_juedi || 
                // pf == ConfigApp.PF_juedi_ad || 
                // pf == ConfigApp.PF_juedi_ios || 
                // pf == ConfigApp.PF_efun_google || 
                // pf == ConfigApp.PF_efun_one || 
                pf == ConfigApp.PF_and_google || 
                // pf == ConfigApp.PF_37_ios ||
                pf == ConfigApp.PF_ios_meng52_tw ||
                // pf == ConfigApp.PF_hf ||
                // pf == ConfigApp.PF_9130_h5 ||
                pf == ConfigApp.PF_caohua ||
                pf == ConfigApp.PF_JJ_caohua_ad ||
                pf == ConfigApp.PF_caohua_ios ||
                pf == ConfigApp.PF_JJ_tanwan_h5 ||
                pf == ConfigApp.PF_tanwan_h5 ||
                pf == ConfigApp.PF_tanwan2_h5 ||
                pf == ConfigApp.PF_tanwan3_h5 ||
                pf == ConfigApp.PF_tanwan4_h5 ||
                pf == ConfigApp.PF_1377_h5 ||
                pf == ConfigApp.PF_r2game_xm_ad ||
                pf == ConfigApp.PF_r2game_kr_ad ||
                pf == ConfigApp.PF_r2game_kr_onestore || 
                pf == ConfigApp.PF_r2game_xm_ios ||
                pf == ConfigApp.PF_r2game_kr_ios ||
                pf == ConfigApp.PF_r2game_kr_h5 ||
                // pf == ConfigApp.PF_panbao_ios ||
                pf == ConfigApp.PF_77you_ios_tw ||
                pf == ConfigApp.PF_77you_ios_jp ||
                pf == ConfigApp.PF_77you_ad_tw ||
                pf == ConfigApp.PF_77you_ad_jp ||
                pf == ConfigApp.PF_6kw_ad ||
                // pf == ConfigApp.PF_panbao_ad ||
                pf == ConfigApp.PF_hutao_h5 ||
                pf == ConfigApp.PF_changwan_h5 ||
                pf == ConfigApp.PF_ios_37 ||
                pf == ConfigApp.PF_hutao2_h5
                // pf == ConfigApp.PF_yqwb)
            ){
                    if(
                        ConfigApp.pf == ConfigApp.PF_JJ_tanwan_h5 ||
                        ConfigApp.pf == ConfigApp.PF_tanwan_h5 ||
                        ConfigApp.pf == ConfigApp.PF_tanwan2_h5 || 
                        ConfigApp.pf == ConfigApp.PF_tanwan3_h5 || 
                        ConfigApp.pf == ConfigApp.PF_tanwan4_h5
                    ){
                        return Platform.h5_sdk_url_data && Platform.h5_sdk_url_data.switchUserBtn && Platform.h5_sdk_url_data.switchUserBtn === 1;
                    }else{
                        return true;
                    }
            } else if (Platform.h5_sdk) {
                return Platform.h5_sdk.switchSupport;
            }
            else{
                return false;
            }
        }
    }
}