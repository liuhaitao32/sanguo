package sg.view.init
{
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.manager.ModelManager;
    import sg.utils.Tools;
    import laya.ui.Box;
    import sg.cfg.ConfigApp;
    import laya.ui.Image;
    import sg.view.com.comIcon;
    import sg.cfg.ConfigServer;
    import sg.model.ModelUser;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;
    import sg.model.ModelGame;
    import ui.init.viewCountryPCUI;
    import sg.view.com.ComPayType;

    public class ViewCountryPC extends viewCountryPCUI{
        private var timerRe:Number = 0;
        private var mType:int = 0;
        private var mHandler:Handler;
        private var recommend:int = 0;
        private var mIsRandom:Boolean = false;
        public function ViewCountryPC(){
            //
            Tools.check1280Img(this.mCountry);
            this.mCountry.centerY = NaN;
            this.mCountry.top = 0;

            //
            this.btn_0.on(Event.CLICK,this,this.click,[0]);
            this.btn_00.on(Event.CLICK,this,this.click,[0]);
            this.btn_1.on(Event.CLICK,this,this.click,[1]);
            this.btn_11.on(Event.CLICK,this,this.click,[1]);
            this.btn_111.on(Event.CLICK,this,this.click,[1]);
            this.btn_2.on(Event.CLICK,this,this.click,[2]);
            this.btn_22.on(Event.CLICK,this,this.click,[2]);
            this.btn_222.on(Event.CLICK,this,this.click,[2]);
            //
            this.btn_start.on(Event.CLICK,this,this.click_start);
            //
            this.btn_re.on(Event.CLICK,this,this.click_re);
            //
            this.tName.on(Event.INPUT,this,this.changeTxt);
            this.tName.prompt = Tools.getMsgById("_public128");//"请输入2~5个中文";
            this.tName.on(Event.INPUT,this,this.onInput);
            this.btn_start.label = Tools.getMsgById("ViewCountry_1");
            //797,798,799
            //
            mIsRandom = false;
            if(!ModelGame.unlock(null,"random_uname").stop){
                this.getName();
			}
            
            //
            
		}
        private function changeTxt():void
        {
            // var s:String = FilterManager.instance.wordBan(this.tName.text);
            // s = FilterManager.instance.nameBan(s);
            // this.tName.text = s;
            mIsRandom = false;

        }        
		override public function initData():void{
            if(ModelGame.unlock(null,"random_uname").stop){
				this.btn_re.visible = false;
			}
            var imgArr:Array = ["icon_country2.png","icon_country3.png","icon_country1.png"];
            ViewManager.isLoadView = true;
            //
            Platform.checkGameStatus(2100);
            // trace(ModelManager.instance);
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsCountry("bg_country.png"));
            this.mHandler = this.currArg;
            //
            var c:int = ModelUser.getCountryID();
            var cp:int = c;
            if(c<0){
                cp = c+3;
            }
            this.recommend = cp;
            var len:int = 3
            for(var i:int = 0; i < len; i++)
            {
                // (this["c"+i] as Box).visible = false;
                // (this["v"+i] as Image).visible = (this.recommend == cp);
                (this["vb"+i] as Image).visible = (this.recommend == i);
                LoadeManager.loadTemp(this["btn_img"+i],AssetsManager.getAssetsCountry(imgArr[i]));
            }
            this.checkSelect(this.recommend);
            //
        }
        private function checkSelect(cp:int):void{
            this.mType = cp;
            var len:int = 3;
            var aid:String = ConfigServer.system_simple.country_advise[2][0];
            var aNum:String = ConfigServer.system_simple.country_advise[2][1];
            for(var i:int = 0; i < len; i++)
            {
                
                (this["c"+i] as Box).visible = false;
                (this["v"+i] as Image).visible = (this.recommend == i);
                (this["award"+i] as comIcon).visible = (this.recommend == i);
                (this["award"+i] as comIcon).setData(aid,-1,-1);
                // (this["vb"+i] as Image).visible = (this.recommend == cp);
            }
            (this["c"+cp] as Box).visible = true;   
            //
            this.cTxt.text = Tools.getMsgById("country_get_"+cp);       
            //
            var king_id:String = ConfigServer.country_king_icon[cp];
            if(king_id.indexOf("hero")!=-1){
                this.heroIcon.visible = true;
                if(this["buildImg"]) this["buildImg"].visible = false;
                this.heroIcon.setHeroIcon(king_id);
            }else{
                this.heroIcon.visible = false;
                if(this["buildImg"]) this["buildImg"].visible = true;
                this["buildImg"].skin = "country/" + ConfigServer.country_king_icon[cp] + ".png";
            }
        }
        private function click(type:int):void{
            this.checkSelect(type);

        }
        private function click_start():void{
            // ViewManager.instance.closeView(true);
            // return;
            if(ModelUser.getCountryID()>=0){

            }
            else{
                var str:String = this.tName.text;
                if(mIsRandom){
                    NetSocket.instance.send(NetMethodCfg.WS_SR_CHOOSE_COUNTRY,{country:this.mType,uname:str,pf_data:Platform.pf_login_data,pf:ConfigApp.pf},Handler.create(this,this.ws_sr_choose_country));
                    return;
                }
				var _this:ViewCountryPC = this;
				Tools.checkNameInput(str, Handler.create(this, function(input:String):void {
                    NetSocket.instance.send(NetMethodCfg.WS_SR_CHOOSE_COUNTRY,{country:_this.mType,uname:str,pf_data:Platform.pf_login_data,pf:ConfigApp.pf},Handler.create(_this,_this.ws_sr_choose_country));
				}));
            }
        }
        private function testChangeName():void{
            NetSocket.instance.send(NetMethodCfg.WS_SR_CHANGE_UNAME,{uname:this.tName.text},Handler.create(this,this.ws_sr_change_uname));
        }
        private function ws_sr_change_uname(re:NetPackage):void{
            ModelManager.instance.modelUser.updateData(re.receiveData);
        }
        private function click_re():void{
            //随机
            this.timerRe = Tools.runAtTimer(this.timerRe,1000,Handler.create(this,this.getName));
        }

        private function getName():void{
            NetSocket.instance.send(NetMethodCfg.WS_SR_GET_RANDOM_UNAME,{},Handler.create(this,this.ws_sr_get_random_uname));
        }
        private function ws_sr_get_random_uname(re:NetPackage):void{
            var str:String = re.receiveData;
            str = str.replace(/\s/g,""); 
            this.tName.text = str;
            mIsRandom = true;
        }
        private function onInput():void{
           
        }
        private function ws_sr_choose_country(re:NetPackage):void{
            Platform.checkGameStatus(2200);
            //
            ModelManager.instance.modelUser.updateData(re.receiveData);
            //
            Platform.uploadUserData(1000);
            // 
            if(ConfigApp.isFirstInstall){
                ConfigApp.isFirstInstall = false;
                Trace.log("111111第一次安装创建角色后成功选国家111111");
                Platform.uploadUserData(0);
            }
            else{
                Trace.log("222222已经安装过创建角色后成功选国家2222222");
            }
            // 
            if(this.mHandler){
                this.mHandler.run();
            }
        }
        override public function onRemoved():void{
            // trace("onRemovedonRemovedonRemovedonRemovedonRemovedonRemovedonRemovedonRemovedonRemoved");
            // Loader.clearRes("res/atlas/country.png",true);
            // Laya.loader.clearUnLoaded();
            // Laya.loader.clearTextureRes("res/atlas/country.png");
            // Laya.loader.clearTextureRes("res/atlas/country.atlas");
        }
    }   
}