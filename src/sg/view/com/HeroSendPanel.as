package sg.view.com
{
	import sg.map.model.MapModel;
	import sg.map.model.entitys.EntityCity;
    import ui.com.hero_send_panelUI;
    import sg.manager.ModelManager;
    import sg.model.ModelGame;
    import laya.events.Event;
    import sg.model.ModelHero;
    import sg.model.ModelTroop;
    import sg.map.model.entitys.EntityMarch;
    import sg.view.map.ItemHeroSend;
    import laya.utils.Handler;
    import sg.utils.StringUtil;
    import sg.boundFor.GotoManager;
    import sg.utils.Tools;

	/**
	 * 部队前往，中间列表
	 * @author
	 */
    public class HeroSendPanel extends hero_send_panelUI
    {
		///目的地城市
        public var mCityId:int;
        public var mTroops:Array;
        public var isOnly:Boolean = false;
        public var onlyHere:Number = 0;  
        public var mSelectArr:Array;      
        public var mChangeHandler:Handler;
        public var mNullHandler:Handler;
        public var mPowerRefer:Number = -1;
        public var mFightType:Number = 0;
        public function HeroSendPanel()
        {
            // ModelManager.instance.modelGame.on(ModelGame.EVENT_HERO_TROOP_EDIT_UI_CHANGE,this,this.event_hero_troop_edit_ui_change);
            this.on(Event.REMOVED,this,this.onRemoved);     
            //
            this.list.itemRender = ItemHeroSend;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.spaceY = 8;
            this.list.scrollBar.hide = true;
            this.list.selectHandler = new Handler(this,this.list_select);     
        }
        private function onRemoved():void
        {
            
        }
        override public function clear():void
        {
            this.tGoto.offAll(Event.CLICK);
            this.list.array = [];
            // this.mSelectArr = [];
            this.list.selectedIndex = -1;
            if(this.mChangeHandler){
                this.mChangeHandler.clear();
                this.mChangeHandler = null;
            }
        }
        public function initData(currArg:*):void{
            
            this.mCityId = currArg[0];
            this.mTroops = currArg[1];
            this.isOnly = currArg[2];
            this.onlyHere = currArg[3];  
            this.mChangeHandler = currArg[4];
            this.mNullHandler = currArg[5];
            this.mFightType = currArg[6];
            //
            this.mSelectArr = [];
        }
        public function click_goto():void
        {
            GotoManager.instance.boundForMap(this.mCityId, 1, "1");
        }
        public function setList(update:Boolean = false):void{
            if(update){
                this.mTroops = ModelManager.instance.modelTroopManager.getMoveCityTroop(this.mCityId,onlyHere);
            }
            //
            this.tGoto.offAll(Event.CLICK);
            this.tGoto.visible = this.mTroops.length<=0;
            this.list.visible = !this.tGoto.visible;
            if(this.mNullHandler){
                this.mNullHandler.runWith(this.tGoto.visible);
            }
            if(this.tGoto.visible){
                this.tGoto.style.fontSize = 20;
                this.tGoto.style.color = "#d4e3ff";
                this.tGoto.style.align = "center";
                this.tGoto.width = this.width;
                this.tGoto.x = 0;
                this.tGoto.y = (this.height - this.tGoto.height)*0.5;
                this.tGoto.innerHTML = Tools.getMsgById("_country44");//"没有部队,调取部队"+
                this.tGoto.on(Event.CLICK,this,this.click_goto);
                return;
            }
            //
			var ec:EntityCity = MapModel.instance.citys[this.mCityId];
            var arr:Array = [];
            var hero:ModelHero;
            var troop:ModelTroop;
            var searchArr:Array = this.mTroops;
            var len:int = searchArr.length;
            var dataObj:Object;
            var tmd:ModelTroop;
            var cityCurr:int = 0;
            var march:EntityMarch;
            var free:Number = 0;
            var freeCity:Number = 0;
            var endCityID:String = "";
            var runTime:Number = 0;
            //
            var changeIndex:int = -1;
            //
            for(var i:int = 0; i < len; i++)
            {
                dataObj = searchArr[i];
                troop = dataObj.model;
                hero = ModelManager.instance.modelGame.getModelHero(troop.hero);
                runTime = 0;
                //
                if(troop.state == ModelTroop.TROOP_STATE_MOVE){
                    march = ModelManager.instance.modelMap.marchs[troop.id];
                    //
                    runTime = march.remainTime();//
                    //
                    cityCurr = 2;
                }
                arr.push({hmd:hero,ct:dataObj,free:dataObj.type,city:cityCurr,time:runTime,ec:ec});
            }
            this.list.array = [];
            //
            if(update){
                this.list.dataSource = arr;
            }
            else{
                this.list.dataSource = arr;
            }
            this.list.selectEnable = this.isOnly;
            //
            var _this:HeroSendPanel = this;
            if(this.isOnly){
                if(arr.length>0){
                    this.list.selectedIndex = 0;
                }
            }
            else{
                this.checkChange();
            }
        }
        private function checkSelect(dataRuler:Object):int
        {
            var len:int = this.mSelectArr.length;
            var dataObj:Object;
            var hmd:ModelHero;
            var hmdRuler:ModelHero = dataRuler.hmd;
            var index:int = -1;
            for(var i:int = 0; i < len; i++)
            {
                dataObj = this.mSelectArr[i];
                hmd = dataObj.hmd;
                if(hmd.id == hmdRuler.id){
                    index = i;
                    break;
                }
            }
            return index;
        } 
        private function click(index:int,item:ItemHeroSend):void{
            if(this.isOnly){
                return;
            }
            if(!item.isFree){
                return;
            }
            var dataObj:Object = this.list.array[index];
            var hmd:ModelHero = dataObj.hmd;
            //
            var select:int = this.checkSelect(dataObj);
            if(select>-1){

                this.mSelectArr.splice(select,1);
                item.setSelectUI(false);
            }
            else{
                this.mSelectArr.push(dataObj);
                item.setSelectUI(true);
            }
            this.checkChange();
          
        }        
        private function list_render(item:ItemHeroSend,index:int):void{
            var dataObj:Object = this.list.array[index];
            var hmd:ModelHero = dataObj.hmd;
            item.setData(hmd);
            item.setTroopStatus(dataObj, this.onlyHere);
			//如果已经有损耗预估，则战力推荐为负数不显示危险
			var timeS:Number = dataObj.ct.time;
            item.setPowerCheck(this.mPowerRefer,timeS);
            item.setSelectUI(this.isOnly?(this.list.selectedIndex == index):this.checkSelect(dataObj)>-1);
            item.mouseEnabled=dataObj.isFree;
            item.off(Event.CLICK,this,this.click);
            item.on(Event.CLICK,this,this.click,[index,item]);
        }
        private function list_select(index:int):void
        {
            // trace(this.isOnly,this.list.array[index]);
            if(this.isOnly && index>-1){
                var dataObj:Object = this.list.array[index];
                var mt:ModelTroop = dataObj.ct.model;
                var isFree:Boolean = (mt.state == ModelTroop.TROOP_STATE_IDLE && !mt.isReadyFight);
                if(mt.state == ModelTroop.TROOP_STATE_MONSTER){
                    isFree = false;
                }
                if(isFree){
                    this.mSelectArr = [];
                    this.mSelectArr.push(dataObj);
                    this.checkChange();
                }
            }
        }  
        private function checkChange():void{
            if(this.mChangeHandler){
                this.mChangeHandler.run();
            }
        }                     
    }
}