package sg.view.map
{
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import ui.map.heroSendItemUI;
	import sg.model.ModelHero;
	import sg.model.ModelBuiding;
	import laya.ui.Label;
	import laya.ui.ProgressBar;
	import sg.model.ModelTroop;
	import sg.model.ModelGame;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
	import sg.manager.ModelManager;
	import sg.map.model.entitys.EntityMarch;
	import sg.view.com.ComPayType;
	
	/**
	 * 部队前往，列表元素
	 * @author
	 */
	public class ItemHeroSend extends heroSendItemUI
	{
		private var mModelHero:ModelHero;
		private var mModelTroop:ModelTroop;
		public var isFree:Boolean = false;
		private var mMarch:EntityMarch;
		private var mPower:Number = 0;
		
		public function ItemHeroSend():void
		{
		
		}
		
		public function setData(hmd:ModelHero):void
		{
			this.mModelHero = hmd;
			//
			this.tName.text = hmd.getName();
			this.heroLv.setNum(hmd.getLv());
			//this.tLv.text = hmd.getLv() + "";
			this.mPower = hmd.getPower(hmd.getPrepare(true));
			this.comPower.setNum(this.mPower);
			//this.tPower.text = this.mPower + "";
			this.heroType.setHeroType(hmd.getType());
			this.heroStar.setHeroStar(hmd.getStar());
			
			//
			this.heroIcon.setHeroIcon(this.mModelHero.getHeadId(), true, this.mModelHero.getStarGradeColor());
		}
		
		/**
		 * onlyHero -1所有部队  0本城部队  1本城除外
		 */
		public function setTroopStatus(dataObj:Object, onlyHere:Number):void
		{
			this.mModelTroop = dataObj.ct.model;
			this.mMarch = null;
			var endStr:String = "";
			if (this.mModelTroop.state == ModelTroop.TROOP_STATE_MOVE)
			{
				this.mMarch = ModelManager.instance.modelMap.marchs[this.mModelTroop.id];//行军
				endStr = " -- " + Tools.getMsgById(ConfigServer.city[this.mMarch.marchData[this.mMarch.marchData.length - 1][0]].name);
			}
			var ec:EntityCity = dataObj.ec;
			var cityName:String = Tools.getMsgById(ConfigServer.city[this.mModelTroop.cityId].name);
			var aimCityName:String = Tools.getMsgById(ConfigServer.city[dataObj.ec.cityId].name);
			var statusName:String = ModelGame.map_troop_status_str[this.mModelTroop.state];
			if (this.mModelTroop.state == ModelTroop.TROOP_STATE_IDLE)
			{
				statusName = this.mModelTroop.isReadyFight ? Tools.getMsgById("fight_troop_turn_fighting") : statusName;//战斗中
			}
			
			
			//
			this.tStatus.text = cityName + " -- " + statusName + endStr;
			this.tStatus.color = '#FFFFFF';
			if(this.mModelTroop.state == ModelTroop.TROOP_STATE_MOVE){

			}else if(dataObj.free == -1 && onlyHere!=-1)
			{
				this.tStatus.text = Tools.getMsgById("_country4");//正在本城
				if(onlyHere == 1)
					this.tStatus.color = '#FFFF00';
			}
			else if (dataObj.free == -3)
			{
				this.tStatus.text = Tools.getMsgById("_country5", [cityName, aimCityName]);//无法到达目的地
				this.tStatus.color = '#FFFF00';
			}
			else if (dataObj.free < -10)
			{
				this.tStatus.text = ec.getAttackErrorInfo(dataObj.free + 100);
				this.tStatus.color = '#FFFF00';
			}
			//
			this.isFree = onlyHere==0 ? (this.mModelTroop.state == ModelTroop.TROOP_STATE_IDLE && !this.mModelTroop.isReadyFight) : (dataObj.free >= 0 || dataObj.free ==-1);
			//
			this.isFree = this.mModelTroop.state == ModelTroop.TROOP_STATE_MOVE ? false : isFree; 
			if (this.mModelTroop.state == ModelTroop.TROOP_STATE_MONSTER)
			{
				this.tStatus.text = Tools.getMsgById("_country6");//野战中
				this.isFree = false;
			}
			dataObj["isFree"] = this.isFree;
			//
			this.box.gray = !this.isFree;
			if (this.box.gray)
			{
				this.cacheAs = 'bitmap';
			}
			else
			{
				this.cacheAs = 'none';
			}
			//
			var armyPerc:Array = this.mModelHero.getArmyHpmPerc(this.mModelHero.getPrepare());
			//
			this.setHeroArmy(this.mModelHero, 0, armyPerc[0]);
			this.setHeroArmy(this.mModelHero, 1, armyPerc[1]);
		}
		
		public function setSelectUI(b:Boolean):void
		{
			if (this.isFree)
			{
				this.select.visible = b;
			}
			else
			{
				this.select.visible = false;
			}
		}
		
		/**
		 * 显示危险，血量不满认为战力削弱
		 */
		public function setPowerCheck(pw:Number, timeS:Number):void
		{
			if (pw < 0)
			{
				
				//如果有行军时间，显示极近等
				if (pw == -1 && timeS)
				{
					this.powerFalse.visible = true;
					var move_time_name:Object = ConfigServer.system_simple.move_time_name;
					var s:String = "";
					var color:String = "";
					for (var i:int = 0; i < move_time_name.length; i++)
					{
						var arr:Array = move_time_name[i];
						if (timeS >= arr[0])
						{
							s = arr[1] + "";
							color = arr[2];
						}
						else
						{
							break;
						}
					}
					this.powerFalse.text = Tools.getMsgById(s);
					this.powerFalse.fontSize = 15;
					this.powerFalse.stroke = 2;
					this.powerFalse.strokeColor = color;
				}
				else
				{
					this.powerFalse.visible = false;
				}
			}
			else
			{
				var hpPer:Number = this.mModelTroop.getHpPer();
				var currPower:Number = (hpPer * 0.7 + 0.3) * this.mPower;
				this.powerFalse.visible = currPower < pw;
				this.powerFalse.text = Tools.getMsgById('191099');
				this.powerFalse.fontSize = 20;
				this.powerFalse.stroke = 3;
				this.powerFalse.strokeColor = '#FF0000';
			}
		}
		
		private function setHeroArmy(hmd:ModelHero, fb:int, armyPerc:Array):void
		{
			var bar:ProgressBar = this["bar" + fb];
			var army:Label = this["army" + fb];
			var armyType:int = hmd.army[fb];
			var tArmyNum:Label = this["tArmyNum" + fb];
			army.text = ModelHero.army_seat_name[fb] + ModelHero.army_type_name[armyType];
			var bmd:ModelBuiding = ModelBuiding.getArmyBuildingByType(armyType);
			//
			// var myNum:Number = bmd.getArmyNum();
			// var heroMax:Number = hmd.getLead();
			var currNum:Number = this.mModelTroop.army[fb];
			//
			bar.value = currNum / armyPerc[1];//myNum/heroMax;
			tArmyNum.text = currNum + "/" + armyPerc[1];
			//
			// this["bar"+fb].setHeroArmy()
			(this["armyIcon" + fb] as ComPayType).setArmyIcon(hmd.army[fb], bmd.getArmyCurrGrade());
			// (this["armyLv"+fb] as ComPayType).setArmyLv(bmd.getArmyCurrGrade());
		}
	}
}