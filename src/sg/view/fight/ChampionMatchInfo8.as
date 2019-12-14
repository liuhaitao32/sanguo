package sg.view.fight
{
    import ui.fight.championMatchInfoUI;
    import ui.fight.itemChampionMatchInfoUI;
    import laya.utils.Handler;
    import sg.utils.Tools;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.fight.FightMain;
    import sg.model.ModelClimb;
    import sg.cfg.ConfigServer;

    public class ChampionMatchInfo8 extends championMatchInfoUI
    {
        private var mGroupData:Object;
        public function ChampionMatchInfo8()
        {
            this.list.itemRender = itemChampionMatchInfoUI;
            this.list.scrollBar.hide = true;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.comTitle.setViewTitle(Tools.getMsgById("_climb55"));
        }
        override public function initData():void{
            this.mGroupData = this.currArg[0];
            // trace(this.mGroupData);
            if(this.mGroupData.log_list){
                var arr:Array = this.mGroupData.log_list;
                var newArr:Array = [];
                newArr.push(arr[8]);
                newArr.push(arr[9]);
                newArr.push(arr[4]);
                newArr.push(arr[6]);
                newArr.push(arr[11]);
                newArr.push(arr[10]);
                newArr.push(arr[5]);
                newArr.push(arr[7]);                
                newArr.push(arr[0]);
                newArr.push(arr[1]);
                newArr.push(arr[2]);
                newArr.push(arr[3]);

                //
                this.list.dataSource = newArr;
            }
        }
        private function list_render(item:itemChampionMatchInfoUI,index:int):void
        {
            var arr:Array = this.list.array[index];
            // trace(arr);
            var p0:Object = arr[0];
            var p1:Object = arr[1];
            item.tOver.visible = true;//Tools.isNullObj(arrTime) || (arrTime && arrTime[2]);
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
            item.heroIcon0.setHeroIcon(Tools.isNullObj(p0.head)?(p0.troop?p1.troop[0].hid:ConfigServer.system_simple.init_user.head):p0.head);
            item.heroIcon1.setHeroIcon(Tools.isNullObj(p1.head)?(p0.troop?p1.troop[0].hid:ConfigServer.system_simple.init_user.head):p1.head);  
            //
			item.tOver.text = Tools.getMsgById("ChampionMatchInfo_1");
			item.btn.label = Tools.getMsgById("_explore029");
            item.btn.offAll(Event.CLICK);   
            item.btn.on(Event.CLICK,this,this.click_view_fight,[index]);      
        }
        private function click_view_fight(index:int):void
        {
			var fightData:Object = ModelClimb.getChampionFightData(this.list.array[index]);
			if (FightMain.checkPlayback(fightData.time)){
				//ViewManager.instance.closePanel();
				FightMain.startBattle(fightData);
			}
			else{
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_explore073"));
			}
        }        
        
    }
}