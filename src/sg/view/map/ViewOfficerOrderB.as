package sg.view.map
{
    import ui.map.officer_order_bUI;
    import sg.cfg.ConfigServer;
    import sg.utils.Tools;
    import sg.manager.AssetsManager;
    import laya.events.Event;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.manager.ModelManager;
    import sg.model.ModelOfficial;
    import sg.manager.ViewManager;

    public class ViewOfficerOrderB extends officer_order_bUI
    {
        private var mOrderKey:String;
        private var mCityID:int;
        private var isFree:Boolean = false;
        private var mType:String;        
        public function ViewOfficerOrderB()
        {
            // this.btn_free.on(Event.CLICK,this,this.click,[true]);
            this.att_coin.on(Event.CLICK,this,this.click,[false,"buff_country3"]);
            this.def_coin.on(Event.CLICK, this, this.click, [false, "buff_country4"]);
			this.kaiqi_1.text = Tools.getMsgById("_public221");
			this.kaiqi_2.text = Tools.getMsgById("_public221");
			this.jiacheng_1.text = Tools.getMsgById("_public220");
			this.jiacheng_2.text = Tools.getMsgById("_public220");
        }
        override public function initData():void{
            //this.iTitle.text = Tools.getMsgById("_lht24");
            this.comTitle.setViewTitle(Tools.getMsgById("_lht24"));
            
            this.isFree = false;
            this.mCityID = this.currArg; 
            //
            var cfg1:Object = ConfigServer.country["buff_country3"];
            var cfg2:Object = ConfigServer.country["buff_country4"];
            this.imgOrder1.skin = AssetsManager.getAssetsUI(cfg1.buff_icon);
            this.imgOrder2.skin = AssetsManager.getAssetsUI(cfg2.buff_icon);
            this.setAtkUI(cfg1);
            this.setDefUI(cfg2);
            this.changeUI(cfg1,cfg2);
        }   
        private function changeUI(cfg1:Object,cfg2:Object):void
        {
            var now:Number = ConfigServer.getServerTimer();
            var buffs1:Array = ModelOfficial.get_country_order_data("buff_country3");
            var usedn1:Number = buffs1?buffs1[3]:0;
            var des1:Number = -1;
            //
            var isNo1:Boolean = ModelOfficial.checkCityIsMyCountry(this.mCityID);
            var nowCity:String = this.mCityID+'';
            var isSameCity1:Boolean = false;
            if(isNo1){
                this.att_coin.disabled = isNo1;
            }
            else{
                if(buffs1){
                    isSameCity1 = nowCity==buffs1[0];
                    if(usedn1>=cfg1.number){
                        this.att_coin.disabled = !ModelOfficial.orderIsNewDay(buffs1,"buff_country3");
                    }
                    else{
                        des1 = Tools.getTimeStamp(buffs1[2])+cfg1.time*Tools.oneMinuteMilli - now;
                        this.att_coin.disabled = (des1>0 && isSameCity1);
                    }
                }
            }
            var tips1:String = (des1>0 && isSameCity1)?Tools.getMsgById("_public94",[Tools.getTimeStyle(des1,3)]):Tools.getMsgById(cfg1.label,[cfg1.number-usedn1]);//"剩余时间:"+Tools.getTimeStyle(des1,3);
            this.attTips.innerHTML = tips1;
            //
            //
            buffs1 = ModelOfficial.get_country_order_data("buff_country4");
            usedn1 = buffs1?buffs1[3]:0;
            var des2:Number = -1;
            var isSameCity2:Boolean = false;
            //
            isNo1 = !ModelOfficial.checkCityIsMyCountry(this.mCityID);
            if(isNo1){
                this.def_coin.disabled = isNo1;
            }
            else{
                if(buffs1){
                    isSameCity2 = nowCity==buffs1[0];
                    if(usedn1>=cfg2.number){
                        this.def_coin.disabled = !ModelOfficial.orderIsNewDay(buffs1,"buff_country4");
                    }
                    else{
                        des2 = Tools.getTimeStamp(buffs1[2])+cfg2.time*Tools.oneMinuteMilli - now;
                        this.def_coin.disabled = (des2>0 && isSameCity2);
                    }
                }
            }
            tips1 = (des2>0 && isSameCity2)?Tools.getMsgById("_public94", [Tools.getTimeStyle(des2,3)]):Tools.getMsgById(cfg2.label,[cfg2.number-usedn1]);
            this.defTips.innerHTML = tips1;

            this.timer.clear(this,this.changeUI);
            if((des1>0 && isSameCity1) || (des2>0 && isSameCity2)){
                this.timer.once(1000,this,this.changeUI,[cfg1,cfg2]);
            }

        }
        private function setAtkUI(cfg:Object):void
        {
            this.attTips.style.fontSize = 16;
            this.attTips.style.align = "center";
            this.attTips.style.color = "#c5dbff";            
            //
            this.attName.text = Tools.getMsgById(cfg.label);
            this.attInfo.style.align = "left";
            this.attInfo.style.color = "#c5dbff";
            this.attInfo.style.fontSize = 16;
            this.attInfo.style.wordWrap = true;
            this.attInfo.style.leading = 6;             
            this.attInfo.innerHTML = Tools.getMsgById(cfg.info);
            this.att_free.visible = false;
            this.att_coin.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN),cfg.consume[1]);
            this.attMerit.text = ""+cfg.reward_now[1];
            //
            
        } 
        private function setDefUI(cfg:Object):void
        {
            this.defTips.style.fontSize = 16;
            this.defTips.style.align = "center";
            this.defTips.style.color = "#c5dbff";              
            //
            this.defName.text = Tools.getMsgById(cfg.label);
            this.defInfo.style.align = "left";
            this.defInfo.style.color = "#c5dbff";
            this.defInfo.style.fontSize = 16;
            this.defInfo.style.wordWrap = true;
            this.defInfo.style.leading = 6;            
            this.defInfo.innerHTML = Tools.getMsgById(cfg.info);
            this.def_free.visible = false;
            this.def_coin.setData(AssetsManager.getAssetsUI(AssetsManager.IMG_COIN),cfg.consume[1]);
            this.defMerit.text = ""+cfg.reward_now[1];
            this.def_coin.disabled = !ModelOfficial.checkCityIsMyCountry(this.mCityID);
        }   
        private function click(free:Boolean,types:String):void
        {
            this.isFree = free;
            this.mType = types;
            var po:Object = {type:types,is_free:free};
            if(this.mCityID>-1){
                po["cid"] = this.mCityID+"";
            }
            NetSocket.instance.send(NetMethodCfg.WS_SR_CREATE_BUFF,po);
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
                var cfg:Object = ConfigServer.country[this.mType];
                gift[cfg.reward_now[0]]=cfg.reward_now[1];
                ViewManager.instance.showRewardPanel(gift);
            }            
            this.closeSelf();
        }                          
    }   
}