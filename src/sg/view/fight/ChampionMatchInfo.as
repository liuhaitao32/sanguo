package sg.view.fight
{
    import ui.fight.championMatchInfoUI;
    import laya.utils.Handler;
    import ui.fight.itemChampionMatchInfoPanelUI;
    import ui.fight.itemChampionMatchInfoUI;
    import sg.utils.Tools;
    import sg.manager.ModelManager;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.fight.FightMain;
    import sg.model.ModelClimb;
    import sg.cfg.ConfigServer;

    public class ChampionMatchInfo extends championMatchInfoUI{
        private var mGroupData:Object;
        private var mRoundMatch:int;
        public function ChampionMatchInfo(){
            
            this.list.itemRender = itemChampionMatchInfoPanelUI;
            this.list.scrollBar.hide = true;
            this.list.renderHandler = new Handler(this,this.list_render);
        }
        override public function initData():void{
            this.mGroupData = this.currArg[0];
            this.mRoundMatch = this.currArg[1];
            //
            var arr:Array = this.mGroupData.log_list;
            var len:int = arr.length;
            var round:Array = [];
            var roundAll:Array = [];
            for(var i:int = 0; i < len; i+=2)
            {
                round = [];
                if(arr[i]){
                    round.push(arr[i]);
                }
                if(arr[i+1]){
                    round.push(arr[i+1]);
                }
                roundAll.push(round);
            }
            //
            this.list.dataSource = roundAll;
            this.comTitle.setViewTitle(Tools.getMsgById("_climb55"));
        }
        private function list_render(item:itemChampionMatchInfoPanelUI,index:int):void{
            var arr:Array = this.list.array[index];
            // trace(arr);
            var arrTime:Array = ModelClimb.getChampionRoundFightTime(this.mRoundMatch+1,index+1);
            item.tTime0.visible = !Tools.isNullObj(arrTime);
            item.tTime1.visible = item.tTime0.visible;
            if(item.tTime0.visible){
                item.tTime1.text = Tools.dateFormat(arrTime[0]);
            }
            item.tName0.text = Tools.getMsgById("_climb10",[index+1]);//"第"+(index+1)+"战";
            item.p0.visible = true;
            item.p1.visible = (arr.length>1);
            //
            if(item.p0.visible){
                this.setPkUI(item.p0,arr[0],arrTime);
            }
            if(item.p1.visible){
                this.setPkUI(item.p1,arr[1],arrTime);
            }            
            item.p0.btn.offAll(Event.CLICK);
            item.p1.btn.offAll(Event.CLICK);
            //
            item.p0.btn.on(Event.CLICK,this,this.click_view_fight,[0,index]);
            item.p1.btn.on(Event.CLICK,this,this.click_view_fight,[1,index]);
        }
        private function click_view_fight(type:int,index:int):void
        {
            var arr:Array = this.list.array[index];
            // mode:5
            // rnd:5
            //team
            // trace(type,arr);
			var fightArr:Array = arr[type];
			if (fightArr)
			{
				var fightData:Object = ModelClimb.getChampionFightData(fightArr);
				if (FightMain.checkPlayback(fightData.time)){
					//ViewManager.instance.closePanel();
					FightMain.startBattle(fightData);
					return;
				}
			}	
			ViewManager.instance.showTipsTxt(Tools.getMsgById("_explore073"));
        }
        private function setPkUI(item:itemChampionMatchInfoUI,arr:Array,arrTime:Array):void{
            var p0:Object = arr[0];
            var p1:Object = arr[1];
            item.tOver.visible = Tools.isNullObj(arrTime) || (arrTime && arrTime[2]);
			item.tOver.text = Tools.getMsgById("ChampionMatchInfo_1");
			item.btn.label = Tools.getMsgById("_explore029");
            //
            item.tName0.text = p0.uname;
            item.tName1.text = p1.uname;
            //
			item.comPower0.setNum(p0.power);
			item.comPower1.setNum(p1.power);
            //item.tPower0.text = p0.power;
            //item.tPower1.text = p1.power;
            //
            item.win0.visible = (arr[2] == 0);
            item.win1.visible = (arr[2] == 1);
            //
            item.heroIcon0.setHeroIcon(Tools.isNullObj(p0.head)?(p0.troop?p0.troop[0].hid:ConfigServer.system_simple.init_user.head):p0.head);
            item.heroIcon1.setHeroIcon(Tools.isNullObj(p1.head)?(p1.troop?p1.troop[0].hid:ConfigServer.system_simple.init_user.head):p1.head);
        }
    }   
}