package sg.view.menu
{
	import sg.map.model.MapModel;
    import ui.menu.troopListUI;
    import laya.events.Event;
    import laya.utils.Handler;
    import sg.scene.constant.EventConstant;
    import sg.manager.ModelManager;
    import sg.model.ModelTroop;
    import sg.model.ModelHero;
    import laya.maths.MathUtil;
    import sg.cfg.ConfigServer;
    import sg.model.ModelGame;
    import sg.model.ModelOffice;
    import sg.utils.Tools;
    import sg.scene.view.MapCamera;
    import sg.manager.ViewManager;
    import laya.display.Sprite;
    import sg.guide.model.ModelGuide;
    import sg.model.ModelSettings;
    import sg.view.ViewScenes;

    public class ViewTroopList extends troopListUI{
        private var mTroopStatusDic:Object;
        public function ViewTroopList(){
            this.height = Laya.stage.height - ViewScenes.TOP_HEIGHT - 152 - 340;
            
            this.list.itemRender = ItemTroop;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.scrollBar.visible = false;
            // this.list.selectEnable = true;
            this.list.selectHandler = new Handler(this,this.list_select);
            this.list.selectedIndex = -1;
            //
            this.mTroopStatusDic = {};
            this.initMapTroop();
            //
            ModelManager.instance.modelGame.off(ModelGame.EVENT_TROOP_SELECT_TRUE,this,this.event_troop_select_true);
            ModelManager.instance.modelGame.on(ModelGame.EVENT_TROOP_SELECT_TRUE,this,this.event_troop_select_true);
            //
            ModelManager.instance.modelGame.off(ModelGame.EVENT_OFFICE_RIGHT_CHANGE,this,this.updateMapTroop);
            ModelManager.instance.modelGame.on(ModelGame.EVENT_OFFICE_RIGHT_CHANGE,this,this.updateMapTroop,[true,"",null]); 

        }
        private function initMapTroop():void{
			//
			var events:Array = [
				EventConstant.TROOP_CREATE,
				EventConstant.TROOP_REMOVE,
                EventConstant.TROOP_ADD_NUM,
				EventConstant.TROOP_MARCH_STATE_CHANGE,
				EventConstant.TROOP_MARCH_MOVE,
				EventConstant.TROOP_MARCH_REMOVE,
                EventConstant.FIGHT_READY,//备注改变排队。
                EventConstant.FIGHT_FINISH_FIGHT,//备注改变排队。死不死
                EventConstant.TROOP_UPDATE,//特殊战斗,异族入侵
                EventConstant.JOIN_FIGHT,//检查是否战斗
                EventConstant.FIGHT_END//检查是否战斗结束
			]
			//
			for (var i:int = 0, len:int = events.length; i < len; i++) {
				ModelManager.instance.modelTroopManager.off(events[i],this, this.updateMapTroop);
				ModelManager.instance.modelTroopManager.on(events[i],this, this.updateMapTroop,[false,events[i]]);
			}	
			//
			this.updateMapTroop(true,"",null);
		}
		private function updateMapTroop(first:Boolean,events:String,evtObj:Object):void{
            if(evtObj){
                if(evtObj.hasOwnProperty("mid")){
                    var mids:String = evtObj["mid"];
                    var mid:String = "mid"+ModelManager.instance.modelUser.mUID;
                    // trace("==updateMapTroop,",mids,evtObj);
                    if(mid != mids){
                        return;
                    }
                }
            }
			var myTroops:Object = ModelManager.instance.modelTroopManager.troops;
			var arr:Array = [];
			var tmd:ModelTroop;
			var hmd:ModelHero;
            //
			for(var key:String in myTroops)
			{
				tmd = myTroops[key] as ModelTroop;
				hmd = ModelManager.instance.modelGame.getModelHero(tmd.hero);
				arr.push({hPower:hmd.getPower(),troop:tmd,evt:events,checkNext:-1});
			}
            if(arr.length>1){
			    arr.sort(MathUtil.sortByKey("hPower",true));
            }

            this.checkTroopStatus(arr);
            //
            var len:int = arr.length;
            var max:int = ModelManager.instance.modelUser.troop_que_max();
            var i:int = 0;
            var isNext:int = 0;
            var noNull:Boolean = false;
            if(len<max){
                for(i = len; i < max; i++){
                    arr.push({troop:null,evt:events,checkNext:isNext});
                    isNext+=1;
                }
            }
            else{
                noNull = true;
            }
            //
            if(first){
                this.list.dataSource = arr;
            }
            else{
                this.list.array = arr;
            }
            //
            if(arr.length>=6){
                this.all.height = 582;
            }
            else{
                this.all.height = 56+90*arr.length-20;
            }

            if(this.all.height>=this.height){
                this.all.height=this.height;
            }
            this.all.centerY=0;
            //
            ModelManager.instance.modelGame.event(ModelGame.EVENT_HERO_TROOP_EDIT_UI_CHANGE,[noNull,events]);
		}
        private function list_render(item:ItemTroop,index:int):void{
            item.initData(this.list.array[index]);
            item.setSelect(this.list.selectedIndex == index);
            item.centerX = 0;
            item.offAll(Event.CLICK);
            item.on(Event.CLICK,this,this.click_item,[item,index]);
        }
        private function click_item(item:ItemTroop,index:int):void
        {
            var data:Object = this.list.array[index];
            var tmd:ModelTroop = data.troop;   
            if(Tools.isNullObj(tmd)){
                this.list.selectedIndex = -1;
                item.click();
            }         
            else{
                if(this.list.selectedIndex!=index){
                    // trace(this.list.selectedIndex, index);
                    this.reListSelection();
                    this.list.selectedIndex = index;
                    item.click();//跳转并直接弹出
                }
                else{//先跳转  后弹出
                    //this.list.selectedIndex = -1;
                    //item.click();
                }
            }
            
        }     
        private function list_select(index:int):void
        {
            if(index<0){
                this.reListSelection();
                return;
            }
            var data:Object = this.list.array[index];
            var tmd:ModelTroop = data.troop;
            if(Tools.isNullObj(tmd)){
                this.reListSelection();
            }
            else{
                if(this.list.selection){
                    (this.list.selection as ItemTroop).setSelect(true);
					
					if (MapModel.instance.marchs[tmd.id]) {
						MapCamera.lookAtDisplay(MapModel.instance.marchs[tmd.id].view, 500);
					} else {
						MapCamera.lookAtCity(tmd.cityId);
					}
                }
            }
        }
        private function reListSelection():void
        {
            if(this.list.selection){
                (this.list.selection as ItemTroop).setSelect(false);
            }
        }
        private function event_troop_select_true():void
        {
            if (ModelGuide.forceGuide())   return;
            this.list.selectedIndex = -1;
        }
        /**
         * 部队状态,战报用
         */
        private function checkTroopStatus(arr:Array):void
        {
            if (ModelGuide.forceGuide()){return;}
            if(!ModelSettings.instance.notifyActive){return;}
            //{hPower:hmd.getPower(),troop:tmd,evt:events,checkNext:-1}   
            var len:Number = arr.length;
            var data:Object;
            var tmd:ModelTroop;
            var st:Object;
            var notice:Array = [];
            var heros:Array = [];
            for(var i:Number = 0; i < len; i++)
            {
                data = arr[i];
                tmd = data.troop;
                if(tmd){
                    heros.push(tmd.hero);
                    var fightIng:Boolean = (tmd.state == ModelTroop.TROOP_STATE_IDLE && tmd.isReadyFight && tmd.index<1);
                    if(this.mTroopStatusDic[tmd.hero]){
                        st = this.mTroopStatusDic[tmd.hero];
                        if(st.status == ModelTroop.TROOP_STATE_MOVE && tmd.state == ModelTroop.TROOP_STATE_IDLE && !fightIng){
                            notice.push({status:0,cid:tmd.cityId,hid:tmd.hero});
                        }
                        else if(!st.isFight && fightIng){
                            notice.push({status:1,cid:tmd.cityId,hid:tmd.hero});
                        }
                        st.status = tmd.state;
                        st.isFight = fightIng;
                    }
                    else{
                        
                        this.mTroopStatusDic[tmd.hero] =  {status:tmd.state,isFight:fightIng};
                        if(fightIng){
                            notice.push({status:1,cid:tmd.cityId,hid:tmd.hero});
                        }
                    }
                }
            }
            for(var key:String in this.mTroopStatusDic)
            {
                if(heros.indexOf(key)<0){
                    delete this.mTroopStatusDic[key];
                }
            }
            
            for(var index:int = 0; index < notice.length; index++)
            {
                ViewManager.instance.showNotice(notice[index]);
            }            
        }

        public function getCellByIndex(index:int):Sprite
        {
            return this.list.getCell(index);
        }
    }   
}