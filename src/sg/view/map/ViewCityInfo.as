package sg.view.map
{
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
    import ui.map.cityInfoUI;
    import sg.manager.ModelManager;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.model.ModelOfficial;
    import laya.utils.Handler;
    import sg.utils.Tools;
    import sg.cfg.ConfigServer;
    import sg.model.ModelUser;
    import sg.model.ModelCityBuild;
    import sg.manager.EffectManager;
    import sg.utils.StringUtil;

    public class ViewCityInfo extends cityInfoUI{
		private var mEntityCity:EntityCity;
        //private var mCid:int;
        private var mData:Object;
        public function ViewCityInfo(){
            this.list.itemRender = ItemCityInfo;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.scrollBar.hide = true;
            // this.btn_info.on(Event.CLICK,this,this.click);
			this.item_1.text = Tools.getMsgById("ViewCityInfo_0");
			this.item_2.text = Tools.getMsgById("_jia0097");
			this.item_3.text = Tools.getMsgById("_jia0098");
			
			this.item_4.text = Tools.getMsgById("ViewCityInfo_1");			
			this.item_5.text = Tools.getMsgById("ViewCityInfo_2");
			this.item_6.text = Tools.getMsgById("ViewCityInfo_3");
			this.item_7.text = Tools.getMsgById("510030");
        }
        override public function initData():void{
            this.mData = this.currArg;

            this.list.array = this.mData.army;
            //
            this.setUI();
        }
        private function setUI():void{
			this.mEntityCity = MapModel.instance.citys[this.mData.cid];
			
            this.mCountry.setCountryFlag(this.mData.country);
            //
            var mayor:Array = this.mData.mayor;//ModelOfficial.getCityMayor(this.mData.cid+"");
            this.tMayor.text = Tools.getMsgById("_public74",[mayor?mayor[1]:Tools.getMsgById("_public76")]);//"太守:"
            this.tTeam.text = "";//Tools.getMsgById("_public75",[mayor?mayor[2]:Tools.getMsgById("_public76")]);//"军团:"+(mayor?mayor[2]:"无");

            this.heroIcon.setHeroIcon(mayor?ModelUser.getUserHead(mayor[3]):"hero000");
            var store:Object = this.mData;
			//this.tTitle.text = this.mEntityCity.name;
            this.comTitle.setViewTitle(this.mEntityCity.name);
            this.tCoin.text = store.coin+"";
            this.tGold.text = store.gold+"";
            this.tFood.text = store.food+"";
            //
            this.tNpc.text = this.mData.troop;
            this.tArmy.text = Tools.getMsgById("_lht29", [this.mData.troop + " + " + this.mData.city_total]);//"驻军数量: " +this.mData.troop+" + "+this.mData.city_total;
			
			this.tLv.visible = true;
			var npcLevel:String = this.mEntityCity.getNPCLevel().toString();
            //this.tLv.text = Tools.getMsgById("_lht30", [this.mEntityCity.getNPCLevel()]);//"驻军等级: " +this.mEntityCity.getNPCLevel();
			
			if (this.mEntityCity.cityId < 0) {//襄阳城
				if (this.mEntityCity.cityId <= -10) {//国阵
					this.tLv.visible = false;
				} else {
					if (ModelManager.instance.modelCountryPvp.mIsToday) {//当天开启
						if (this.mEntityCity.country > 2) { //黄巾军才显示驻军。
							//黄巾军。
							//this.tLv.text = Tools.getMsgById("_lht30", [this.mEntityCity.getNPCLevel()]);//"驻军等级: " +this.mEntityCity.getNPCLevel();
						} else {
							this.tLv.visible = false;
						}
					} else {
						npcLevel = "??";
						//this.tLv.text = "??";//"驻军等级: " +this.mEntityCity.getNPCLevel();
					}
				}				
			} else {
				//this.tLv.text = Tools.getMsgById("_lht30", [this.mEntityCity.getNPCLevel()]);//"驻军等级: " +this.mEntityCity.getNPCLevel();
			}
			
			this.tLv.text = Tools.getMsgById("_lht30", [npcLevel]);//"驻军等级: " +this.mEntityCity.getNPCLevel();
			
            //this.tInfo.text = Tools.getMsgById(ModelOfficial.getCityCfg(this.mData.cid).info);
            this.tInfo.text = this.mEntityCity.getFightTimeStr();
            //
            this.cityType.text = ModelOfficial.getCityType(this.mData.cid);
            //
            this.checkBuffs();
        }
        private function checkBuffs():void
        {
            this.buff1.setCityBuffs(3,Tools.getMsgById("_lht31"));
            this.buff2.setCityBuffs(3,Tools.getMsgById("_lht32"));
            this.buff3.setCityBuffs(2,"");//鼓舞
            this.buff4.setCityBuffs(1,"");//加速
            //
            var faith:Array = ModelOfficial.getCityFaith(this.mData.cid);
           
			if (this.mEntityCity.cityType == 0)
			{
				 this.buff1.visible = this.buff2.visible = false;
			}
			else{
				 this.buff1.visible = this.buff2.visible = true;
				 var blv:Number = this.mEntityCity.getB07lv();
				 if (blv < 1){
					 this.buff1.gray = true;
					 this.buff1.alpha = 0.5;
				 }
				 else{
					 this.buff1.gray = false;
					 this.buff1.alpha = 1;
				 }
				 if (blv < 5){
					 this.buff2.gray = true;
					 this.buff2.alpha = 0.5;
				 }
				 else{
					 this.buff2.gray = false;
					 this.buff2.alpha = 1;
				 }
			}
            //
            this.flag3.visible = this.buff3.visible = false;
            this.flag4.visible = this.buff4.visible = false;
			
		
            if (faith){
				//此城当前所属国
				var country:int = Number(this.mData.country);
				var faithCountry:int = faith[0];
				var buffLv:int = faith[1];
				var armyGoLv:int = faith[2];

				if (buffLv > 0 && country >= 0 && country <= 2)
				{
					//鼓舞
					this.flag3.visible = this.buff3.visible = true;
					this.flag3.setCountryFlag(faithCountry);
					EffectManager.changeSprColor(this.buff3, buffLv);
				}
				if (armyGoLv > 0)
				{
					//加速
					this.flag4.visible = this.buff4.visible = true;
					this.flag4.setCountryFlag(faithCountry);
					EffectManager.changeSprColor(this.buff4, armyGoLv);
				}
            }
            //
            this.buff1.off(Event.CLICK,this,this.click_buff);
            this.buff2.off(Event.CLICK,this,this.click_buff);
            this.buff3.off(Event.CLICK,this,this.click_buff);
            this.buff4.off(Event.CLICK,this,this.click_buff);
            //
            this.buff1.on(Event.CLICK,this,this.click_buff,[1,faith]);
            this.buff2.on(Event.CLICK,this,this.click_buff,[2,faith]);
            this.buff3.on(Event.CLICK,this,this.click_buff,[3,faith]);
            this.buff4.on(Event.CLICK,this,this.click_buff,[4,faith]);
        }
		
		private function getCountryHTML(country:int):String
        {
			var str:String = StringUtil.htmlFontColor(Tools.getMsgById("country_" + country), ConfigServer.world.COUNTRY_COLORS[country]);
			return str;
		}
        private function click_buff(type:Number,faith:Array):void
        {
            var title:String = "";
            var info:String = "";
            var arrT:Array = [];
            var arrI:Array = [];
			var countryHTML:String;
			
            switch(type)
            {
                case 1:
                    title = "city_addtroop_name";
                    info = "city_addtroop_info";
                    break;
                case 2:
                    title = "city_dismisstroop_name";
                    info = "city_dismisstroop_info";
                    break;  
                case 3:
					//鼓舞
                    title = "citybuff_fighting_name";
                    info = "citybuff_fighting_info";
                    if (faith){
						countryHTML = this.getCountryHTML(faith[0]);
                        arrT = [countryHTML,faith[1]];
                        arrI = [countryHTML,this.mEntityCity.name,StringUtil.numberToPercent(ConfigServer.world.faithBuffDmgRate[faith[1]-1]),StringUtil.numberToPercent(ConfigServer.world.faithBuffResRate[faith[1]-1])];
                    }
                    break;   
                case 4:
					//加速
					title = "citybuff_speed_name";
                    info = "citybuff_speed_info";
					if (faith){
						countryHTML = this.getCountryHTML(faith[0]);
                        arrT = [countryHTML,faith[2]];
                        arrI = [countryHTML,StringUtil.numberToPercent(ConfigServer.world.faithBuffSpeedRate[faith[2]-1])];
                    }
                    break;                                                
                default:
                    break;
            }
            ViewManager.instance.showTipsPanel(Tools.getMsgById(info,arrI),0,Tools.getMsgById(title,arrT));
        }
        private function click(index:int):void{
            var data:Array = this.list.array[index];
            ModelManager.instance.modelUser.selectUserInfo(data[0]);
        }
        private function list_render(item:ItemCityInfo,index:int):void{
            item.setUI(this.list.array[index],this.mData.country);
            item.off(Event.CLICK,this,this.click);
            item.on(Event.CLICK,this,this.click,[index]);
        }        
    }
}