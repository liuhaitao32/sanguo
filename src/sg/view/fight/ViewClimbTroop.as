package sg.view.fight
{
    import laya.events.Event;
    import laya.utils.Handler;
	import sg.fight.FightMain;
	import sg.manager.ViewManager;

    import sg.manager.ModelManager;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.net.NetSocket;

    import ui.fight.climbTroopUI;
    import sg.model.ModelGame;
    import sg.utils.Tools;

    public class ViewClimbTroop extends climbTroopUI{
        
        protected var mSelectArr:Array;
        protected var mMaxTroop:Number;
        protected var filterHeros:Array; // 需要过滤掉的英雄（探险）
        protected var limitTypes:Array;  // 上阵的类型限制（传奇）
        public function ViewClimbTroop(){
            this.list.itemRender = ItemTroop;
            this.list.renderHandler = new Handler(this,this.list_render);
            // this.list.selectEnable = true;
            this.list.scrollBar.hide = true;
            //
            this.btn_fight.on(Event.CLICK,this,this.click);
            this.comTitle.setViewTitle(Tools.getMsgById("_climb60"));
            this.btn_fight.label=Tools.getMsgById("_climb48");
            this.text0.text=Tools.getMsgById("_climb62");
            this.text1.text=Tools.getMsgById("_climb61");
            //
        }
        override public function initData():void{
            mMaxTroop = currArg.mMaxTroop || 1;
            filterHeros = currArg.filterHeros || [];
            limitTypes = currArg.limitTypes;
            var heroArr:Array = ModelManager.instance.modelUser.getMyHeroArr(true,"",null,true);

            // 过滤掉部分英雄
            heroArr = heroArr.filter(function(item:Object):Boolean { return filterHeros.indexOf(item.id) === -1 && (!limitTypes is Array || limitTypes.length === 0 || limitTypes.indexOf(item.type) !== -1); }, this);
            mMaxTroop = mMaxTroop > heroArr.length ? heroArr.length : mMaxTroop; // 英雄数量不足
            mc_tips.visible = heroArr.length === 0; // 无可上阵英雄
            if (mc_tips.visible) {
                mMaxTroop = 1;
                txt_tips.text = Tools.getMsgById('legend1');
            }
            this.list.dataSource = heroArr;
            this.list.scrollBar.value = 0;
            mSelectArr = [];
            for(var i:int=0, max:int = Math.min(heroArr.length, mMaxTroop);i < max; i++){
                mSelectArr.push(i);
            }
            this.list.refresh();
            //
            this.setUI();
        }
        protected function setUI():void{
            this.tStatus.text = this.mSelectArr.length+" / "+this.mMaxTroop;
            this.btn_fight.gray = mSelectArr.length === 0;
        }
        private function list_render(item:ItemTroop,index:int):void{

            item.offAll(Event.CLICK);
            item.on(Event.CLICK,this,this.click_troop1,[item,index]);
            //
            this.selectItem(item,index);
        }
        private function click_troop1(item:ItemTroop,index:int):void{
            
            var sID:int = this.mSelectArr.indexOf(index);
            var b:Boolean = sID>-1;
            //
            if(sID>-1){
                
                this.mSelectArr.splice(sID,1);
            }
            else{
                if(this.mSelectArr.length>=this.mMaxTroop){
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_public102"));
                    return;
                }
                this.mSelectArr.push(index);
            }
            // item.setData(!b,null);
            // this.selectItem(item,index);
            this.list.refresh();
            //
            this.setUI();
        }
        private function selectItem(item:ItemTroop,index:int):void
        {
            var abs:int = this.mSelectArr.indexOf(index);
            item.setData(abs>-1,this.list.array[index],true);
            item.setIndex((abs>-1)?Tools.getMsgById("_climb44",[abs+1]):Tools.getMsgById("_public88"));//"第"+(abs+1)+"阵":"空闲"
            item.heroStar.visible = true;            
        }
        private function click():void{
			var len:int = this.mSelectArr.length;
            if(len>0){
                //
				var hidArr:Array = [];
				for (var i:int = 0; i < len; i++) 
				{
					var heroObj:Object = this.list.array[this.mSelectArr[i]];
					hidArr.push(heroObj.id);
				}
                this.chooseFinished(hidArr);
            }
            else{
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_climb14"));
            }
            
        }

        protected function chooseFinished(hidArr:Array):void {
            NetSocket.instance.send(NetMethodCfg.WS_SR_CLIMB,{hids:hidArr},Handler.create(this,this.ws_sr_climb));
        }

        private function ws_sr_climb(re:NetPackage):void{
			// var receiveData:* = re.receiveData;
            // trace("ws_sr_climb", receiveData);
			ModelManager.instance.modelUser.updateData(re.receiveData);
            //
            ModelManager.instance.modelClimb.setClimbFightingToEnd();
            //
            ModelManager.instance.modelGame.event(ModelGame.EVENT_PK_TIMES_CHANGE);            
            //
            ModelManager.instance.modelClimb.climb_fight(re.receiveData);
            //
            this.closeSelf();
        }
		
		private function outFight(receiveData:*):void{

		}
    }   
}