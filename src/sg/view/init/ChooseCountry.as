package sg.view.init
{
    import ui.init.viewCountryUI;
    import sg.utils.Tools;
    import sg.model.ModelGame;
    import laya.events.Event;
    import laya.utils.Handler;
    import sg.cfg.ConfigApp;
    import sg.manager.ModelManager;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.model.ModelUser;
    import sg.cfg.ConfigServer;
    import laya.ui.Image;
    import sg.view.com.comIcon;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;
    import sg.manager.ViewManager;

    public class ChooseCountry
    {
        private var ui:viewCountryUI = null;
        private var timerRe:Number = 0;
        private var mSelect:int = 0;
        private var recommend:int = 0; // 推荐国家
        private var mHandler:Handler;
        private var mIsRandom:Boolean = false;
        public function ChooseCountry(ui:viewCountryUI) {
            this.ui = ui;
            Tools.check1280Img(ui.mCountry);
            ui.mCountry.centerY = NaN;
            ui.mCountry.top = 0;
            ui.btn_img0.on(Event.CLICK, this, this.selectCountry, [0]);
            ui.btn_img1.on(Event.CLICK, this, this.selectCountry, [1]);
            ui.btn_img2.on(Event.CLICK, this, this.selectCountry, [2]);
            ui.btn_start.on(Event.CLICK,this,this.click_start);
            //
            ui.btn_re.on(Event.CLICK,this,this.click_re);
            //
            ui.tName.on(Event.INPUT,this,this.changeTxt);
            ui.tName.prompt = Tools.getMsgById("_public128");//"请输入2~5个中文";
            ui.btn_start.label = Tools.getMsgById("ViewCountry_1");
            mIsRandom = false;
            if(!ModelGame.unlock(null,"random_uname").stop){
                this.getName();
			}
        }

        public function initUI():void {
            this.mHandler = ui.currArg;
            if(ModelGame.unlock(null,"random_uname").stop){
				ui.btn_re.visible = false;
			}
            var imgArr:Array = ["icon_country2.png","icon_country3.png","icon_country1.png"];
            ViewManager.isLoadView = true;
            Platform.checkGameStatus(2100);
            LoadeManager.loadTemp(ui.img_bg, AssetsManager.getAssetsCountry("bg_country.png"));
            //
            var c:int = ModelUser.getCountryID();
            this.recommend = c < 0 ? (c + 3) : c;
            var aid:String = ConfigServer.system_simple.country_advise[2][0];
            // var aNum:String = ConfigServer.system_simple.country_advise[2][1];
            for(var i:int = 0; i < 3; i++) {
                var award:comIcon = ui["award" + i] as comIcon;
                award.setData(aid, -1, -1);
                award.clearEvents();
                LoadeManager.loadTemp(ui["btn_img" + i],AssetsManager.getAssetsCountry(imgArr[i]));
            }
            this.selectCountry(this.recommend);
        }

        private function selectCountry(countryId:int):void{
            mSelect = countryId;
            for(var i:int = 0; i < 3; i++) {
                (ui["btn_img" + i] as Image).alpha = i === countryId ? 1 : 0.01;
                var recommendChoosed:Boolean = this.recommend === i;
                (ui["img_recommend" + i] as Image).visible = recommendChoosed;
                (ui["award" + i] as comIcon).visible = recommendChoosed;
                (ui["img_flag" + i] as Image).visible = mSelect === i;
            }
            ui.cTxt.text = Tools.getMsgById("country_get_" + countryId);
            var king_id:String = ConfigServer.country_king_icon[countryId];
            if(king_id.indexOf("hero")!=-1){
                ui.heroIcon.visible = true;
                if(ui["buildImg"]) ui["buildImg"].visible = false;
                ui.heroIcon.setHeroIcon(king_id);
            } else {
                ui.heroIcon.visible = false;
                if(ui["buildImg"]) ui["buildImg"].visible = true;
                ui["buildImg"].skin = "country/" + ConfigServer.country_king_icon[countryId] + ".png";
            }
		}
        private function changeTxt():void {
            mIsRandom = false;
        }
        
        private function click_start():void {
            if(ModelUser.getCountryID() < 0){
                var str:String = ui.tName.text;
                mIsRandom && this.chooseCountry(str);
                mIsRandom || Tools.checkNameInput(str, Handler.create(this, this.chooseCountry));
            }
        }
        
        private function chooseCountry(input:String):void {
            NetSocket.instance.send(NetMethodCfg.WS_SR_CHOOSE_COUNTRY,{country:mSelect,uname:input,pf_data:Platform.pf_login_data,pf:ConfigApp.pf},Handler.create(this,this.chooseCountryCB));
        }

        private function testChangeName():void {
            NetSocket.instance.send(NetMethodCfg.WS_SR_CHANGE_UNAME,{uname:ui.tName.text},Handler.create(this,this.ws_sr_change_uname));
        }

        private function ws_sr_change_uname(re:NetPackage):void {
            ModelManager.instance.modelUser.updateData(re.receiveData);
        }

        private function click_re():void {
            //随机
            this.timerRe = Tools.runAtTimer(this.timerRe,1000,Handler.create(this,this.getName));
        }

        private function getName():void {
            NetSocket.instance.send(NetMethodCfg.WS_SR_GET_RANDOM_UNAME,{},Handler.create(this,this.ws_sr_get_random_uname));
        }

        private function ws_sr_get_random_uname(re:NetPackage):void{
            var str:String = re.receiveData;
            str = str.replace(/\s/g,""); 
            ui.tName.text = str;
            mIsRandom = true;
        }
        
        private function chooseCountryCB(re:NetPackage):void{
            Platform.checkGameStatus(2200);
            ModelManager.instance.modelUser.updateData(re.receiveData);
            // 
            Platform.uploadUserData(1000);
            if(ConfigApp.isFirstInstall){
                ConfigApp.isFirstInstall = false;
                Trace.log("111111第一次安装创建角色后成功选国家111111");
                Platform.uploadUserData(0);
            } else {
                Trace.log("222222已经安装过创建角色后成功选国家2222222");
            }
            mHandler && mHandler.run();
        }
    }
}