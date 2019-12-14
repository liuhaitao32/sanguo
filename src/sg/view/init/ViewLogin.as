package sg.view.init
{
    import ui.init.viewLoginUI;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.net.NetHttp;
    import sg.net.NetMethodCfg;
    import sg.model.ModelPlayer;
    import sg.cfg.ConfigApp;
    import laya.utils.Handler;
    import sg.model.ModelGame;
    import sg.utils.SaveLocal;
    import sg.utils.Tools;
    import sg.manager.FilterManager;
    import sg.cfg.ConfigServer;
    import sg.net.NetSocket;
    import sg.utils.ThirdRecording;
    import laya.maths.MathUtil;
    import laya.ui.Box;
    import laya.ui.Label;
    import sg.cfg.ConfigClass;
    import laya.utils.Browser;

    public class ViewLogin extends viewLoginUI
    {
        private var mType:int = 0;
        private var mRegistTime:Number = 1000;
        public function ViewLogin()
        {
            this.btn_phone.label=Tools.getMsgById("_login_text1");
            this.btn_real.label=Tools.getMsgById("_login_text2");
            this.btn_register.label=Tools.getMsgById("_login_text3");
            this.btn_fast.label=Tools.getMsgById("_login_text4");

            this.btn_login.on(Event.CLICK,this,this.click,[0]);
            //
            this.btn_register.on(Event.CLICK,this,this.click,[1]);
            //
            this.btn_real.on(Event.CLICK,this,this.click,[2]);

            this.btn_phone.on(Event.CLICK,this,this.click,[3]);
            
            this.btn_fast.on(Event.CLICK,this,this.click,[4]);
            //
            this.btn_users.on(Event.CLICK,this,this.click,[5]);
            //
            this.btn_fb.on(Event.CLICK,this,this.click_facebook);
            //
            // this.btn_auto.toggle = false;
            // this.btn_auto.on(Event.CLICK,this,this.click_auto,[false]);
            //
            // this.tName.restrict = "0-9\a-z\A-Z";
            this.tName.maxChars = 32;
            this.tName.on(Event.INPUT,this,this.changeTxt);
            this.tPwd1.restrict = "0-9\a-z\A-Z";
            this.tPwd1.maxChars = 16;
            this.tPwd2.restrict = "0-9\a-z\A-Z";
            this.tPwd2.maxChars = 16;

            this.tName.on(Event.CLICK,this,this.onTxtClick,[1]);
            this.tPwd1.on(Event.CLICK,this,this.onTxtClick,[2]);
            this.tPwd2.on(Event.CLICK,this,this.onTxtClick,[3]);
            //
            this.mRegistTime = 0;
            //
            this.listName.renderHandler = new Handler(this,this.listRender);
            this.listName.selectEnable = true;
            this.listName.selectHandler = new Handler(this,this.listSelect);
        }
        private function listRender(item:Box,index:int):void{
           
            var data:Object = this.listName.array[index];
            var uname:Label = item.getChildByName("uname") as Label;
            uname.text = data.name;
        }
        private function listSelect(index:int):void{
            if(index>-1){
                var data:Object = this.listName.array[index];
                // trace(data.name,data.pwd);
                this.tName.text = data.name;
                this.tPwd1.text = data.pwd?data.pwd:(data.pwd_s?data.pwd_s:"");
                this.listBox.visible = false;
            }
        }
        private function changeTxt():void
        {
            // trace(this.tName.text);
            //if(this.boxReg.visible){
                //this.tName.text = FilterManager.instance.Exec(this.tName.text,1);
            //}
        }
        override public function initData():void{
            this.tName.prompt = Tools.getMsgById("_public229");
            this.tPwd1.prompt = Tools.getMsgById("_public230");
            this.tPwd2.prompt = Tools.getMsgById("_public231");
            //
            this.btn_fb.visible = false;//(ConfigApp.pf == ConfigApp.PF_ios_meng52_tw);

            this.mType = this.currArg;
            //
            this.listBox.visible = false;
            this.btn_users.visible = true;
            // this.t3.visible = false;
            this.boxReg.visible = false;
            this.tPwd2.visible = false;
            this.btn_login.visible = true;
            this.btn_register.visible = true            
            this.btn_phone.visible = true;
            this.btn_fast.visible = true;;
            this.boxReal.visible = true;
            this.btn_login.label = Tools.getMsgById("_lht69");
            // this.btn_auto.selected = ModelPlayer.instance.getAutoLogin();
            //
            ModelGame.unlock(this.btn_real,"tired_real_name");
            // this.btn_real.visible = true;
            if(this.btn_real.visible && !ModelPlayer.instance.isTempPlayer){
                this.btn_real.visible = false;
            }
            if(!this.btn_real.visible){
                // this.btn_auto.x = 138;
            }
            //
            // this.btn_login.centerX = 190;
            // this.btn_register.centerX = -190;
            // this.btn_real.centerX = -150;
            //this.tTitle.text = Tools.getMsgById("_public139");//"登录游戏";
            this.comTitle.text = Tools.getMsgById("_public139");
            //
            var isNull:Boolean = this.mType!=1;
            this.tName.text = isNull?"":ModelPlayer.instance.getName();
            this.tPwd1.text = isNull?"":ModelPlayer.instance.getPWD();
            this.tPwd2.text = "";

            //            
            this.click_auto(true);
            //
            Platform.checkGameStatus(1301);

            if(mType==2){//注册
                click(1);
            }
        }
        private function onTxtClick(type:Number):void{
            trace("onTxtClick:::",type);
            Platform.checkGameStatus(1400+type);
        }
        private function click_auto(set:Boolean):void
        {
            // this.btn_auto.selected = set?set:!this.btn_auto.selected;
            // ModelPlayer.instance.setAutoLogin(this.btn_auto.selected);
            ModelPlayer.instance.setAutoLogin(true);
        }
        override public function closeSelf(onlySelf:Boolean = true):void{
            var isNull:Boolean = this.mType!=1;
            var b:Boolean = false;
            if(!onlySelf){
                b = true;
            }
            else{
                if(isNull){
                    b = true;
                    if(this.boxReg.visible){
                        this.initData();
                    }
                    else{
                        // b = true;
                        ViewManager.instance.showTipsTxt(Tools.getMsgById("_public140"));//"请登录或注册一个游戏账号"
                    }
                }
                else{
                    b = true;
                }
            }
			if(b){
                ViewManager.instance.closePanel(onlySelf?this:null);
                
            }
		}
        private function click_facebook():void
        {
            var _this:* = this;
            Platform.login(Handler.create(null,function(status:*,re:*):void{
                if(re){
                    // var pa:Object = {username:re.uid,pf:ConfigApp.pf_channel,pwd:re.pwd,pwd1:re.pwd};
                    // NetHttp.instance.send(NetMethodCfg.HTTP_USER_REGISTER,pa,Handler.create(_this,_this.http_user_register));
                    _this.tName.text = re.uid,
                    _this.tPwd1.text = re.pwd,
                    _this.http_user_login(true);
                }
            }),"fb");
        }
        private function click(type:Number):void
        {
            if(type == 1){
                    // this.t3.visible = true;
                    Platform.checkGameStatus(1304);
                    this.boxReg.visible = true;
                    this.tPwd2.visible = true;   
                    //
                    this.tPwd1.text = "";
                    this.tPwd2.text = "";
                    this.tName.text = "";
                    //this.tTitle.text = Tools.getMsgById("_public145");//"注 册";
                    this.comTitle.text = Tools.getMsgById("_public145");
                    //
                    // this.btn_register.centerX = 0;
                    // this.btn_login.visible = false;
                    this.btn_login.label = Tools.getMsgById("_lht68");
                    this.btn_users.visible = false;
                    this.btn_real.visible = false;
                    this.btn_register.visible = false;
                    this.boxReal.visible = false;
                    this.btn_fast.visible = false;
                    this.btn_phone.visible = false;
                    
                // }
            }else if(type==2){
                ViewManager.instance.showView(["ViewRealName",ViewRealName],null,{type:0});
            }
            else if(type == 3){
                Platform.checkGameStatus(1302);
                ViewManager.instance.showView(["ViewLoginPhone",ViewLoginPhone],null,{type:0});
            }
            else if(type == 4){
                if(this.registCheck()){
                    return;
                }
                Trace.log("2准备注册的channel--:"+ConfigApp.pf_channel);
                NetHttp.instance.send(NetMethodCfg.HTTP_USER_REGISTER_FAST,{pf:ConfigApp.pf_channel},Handler.create(this,this.registFast));
            }
            else if(type == 5){
                Platform.checkGameStatus(1305);
                this.listBox.visible = !this.listBox.visible;
                if(this.listBox.visible){
                    var arr:Array = [];
                    for each(var value:Object in ModelPlayer.instance.mPlayerList)
                    {
                        if(value.uid && value.uid=="ready"){
                            continue;
                        }
                        if(value["name"] && value["name"]!=this.tName.text){
                            if(!value["times"]){
                                value["times"] = 1;
                            }
                            arr.push(value);
                        }
                    }
                    arr.sort(MathUtil.sortByKey("times",true));
                    this.listName.dataSource = arr;   
                    this.listName.selectedIndex = -1;                 
                }
            }
            else{
                if(this.boxReg.visible){
                    this.func_register();
                }
                else{
                    Platform.checkGameStatus(1303);
                    this.func_login(true);
                }
            }
        }
        private function registFast(re:Object):void
        {
            Platform.checkGameStatus(501);
            Trackingio.postReport(3,re);
            ThirdRecording.setRegister();
            this.closeSelf(false);
            //username: "21b48dcc7", pwd: "253604
           ViewManager.instance.showView(["ViewRegistFast",ViewRegistFast],re); 
        }
        private function registCheck():Boolean{
            var b:Boolean = false;
            var nowS:Number = new Date().getTime();
            var des:Number = nowS - this.mRegistTime;
            var ruler:Number = ConfigServer.system_simple.regist_gap_time*1000;
            if(des>=ruler){
                this.mRegistTime = nowS;
            }
            else{
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_lht72")+Tools.getTimeStyle(ruler-des));
                b = true;
            }
            return b;
        }
        private function func_register():void
        {
            if(this.registCheck()){
                return;
            }
            var b1:Boolean = false;
            var b2:Boolean = false;
            var b3:Boolean = false;
            var b4:Boolean = false;
            var str1:String = this.tName.text;
            str1 = str1.replace(/\s/g,"");             
            if(str1.length>=3){
                b1 = true;
            }
            else{
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_public141"));////"用户名字格式不正确"
                return;
            }
            if(this.tPwd1.text.length>=6){
                b2 = true;
            }
            else{
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_public142"));//"密码格式不正确"
                return;
            }            
            if(this.tPwd2.text.length>=6){
                b3 = true;
            } 
            else{
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_public143"));//"密码确认格式不正确"
                return;
            }             
            if(this.tPwd1.text == this.tPwd2.text){
                b4 = true;
            }
            else{
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_public144"));//"密码不一致"
                return;
            }                    
            if(b1 && b2 && b3 && b4){
                var pa:Object = {username:str1,pf:ConfigApp.pf_channel,pwd:this.tPwd1.text,pwd1:this.tPwd2.text};
                Trace.log("1准备注册的channel--:"+ConfigApp.pf_channel);
                NetHttp.instance.send(NetMethodCfg.HTTP_USER_REGISTER,pa,Handler.create(this,this.http_user_register));
            }
        }
        private function func_login(login:Boolean):void{
            var b1:Boolean = false;
            var b2:Boolean = false;    
            var str:String = this.tName.text;
            str = str.replace(/\s/g,"");            
            if(str.length>=3){
                b1 = true;
            }
            else{
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_public141"));//"用户名字格式不正确"
                return;
            }            
            if(this.tPwd1.text.length>=6){
                b2 = true;
            }  
            else{
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_public142"));//"密码格式不正确"
                return;
            }             
            if(b1 && b2){
                //登录
                this.http_user_login(login);
            }          
        }
        private function http_user_register(re:Object):void{
            Platform.checkGameStatus(502);
            //
            if(NetHttp.checkReIsError(re)){
                ViewManager.instance.showTipsTxt(re.msg);//用户名重复
                return;
            }
            //
            Trackingio.postReport(3,re);
            // 
            ThirdRecording.setRegister();
            //
            this.func_login(false);
        }
        private function http_user_login(login:Boolean):void
        {
            var str:String = this.tName.text;
            str = str.replace(/\s/g,"");
            // ModelPlayer.instance.setUID("ready");
            // ModelPlayer.instance.setName(str);
            // ModelPlayer.instance.setPWD(this.tPwd1.text);
            // ModelPlayer.instance.setPlayerList();
            ModelPlayer.instance.loginName = str;                                
            ModelPlayer.instance.loginPwd = this.tPwd1.text;                                
            // //
            this.closeSelf(false);
            // //
            ModelPlayer.instance.event(ModelPlayer.EVENT_LOGIN_OK,login?0:-1);
            //
        }

        override public function onRemoved():void{
            
        }
    }
}