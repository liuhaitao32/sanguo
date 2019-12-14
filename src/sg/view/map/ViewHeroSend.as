package sg.view.map
{
	import sg.map.model.entitys.EntityCity;
	import sg.map.utils.TestUtils;
    import ui.map.heroSendUI;
    import laya.utils.Handler;
    import sg.manager.ModelManager;
    import sg.model.ModelHero;
    import laya.events.Event;
    import sg.model.ModelTroop;
    import sg.utils.Tools;
    import sg.model.ModelGame;
    import laya.maths.MathUtil;
    import sg.map.model.entitys.EntityMarch;
    import sg.cfg.ConfigServer;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.model.ModelBuiding;
    import sg.manager.AssetsManager;
    import sg.fight.logic.utils.FightUtils;
    import sg.view.com.HeroSendPanel;
    import sg.utils.StringUtil;
    import sg.scene.constant.EventConstant;

	/**
	 * 部队前往
	 * @author
	 */
    public class ViewHeroSend extends heroSendUI{

        public var onlyHero:String="";
        public var mCityId:int;
        public var mTroops:Array;
        public var mOtherPa:*;
        public var isOnly:Boolean = false;
        public var onlyHere:Number = 0;//-1 所有部队  0 本城部队  1 非本城部队
        //public var solo_rate_name:Array;
        public var lossData:Object;
        public var mHeroSendPanel:HeroSendPanel;
        public var mFoodNum:Number=0;
        public function ViewHeroSend():void{
            //
            this.mHeroSendPanel = new HeroSendPanel();
            this.boxMain.addChild(this.mHeroSendPanel);
            this.mHeroSendPanel.left = 6;
            this.mHeroSendPanel.right = 6;
            this.mHeroSendPanel.top = 50;
            //
            this.btn_send.on(Event.CLICK,this,this.click_send);
            this.btn_send.label = Tools.getMsgById("_lht25");
            this.text2.text=Tools.getMsgById("_public209");
        }
        override public function initData():void{
            ModelManager.instance.modelGame.on(ModelGame.EVENT_HERO_TROOP_EDIT_UI_CHANGE,this,this.event_hero_troop_edit_ui_change);
            //this.tPowerInfo.visible = this.comPower.visible = false;
            var power:int = this.currArg[5];
			if (power !=-1){
				this.tPowerInfo.text = Tools.getMsgById('_public215');
				this.comPower.setNum(Math.abs(power));
				//this.tPower.text = Tools.getMsgById('_estate_text24', [Math.abs(power)]);
				this.tPowerInfo.visible = this.comPower.visible = true;
			}
			else{
				this.tPowerInfo.visible = this.comPower.visible = false;
			}
            
            this.boxPay.visible = false;
            tStatus.text="";
            this.text0.text = "";
            this.text1.text = "";
            
            //
            //this.solo_rate_name = ConfigServer.system_simple.solo_rate_name;
            
            this.mCityId = this.currArg[0];
            this.mTroops = this.currArg[1];
            this.mOtherPa = this.currArg[2];
            this.isOnly = this.currArg[3];
            this.onlyHere = this.currArg[4];
            this.mHeroSendPanel.mPowerRefer = this.currArg[5];
            //
            this.mHeroSendPanel.initData([this.mCityId,this.mTroops,this.isOnly,this.onlyHere,new Handler(this,this.hspChange),new Handler(this,this.hspTroopNull),this.currArg[6]]);
            //
            this.setUI();
			
			if (0 == this.mHeroSendPanel.mSelectArr.length) this.hspChange();
        }
        private function hspTroopNull(isNull:Boolean):void
        {
            this.btn_send.disabled = isNull;
            this.tPayFood.visible = !isNull;
            this.tStatus.visible = !isNull;
            this.tPayTime.visible = !isNull;
            //this.boxPay.visible = !isNull;
        }
        private function hspChange():void
        {
            this.showLoss();
            this.checkUI();
        }
        private function event_hero_troop_edit_ui_change(noNull:*,events:*):void{
            // trace(events,EventConstant.TROOP_UPDATE)
            if(events == EventConstant.TROOP_UPDATE){
                //异族入侵、名将来袭、不更新部队状态
                return;
            }
            this.setUI(true);            
        }
        override public function onRemoved():void{
            ModelManager.instance.modelGame.off(ModelGame.EVENT_HERO_TROOP_EDIT_UI_CHANGE,this,this.event_hero_troop_edit_ui_change);
            this.lossData = null;
            this.mHeroSendPanel.clear();
        }        
        private function setUI(update:Boolean = false):void{
            this.mHeroSendPanel.setList(update);
            this.setPKstatusUI(false);
        }
        public function showLoss():void{
            this.box_other.visible = true;
            this.mHeroSendPanel.bottom = 164;
        }
        public function selectLoss(netMethod:String,pro:Object):void{
            
            if(Tools.isNullObj(this.lossData)){
                NetSocket.instance.send(netMethod,pro,Handler.create(this,function(re:NetPackage):void{
                    this.lossData = re.receiveData;
                    this.setLossUI();
                }));
            }
            else{
                this.setLossUI();
            }
        }
		/**
		 * 预估损耗
		 */
        private function setLossUI():void{
            //hmd:ModelHero  判断当前部队血量
			var mt:ModelTroop = ModelManager.instance.modelTroopManager.getTroop(this.mHeroSendPanel.mSelectArr[0].hmd.id);
			var troopObj:Object = this.mHeroSendPanel.mSelectArr[0].hmd.getPrepareObjBy();
			if (mt){
				troopObj.army[0].hp = mt.army[0];
				troopObj.army[1].hp = mt.army[1];
			}
			
            this.lossData.team[0]={"troop":[troopObj]};
            var n:Number=FightUtils.checkSoloRate(this.lossData);
            var s:String = "";
			var color:String = "";
			var solo_rate_name:Object = ConfigServer.system_simple.solo_rate_name;
            for(var i:int=0;i<solo_rate_name.length;i++){
                var arr:Array=solo_rate_name[i];
                if(n>=arr[0]){
                    s = arr[1] + "";
					color = arr[2];
                }else{
                    break;
                }
            }
            this.text0.text = Tools.getMsgById(s);
			this.text0.color = color;
            this.text1.text=Tools.getMsgById("_country26",[StringUtil.numberToPercent(n)]);//"(预计损耗兵力"+Math.floor(n*100)+"%)";
            //
            this.boxPay.visible = false;
            //this.setPKstatusUI(true);            
        }
        public function setPKstatusUI(b:Boolean):void{
            //this.text0.visible = b;
            //this.text1.visible = b;
            //if(b) this.boxPay.visible = false;
        }        
        private function checkUI():void{
            this.tStatus.text = Tools.getMsgById("_country27",[this.mHeroSendPanel.mSelectArr.length]);//"已选择部队 "+this.mHeroSendPanel.mSelectArr.length;
            //
            var pay:Object = this.getTroopPay();
            var b:Boolean = pay.l>0;
            //
            // this.tPay.visible = b;
            this.btn_send.disabled = !b;
            // this.tPay.text = "时间: "+Tools.getTimeStyle(pay.s*Tools.oneMilliS) +"粮草: "+pay.food;
            //

			var titleName:String = this.onlyHere!=1 ? Tools.getMsgById("_public93") : Tools.getMsgById("_public93") + Tools.getMsgById(ConfigServer.city[this.mCityId].name);
			//this.tCity.text = titleName;
            this.cTitle.setViewTitle(titleName);
			//推荐战力
			
			

            mFoodNum=pay.food;
            //
            this.tPayFood.setData(ModelBuiding.getMaterialTypeUI("food"),pay.food);
            this.tPayTime.setData(AssetsManager.getAssetsUI("img_icon_02.png"),Tools.getTimeStyle(pay.s*Tools.oneMillis));
            this.boxPay.visible = (this.text0.text=="") && (this.mHeroSendPanel.mSelectArr.length>0 && pay.l>0 && (this.onlyHere==1));
        }
        private function getTroopPay():Object{
            var len:int = this.mHeroSendPanel.mSelectArr.length;
            var arr:Array = [];
            var obj:Object;
            var timeS:Number;
            var troop:ModelTroop;
            var foodAll:Number = 0;
            var tAll:Number = 0;
            for(var i:int = 0; i < len; i++)
            {
                obj = this.mHeroSendPanel.mSelectArr[i].ct;//this.list.array[this.mSelectArr[i]].ct;
                //
                troop = obj.model;
                //
                timeS = obj.time;

                foodAll += obj.food;

                tAll = Math.max(timeS,tAll);
            }    
            return {s:tAll,food:foodAll,l:len};
        }
        private function click_send():void{
            var len:int = this.mHeroSendPanel.mSelectArr.length;
            var arr:Array = [];
            for(var i:int = 0; i < len; i++)
            {
               arr.push(this.mHeroSendPanel.mSelectArr[i].ct);
            }
            if(arr.length>0){
                if(this.onlyHere==-1){//列表里是所有部队时 直接派兵去打  
                    this.click_send_func(arr);
                    return;
                }
                if(!Tools.isCanBuy("food",mFoodNum)){
                    return;
                }
				var handler:Handler = Handler.create(this, function(str:String, param:Array):void{
					ViewManager.instance.showAlert(Tools.getMsgById(str, param), Handler.create(this, function(index:int):void{
						if (index == 0) {
							click_send_func(arr);
							closeSelf();
						}
					}));
				})
				for (var j:int = 0, len2:int = arr.length; j < len2; j++) {
					if (!arr[j].citys) continue;
					var targetCity:EntityCity = arr[j].citys[arr[j].citys.length - 1];
					if (targetCity.fire && targetCity.getAttackError(arr[j].model) == 3 && targetCity.myCountry) {
						var limit:int = targetCity.getLimitLevel();
						var hmd:ModelHero = ModelManager.instance.modelGame.getModelHero(arr[j].model.hero);
						
						handler.runWith(["530100", [targetCity.getName(), limit]]);
						return;
					}
					
					for (var k:int = 0, len3:int = arr[j].citys.length - 1; k < len3; k++) {
						var city:EntityCity = arr[j].citys[k];
						if (city.fire && targetCity.myCountry) {
							handler.runWith(["530101", null]);
							return;
						}
					}
				}
                this.click_send_func(arr);
            }
            this.closeSelf();
        }
        public function click_send_func(arr:Array):void{
            ModelManager.instance.modelTroopManager.sendMoveTroops(arr);
        }

		/**
		 * 根据名字获取界面中的对象
		 * @param	name
		 * @return 	Sprite || undefined
		 */
		override public function getSpriteByName(name:String):*
		{
            if(name.indexOf('list') !== -1) {
                return this.mHeroSendPanel.list.getCell(name.match(/\d/)[0])
            }
            return super.getSpriteByName(name);
		}
    }   
}