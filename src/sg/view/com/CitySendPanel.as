package sg.view.com
{
	import sg.cfg.ConfigServer;
	import sg.fight.FightMain;
	import sg.fight.client.unit.ClientTroop;
	import sg.fight.logic.unit.TroopLogic;
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
	import sg.model.ModelOffice;
	import sg.model.ModelOfficeRight;
	import sg.view.map.ItemCitySend;
    import ui.com.hero_send_panelUI;
    import sg.manager.ModelManager;
    import sg.model.ModelGame;
    import laya.events.Event;
    import sg.model.ModelHero;
    import sg.model.ModelTroop;
    import sg.map.model.entitys.EntityMarch;
    import sg.view.map.ItemHeroSend;
    import laya.utils.Handler;

	/**
	* 确定部队，选择临近的目的地城市  突进或撤军的列表
	* @author zhuda
	*/
    public class CitySendPanel extends hero_send_panelUI
    {
        public var mCityId:int;
		public var mType:int; //0撤军 1突进 -1皆可
		private var mModel:ModelTroop;
		
        public var mCitys:Array;
		///行军时间和耗粮
		public var mPays:Array;

        public var mSelectArr:Array;      
        public var mChangeHandler:Handler;

        public function CitySendPanel()
        {
            // ModelManager.instance.modelGame.on(ModelGame.EVENT_HERO_TROOP_EDIT_UI_CHANGE,this,this.event_hero_troop_edit_ui_change);
            this.on(Event.REMOVED,this,this.onRemoved);     
            //
            this.list.itemRender = ItemCitySend;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.scrollBar.hide = true;
            this.list.selectHandler = new Handler(this, this.list_select);     
			this.tGoto.visible = false;
        }
        private function onRemoved():void
        {
            
        }
        override public function clear():void
        {
            this.mSelectArr = [];
            this.list.selectedIndex = -1;
            if(this.mChangeHandler){
                this.mChangeHandler.clear();
                this.mChangeHandler = null;
            }
        }
        public function initData(currArg:*):void{
            
            this.mCityId = currArg[0];
			this.mCitys = currArg[1];
            this.mModel = currArg[2];
			this.mType = currArg[3];
            this.mChangeHandler = currArg[4];
            //
            this.mSelectArr = [];
        }
		
        public function setList(update:Boolean = false):void{
			//if (update){
				//this.initCitys();
			//}
            var arr:Array = [];
			var dataObj:Object;
            var ec:EntityCity;
            var cid:int;
			var dir:int;
            var searchArr:Array = this.mCitys;
            var len:int = searchArr.length;
            var type:int; //1突进 0撤军
			//0可以突进 1该城市不可被攻击 2该城市不在可攻击时段内 3该城市要求攻城英雄等级未达标 4该英雄当前血量不足半数 98粮草不足 99不在国战中或前方排队人数不足 100需要在爵位中解锁特权 
			//0可以撤军 -1可撤军但要哗变 98粮草不足 99不在国战中或前方排队人数不足 100需要在爵位中解锁特权 
			var errorType:int; 
            var runTime:Number = 0;
            var changeIndex:int = -1;
			var troop:TroopLogic;
			if (FightMain.instance.client)
			{
				troop = FightMain.instance.client.findTroop( -1, this.mModel.hero, parseInt(this.mModel.uid));
			}

			var righttype:Object  = ConfigServer.office.righttype;
			
            for(var i:int = 0; i < len; i++)
            {
				dataObj = searchArr[i];

                runTime = 0;
				ec = MapModel.instance.citys[dataObj.cid];
				type = ec.myCountry?0:1;
				
				if (type == 1)
				{
					//突进
					if (!ModelOfficeRight.isOpen(righttype['break'][0])){
						//特权
						errorType = 100;
					}else{
						errorType = ec.getAttackError(this.mModel);
					}
				}
				else{
					//撤军
					if (!ModelOfficeRight.isOpen(righttype['runaway'][0])){
						//特权
						errorType = 100;
					}else{
						var cfgArr:Array = ConfigServer.world.troopRunAway;
						if (troop && troop.getHpPer(false) > cfgArr[0])
						{
							errorType = -1;
						}else{
							errorType = 0;
						}
					}
				}
                //changeIndex = this.checkSelect({ec:ec});
                //if(changeIndex>-1 && this.mSelectArr.length>0 && !this.isOnly){
                    //this.mSelectArr.splice(changeIndex,1);
                //}
				
				//计算行军时间和耗粮
				var payObj:Object;
				var troopArr:Array;
				troopArr = ModelManager.instance.modelTroopManager.getMoveCityTroop(dataObj.cid, -1, this.mModel.id);
				if (troopArr.length > 0){
					payObj = troopArr[0];
				}
				else{
					payObj = {time:0,food:0};
				}

				if(this.mType <0 || type==this.mType){
					arr.push({ec:ec, ct:dataObj, city:this.mCityId, time:runTime, type:type , errorType:errorType, time:payObj.time, food:payObj.food});
				}
            }
            //
            if(update){
                this.list.array = arr;
            }
            else{
                this.list.dataSource = arr;
            }
            this.list.selectEnable = true;
            this.checkChange();         
        }
        private function checkSelect(dataRuler:Object):int
        {
            var len:int = this.mSelectArr.length;
            var dataObj:Object;
			
			var ecRuler:EntityCity = dataRuler.ec;
            var ec:EntityCity;
            var index:int = -1;
            for(var i:int = 0; i < len; i++)
            {
                dataObj = this.mSelectArr[i];
                ec = dataObj.ec;
                if(ec.cityId == ecRuler.cityId){
                    index = i;
                    break;
                }
            }
            return index;
        } 
      
        private function list_render(item:ItemCitySend,index:int):void{
            var dataObj:Object = this.list.array[index];
            item.setData(dataObj);
            item.setSelectUI(this.list.selectedIndex == index);
        }
        private function list_select(index:int):void
        {
            if(index>-1){
                this.mSelectArr = [];
                this.mSelectArr.push(this.list.array[index]);
                this.checkChange();
            }
        }  
        private function checkChange():void{
            if(this.mChangeHandler){
                this.mChangeHandler.run();
            }
        }                     
    }
}