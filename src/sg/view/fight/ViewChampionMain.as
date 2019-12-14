package sg.view.fight
{
    import laya.events.Event;
    import laya.ui.Box;
    import laya.ui.Button;
    import laya.utils.Handler;

    import sg.cfg.ConfigClass;
    import sg.manager.ModelManager;
    import sg.manager.ViewManager;

    import ui.fight.championMainUI;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.utils.Tools;
    import sg.cfg.ConfigServer;
    import sg.model.ModelHero;
    import sg.model.ModelClimb;
    import laya.ui.Image;
    import sg.utils.StringUtil;
    import sg.boundFor.GotoManager;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;
    import sg.model.ModelGame;

    public class ViewChampionMain extends championMainUI{
        private var mView:Box;
        private var mSelectIndex:int;
        private var mGroupData:Object;
        private var mMyGroupIndex:int;
        private var mStatus:int = -1;
        private var mSeasonNum:Number;
        public function ViewChampionMain(){
            // this.tab.labels = "比武商店,比武奖励,比武押注,比武布阵";
            // this.tab.selectHandler = new Handler(this,this.tab_render);
            this.listFun.renderHandler = new Handler(this,this.tab_render);
            this.listFun.selectEnable = true;
            this.listFun.selectHandler = new Handler(this,this.tab_select);
            
            //
            this.list.renderHandler = new Handler(this,this.list_render);
            // this.list.selectHandler = new Handler(this,this.list_select);
            this.list.selectEnable = true;
            //
            this.list.dataSource = [
                {label:Tools.getMsgById("_climb26")},
                {label:Tools.getMsgById("_climb27")},
                {label:Tools.getMsgById("_climb28")},
                {label:Tools.getMsgById("_climb29")},
                {label:Tools.getMsgById("_climb30")},
                {label:Tools.getMsgById("_climb31")},
                {label:Tools.getMsgById("_climb32")},
                {label:Tools.getMsgById("_climb33")}
            ];
            this.btn_name.on(Event.CLICK,this,this.click_name);
            //
            this.btnInfo.on(Event.CLICK,this,this.click_info8);
            //
            this.btnHelp.on(Event.CLICK,this,this.click_help);
        }
        private function click_help():void
        {
            ViewManager.instance.showTipsPanel(Tools.getMsgById(ConfigServer.pk_yard.pk_info),500);
        }
        override public function initData():void{
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("bg_19.png"));
            this.setTitle(Tools.getMsgById("add_pk_yard"));
            // 是否开始比赛
            this.mSelectIndex = -1;
            this.mMyGroupIndex = -1;
            //
            this.mSeasonNum = ModelClimb.getChampionHowSeason();
            //
            this.tTitle.text = Tools.getMsgById("_climb34", [StringUtil.numberToChinese(this.mSeasonNum)]);
			this.btnInfo.label = Tools.getMsgById("_climb55");
            //
            this.mTips.visible = false;     
            this.btnInfo.visible = false;
            //
            var now:Number = ConfigServer.getServerTimer();
            if(ModelClimb.isChampionStartSeason()){//是开赛赛季
                if(this.checkTime()){
                    var arr:Array = ModelClimb.checkChampionTimetableByIndex(7);
                    //根据时间判断进入第几轮了
                    if(arr[0]<0){//有可能结束了
                        this.mStatus = 1;//结束了
                        this.click(7);
                    }
                    else{
                        this.mStatus = 0;//进行中
                        this.click(arr[0]);
                    }                    
                }
                else{
                    this.mStatus = -1;//没开始
                    this.click(0);
                }
            }
            else{
                this.mStatus = 2;//结束了
                this.click(7);//进入膜拜期
            }
            //
            this.timeGo();
        }
        private function timeGo():void
        {
            this.listFun.dataSource = [Tools.getMsgById("tournament_shop"),Tools.getMsgById("_climb23"),Tools.getMsgById("_climb24"),Tools.getMsgById("_climb25")];
            this.checkTime();
            //
            this.timer.once(1000,this,this.timeGo);            
        }
        private function checkTime():Boolean
        {
            var nextDate:Date;
            var nextms:Number;
            var now:Number = ConfigServer.getServerTimer();
            if(ModelClimb.isChampionStartSeason()){//是开赛赛季
                var startms:Number = ModelClimb.getChampionStartTimer();
                var des:Number = ModelClimb.getChampionIngTime();
                var endms:Number =(startms+ModelClimb.getChampionUseTimer()-now);
                nextDate = ModelClimb.getChampionStarTime(true,ConfigServer.pk_yard.begin_time[0]);
                nextms = ModelClimb.getChampionStartTimer(nextDate.getTime());
                this.tSession.text = (des<0)?Tools.getMsgById("_climb35"):((endms>0)?Tools.getMsgById("_climb36"):Tools.getMsgById("_climb37"));//"本届开启倒计时":((endms>0)?"距离结束":"距离下届");
                this.tSessionTime.text = (des<0)?Tools.getTimeStyle(Math.abs(des),4):((endms>0)?Tools.getTimeStyle(endms):Tools.getTimeStyle(nextms-now,4));   
                //
            }
            else{
                nextDate = ModelClimb.getChampionStarTime(false,ConfigServer.pk_yard.begin_time[0]);
                nextms = ModelClimb.getChampionStartTimer(nextDate.getTime());
                this.tSession.text = Tools.getMsgById("_climb37");
                this.tSessionTime.text = Tools.getTimeStyle(nextms-now);
            }
            return now>=startms;
        }
        override public function onAdded():void{
            ModelManager.instance.modelClimb.on(ModelClimb.EVENT_CHAMPION_SIGN_OK,this,this.event_champion_sign_ok);
        }
        private function event_champion_sign_ok():void{
            this.btn_name.disabled = true;
            this.btn_name.label = Tools.getMsgById("_climb13");//"已报名";
        }
        override public function onRemoved():void{
            ModelManager.instance.modelClimb.off(ModelClimb.EVENT_CHAMPION_SIGN_OK,this,this.event_champion_sign_ok);
            this.timer.clear(this,this.timeGo);
            this.clearView();
            this.mSelectIndex = -1;
            this.mMyGroupIndex = -1;
            this.mStatus = -1;
        }
        private function list_render(item:Button,index:int):void{
            //WS_SR_GET_PK_YARD_LOG
            (item.getChildByName("imgSelect") as Image).visible = (this.list.selectedIndex == index);
            item.off(Event.CLICK,this,this.click);
            item.on(Event.CLICK,this,this.click,[index]);
        } 
        private function tab_render(item:Button,index:int):void{
            item.label = this.listFun.array[index];
            if(index==2){
                ModelGame.redCheckOnce(item,ModelClimb.isChampionBet());
            }
        }
        private function tab_select(index:int):void
        {
            if(index>-1){
                this.click_func(index);
            }            
        }

        private function click_func(index:int):void{
            if(index == 1){
                ViewManager.instance.showView(ConfigClass.VIEW_CHAMPION_RANK);
            }
            else if(index == 2){
                this.sendServer(1,6);
            }
            else if(index == 3){
                ModelManager.instance.modelClimb.send_WS_SR_GET_MY_PK_YARD_HIDS(Handler.create(this,this.ws_sr_get_my_pk_yard_hids));
            }
            else{
                GotoManager.boundForPanel(GotoManager.VIEW_SHOP,"tournament_shop",null,{child:true});
            }
            this.listFun.selectedIndex = -1;
        }        
        private function ws_sr_get_my_pk_yard_hids(re:NetPackage):void{
            //
            ViewManager.instance.showView(ConfigClass.VIEW_CHAMPION_HERO_EDIT,re.receiveData);
        }
        private function sendServer(func:int,index:int):void{
            if(this.mSelectIndex == index && func!=1){
                return;
            }            
            //
            var rn:int = index+1;
            rn = (rn>7)?7:rn;
            NetSocket.instance.send(NetMethodCfg.WS_SR_GET_PK_YARD_LOG,{ym:rn,tn:-1},Handler.create(this,this.ws_sr_get_pk_yard_log),[func,index]);
        }
        private function click(index:int):void{
            if(this.mSeasonNum==1 && index!=7 && !ModelClimb.isChampionStartSeason()){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_climb42",[Tools.getMsgById("lvup07_1_name")]));
                return;
            }
			if(index<6){
				this.btnInfo.visible = false;
			}
            this.list.selectedIndex = index;
            this.sendServer(0,index);//正常查询,每轮
        }
        private function ws_sr_get_pk_yard_gamble(re:NetPackage):void{
            if(this.mGroupData){
                ViewManager.instance.showView(ConfigClass.VIEW_CHAMPION_BET,[this.mGroupData,re.receiveData]);
            }
            else{
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_climb38"));//"无法押注,只能在八强期准备期押注"
            }
        }
        private function ws_sr_get_pk_yard_log(re:NetPackage):void{
            //
            var func:int = re.otherData[0];
            var index:int = re.otherData[1];
            //
            if(func!=1){
                this.mSelectIndex = index;
            }
            //
            this.mGroupData = re.receiveData;
            //
            if(func == 1){//押注功能,下面跳过
                var betB:Boolean = false;
                if(this.mGroupData){
                    // var fa:Array = this.mGroupData.log_list;
                    // var flg:int = this.mGroupData.if_log;
                    // if(flg<=0)// || (flg>0 && fa.length<12))
                    // {
                    if(ModelClimb.isChampionIng()){//是开赛赛季
                        betB = true;
                    }
                    // }
                }
                if(betB){
                    
                    NetSocket.instance.send(NetMethodCfg.WS_SR_GET_PK_YARD_GAMBLE,{},Handler.create(this,this.ws_sr_get_pk_yard_gamble));
                }
                else{
                    ViewManager.instance.showTipsTxt(Tools.getMsgById("_climb38"));//无法押注,只能在八强期准备期押注
                }
                return;
            }
            //查看
            if(this.mGroupData){
                this.mMyGroupIndex = this.mGroupData.tn;   
            }
            else{
                this.mMyGroupIndex = -1;
            }
            this.setUI(index);//轮次
        }
        private function setUI(index:Number):void{
            //
            this.mTips.visible = false;
            this.mPanel.visible = false;
            this.clearView();
            //
            if(this.mMyGroupIndex<0 && index<6){//没有数据
                this.setUIready(index);
                return;
            }
            if(index>=6 && !this.mGroupData){
                this.setUIready(index);
                return;    
            }
            if(index>6 && this.mGroupData && this.mGroupData.if_log <1){
                this.setUIready(index);
                return;    
            }
            if(index>6 && this.mGroupData.log_list.length<12 && this.mGroupData.if_log>0){
                this.setUIready(index);
                return; 
            }
            //有数据的处理
            if(index == 7){//报名
                this.mView = new ChampionWorship(this.mGroupData);
            }
            else if(index == 6){//八强
                this.mView = new ChampionMatchB(this.mGroupData);
            }
            else{//轮次
                this.mView = new ChampionMatchA(index,this.mGroupData,this.mMyGroupIndex);
            }
            if (index >= 6){
				//this.btnInfo.visible = true;
                this.btnInfo.visible = !ModelClimb.isChampionIng();
            }
            this.mPanel.visible = true;
            this.mPanel.addChild(this.mView);
        }
        private function click_info8():void
        {
            ViewManager.instance.showView(ConfigClass.VIEW_CHAMPION_MATCH_INFO8,[this.mGroupData]);
        }
        private function clearView():void{
            if(this.mView){
                this.mView.destroyChildren();
                this.mView.destroy(true);
                this.mView = null;
            }
            this.mPanel.destroyChildren();
        }
        /**
         * 比武大会没有数据状态
         */
        private function setUIready(index:Number):void{
            this.mTips.visible = true;
            //
            ModelManager.instance.modelClimb.send_WS_SR_GET_MY_PK_YARD_HIDS(null,this.btn_name);
            if(this.mStatus>0 && ModelClimb.isChampionStartSeason()){
                this.mStatus = 0;
            }
            if(this.mStatus == 0){
                if(index==6){
                    this.tInfo.text = Tools.getMsgById("_climb39");//八强赛选拔准备中
                }
                else if(index==7){
                    this.tInfo.text = Tools.getMsgById("_climb40");//决赛选拔准备中
                }
                else{
                    this.tInfo.text = Tools.getMsgById("_climb41",[this.list.dataSource[index].label]);
                    // this.list.dataSource[index].label+"轮比赛准备中";//轮比赛准备中
                }
            }
            else if(this.mStatus == -1){
                this.tInfo.text = Tools.getMsgById("_climb42",[this.list.dataSource[index].label]);
                // this.list.dataSource[index].label+"即将开始";
            }
            else if(this.mStatus>0){
                this.tInfo.text = Tools.getMsgById("_climb43");//"新比武大会报名中";
            }
        }
        private function click_name():void{
            var arr:Array = ModelClimb.getChampionHeroRecommend(ModelClimb.getChampionHeroNum());
            //
            var len:int = arr.length;
            var hmd:ModelHero;
            var sArr:Array = [];
            for(var i:int = 0; i < len; i++)
            {
                hmd = arr[i];
                sArr.push(hmd.id);
            }
            ModelManager.instance.modelClimb.send_WS_SR_JOIN_PK_YARD(sArr,Handler.create(this,this.ws_sr_join_pk_yard));
        }
        private function ws_sr_join_pk_yard(re:NetPackage):void{
            ViewManager.instance.showTipsTxt(Tools.getMsgById("_climb12"));
            this.event_champion_sign_ok();
        }
    }   
}