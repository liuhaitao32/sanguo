package sg.view.fight
{
    import ui.fight.championMatchAUI;
    import laya.events.Event;
    import laya.utils.Handler;
    import ui.fight.itemChampionGroupUI;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.manager.ModelManager;
    import sg.net.NetPackage;
    import sg.net.NetMethodCfg;
    import sg.net.NetSocket;
    import sg.utils.Tools;
    import sg.model.ModelClimb;
    import sg.model.ModelHero;
    import sg.cfg.ConfigServer;

    public class ChampionMatchA extends championMatchAUI{
        private var mRoundMatch:int;
        private var mGroupMax:Number;
        private var mGroupCurr:Number;
        private var mGroupData:Object;
        private var mMyGroupIndex:int;     
        //
        private var tClick:Number;
        //   
        public function ChampionMatchA(index:int,data:Object,myIndex:int){
            this.on(Event.REMOVED, this, this.onRemove);
			this.text0.text = Tools.getMsgById("_champion01");
			this.btn.label = Tools.getMsgById("_climb55");
            //
            this.mGroupData = data;
            this.mMyGroupIndex = myIndex;
            this.mRoundMatch = index;
            //
            this.list.itemRender = itemChampionGroupUI;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.scrollBar.hide = true;
            //
			//this.btn_next.text = Tools.getMsgById("_climb55");
            this.btn_next.on(Event.CLICK,this,this.click,[1]);
            this.btn_back.on(Event.CLICK,this,this.click,[-1]);
            this.btn.on(Event.CLICK,this,this.click_pk);
            //
            this.initUI();
        }
        override public function clear():void{
            this.timer.clear(this,this.timer_next_big);
            this.timer.clear(this,this.timer_next_sm);
            this.list.destroy(true);
            this.btn.destroy();
            this.btn_next.destroy();
            this.btn_back.destroy();
            //
            this.destroy(true);
        }
        private function initUI():void{
            this.tClick = 0;
            //
            var groupNum:Number = 1024;
            groupNum = groupNum/Math.pow(4,this.mRoundMatch+1);
            if(this.mRoundMatch>1){
                groupNum = groupNum*Math.pow(2,this.mRoundMatch-1);
            }
            this.mGroupMax = groupNum;
            this.mGroupCurr = (this.mMyGroupIndex<0)?0:(this.mMyGroupIndex-1);
            //
            this.tGroup.label = Tools.getMsgById("_climb1",[(this.mRoundMatch+1)]);//"第"+(this.mRoundMatch+1)+"轮小组赛";
            this.click(0,Tools.isNullObj(this.mGroupData));
        }
        private function list_render(item:itemChampionGroupUI,index:int):void{
            var data:Object = this.list.array[index];
            item.tagIndex.setRankIndex(index+1,"",true);
            item.tName.text = data.uname;
			item.comPower.setNum(data.power);
            //item.tPower.text = data.power;
            item.mCountry.setCountryFlag(data.country);
            item.tagOK.visible = (this.mRoundMatch==0)?(index<1):(index<2);
            //
            var winStr:String = data.win;
            var winArr:Array = data.winArr;
            
            var winN:int = 0;
            var loseN:int = 0;
            if(this.mGroupData.if_log>0 && winArr){
                var len:int = winArr.length;
                for(var i:int = 0; i < len; i++)
                {
                    if(winArr[i]==1){
                        winN+=1;
                    }
                    else if(winArr[i]==0){
                        loseN+=1;
                    }
                }
            }
            item.tWin.text = winN+"";
            item.tLose.text = loseN+"";
            //
            if(Tools.isNullObj(data.head)){
                if(data.troop){
                    var s:String=(data.troop?data.troop[0].hid:ConfigServer.system_simple.init_user.head);
                    s=(data.troop && data.troop[0].awaken==1) ? s+"_1" : s+"";
                    item.heroIcon.setHeroIcon(s);
                }
                else{
                    item.heroIcon.setHeroIcon(ConfigServer.system_simple.init_user.head);
                }
            }
            else{
                item.heroIcon.setHeroIcon(data.head);
            }

            item.heroIcon.off(Event.CLICK,this,this.click_head);
            item.heroIcon.on(Event.CLICK,this,this.click_head,[data.uid]);
        }

        private function click_head(_uid:*):void{            
            ModelManager.instance.modelUser.selectUserInfo(_uid);
        }

        private function click_pk():void{
            ViewManager.instance.showView(ConfigClass.VIEW_CHAMPION_MATCH_INFO,[this.mGroupData,this.mRoundMatch]);
        }
        private function click(step:int,getServer:Boolean = true):void{
            this.tClick = Tools.runAtTimer(this.tClick,1000,Handler.create(this,this.clickRun,[step,getServer]));
        }
         private function clickRun(step:int,getServer:Boolean = true):void{
            this.mGroupCurr+=step;
            //
            this.btn_next.disabled = (this.mGroupCurr>=(this.mGroupMax-1));
            this.btn_back.disabled = (this.mGroupCurr<=0);
            //
            if(getServer){
                this.getGroupData(this.mGroupCurr);
            }
            else{
                this.setUI();
            }
         }
        private function getGroupData(group:int):void{
            NetSocket.instance.send(NetMethodCfg.WS_SR_GET_PK_YARD_LOG,{ym:(this.mRoundMatch+1),tn:(group+1)},Handler.create(this,this.ws_sr_get_pk_yard_log),group);
        }
        private function ws_sr_get_pk_yard_log(re:NetPackage):void{
            this.mGroupData = re.receiveData;
            //
            this.setUI();
        }
        private function setUI():void{
            //小组数据  this.mGroupData
            this.tPage.text = Tools.getMsgById("_climb2",[this.mGroupCurr+1]);//"第"+(this.mGroupCurr+1)+"组";
            this.pageNum.text = (this.mGroupCurr+1)+"/"+this.mGroupMax;
            //
            var arr:Array;
            if(this.mGroupData.if_log>0){
                arr = ModelClimb.formatChampionGroupLog(this.mGroupData);
                this.btn.visible = true;
            }
            else{
                arr = ModelClimb.formatChampionGroupReady(this.mGroupData);
                this.btn.visible = false;
            }
            this.list.dataSource = arr;
            //
            var fing:Boolean = ModelClimb.isChampionIng();
            this.tTime.visible = fing;
            this.boxTime.visible = fing;
            //
            if(fing){
                this.timer_next_big();
                //
                this.timer_next_sm();
            }
        }
        private function timer_next_big():void
        {
            var nrms:Number = ModelClimb.getChampionNextRoundTimr(this.mRoundMatch+1);
            this.tTime.text = (nrms>-1)?Tools.getMsgById("_climb3",[Tools.getTimeStyle(nrms)]):"";//下一轮:  
            if(nrms>-1){
                this.timer.once(1000,this,this.timer_next_big);
            }                      
        }
         private function timer_next_sm():void
         {
            var nfms:Number = ModelClimb.getChampionRoundNextFightTimr();
            this.tRound0.text = (nfms>0)?Tools.getMsgById("_climb5"):"";//距离开战:
            this.tRound1.text = (nfms>0)?""+Tools.getTimeStyle(nfms):"";
            //
            if(nfms>0){
                this.timer.once(1000,this,this.timer_next_sm);
            }
         }
    }   
}