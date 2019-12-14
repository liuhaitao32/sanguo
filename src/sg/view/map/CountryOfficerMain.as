package sg.view.map
{
    import ui.map.country_officer_mainUI;
    import laya.events.Event;
    import ui.map.item_country_officerUI;
    import sg.model.ModelOfficial;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.manager.ModelManager;
    import sg.utils.Tools;
    import sg.model.ModelUser;
    import sg.model.ModelOffice;
    import sg.manager.AssetsManager;
    import sg.manager.LoadeManager;
    import laya.net.Loader;
    import laya.net.URL;
    import sg.view.country.ViewCountryRank;
    import sg.view.country.ViewCountryMayor;
    import laya.utils.Handler;
    import sg.manager.EffectManager;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.cfg.ConfigServer;
    import sg.model.ModelAlert;
    import sg.model.ModelGame;
    import sg.cfg.HelpConfig;
    import laya.ui.Panel;

    public class CountryOfficerMain extends country_officer_mainUI
    {
        private var mOfficers:Array
        public function CountryOfficerMain()
        {
            this.on(Event.REMOVED,this,this.onRemove);
            ModelManager.instance.modelOfficel.on(ModelOfficial.EVENT_SET_OFFICER_IS_OK,this,this.setUI);
            ModelManager.instance.modelOfficel.on(ModelOfficial.EVENT_UPDATE_IMPEACH,this,this.checkRedImpeach);
            //
            LoadeManager.loadTemp(this.adImg1,AssetsManager.getAssetLater("bg_003.png"));
            LoadeManager.loadTemp(this.adImg2,AssetsManager.getAssetLater("bg_003.png"));        
            //
            this.iCity.text = Tools.getMsgById("_lht33");    
            this.btn0.on(Event.CLICK,this,btnClick,[this.btn0]);

            this.btn1.on(Event.CLICK,this,btnClick,[this.btn1]);

            this.btn0.label=Tools.getMsgById("_country59");
            this.btn1.label=Tools.getMsgById("_country69");
            //this.btn0.visible=this.btn1.visible=false;
            this.setUI();
            this.checkRedImpeach();
            if(this["pan"]){
                (this["pan"] as Panel).vScrollBar.visible = false;
            }
        }

        public function btnClick(obj:*):void{
            switch(obj){
                case this.btn0:
                    ViewManager.instance.showView(["ViewCountryRank",ViewCountryRank]);
                break;

                case this.btn1:
                    ViewManager.instance.showView(["ViewCountryMayor",ViewCountryMayor]);
                break;
            }
        }

        private function checkRedImpeach():void{
            ModelGame.redCheckOnce(this["minister0"].icon,ModelAlert.red_country_check("country_impeach"));
        }


        private function onRemove():void{
            ModelManager.instance.modelOfficel.off(ModelOfficial.EVENT_SET_OFFICER_IS_OK,this,this.setUI);
            ModelManager.instance.modelOfficel.off(ModelOfficial.EVENT_UPDATE_IMPEACH,this,this.checkRedImpeach);
            this.destroyChildren();
            this.destroy(true);
        }
        private function setUI():void
        {
            //
            this.mOfficers = ModelOfficial.getOfficers();
            //
            var len:int = 13;
            var item:item_country_officerUI;
            for(var i:int = 0; i < len; i++)
            {
                item = this["minister"+i];

                this.setItemUI(item,i);
            }
            var curr:Number = ModelOfficial.getInvade();
            if(HelpConfig.type_app == HelpConfig.TYPE_WW){
                this["minister0"].bgColor.visible = this["minister0"].tOfficer.visible = this["minister0"].bgImg.visible = false;
                if(this["tOfficer"]) this["tOfficer"].text = this["minister0"].tOfficer.text;
            }
            // trace(curr);
            //
            this.tInvade.text = (curr>0)?Tools.getMsgById(ModelOfficial.getInvadeCfg(curr).name):"";
            this.tCityNum.text = ModelOfficial.getMyCities(ModelUser.getCountryID(),[4]).length+"";
        }
        private function setItemUI(item:item_country_officerUI,id:int):void{
            var od:Array = Tools.isNullObj(this.mOfficers[id])?[]:this.mOfficers[id];
            //[248, "江阳王敬文", null, null]
            item.tOfficer.text = ModelOfficial.getOfficerName(id);
            var isOpen:Boolean = ModelOfficial.checkOfficerIsOpen(id);
            item.lock.visible = !isOpen;
            item.icon.visible = isOpen;
            item.bg.visible = !(id == 0);
            if(isOpen){
                if(od.length>0){
                    item.tName.text = od[1];
                    item.icon.setHeroIcon(ModelUser.getUserHead(od[3]));
                }
                else{
                    item.icon.setHeroIcon("hero000");
                    item.tName.text = Tools.getMsgById("_country2");//虚位以待
                }
            }
            else{
                item.tName.text = Tools.getMsgById("_country2");//虚位以待Tools.getMsgById(ModelOfficial.getInvadeCfg(ModelOfficial.getOfficerInvade(id)).name);
            }
            //item.bgColor.skin = AssetsManager.getAssetsUI((ModelOfficial.isKingKing("") && (id == 0))?"icon_chenghao2.png":"icon_chenghao0.png");
            Tools.textFitFontSize(item.tName);
            
            EffectManager.changeSprColor(item.bgColor, ModelOfficial.getOfficerColorLevel(id, ModelOfficial.getInvade(ModelManager.instance.modelUser.country)));
            //icon_chenghao0.png,icon_chenghao2.png
            item.off(Event.CLICK,this,this.click);
            item.on(Event.CLICK,this,this.click,[id,od,isOpen]);
        }
        private function click(id:int,od:Array,isOpen:Boolean):void{
            if(od[0]){
                if(id==0 && isOpen && od[0]+""!=ModelManager.instance.modelUser.mUID){
                    NetSocket.instance.send(NetMethodCfg.WS_SR_GET_USERS,{type:1,page:0,size:ConfigServer.country.impeach.start+1},Handler.create(this,function(np:NetPackage):void{
                       clickHandler(id,od,isOpen,np.receiveData.data);
                    }));
                }else{
                    clickHandler(id,od,isOpen);
                    
                }
            }else{
                ViewManager.instance.showView(ConfigClass.VIEW_COUNTRY_OFFICER_INFO,[id,od,isOpen,false]);
            }
        }

        private function clickHandler(id:int,od:Array,isOpen:Boolean,np:*=null):void{
            ModelManager.instance.modelUser.checkUserOnline([od[0]],Handler.create(this,function(re:*):void{
                ViewManager.instance.showView(ConfigClass.VIEW_COUNTRY_OFFICER_INFO,[id,od,isOpen,re[od[0]],np]);
            }));
        }
    }   
}   