package sg.view.map
{
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.MathUtil;
	import laya.utils.Handler;

	import sg.boundFor.GotoManager;
	import sg.cfg.ConfigServer;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.model.ModelGame;
	import sg.model.ModelOfficial;
	import sg.model.ModelUser;
	import sg.net.NetMethodCfg;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.utils.Tools;
	import sg.view.com.ComPayType;

	import ui.map.country_invade_mainUI;
	import ui.map.item_country_invadeUI;
	import sg.guide.model.ModelGuide;
	import ui.bag.bagItemUI;
	import sg.manager.LoadeManager;
	import sg.manager.AssetsManager;

    public class ViewCountryInvadeMain extends country_invade_mainUI
    {
        private var mCurrInvade:int = 0;
        private var mCurrCity:Array; 
        private var _info:String = '';
        public function ViewCountryInvadeMain()
        {
            this.list.itemRender = item_country_invadeUI;
            this.list.renderHandler  = new Handler(this,this.list_render);
            // this.list.scrollBar.hide = true;
            this.list.selectEnable = true;
            this.list.selectHandler = new Handler(this,this.list_select);
            //
            this.btn_country.on(Event.CLICK,this,this.click_award,[1]);
            // this.btn_award.on(Event.CLICK,this,this.click_award,[2]);
            this.btn_go.on(Event.CLICK,this,this.click_go);
            this.btnHelp.on(Event.CLICK,this,this.click_help);
            this.btnHelp2.on(Event.CLICK,this,this.click_help);
            img_reward_year.on(Event.CLICK,this,this.click_reward_year);
            
            //
            this.iTitle.text = Tools.getMsgById("_country35");
            txt_reward0.text = Tools.getMsgById("_lht40");
            txt_reward1.text = Tools.getMsgById("_lht42");
            this.text0.text = Tools.getMsgById("_country45");
            this.zhanling.text = Tools.getMsgById("530051");
			txt_mail.text = Tools.getMsgById('_jia0120');
			txt_reward_title.text = Tools.getMsgById('_jia0129');
            img_ad.on(Event.CLICK, this, this._onClickImgAd);

            ConfigServer.country_pvp.winner.reward.forEach(function(arr:Array, index:int):void {
                (rewardList.getCell(index) as bagItemUI).setData(arr[0], arr[1], -1);
            }, this);
        }
        private function click_help(e:Event):void {
            ViewManager.instance.showTipsPanel(e.target === btnHelp ? Tools.getMsgById("530078") :_info);
        }

        private function click_award(type:int):void {
            var data:Object = this.list.array[this.list.selectedIndex];
            if(type == 1){
                NetSocket.instance.send(NetMethodCfg.WS_SR_GET_MILEPOST_REWARD,{milepost:data.index},Handler.create(this,this.ws_sr_get_milepost_reward),this.btn_country);
            }
            else{
                // NetSocket.instance.send(NetMethodCfg.WS_SR_GET_MILEPOST_FIGHT_REWARD,{milepost:data.index},Handler.create(this,this.ws_sr_get_milepost_reward),this.btn_award);
            }
        }    

        private function ws_sr_get_milepost_reward(re:NetPackage):void{
            var coin:Number = ModelManager.instance.modelUser.coin;
            ModelManager.instance.modelUser.updateData(re.receiveData);
            //
            // var clip:Button = re.otherData;
            // var po:Point = clip.localToGlobal(new Point(clip.x+clip.width*0.5,clip.y+clip.height*0.5));
            // ViewManager.instance.showIcon({coin:ModelManager.instance.modelUser.coin-coin},po.x,po.y);
            //
            var addCoin:Number = ModelManager.instance.modelUser.coin-coin;
            if(addCoin>0){
                ViewManager.instance.showRewardPanel({coin:addCoin});
            }
            //
            this.setUI(this.list.selectedIndex);
            this.list.changeItem(this.list.selectedIndex,this.list.array[this.list.selectedIndex]);
        }

        override public function initData():void{
            this.mCurrCity = [];
            //
            var cfg:Object = ConfigServer.country.milepost[ModelUser.getCountryID()];
            var arr:Array = [];
            for(var key:String in cfg)
            {
                cfg[key]["index"] = key;
                arr.push(cfg[key]);
            }
            arr.sort(MathUtil.sortByKey("index"));
            this.list.dataSource = arr;
            this.mCurrInvade = ModelGuide.forceGuide() ? 1 : ModelOfficial.getInvade();
            this.mCurrInvade = (this.mCurrInvade>0)?this.mCurrInvade:1;
            this.list.selectedIndex = (this.mCurrInvade-1);
        }
        private function list_render(item:item_country_invadeUI,index:int):void
        {
            var data:Object = this.list.array[index];
            item.tName.text = Tools.getMsgById(data.name);
            item.bg.toggle = false;
            item.mSelect.visible = (this.list.selectedIndex == index);
            item.off(Event.CLICK,this,this.click);
            item.on(Event.CLICK,this,this.click,[index]);
            //
            item.bg.selected = false;
            var invade:Number = (index+1);
            if(ModelOfficial.getInvadeAwardMax() >= invade){
                item.bg.selected = true;              
            }
            ModelGame.redCheckOnce(item, checkRed(invade));
        }
        
        /**
         * 检测红点
         */
        public static function checkRed(invade:int):Boolean
        {
            var modelUser:ModelUser = ModelManager.instance.modelUser;
            var cfg:Object = ModelOfficial.getInvadeCfg(invade);
            // return ModelOfficial.getInvadeAwardMax() >= invade && cfg.reward && cfg.reward.length && (modelUser.milepost_reward.indexOf(invade) === -1 || modelUser.milepost_fight_reward.indexOf(invade) === -1);
            return ModelOfficial.getInvadeAwardMax() >= invade && cfg.reward && cfg.reward.length && (modelUser.milepost_reward.indexOf(invade) === -1);
        }

        private function click(index:int):void
        {
            if(index>-1){
                if(this.list.selection){
                    (this.list.selection as item_country_invadeUI).mSelect.visible = false;
                }
                this.list.selectedIndex = index;
                //
            }
        }
        private function click_go():void
        {
            if(this.mCurrCity.length>0){
                var arr:Array = this.mCurrCity[1];
                var len:int = arr.length;
                var cid:int = -1;
                for(var i:int = 0;i < len;i++){
                    cid = parseInt(arr[i].split("_")[1]);
                    // if(!ModelOfficial.checkCityIsMyCountry(cid)){
                        GotoManager.instance.boundForMap(cid);
                        // MapCamera.lookAtCity(cid);
                        // this.closeSelf();
                        break;
                    // }
                }
            }
        }
        private function list_select(index:int):void
        {
            if(index>-1){
                this.setUI(index);
            }
        }
        public function setUI(index:int):void{
            this.clearBox();
            //
            this.iName1.text = Tools.getMsgById("_lht44");
            this.iName2.text = Tools.getMsgById("_lht45");
            //
            var data:Object = this.list.array[index];
            var unlockArr:Array = data["Unlock"];
            var len:int = unlockArr.length;
            var oname:String;
            var item:ComPayType;
            for(var i:int = 0; i < len; i++)
            {
                oname = unlockArr[i];
                oname = oname.replace("minister","");
                item = officerList.getCell(i) as ComPayType;
                item && item.setOfficialIcon(parseInt(oname));
            }
            this.iRuler.visible = Boolean(len);
            //
            this.mCurrCity = ModelOfficial.getInvadeUnlock(parseInt(data.index));
            //
            // this.tName.text = Tools.getMsgById(data.name);
            this.tName.text = ModelOfficial.getOfficerName(0, data.index);
            this.tInfo.text = (this.mCurrCity[0]!="")?Tools.getMsgById("_country9",[this.mCurrCity[0]]):"";//"本国占领:"+this.mCurrCity[0]):"";
            //
            var user:ModelUser = ModelManager.instance.modelUser;
            var cb:Boolean = user.milepost_reward.indexOf((index+1))<0;
            var ab:Boolean = user.milepost_fight_reward.indexOf((index+1))<0;
            //
            var invB:Boolean = true;
            if(index+1 > ModelOfficial.getInvadeAwardMax()){
                cb = false;
                ab = false;
                invB = false;
            }
            this.boxClip1.destroyChildren();
            // this.boxClip1.scale(1.5,2);
            if(cb){
                var upClip1:Animation = EffectManager.loadAnimation("glow014");
                upClip1.x = 50;
                upClip1.y = 50;
                this.boxClip1.addChild(upClip1); 
            } 
            this.btn_country.visible = cb;
            // this.btn_award.visible = ab;
            this.btn_go.visible = this.mCurrCity[1].length>0;
            //
            var cfg:Object = ModelOfficial.getInvadeCfg(parseInt(data.index));
            //
            this.box_award.visible = (cfg.reward.length>0);
            this.box_award_merit.visible = box_award.visible;
            // this.box_award_merit.visible = (cfg.fight_reward.length>0);
            //
            this.tNoInfo.visible = !this.box_award.visible && !this.box_award_merit.visible;

            img_ad.visible = txt_tips.visible = tNoInfo.visible && !user.isMerge;
            if (img_ad.visible) {
                LoadeManager.loadTemp(img_ad, AssetsManager.getAssetsAD('actPay1_24.jpg'));
                var bold_recharge:Object = ConfigServer.system_simple.bold_recharge;
                var gameDate:int = user.getGameDate();
                txt_tips.text = Tools.getMsgById(bold_recharge.text3);
                txt_count_tips.visible = bold_recharge.blind_time < gameDate;
                if (bold_recharge.inform_time > gameDate) {
                    txt_count_tips.text = Tools.getMsgById(bold_recharge.text1, [bold_recharge.inform_time - gameDate]);
                }
                else {
                    txt_count_tips.text = Tools.getMsgById(bold_recharge.text2);
                }
                txt_count_tips.y = img_ad.height - (txt_count_tips.textField.textHeight + 50);
            }
            var tempArr:Array = [Tools.getMsgById(mCurrCity[1][0]), Tools.getMsgById(mCurrCity[1][1]), ModelUser.country_name[ModelUser.getCountryID()]];
            _info = Tools.getMsgById(cfg.info2, tempArr);
            // this.tNoInfo.text = Tools.getMsgById(cfg.info);
            // this.fight_rewardTxt.text = Tools.getMsgById("_lht42");flag_2
            //
            if(cfg.reward.length>0){
                this.isGet1.visible = invB && !cb;//((cfg.reward.length>0) || this.btn_country.visible)?false:true;
                // this.reward.setData(ModelItem.getItemIcon(cfg.reward[0]),7,"",cfg.reward[1]);
                this.reward.setData(cfg.reward[0],cfg.reward[1],-1);
            }
            if(cfg.fight_reward.length>0){
                //this.fight_reward.setData(ModelItem.getItemIcon(cfg.fight_reward[0]),7,"",cfg.fight_reward[1]);
                // this.fight_reward.setData(cfg.fight_reward[0],cfg.fight_reward[1],-1);
                var ratio:Number = cfg.fight_reward[0];
                txt_ratio.text = 'x' + ratio;
                ratio === 1 && (box_award_merit.visible = false);
                box_award.x = box_award_merit.visible ? 49 : 183;
            }
			
			
			var citys:Array = this.mCurrCity[1].map(function(s:String, i:int, arr:Array):String{
				return s.split("_")[1];
			});
            
            outline.clear();
			outline.initCitys(citys);
		
        }

        private function clearBox():void {
        }

        private function _onClickImgAd():void {
        }
        
        override public function onRemoved():void {
            this.clearBox();
            outline.clear();
            this.list.selectedIndex = -1;
        }

        private function click_reward_year():void {
            ViewManager.instance.showTipsTxt(Tools.getMsgById('_country86'));
        }
    }   
}