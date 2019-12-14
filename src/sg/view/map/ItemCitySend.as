package sg.view.map
{
	import laya.display.Animation;
	import sg.manager.EffectManager;
	import sg.map.model.entitys.EntityCity;
	import ui.map.citySendItemUI;
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
	* 选择临近的目的地城市  突进或撤军
	* @author zhuda
	*/
    public class ItemCitySend extends citySendItemUI{
        private var mEntityCity:EntityCity;
        private var mMarch:EntityMarch;
		private var res:String;
        public function ItemHeroSend():void{
			this.mouseEnabled = true;

			

        }
        public function setData(data:*):void{
			this.txtNum_.text = Tools.getMsgById("_lht29",[""]);
			this.txtUser_.text = Tools.getMsgById("_lht79",[""]);
			this.txtLv_.text = Tools.getMsgById("_lht30",[""]);

            this.mEntityCity = data.ec;
            //
			//this.imgFrame.addChild(this.sprMask);
			var res:String = this.mEntityCity.getParamConfig("res");
			if (this.res != res)
			{
				this.res = res;
				this.imgFrame.destroyChildren();
				
				EffectManager.fillCityAnimation(this.mEntityCity, this.imgFrame);
				//var arr:Array = res.split("_");
				//res = arr[0];
				//var ani:Animation = EffectManager.loadAnimation(res);
				//if (arr.length > 1) {
					//ani.scaleX *= -1;
				//}
				//var scale:Number = this.mEntityCity.getParamConfig("scale");
				//if (scale > 1){
					//var temp:Number = 1 / Math.pow(scale,0.9);
					//ani.scale(temp, temp);
				//}
				//ani.x = this.imgFrame.width * 0.5;
				//ani.y = this.imgFrame.height * (0.58 - (scale-1)*0.03);
				//this.imgFrame.addChild(ani);
			}

			this.flag.setCountryFlag(this.mEntityCity.country);
			this.txtName.text = this.mEntityCity.name;
			this.txtType.text = this.mEntityCity.cityTypeName;
			this.txtNum.text = data.ct.troop;
			this.txtLv.text = this.mEntityCity.getNPCLevel().toString();
			this.txtUser.text = data.ct.city_total;

			this.txtNum.x = this.txtNum_.x + this.txtNum_.width + 4;
			this.txtUser.x = this.txtUser_.x + this.txtUser_.width + 4;
			this.txtLv.x = this.txtLv_.x + this.txtLv_.width + 4;

			//var dir:int = -data.ct.dir * 90 + 45;
			//this.sprDir.skew(dir, -dir);
			var angle:Number = -data.ct.angle*180/Math.PI + 180;
			this.sprDir.skew(angle, -angle);
			//this.imgDir.skew(angle, -angle);
			
			var errorType:int = data.errorType;
			if (errorType == 0){
				this.txtInfo.color = '#00FF00';
				this.box.disabled = false;
				this.cacheAs = 'none';
				
			}else if(errorType > 0){
				this.txtInfo.color = '#FFFF30';
				this.box.disabled = true;
				this.cacheAs = 'bitmap';
			}else{
				this.txtInfo.color = '#FFFF00';
				this.box.disabled = false;
				this.cacheAs = 'none';
			}
			var str:String;
			if (data.type == 1)
			{
				//突进  0可以突进 1该城市不可被攻击 2该城市不在可攻击时段内 3该城市要求攻城英雄等级未达标 4该英雄当前血量不足半数 98粮草不足 99不在国战中或前方排队人数不足 100需要在爵位中解锁特权
				str = this.mEntityCity.getAttackErrorInfo(errorType);
			}
			else
			{
				//撤军  0可以撤军 -1可撤军但要哗变 98粮草不足 99不在国战中或前方排队人数不足 100需要在爵位中解锁特权 
				str = Tools.getMsgById('troopRunAwayWarning' + errorType);
			}
			this.txtInfo.text = str;

            //
            //this.heroIcon.setHeroIcon(this.mModelHero.id,true,this.mModelHero.getStarGradeColor());
        }

        public function setSelectUI(b:Boolean):void{
			this.select.visible = b;
        }
        //public function setPowerCheck(pw:Number):void
        //{
            //this.powerFalse.visible = this.mPower<pw;
        //}
        //private function setHeroArmy(hmd:ModelHero,fb:int,armyPerc:Array):void{
            //var bar:ProgressBar  = this["bar"+fb];
            //var army:Label = this["army"+fb];
            //var armyType:int = hmd.army[fb];
            //var tArmyNum:Label = this["tArmyNum"+fb];
            //army.text = ModelHero.army_seat_name[fb] + ModelHero.army_type_name[armyType];
            //var bmd:ModelBuiding = ModelBuiding.getArmyBuildingByType(armyType);
            ////
            //// var myNum:Number = bmd.getArmyNum();
            //// var heroMax:Number = hmd.getLead();
            //var currNum:Number = this.mModelTroop.army[fb];
            ////
            //bar.value = currNum/armyPerc[1];//myNum/heroMax;
            //tArmyNum.text = currNum+"/"+armyPerc[1];
            ////
            //// this["bar"+fb].setHeroArmy()
            //(this["armyIcon"+fb] as ComPayType).setArmyIcon(hmd.army[fb],bmd.getArmyCurrGrade());
            //// (this["armyLv"+fb] as ComPayType).setArmyLv(bmd.getArmyCurrGrade());
        //}
    }   
}