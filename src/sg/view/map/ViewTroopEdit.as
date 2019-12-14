package sg.view.map
{
	import laya.events.Event;
	import laya.maths.MathUtil;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.utils.Handler;
	import sg.cfg.ConfigClass;
	import sg.cfg.ConfigServer;
	import sg.fight.FightMain;
	import sg.fight.client.ClientBattle;
	import sg.fight.logic.unit.TroopLogic;
	import sg.manager.EffectManager;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.map.model.entitys.EntityMarch;
	import sg.model.ModelBuiding;
	import sg.model.ModelGame;
	import sg.model.ModelHero;
	import sg.model.ModelOfficeRight;
	import sg.model.ModelOfficial;
	import sg.model.ModelTroop;
	import sg.model.ModelTroopManager;
	import sg.net.NetMethodCfg;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.scene.constant.EventConstant;
	import sg.scene.view.MapCamera;
	import sg.utils.Tools;
	import ui.map.troopEditArmyUI;
	import ui.map.troopEditUI;
	import sg.model.ModelCityBuild;
	import sg.boundFor.GotoManager;
	import laya.display.Animation;
	import sg.utils.MusicManager;
	import laya.display.Sprite;

	/**
	* 部队编辑
	*/
    public class ViewTroopEdit extends troopEditUI{
		static private var _BTN_CONFIG:Object = {
			'set':[1, 'ui/btn_ok.png',"#fffcac"],       // 创建
			'del':[0, 'ui/btn_no_s2.png',"#fffcac"],    // 解散
			'add':[2, 'ui/btn_ok.png',"#fffcac"],       // 补兵
			'cd':[2, 'ui/btn_ok.png',"#fffcac"],        // 加速
			'back':[0, 'ui/btn_no_s2.png',"#fffcac"],   // 撤回
			'break':[2, 'ui/btn_ok.png',"#fffcac"],     // 突进
			'runaway':[0, 'ui/btn_no_s2.png',"#fffcac"]// 撤军
		};
		static private var _BTN_NUM:int = 3;
		
        private var mModel:ModelTroop;
        private var mStatus:int = 0;
        private var mHeroIcon:ItemHero;
        private var mMarch:EntityMarch;
        private var mMarchTime:Number = 0;
        private var imgBox0:Box;
        private var imgBox1:Box;
        private var funs:Array;
        private var cityB07lv:Number;
        private var forceDel:Boolean;
		private var delStatus:Number = 0;
		private var armyData_f:Object = {};
		private var armyData_b:Object = {};
        private var armyAddCoinArr:Array = [0,0];
        private var armyAddCoinPersonArr:Array = [0,0];
        private var _operateHid:String = ''; // 创建英雄的Id（在创建完成之后要用到）
        private var mIsXYZ:Boolean;//是否是襄阳战编组
        public function ViewTroopEdit():void{
            this.list.itemRender = ItemHero;
            this.list.scrollBar.visible = false;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.selectEnable = true;
            this.list.selectHandler = new Handler(this, this.list_select);

			this.funs = [];
			for (var i:int = 0; i < _BTN_NUM; i++) 
			{
				this.funs.push(null);
				var btn:Button = this['btn_' + i] as Button;
				btn.on(Event.CLICK,this,this.click_func,[i]);
			}
			this.army0.kucun.text = Tools.getMsgById("BuildClip_1");
			this.army1.kucun.text = Tools.getMsgById("BuildClip_1");
        }
		private function getBtn(type:String):Button{
			var cfg:Object = _BTN_CONFIG[type];
			if (cfg){
				var index:int = cfg[0];
				var btn:Button = this['btn_' + index] as Button;
                if(btn.visible && btn["type"] == type){
				    return btn;
                }
                else{
                    return null;
                }
			}
			return null;
		}
		private function setBtn(type:String,gray:Boolean = false):Button{
			var cfg:Object = _BTN_CONFIG[type];
			if (cfg){
				var index:int = cfg[0];
				var btn:Button = this['btn_' + index] as Button;
				btn.visible = true;
				btn.skin = cfg[1];
                btn.labelColors = cfg[2];
                if(this.forceDel && type=="del"){
                    btn.label = Tools.getMsgById("troopEditBtn_force");
                }
				else{
                    btn.label = Tools.getMsgById('troopEditBtn_' + type);
                }
				btn.gray = gray;
                btn["type"] = type;
				this.funs[index] = this['click_' + type];
				return btn;
			}
			return null;
		}
		private function resetBtns():void{
			for (var i:int = 0; i < _BTN_NUM; i++) 
			{
				var btn:Button = this['btn_' + i] as Button;
				btn.visible = false;
                btn["type"] = "";
				this.funs[i] = null;
			}
		}
        override public function initData():void{
            //
            this.tLvName.text = Tools.getMsgById("_hero14");
            if(this.currArg is Boolean){
                this.mModel = null;
                mIsXYZ=this.currArg;
            }else{
                this.mModel = this.currArg as ModelTroop;
            }
            this.mStatus = this.mModel?this.mModel.state: -1;
			if (this.mModel && this.mModel.entityCity){
				this.cityB07lv = this.mModel.entityCity.getB07lv(); //ModelCityBuild.getBuildLv(this.mModel.cityId + "", "b07");
			}
			else{
				this.cityB07lv = -1;
			}
            this.list.selectedIndex=-1;
            this.initUI();
            //this.goCity();
            if(this.mStatus<0){
                if(mIsXYZ)
                    MapCamera.lookAtCity((ModelManager.instance.modelUser.country+10)*-1);
            }
        }
        private function goCity():void{
            if(this.mStatus<0){
                MapCamera.lookAtCity(ModelManager.instance.modelMap.myCapital.cityId);
            }
            else{
                if(this.mStatus == 0){
                    MapCamera.lookAtCity(this.mModel.cityId);
                }
            }
        }
        override public function onAdded():void{
            ModelManager.instance.modelGame.on(ModelGame.EVENT_HERO_TROOP_EDIT_UI_CHANGE,this,this.event_hero_troop_edit_ui_change);  
            aniBox.destroyChildren();
            
        }
        override public function onRemoved():void{
            ModelManager.instance.modelGame.off(ModelGame.EVENT_HERO_TROOP_EDIT_UI_CHANGE,this,this.event_hero_troop_edit_ui_change);
            //
            this.clearA();

            if(this["imgBox"+0])
                this["imgBox"+0].destroyChildren();

            if(this["imgBox"+1])
                this["imgBox"+1].destroyChildren();
        }
        private function clearA():void
        {
            this.changeSelect(false);
            this.list.selectedIndex = -1;
            this.timer.clear(this,this.troopRunning);
        }
        private function event_hero_troop_edit_ui_change(noNull:Boolean,events:String):void{
            switch(events)
            {
                case EventConstant.TROOP_UPDATE:
                    this.initUI(); 
                    return;
                case EventConstant.TROOP_CREATE:
                    this.clearA();
                    this._checkTroopIsFull(2);
                    if(mIsXYZ){
                        ViewManager.instance.showTipsTxt(Tools.getMsgById("500033",[Tools.getMsgById(ConfigServer.city[(ModelManager.instance.modelUser.country+10)*-1].name)]));//新部队已在【{0}】待命
                        var a:Animation=EffectManager.loadAnimation("glow040",'',1);
        				this.aniBox.addChild(a);
				        a.x=this.aniBox.width/2;
				        a.y=this.aniBox.height/2;
                        MusicManager.playSoundUI(MusicManager.SOUND_XYZ_1);
                    }else{
                        ViewManager.instance.showTipsTxt(Tools.getMsgById("_country28"));//成功创建新部队
                    }   
                    var arr:Array = ModelManager.instance.modelUser.getTroops();
                    if(noNull || arr.length<1){
                        this.closeSelf();
                        return;
                    }
                    break;
                case EventConstant.TROOP_REMOVE:
                    this.clearA();
                    this.mModel = null;
                    this.mStatus = -1;
                    this.closeSelf();    
                    break;
                case EventConstant.TROOP_ADD_NUM:
                    if (mModel) {
                        _operateHid = mModel.hero;
                        this._checkTroopIsFull();
                    }
                    break;
                default:
                    break;
            }

            this.mStatus = this.mModel?this.mModel.state: -1;
			if (this.mModel && this.mModel.deaded){
				this.closeSelf();
			}
			else{
				this.initUI();   
			}    
        }

        /**
         * 检查创建的部队是否满员
         */
        private function _checkTroopIsFull(create:int = 0):void {
            if (!(/hero\d{3}/.test(_operateHid)))    return;
			var hmd:ModelHero = ModelManager.instance.modelGame.getModelHero(_operateHid);
            var dataArr:Array = this._getTroopDataArr(_operateHid);
            _operateHid = '';
            var price:Number = 0;
            dataArr.forEach(function(item:Object):void { price += item.needCoin; }, this);
            var coin:int = Math.floor(price + 1);
            var canBuy:Boolean = ModelManager.instance.modelUser.checkPayMoneyAddArmy(coin);
            ViewManager.instance.showView(ConfigClass.VIEW_TROOP_COIN_FILL, {
                'content': Tools.getMsgById('_jia0085'),
                'price': canBuy ? coin: 0,
                'handlers': [
                    Handler.create(this,this._onClickGo, [hmd.id]), // 前往训练
                    Handler.create(this,this._onClickCoinFill, [hmd.id, coin, create]) // 一键补兵
                ]
            });
        }

        /**
         * 获取显示所需的各个数据
         */
        private function _getTroopDataArr(hid:String):Array {
            return [{hid: hid, fb: 0}, {hid: hid, fb: 1}].map(this._getTroopData, this);
        }

        private function _getTroopData(obj:Object):Object {
            var hid:String = obj.hid;
            var fb:int = obj.fb;
			var hmd:ModelHero = ModelManager.instance.modelGame.getModelHero(hid);
			var mt:ModelTroop = ModelManager.instance.modelTroopManager.getTroop(hid); // 英雄的行军对象
            var armyType:int = hmd.army[fb];
            var bmd:ModelBuiding = ModelBuiding.getArmyBuildingByType(armyType);    // 军营model
            var armyNum:Number = bmd.getArmyNum(); // 库存兵量
            var heroMax:Number = hmd.getArmyHpm(fb,hmd.getPrepare()); // 英雄最大兵量
            var myNum:Number = (mt && !mt.deaded) ? mt.army[fb] : 0; // 当前英雄兵量
            var needNum:Number = heroMax - myNum; // 需要兵量
            return {
                fb: fb,
                armyNum: armyNum,
                heroMax: heroMax,
                myNum: myNum,
                needNum: needNum,
                armyType: armyType,
                needCoin: bmd.getArmyMakePayCoin(needNum)
            };
        }

        private function list_render(item:ItemHero,index:int):void{
            item.setData(this.list.array[index]);
            item.item.setHeroSelection(this.list.selectedIndex == index);
            item.offAll(Event.CLICK);
            item.on(Event.CLICK,this,this.click,[index]);
        }
        private function changeSelect(b:Boolean):void{
            if(this.list.selection){
                (this.list.selection as ItemHero).item.setHeroSelection(b);
            }
        }
        private function list_select(index:int):void{
            if(index>-1){
                this.setUI(this.list.array[index]);
            }
        }
        private function click(index:int):void{
            if(index>-1 && index!=this.list.selectedIndex){
                this.list.selectedIndex = index;
            }
        }

		
        private function click_func(type:int):void{
			var fun:Function = this.funs[type];
			if (fun){
				fun.apply(this);
			}
        }
		private function click_add():void{
            if (this.cityB07lv < 1){
				if (this.mModel.entityCity && !this.mModel.entityCity.canBuild){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_country50"),3);
				}
				else{
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_country48"));//本城军营等级不足
				}
                return;
            }
            if(ModelOfficial.getBuffByCid(this.mModel.entityCity.cityId+"",ModelOfficial.BUFF_5)!=null){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_country73"));
                return;
            }             
            if(!ModelManager.instance.modelUser.isFinishFtask(this.mModel.cityId+"")){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_ftask_tips01"));//请先完成民
                return;
            }

            if (this.armyAddCoinPersonArr.every(function(num:int):Boolean { return num === 0; })) { // 部队满员
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_public227"));
                this.closeSelf();
            }
            else if (this.armyEnough()) { // 兵量充足
                ModelManager.instance.modelTroopManager.sendAddArmyNumTroops(this.mModel.hero);
                this.closeSelf();
            }
            else if (this.haveArmy()) {
                ModelManager.instance.modelTroopManager.sendAddArmyNumTroops(this.mModel.hero);
            }
            else {
                this.click_coin_fill_troop();
            }
            
		}
		private function click_del():void{
            if(this.delStatus == 3 || this.delStatus == 2){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_country33"));//本城军营等级不足
                return;                
            }
            if(this.forceDel){
                ViewManager.instance.showAlert(Tools.getMsgById("_country34"),Handler.create(this,this.tips_del));
                return
            }
            else{
                if (this.cityB07lv < 5){
					if (this.mModel.entityCity && !this.mModel.entityCity.canBuild){
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_country50"),3);
					}
					else{
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_country49"));//本城军营等级不足
					}
                    return;
                }    
            }
            if(!ModelManager.instance.modelUser.isFinishFtask(this.mModel.cityId+"")){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_ftask_tips01"));//请先完成民
                return;
            }            
            this.tips_del(0);
		}

        private function click_coin_fill_troop(create:int = 0):void{
            var hid:String = '';
            if(this.mStatus==-1){
                var hmd:ModelHero = this.list.array[this.list.selectedIndex];
                hid = hmd.id;
            }else{
                hid = mModel.hero;
            }
            var coin:Number = Math.floor(this.armyAddCoinArr[0]+this.armyAddCoinArr[1]+1);
            var canBuy:Boolean = ModelManager.instance.modelUser.checkPayMoneyAddArmy(coin);
            ViewManager.instance.showView(ConfigClass.VIEW_TROOP_COIN_FILL, {
                'content': Tools.getMsgById('_jia0085'),
                'price': canBuy ? coin: 0,
                'handlers': [
                    Handler.create(this, this._onClickGo, [hid]), // 前往训练
                    Handler.create(this, this._onClickCoinFill, [hid, coin, create]) // 一键创建或补兵
                ]
            });
        }

        /**
         * 前往训练
         */
        private function _onClickGo(hid:String):void
        {
            var tempArr:Array = this._getTroopDataArr(hid);
            var armyType:int = tempArr[0].needNum ? tempArr[0].armyType : tempArr[1].armyType;;
            var bmd:ModelBuiding = ModelBuiding.getArmyBuildingByType(armyType);
            GotoManager.instance.boundForHome(bmd.id, 0);
            this.closeSelf();
        }
        
        /**
         * 检测兵营是否解锁
         */
        private function _isBarracksOpen(hid:String):Boolean {
			var hmd:ModelHero = ModelManager.instance.modelGame.getModelHero(hid);
            return [0, 1].every(function (fb:int):Boolean{
                var armyType:int = hmd.army[fb];
                var bmd:ModelBuiding = ModelBuiding.getArmyBuildingByType(armyType);    // 军营model
                return bmd.lv >= 1;
            }, this);
        }

        /**
         * 一键补兵
         * create 0 直接补兵 1一键创建 2 创建后一键补兵
         */
        private function _onClickCoinFill(hid:String, coin:int, create:int = 0):void
        {
            if (Tools.isCanBuy(ConfigServer.system_simple.fast_train_type, coin)) {
                if (this._isBarracksOpen(hid)) {
                    create === 1 && ModelManager.instance.modelTroopManager.sendCreateTroops(hid,true,mIsXYZ); // 一键创建
                    create !== 1 && ModelManager.instance.modelTroopManager.sendAddArmyNumTroops(hid, true); // 补兵 或创建后直接一键补兵
                    create === 0 && this.closeSelf(); // 补兵
                }
                else {
                    ViewManager.instance.showTipsTxt(Tools.getMsgById('_jia0116'));
                }
            }
        }

        private function tips_del(type:int):void
        {
            if(type==0){
                ModelManager.instance.modelTroopManager.sendRemoveTroops(this.mModel.hero,this.forceDel);
                this.closeSelf();
            }
        }

		private function click_set():void{
            var hmd:ModelHero = this.list.array[this.list.selectedIndex];
            if (this.haveArmy()) {
                ModelManager.instance.modelTroopManager.sendCreateTroops(hmd.id,false,mIsXYZ);
                if (!this.armyEnough()) { // 兵力不足
                    _operateHid = hmd.id;
                }
            }
            else { // 没兵
                this.click_coin_fill_troop(1);
            }
		}

        private function haveArmy():Boolean
        {
            return armyData_f['num'] !== 0 || armyData_b['num'] !== 0;
        }

        private function armyEnough():Boolean
        {
            return armyData_f['num'] >= armyData_f['need'] && armyData_b['num'] >= armyData_b['need'];
        }

		private function click_cd():void{          
			// ModelManager.instance.modelTroopManager.sendSpeedUpTroops(this.mModel.hero, 2);
            if(this.mModel){
                ViewManager.instance.showView(ConfigClass.VIEW_TROOP_QUICKLY,this.mModel);
            }
			this.closeSelf();
		}
		private function click_back():void{
			ModelManager.instance.modelTroopManager.sendRecallTroops(this.mModel.hero);
			this.closeSelf();
		}
		private function click_break():void{
			if (getBtn('break').gray)
			{
				if (this.mModel.cityId >= 0){
					ViewManager.instance.showTipsTxt(Tools.getMsgById('troopAttackWarning100'));
				}
				else{
					ViewManager.instance.showTipsTxt(Tools.getMsgById('troopAttackWarning103'));
				}
				return;
			}
			
			var arr:Array = this.getBreakArr(1);
			if (arr){
				if (arr.length == 0){
					ViewManager.instance.showTipsTxt(Tools.getMsgById('troopAttackWarning101'));
				}
				else
				{
					this.send_to_break(arr);
				}
			}
			else{
				ViewManager.instance.showTipsTxt(Tools.getMsgById('troopAttackWarning102',[ConfigServer.world.troopBreakIndex]));
			}
		}
		private function click_runaway():void{
			if (getBtn('runaway').gray)
			{
				if (ModelManager.instance.modelCountryPvp.isLast() && this.mModel.cityId < 0) {
					ViewManager.instance.showTipsTxt(Tools.getMsgById('troopRunAwayWarning104'));
				} else {
					ViewManager.instance.showTipsTxt(Tools.getMsgById('troopRunAwayWarning100'));
				}
				
				return;
			}
			
			var arr:Array = this.getBreakArr(0);
			if (arr){
				if (arr.length == 0){
					ViewManager.instance.showTipsTxt(Tools.getMsgById('troopRunAwayWarning101'));
				}
				else
				{
					this.send_to_break(arr);
				}
			}
			else{
				ViewManager.instance.showTipsTxt(Tools.getMsgById('troopRunAwayWarning102',[ConfigServer.world.troopBreakIndex]));
			}
		}		
		
		private function send_to_break(arr:Array):void{
			var citys:Array = arr[2];
			var len:int = citys.length;
			var i:int;
			var	cityIds:Array = [];	
			for (i = 0; i < len; i++) 
			{
				cityIds.push(citys[i].cid);
			}
			//
			NetSocket.instance.send(NetMethodCfg.WS_SR_GET_CITY_INFO,{cid:cityIds},Handler.create(this,function (re:NetPackage):void
			{
				var len:int = citys.length;
				for (var i:int = 0; i < len; i++) 
				{
					var cityObj:Object = citys[i];
					var reObj:Object = re.receiveData[i];
					cityObj.city_total = reObj.city_total;
					cityObj.troop = reObj.troop;
				}
				ViewManager.instance.showView(ConfigClass.VIEW_CITY_SEND, arr);
				this.closeSelf();
			}));		
		}
		
		///阵前超过5人，解锁0撤军，1突进功能
		private function getBreakArr(type:int):Array{
			
			var battle:ClientBattle = FightMain.instance.client;
			if(battle){
				var troop:TroopLogic = battle.findTroop(-1,this.mModel.hero,parseInt(this.mModel.uid));
				if (troop && troop.troopIndex >= ConfigServer.world.troopBreakIndex){
					var mt:ModelTroop = ModelManager.instance.modelTroopManager.getTroop(troop.hid);
					var citys:Array = EntityCity.exportNearCitys(mt.cityId, type);
					if (citys.length == 0)
						return citys;
					
					return [mt, mt.cityId,citys, type];
				}
			}
			return null;
		}
		
		
        private function initUI():void{
            this.resetBtns();
            this.tTime.visible = false;
            this.tTime.text = "";
            //
            this.mMarch = null;
            this.mMarchTime = 0;
            this.timer.clear(this,this.troopRunning);
            if(this.mStatus==-1){ // 创建部队
                this.cityName.text = mIsXYZ ? Tools.getMsgById(ConfigServer.city[(ModelManager.instance.modelUser.country+10)*-1].name) : ModelManager.instance.modelMap.myCapital.name;
				//this.tTitle.text = Tools.getMsgById('troopEditBtn_set');
                this.itemTitle.setViewTitle(Tools.getMsgById('troopEditBtn_set'));
                this.tStatus.text = '';// "可以编辑队伍";
                this.box_list.visible = true;
                this.mBox.height = 620;
                var arr:Array = ModelManager.instance.modelUser.getTroops();
                if(arr.length>=1){
                    this.setBtn('set');
                }
                if(arr.length>1){
                    arr.sort(MathUtil.sortByKey("sortPower",true));
                }
                this.list.dataSource = arr;
                //
                this.click((this.list.selectedIndex<0)?0:this.list.selectedIndex);
                
            }
            else{ // 补兵
                if (this.mStatus == ModelTroop.TROOP_STATE_IDLE){
					
					if (this.mModel.isReadyFight && FightMain.instance.client){
						//战斗中打开，可以突进或撤军
						var righttype:Object  = ConfigServer.office.righttype;
                        //襄阳||城门 无法突进
						if (this.mModel.cityId >= 0) {
							this.setBtn('break', !ModelOfficeRight.isOpen(righttype['break'][0]));
						}
						else{
							this.setBtn('break', true);
						}
						var isLastXYZ:Boolean = ModelManager.instance.modelCountryPvp.isLast() && this.mModel.cityId < 0 ? true : false;
						
						this.setBtn('runaway',!ModelOfficeRight.isOpen(righttype['runaway'][0]) || isLastXYZ);
					}
					else{
                        this.forceDel = this.checkForceDel();
						this.setBtn('add');
						this.setBtn('del'); 
					}
                }
                else if(this.mStatus == ModelTroop.TROOP_STATE_MOVE){
                    this.mMarch = ModelManager.instance.modelMap.marchs[this.mModel.id];//行军
                    this.mMarchTime = this.mMarch.remainTime();
                    this.timer.loop(1000, this, this.troopRunning);
					this.troopRunning();
					this.setBtn('cd');
					if (ModelManager.instance.modelTroopManager.canRecall(this.mModel.hero)){
						//能否撤退
						this.setBtn('back');
					}
                    //
                    this.tTime.visible = true;
                }
                else if (this.mStatus == ModelTroop.TROOP_STATE_MONSTER){
                    this.forceDel = this.checkForceDel();
					this.setBtn('add');
					this.setBtn('del');              
                }
                this.cityName.text = ModelOfficial.getCityName(this.mModel.cityId + "");

                var statusStr:String = ModelGame.map_troop_status_str[this.mModel.state];
                if(this.mModel.state==1){
                    statusStr = statusStr+" -- "+ Tools.getMsgById('_jia0135',[this.mMarch.endCity.getName()]) ;//Tools.getMsgById("_public93")+this.mMarch.endCity.getName();
                }
                this.tStatus.text = statusStr

                this.box_list.visible = false;
                this.mBox.height = 478;
                //
                if (this.mModel){
					var hmd:ModelHero = ModelManager.instance.modelGame.getModelHero(this.mModel.hero);
					//this.tTitle.text = Tools.getMsgById('troopEditTitle',[hmd.getName()]);
                    this.itemTitle.setViewTitle(Tools.getMsgById('troopEditTitle',[hmd.getName()]));
                    this.setUI(hmd);
                }
            }
        }
        private function checkForceDel():Boolean
        {
            var troopInfo:Object = ModelManager.instance.modelTroopManager.getMoveCityTroop(MapModel.instance.myCapital.cityId, -1, this.mModel.id)[0];
            var arrived:Boolean = troopInfo && troopInfo.type != -3;//是否到达。
            
            var citys:Array = this.mModel.entityCity.nearCitys.concat(this.mModel.entityCity);
            var notDel:Boolean = citys.every(function(city:EntityCity, index:int, arr:Array):Boolean {
                return this.cityB07lv < 5;//判断是否不能解散， 不能解散返回true。
            }, this)
            
            return (!arrived && notDel);            
        }
        private function troopRunning():void{
            if(this.mMarch && this.tTime.visible){
                this.mMarchTime-=1
                if(this.mMarchTime>0){
                    this.tTime.text = Tools.getMsgById("_public94",[Tools.getTimeStyle(this.mMarchTime*Tools.oneMillis)]);//"剩余时间:"+Tools.getTimeStyle(this.mMarchTime*Tools.oneMillis);
                }
                else{
                    this.timer.clear(this,this.troopRunning);
                }
            }
        }
        private function setUI(hmd:ModelHero):void{
            if(hmd){
                hmd.getPrepare(true);

                this.tName.text = hmd.getName();
                this.tLv.text = "" + hmd.getLv()
				this.comPower.setNum(hmd.getPower());
                //this.tPower.text = Tools.getMsgById("_public84",[hmd.getPower()]);//"战力: "+hmd.getPower();
                //
                this.heroType.setHeroType(hmd.getType(true));
                //
                this.setHeroArmy(hmd,this.army0,0);
                this.setHeroArmy(hmd,this.army1,1);
                if(this.getBtn("add")){
                    this.getBtn("add").gray = this.cityB07lv < 1 || ModelOfficial.getBuffByCid(this.mModel.entityCity.cityId+"",ModelOfficial.BUFF_5)!=null;
                }
                if(this.getBtn("del")){
                    this.delStatus = 0;
                    if(this.mStatus == ModelTroop.TROOP_STATE_MONSTER){
                        this.getBtn("del").gray = true;
                        this.delStatus = 3;
                    }
                    else if(this.mStatus == ModelTroop.TROOP_STATE_IDLE){
                        if(this.mModel.isReadyFight && FightMain.instance.client){
                            this.getBtn("del").gray = true;
                            this.delStatus = 2;
                        }
                        else{
                            this.delStatus = 0;
                        }
                    }
                    else{
                        this.delStatus = 0;
                    }
                    if(this.delStatus==0){
                        if(this.forceDel){
                            this.getBtn("del").gray = false;
                        }
                        else{
                            this.getBtn("del").gray = (this.cityB07lv<5);
                        }
                    }
                }                
                //5,1
                this.heroIcon.setHeroIcon(hmd.getHeadId(),true,hmd.getStarGradeColor());//
                //
                var cexp:Number = hmd.getExp();
                var nexp:Number = hmd.getLvExp(hmd.getLv()+1);
                this.barExp.value = cexp/nexp;    
            }
        }

        private function setHeroArmy(hmd:ModelHero,army:troopEditArmyUI,fb:int):void {
            //
            this["armyAddCoinArr"][fb]=0;
            this["armyAddCoinPersonArr"][fb]=0;
            if(this["imgBox"+fb] == null){
                this["imgBox"+fb] = new Box();
                army.addChild(this["imgBox"+fb]);
            }

            var armyType:int = hmd.army[fb];
            army.tName.text = ModelHero.army_seat_name[fb] + ModelHero.army_type_name[armyType];
            army.tLv.text = Tools.getMsgById("_hero16",[hmd.getMyArmyLv()[fb]]);//hmd.getMyArmyLv()[fb] + '阶';
            //
            var bmd:ModelBuiding = ModelBuiding.getArmyBuildingByType(armyType);
            
            army.army_type.setArmyIcon(armyType,bmd.getArmyCurrGrade());
            //EffectManager.loadArmysIcon(aid)
            // army.army_lv.setArmyLv(bmd.getArmyCurrGrade());
            //
            var armyNum:Number = bmd.getArmyNum(); // 库存兵量
            var heroMax:Number = hmd.getArmyHpm(fb,hmd.getPrepare()); // 英雄最大兵量
            var armyData:Object = fb === 0 ? armyData_f : armyData_b;

            armyData['type'] = armyType;
            armyData['num'] = armyNum;
            var myNum:Number = 0;
            var addNum:Number = 0;
            if(this.mStatus == -1){
                
                // 创建部队
                myNum = Math.min(armyNum, heroMax);
                armyData['need'] = heroMax;
                army.tArmy.text = armyNum < heroMax ? Tools.getMsgById("_public95") : String(armyNum - heroMax);
                army.tBar.text = myNum +" / "+heroMax;
                army.bar.value = myNum/heroMax;
                addNum = heroMax;
            }
            else{
                // 补兵
                myNum = this.mModel.deaded ? 0:this.mModel.army[fb];
                armyData['need'] = heroMax - myNum;
                army.tArmy.text = ""+armyNum;
                army.tBar.text = myNum+" / "+heroMax;
                army.bar.value = myNum/heroMax;
                //
                addNum = heroMax-myNum;
            }
           
            if(addNum){ // 需要的兵量
                this["armyAddCoinPersonArr"][fb]=addNum;
                this["armyAddCoinArr"][fb]=bmd.getArmyMakePayCoin(addNum);
            }
            //            
            army.img.visible = false;
            
            var armyAID:String = "army"+hmd.army[fb]+""+ModelBuiding.getArmyCurrGradeByType(hmd.army[fb]);
            var sp:Sprite = EffectManager.loadArmysIcon(armyAID);
            sp.name = armyAID;
            if((this["imgBox"+fb] as Box).getChildByName(armyAID)==null){
                (this["imgBox"+fb] as Box).destroyChildren();
                (this["imgBox"+fb] as Box).addChild(sp);
            }
            (this["imgBox"+fb] as Box).x = army.img.x+army.img.width*0.5;
            (this["imgBox"+fb] as Box).y = army.img.y+army.img.height*0.5;
        }
    }
}