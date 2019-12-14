package sg.view.map
{
    import ui.map.officer_order_aUI;
    import sg.cfg.ConfigServer;
    import sg.utils.Tools;
    import sg.manager.AssetsManager;
    import laya.events.Event;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.model.ModelOfficial;
    import sg.manager.ModelManager;
    import sg.manager.ViewManager;
    import sg.manager.LoadeManager;

    public class ViewOfficerOrderA extends officer_order_aUI
    {
        private var mOrderKey:String;
        private var mCityID:int;
        private var isFree:Boolean = false;
        private var mCfg:Object;
        public function ViewOfficerOrderA()
        {
            this.btn_free.on(Event.CLICK,this,this.click,[true]);
            this.btn_coin.on(Event.CLICK,this,this.click,[false]);
            //
            this.btn_free.label = Tools.getMsgById("_public34");

            this.text0.text=Tools.getMsgById("_public220");
            this.text1.text=Tools.getMsgById("_public221");
        }
        override public function initData():void{
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("bg_166.png"));
            //
            //this.iTitle.text = Tools.getMsgById("_lht24");
            this.comTitle.setViewTitle(Tools.getMsgById("_lht24"));
            
            this.isFree = false;
            this.mOrderKey = this.currArg[0];
            this.mCityID = this.currArg[1];
            //
            this.mCfg = ConfigServer.country[this.mOrderKey];
            //
            this.tInfo.style.align = "left";
            this.tInfo.style.color = "#c5dbff";
            this.tInfo.style.fontSize = 16;
            this.tInfo.style.wordWrap = true;
            this.tInfo.style.leading = 6;
            //
            this.tName.text = Tools.getMsgById(this.mCfg.name);
            this.tInfo.innerHTML = Tools.getMsgById(this.mCfg.info, [Tools.getMsgById(ConfigServer.city[this.mCityID].name)]);

            this.btn_free.visible = this.mCfg.gratis>0;
            this.btn_coin.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN),this.mCfg.consume[1]);
            this.btn_free.centerX = 150;
            this.btn_coin.centerX = this.btn_free.visible?-150:0;
            
            this.tMerit.text = ""+this.mCfg.reward_now[1];
            this.tTips.style.fontSize = 16;
            this.tTips.style.align = "center";
            this.tTips.style.color = "#c5dbff";
            //
            this.heroIcon.setHeroIcon(ModelManager.instance.modelUser.getHead());
            //
            this.imgOrder.skin = AssetsManager.getAssetsUI(this.mCfg.buff_icon);
            //
            this.changeUI();
        }
        private function changeUI():void
        {
            var usedn:Number = 0;
            var buffs:Array = null;
            if(this.mOrderKey == "buff_corps"){
                buffs = ModelOfficial.get_city_order_data(this.mOrderKey,this.mCityID);
            }
            else{
                buffs = ModelOfficial.get_country_order_data(this.mOrderKey);
            }
            var now:Number = ConfigServer.getServerTimer();
            var des:Number = -1;
            if(buffs){
                usedn = buffs[3];
                if (Tools.isNewDay(buffs[2])) {
                    usedn = 0;
                }
                if(usedn>=this.mCfg.number){
                    if(this.btn_free.visible){
                        this.btn_free.disabled = !ModelOfficial.orderIsNewDay(buffs,this.mOrderKey);
                    }
                    this.btn_coin.disabled = !ModelOfficial.orderIsNewDay(buffs,this.mOrderKey);
                }
                else{
                    if(this.mOrderKey==ModelOfficial.BUFF_5){//都尉令可以同时对多个城市生效 所以只要有次数就让用
                        des = -1;
                    }else{
                        //新补丁  守城令和攻城令也不走cd
                        if(this.mOrderKey==ModelOfficial.BUFF_3 || this.mOrderKey==ModelOfficial.BUFF_4){
                            des = -1;
                        }else{
                            des = Tools.getTimeStamp(buffs[2])+this.mCfg.time*Tools.oneMinuteMilli - now;
                        }
                        
                    }
                    this.btn_free.disabled = (des>0);
                    this.btn_coin.disabled = (des>0);
                }
            } else{
                this.btn_coin.disabled = false;
            }
            var tips:String = (des<0)?Tools.getMsgById(this.mCfg.tips,[this.mCfg.number-usedn]):Tools.getMsgById("_public94",[Tools.getTimeStyle(des,3)]);//"剩余时间:"+Tools.getTimeStyle(des,3);

            this.timer.clear(this,this.changeUI);
            if(des>0){
                this.timer.once(1000,this,this.changeUI);
            }
            this.tTips.innerHTML = tips;             
        }
        override public function onAdded():void{
            ModelManager.instance.modelGame.on(ModelOfficial.EVENT_UPDATE_ORDER,this,this.reFun);
        }
        override public function onRemoved():void{
            this.timer.clear(this,this.changeUI);
            ModelManager.instance.modelGame.off(ModelOfficial.EVENT_UPDATE_ORDER,this,this.reFun);
        }
        private function reFun(receiveData:*,isMe:Boolean):void
        {
            if(isMe && !this.isFree){
                var gift:Object = {};
                gift[this.mCfg.reward_now[0]]=this.mCfg.reward_now[1];
                ViewManager.instance.showRewardPanel(gift);
            }
            this.closeSelf();
        }
        private function click(free:Boolean):void
        {
            this.isFree = free;
            if(free==false){
                if(!Tools.isCanBuy("coin",this.mCfg.consume[1])){
                    return;
                }
            }
            var po:Object = {type:this.mOrderKey,is_free:free};
            if(this.mCityID>=-1){
                po["cid"] = this.mCityID+"";
            }
            NetSocket.instance.send(NetMethodCfg.WS_SR_CREATE_BUFF,po);
        }
    }   
}