package sg.view.fight
{
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import ui.fight.climbMainUI;
    import sg.cfg.ConfigServer;
    import sg.model.ModelClimb;
    import sg.manager.ModelManager;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.model.ModelHero;
    import sg.model.ModelGame;
    import sg.utils.Tools;
    import ui.bag.bagItemUI;
    import sg.model.ModelItem;
    import sg.model.ModelPrepare;
    import sg.fight.test.TestFightData;
    import laya.maths.Rectangle;
    import sg.model.ModelUser;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;
    import sg.festival.model.ModelFestival;

    public class ViewClimbMain extends climbMainUI{
        private var mModel:ModelClimb;
        private var mStatus:int = -1;
        public function ViewClimbMain(){
            this.text0.text=Tools.getMsgById("_climb57");
            this.text1.text=Tools.getMsgById("_climb58");
            this.btn_rank.on(Event.CLICK,this,this.click_rank,[0]);
            this.btn_ok.on(Event.CLICK,this,this.click);
            this.btn_add.on(Event.CLICK,this,this.click_add);
            this.btn_help.on(Event.CLICK,this,this.click_help);
            //
            this.list.selectEnable = false;
            this.list.renderHandler = new Handler(this, this.list_render);
			this.btn_rank.label = Tools.getMsgById("ViewClimbMain_1");
			this.iRank.text = Tools.getMsgById("_public214");
           
        }
        private function click_help():void
        {
            ViewManager.instance.showTipsPanel(Tools.getMsgById(ModelClimb.getCfgConfigure().tips));
        }
        private function clipRFunc():void
        {
            this.clip0.rotation+=0.2;
        }
        override public function initData():void{
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("bg_19.png"));
            this.setTitle(Tools.getMsgById("add_climb"));
            //
            this.timer.frameLoop(1,this,this.clipRFunc);
            //
            ModelManager.instance.modelGame.on(ModelGame.EVENT_PK_TIMES_CHANGE,this,this.setUI);
            ModelManager.instance.modelGame.on(ModelGame.EVENT_NEW_DAY_COM_ON,this,this.setUI);
            //
            this.mModel = ModelManager.instance.modelClimb;
            //
            this.setUI();
        }
        override public function onRemoved():void{
            ModelManager.instance.modelGame.off(ModelGame.EVENT_PK_TIMES_CHANGE,this,this.setUI);
            ModelManager.instance.modelGame.off(ModelGame.EVENT_NEW_DAY_COM_ON,this,this.setUI);
            //
            this.timer.clear(this,this.checkFighting);
            this.timer.clear(this,this.clipRFunc);
        }
        private function list_render(item:bagItemUI,index:int):void{
            var data:Array = this.list.array[index];
            // item.setIcon(ModelItem.getItemIcon(data[0]));
            // item.setNum(data[1]);
            item.setData(data[0]);//data[1]
            item.setName("");
        }
        private function setUI():void{
            this.iKill.text = Tools.getMsgById("_country42");
            this.award_txt.text = Tools.getMsgById("_public113");
            this.txt0.text = Tools.getMsgById("_lht38");
            this.txt1.text = Tools.getMsgById("_lht37");
            this.iTimes.text = Tools.getMsgById("_pve_text01");
            this.tNumMax.text = this.mModel.getMyKillNumMax()+"";

            this.tSeason.text = Tools.getMsgById("_climb45",[ModelManager.instance.modelUser.getSeasonName()]);//"过关斩将--"++"季";
            
            this.tTips1.text =  Tools.getMsgById("_climb47");//[ModelUser.season_name[ModelClimb.getCfgConfigure().num_season],ModelClimb.getCfgConfigure().num_time[0]]
            //每年春季结束后结算排行奖励，通过邮件发放
            //+"季"++"点结算，通过邮件发放奖励";
            this.tTips2.text = Tools.getMsgById("_climb46");//"每击杀一只部队,随机获得以下奖励之一(上限100份)";
            this.tLv.text = this.mModel.getPClv()+"";
            //
            var arg:Array = this.currArg["receive_data"];
            this.army0.setArmyIcon(arg[0],1,true);
            this.army1.setArmyIcon(arg[1],1,true);
            //
            var n:Number = this.mModel.getMyClimbTimes();
            var max:Number = this.mModel.getFightTimesByDay()+this.mModel.getBuyTimesGet();
            this.tTimes.text = n+"/"+max;//"今日剩余次数 "+
            //
            this.award.visible = false;
            this.award_txt.visible = false;
            //
            
            this.mStatus = -1;
            this.rankCom.setRankIndex(0);
            // this.tRank.text = "未上榜";
            this.tKill.text = "--";
            //
            var isIng:Number = this.mModel.isClimbIng();
            //
            this.timer.clear(this,this.checkFighting);
            this.btn_ok.gray = false;
            if(isIng>0){
                this.timer.loop(1000,this,this.checkFighting);
                this.btn_ok.label = Tools.getMsgById("_public98");//"查看战斗";//查看战斗
                this.tNumMax.text=Tools.getMsgById("_climb64");
                this.mStatus = 1;
            }
            else{
                if(this.mModel.isGetAward()){
                    this.mStatus = 2;
                    this.btn_ok.label = Tools.getMsgById("_public99");//"获取奖励";//获取奖励
                }
                else{
                    this.mStatus = 0;
                    this.btn_ok.label = Tools.getMsgById("_climb48");//"开始挑战";
                    this.btn_ok.gray = n<=0;
                }
            }
            //
            var award:Array = this.mModel.getAwardItems().concat();

			var fest:Array=ModelFestival.getRewardInterfaceByKey("climb");
			if(fest.length!=0)
				award.unshift(fest);
            //
            this.list.repeatX = award.length;
            //
            this.list.dataSource = award;
            //
            this.click_rank(1);
        }
        private function checkFighting():void
        {
            var isIng:Number = this.mModel.isClimbIng();
            if(isIng<=0){
                this.setUI();
            }
        }
        private function click_myAward(reward:Object):void{
            ViewManager.instance.showRewardPanel(reward,null,true);
        }
        private function click_add():void{
            if(this.mModel.getBuyTimesGet()>=this.mModel.getBuyTimes()){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_public100",[this.mModel.getBuyTimes()]));
                //"每天只能购买 "+this.mModel.getBuyTimes()+" 次"
                return;
            }
            ViewManager.instance.showBuyTimes(0,1,this.mModel.getBuyTimes()-this.mModel.getBuyTimesGet(),this.mModel.getTimesBuyCoin());
        }
        private function click():void{
            if(this.btn_ok.gray){
                if(this.mModel.getBuyTimesGet()<this.mModel.getBuyTimes()){
                    this.click_add();
                }
                else{
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_pve_tips08"));
                }
                return;
            }
            //
            if(this.mStatus == 0){
                ViewManager.instance.showView(ConfigClass.VIEW_CLIMB_TROOP, {mMaxTroop: ModelManager.instance.modelUser.troop_que_max()});
            }
            else if(this.mStatus == 1){
                this.mModel.climb_fight({pk_result:ModelManager.instance.modelUser.climb_records.pk_result,pk_data:ModelManager.instance.modelUser.climb_records.pk_data});
            }
            else if(this.mStatus == 2){
                //
                this.mModel.getClimbAwardToMe(Handler.create(this,this.setUI));
            }
        }
        private function click_rank(type:int):void{
            //
            NetSocket.instance.send(NetMethodCfg.WS_SR_GET_CLIMB_RANK,{},Handler.create(this,this.ws_sr_get_climb_rank),type);
        }
        private function ws_sr_get_climb_rank(re:NetPackage):void{
            //re.receiveData=[自己数据,排行榜数据]
            var arr:Array = re.receiveData[1] ? re.receiveData[1] : [];
            var type:int  = re.otherData;
            if(type>0){
                this.checkIsEndShowUI(re.receiveData);
                return;
            }
            if(arr.length<=0){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_climb49"));//"没有人上榜"
                return;
            }
            ViewManager.instance.showView(ConfigClass.VIEW_CLIMB_RANK,re.receiveData[1]);
        }  
        private function checkIsEndShowUI(a:Array):void{
            var arr:Array = a[1] ? a[1] : [];
            if(arr.length<=0){
                return;
            }
            var len:int = arr.length;
            var myData:Object = null;
            for(var i:int = 0; i < len; i++)
            {
                if(arr[i].uid == ModelManager.instance.modelUser.mUID){
                    myData = arr[i];
                    myData["sortIndex"] = i;
                    break;
                }
            }
            
            this.rankCom.visible = true;
            //
            if(myData){

                this.award.visible = true;
                this.award_txt.visible = true;
                //
                var myAward:Object = this.mModel.getClimbRankAward(myData.rank);
                //
                //this.award.setIcon(ModelItem.getItemIcon(myAward.show));
                this.award.setData(myAward.show,-1,-1);
                //
                this.award.off(Event.CLICK,this,this.click_myAward);
                this.award.on(Event.CLICK,this,this.click_myAward,[myAward.reward]);
                this.award.mouseEnabled = true;
                this.award.hitArea = new Rectangle(0,0,this.award.width,this.award.height);                
                //
                this.tKill.visible = true;
                this.rankCom.setRankIndex((myData.sortIndex+1));
                // this.tRank.text =(myData.sortIndex+1)+"";
                this.tKill.text = ""+myData.kill_num;
            }
            else{
                this.rankCom.setRankIndex(0,Tools.getMsgById("_public101"));//未上榜
                this.tKill.text = a[0] && a[0].kill_num ? a[0].kill_num : "0";//"0";
            }
        }      
    }   
}