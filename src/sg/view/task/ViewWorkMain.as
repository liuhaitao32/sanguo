package sg.view.task
{
    import ui.task.work_mainUI;
    import laya.events.Event;
    import laya.utils.Handler;
    import ui.task.item_workUI;
    import laya.ui.ScrollBar;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.manager.ModelManager;
    import sg.model.ModelTask;
    import sg.utils.Tools;
    import sg.cfg.ConfigServer;
    import sg.scene.view.MapCamera;
    import sg.model.ModelGame;
    import sg.model.ModelBuiding;
    import sg.model.ModelItem;
    import sg.manager.AssetsManager;
    import sg.model.ModelOfficial;
    import sg.boundFor.GotoManager;
    import sg.manager.LoadeManager;
    import sg.festival.model.ModelFestival;

    public class ViewWorkMain extends work_mainUI
    {
        private var mSelectOld:int = -1;
        private var mDsTimer:Number = 0;
        private var mHadAcpt:Boolean = false;
        public function ViewWorkMain()
        {
            this.on(Event.REMOVED,this,this.onRemove);
            //
            ModelManager.instance.modelGame.on(ModelTask.EVENT_GTASK_UPDATE,this,this.checkListData);
            //
            this.list.itemRender = item_workUI;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.selectEnable = true;
            this.list.scrollBar.hide = true;
            this.list.selectHandler = new Handler(this,this.list_select);
            //
            this.btn_add.on(Event.CLICK,this,this.click_btn,[0]);
            this.btn_del.on(Event.CLICK,this,this.click_btn,[-1]);
            this.btn_go.on(Event.CLICK,this,this.click_btn,[1]);
            this.btn_coin.on(Event.CLICK,this,this.click_btn,[2]);
            this.btn_ok.on(Event.CLICK,this,this.click_btn,[3]);
            //
            this.btn_re.on(Event.CLICK,this,this.click_ref);
            this.btn_times.on(Event.CLICK,this,this.click_times);
            this.btn_times2.on(Event.CLICK,this,this.click_times);
            this.box_had.visible = false;
            this.box_null.visible = false;
            var bh:Number = Laya.stage.height - 220;
			this.box_had.height = this.height = (bh>790)?bh:790;
            //
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("bg_17.png"));
            //
            this.btn_go.label = Tools.getMsgById("_jia0032");
            this.btn_del.label = Tools.getMsgById("_ftask_text05");
            this.btn_times2.label= Tools.getMsgById("_lht1");
            this.btn_ok.label = Tools.getMsgById("_lht2");
            this.btn_add.label = Tools.getMsgById("_lht4");
            this.btn_re.label = Tools.getMsgById("_public77");
            this.tTimesHint.text = Tools.getMsgById("_pve_text01");
            //
            this.init();
        }
        private function click_ref():void
        {
            if(ModelTask.gTask_refresh_refresh_times()<ModelTask.gTask_gtask_brush()[0]){
                this.checkGTask(1);
            }
            else{
                ViewManager.instance.showAlert(Tools.getMsgById("_gtask1"),Handler.create(this,this.refCoin),["coin",ModelTask.gTask_gtask_brush()[2]],"",false,false,"work");//是否花费元宝刷新一次
            }
        }
        private function click_times():void
        {
            if(ModelTask.gTask_self_buy_times()<ModelTask.gTask_gtask_buy().length){
                var cost:Number = ModelTask.gTask_gtask_buy()[ModelTask.gTask_self_buy_times()];
                if(!Tools.isCanBuy("coin",cost)){
                    return;
                }
                ViewManager.instance.showAlert(Tools.getMsgById("_gtask2"),Handler.create(this,this.addTimes),["coin",cost],"");//购买一次接受任务
            }
            else{
                //买不了了
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_public63"));//今日无法购买了
            }
        }
        private function addTimes(type:int):void
        {
            if(type==0){
                NetSocket.instance.send(NetMethodCfg.WS_SR_BUY_GTASK_TIMES,{},Handler.create(this,this.ws_sr_buy_gtask_times));
            }            
        }
        private function ws_sr_buy_gtask_times(re:NetPackage):void
        {
            ModelManager.instance.modelUser.updateData(re.receiveData);
            ModelManager.instance.modelGame.event(ModelGame.EVENT_TASK_RED);
            //
            this.setUI();
        }
        private function refCoin(type:int):void{
            if(type==0){
                this.checkGTask(1);
            }
        }
        private function onTimer():void
        {
            this.checkTimer();
        }
        private function onTimerSec():void{
            if(this.mDsTimer>0){
                this.tReTime.text = Tools.getTimeStyle(this.mDsTimer)+Tools.getMsgById("_shop_text02");
                this.mDsTimer-=1000;
                this.timer.clear(this,this.onTimerSec);
                this.timer.once(1000,this,this.onTimerSec);                  
            }
        }
        private function checkTimer(isFirst:Boolean = false):void{
            var rt:Number = ModelTask.gTask_refresh_time();
            var nt:Number = ConfigServer.getServerTimer();
            if(Tools.isDiffHour(nt,rt)){
                this.checkGTask();
            }
            else{
                var ds:Number = Tools.getMsNextHourMs(nt)-nt+1000;
                this.mDsTimer = ds;
                //
                this.timer.clear(this,this.onTimerSec);
                this.timer.once(1000,this,this.onTimerSec);
                this.tReTime.text = "";//
                //
                this.timer.clear(this,this.onTimer);
                this.timer.once(ds,this,this.onTimer);
                //
                if(isFirst){
                    this.checkGTask();
                }
            }
        }
        private function checkGTask(v:int = 0):void{
            this.list.visible = false;
            //
            var sn:String = NetMethodCfg.WS_SR_GET_GTASK;
            if(v>0){
                sn = NetMethodCfg.WS_SR_REFRESH_GTASK;
            }
            NetSocket.instance.send(sn,{},Handler.create(this,this.ws_sr_get_gtask));
        }
        private function ws_sr_get_gtask(re:NetPackage):void
        {
            ModelManager.instance.modelUser.updateData(re.receiveData);
            
            if (this.list) {
                this.checkTimer();
                //
                this.checkListData();
            }
        }
        private function checkListData(task_id:String = ""):void
        {
            var arr:Array = ModelTask.gTask_self_take_arr();
            this.mHadAcpt = false;
            var len:Number = arr.length;
            var sindex:Number = -1;
            for(var i:Number = 0;i < len;i++){
                if(arr[i].status!=0){
                    this.mHadAcpt = true;
                    // break;
                }
                if(arr[i].id == task_id){
                    sindex = i;
                }
            }
            //
            if(arr.length>0){
                this.list.dataSource = arr;
                this.mSelectOld = this.list.selectedIndex;
                this.list.selectedIndex = -1;
                if(task_id==""){
                    this.list.selectedIndex = this.mSelectOld<0?0:this.mSelectOld;
                }
                else{
                    this.list.selectedIndex = (sindex>-1)?sindex:0;
                }
                //
            }
            this.setUI();
        }
        override public function init():void{
            //
            this.checkTimer(true);
        }
        override public function clear():void{
            this.timer.clearAll(this);
            ModelManager.instance.modelGame.off(ModelTask.EVENT_GTASK_UPDATE,this,this.checkListData);
            this.off(Event.REMOVED,this,this.onRemove);
            //
            this.mSelectOld = -1;
            //
            if(this.list){
                this.list.destroy(true);
            }
            this.list = null;
        }
        private function list_render(item:item_workUI,index:int):void
        {
            var vis:Boolean = this.list.selectedIndex == index; 
            this.setItem(item,vis);
            item.offAll(Event.CLICK);
            
            //
            var obj:Object = this.list.array[index];
            var need:Array = ModelTask.gTask_need(obj.id);
            item.tName.text = ModelTask.gTask_name(obj.id,[obj.hasOwnProperty("city_id")?ModelOfficial.getCityName(obj.city_id):""]);
            
            //
            var score:Number = obj.rate/need[0]/ModelTask.gTask_gtask_exceed_need(obj.id);
            var meritScore:Number = score;
            meritScore = meritScore>=ConfigServer.gtask.reward_mulitmer?ConfigServer.gtask.reward_mulitmer:meritScore;
            var arr:Array = ModelTask.gTask_reward_mer(obj.id);
            //
            item.award_merit.setData(ModelBuiding.getMaterialTypeUI("merit"),arr[1]);
            item.award_other.setData(ModelItem.getItemIconAssetUI(obj.reward_key),(obj.reward_key == "gold")?arr[2]:1);
            //
            var min:Number = need[0];
            var isEnd:Boolean = obj.rate>=min;
            item.isSub.visible = (isEnd && (obj.status != 0));
            item.isGet.visible =  (!isEnd && (obj.status != 0));
            //
            item.tInfo.text = ModelTask.gTask_info(obj.id,[Tools.getMsgById(ConfigServer.city[obj.city_id]["name"]),need[0],obj.rate],obj.status);
            //
            item.on(Event.CLICK,this,this.click,[index]);
            //
            item.iTitle.text = Tools.getMsgById("_lht11");

            var fest:Array=ModelFestival.getRewardInterfaceByKey("gtask");
            item.cCom.visible=fest.length!=0;
            if(fest.length!=0)
                item.cCom.setData(fest[0],fest[1],-1);
            item.cCom.off(Event.CLICK,this,comClick);
            item.cCom.on(Event.CLICK,this,comClick,[fest[0]]);

        }

        private function comClick(key:String):void{
            ViewManager.instance.showItemTips(key);
        }

        private function list_select(index:int):void
        {
            if(index>-1){
                this.checkBtns(index);
            }
        }
        private function setItem(item:item_workUI,vis:Boolean):void{
            item.mSelect.visible = vis;
        }
        private function checkBtns(index:int):void{
            this.list.visible = true;
            //
            var obj:Object = this.list.array[index];

            this.btn_add.visible = (obj.status == 0);//可以接受
            //
            var re:Array = ModelTask.gTask_need(obj.id);
            var min:Number = re[0];
            var max:Number = re[1];
            var isEnd:Boolean = obj.rate>=min;
            //
            this.mBox_ok.visible = (!this.btn_add.visible && isEnd);//完成
            this.mBox_get.visible = (!this.btn_add.visible && !isEnd);
            //
            this.tInfo.text = ModelTask.gTask_get_talk();
            //
            // if(this.mBox_ok.visible){
            //     this.tInfo.text = Tools.getMsgById("gtask_talk03");
            // }
            // else{
            //     var timesNum:Number = ModelTask.gTask_self_task_times();
            //     var timesMax:Number = (ModelTask.gTask_gtask_intial_num_max()+ModelTask.gTask_self_buy_times());   
            //     //
            //     if(timesNum<=0){
            //         this.tInfo.text = Tools.getMsgById("gtask_talk02");
            //     }
            //     else{
            //         this.tInfo.text = Tools.getMsgById("gtask_talk03");
            //     }   
            // }     

        }
        private function click(index:int,exceed:Boolean):void
        {
            if(this.list.selectedIndex != index){
                if(this.list.selection){
                    this.setItem(this.list.selection as item_workUI,false);
                }
                this.list.selectedIndex = index;
            }
        }
        private function setUI():void
        {
            var timesNum:Number = ModelTask.gTask_self_task_times();
            var timesBuy:Number = ModelTask.gTask_self_buy_times();
            var timesDef:Number = ModelTask.gTask_gtask_intial_num_max();
            var timesMax:Number = (timesDef+timesBuy);
            this.tTimes.text = timesNum+" / "+timesMax;//"今日可用次数:"+
            var rt:Number = (ModelTask.gTask_gtask_brush()[0]-ModelTask.gTask_refresh_refresh_times());
            this.btn_re.label = rt>0?Tools.getMsgById("_public235",[rt,ModelTask.gTask_gtask_brush()[0]]):Tools.getMsgById("_public78");//免费刷新:刷新
            this.heroIcon.setHeroIcon(ConfigServer.gtask.gtask_herotalk || "hero747");
            //
            this.box_null.visible = (timesNum==0 && !this.mHadAcpt);
            this.box_had.visible = !this.box_null.visible;
            this.btn_coin.setNum(ModelTask.gTask_gtask_get_mon());
            this.btn_coin.textlabel.text = Tools.getMsgById("_lht58");
            //
            if(this.box_null.visible){
                this.tTalk.text = ModelTask.gTask_get_talk();//Tools.getMsgById("gtask_talk02");
                this.heroIcon2.setHeroIcon(ConfigServer.gtask.gtask_herotalk || "hero747");
            }
        }
        private function click_btn(type:int):void
        {
            var obj:Object = this.list.array[this.list.selectedIndex];
            switch(type)
            {
                case -1://放弃
                    ViewManager.instance.showAlert(Tools.getMsgById("gtask_ui_acc04"),Handler.create(this,this.getOffTask,[obj]),null);
                    break;
                case 0://接受
                    NetSocket.instance.send(NetMethodCfg.WS_SR_RECEIVE_GTASK,{task_id:obj.id},Handler.create(this,this.get_or_del_gtask),0);
                    break;  
                case 1://前往
                    if(ModelTask.gTask_type(obj.id) == ModelTask.GTASK_TYPE_GTASK_COLLECT){
                        GotoManager.boundFor({type:1,cityID:obj.city_id});
                        MapCamera.lookAtGtask(obj.city_id);
                        // ViewManager.instance.closeView(true);
                    }
                    else{
                        GotoManager.boundFor({type:1,cityID:obj.city_id,state:1});
                    }
                    break;  
                case 2://打赏
                    if(ModelTask.gTask_exceed(obj)){
                        ViewManager.instance.showTipsTxt(Tools.getMsgById("gtask_hint03"));
                    }
                    else{
                        this.task_end_get_award(obj,1);
                    }
                    break; 
                case 3://领奖
                    this.task_end_get_award(obj,0);
                    break;                                                                       
                default:
                    break;
            }
        }
        private function getOffTask(obj:Object,type:int):void
        {
            if(type==0){
                // var obj:Object = this.list.array[this.list.selectedIndex];
                NetSocket.instance.send(NetMethodCfg.WS_SR_DROP_GTASK,{task_id:obj.id},Handler.create(this,this.get_or_del_gtask),-1);
            }
        }
        private function task_end_get_award(obj:Object,type:int):void{
            //领取任务开始
            if(type == 1){
                ViewManager.instance.showAlert(Tools.getMsgById("_gtask3"),Handler.create(this,this.task_coin),["coin",ModelTask.gTask_gtask_get_mon()],Tools.getMsgById("_gtask4"));//立刻获取全额奖励:额外提升政务评定分数
            }
            else{
                NetSocket.instance.send(NetMethodCfg.WS_SR_GET_GTASK_REWARD,{task_id:obj.id,cost:0},Handler.create(this,this.ws_sr_get_gtask_reward),obj);
            }
        }
        private function task_coin(btn:int):void{
            if(btn==0){
                var obj:Object = this.list.array[this.list.selectedIndex];
                NetSocket.instance.send(NetMethodCfg.WS_SR_GET_GTASK_REWARD,{task_id:obj.id,cost:1},Handler.create(this,this.ws_sr_get_gtask_reward),obj);
            }
        }
        private function ws_sr_get_gtask_reward(re:NetPackage):void
        {            
            var task_id:String = re.sendData.task_id;
            var cid:String = ModelTask.gTask_self_task_city(task_id);
            var param:Object = this.getMapData(re,true);
            //
            
            ViewManager.instance.showView(ConfigClass.VIEW_WORK_ASSESS,[re.otherData,re.sendData.cost,re.receiveData]);
            //
            this.checkListData();
            //
            if(param){
                ModelManager.instance.modelGame.event(ModelGame.EVENT_TASK_WORK_CHANGE,param);
            }   
            ModelManager.instance.modelGame.event(ModelGame.EVENT_TASK_WORK_GET_OR_DEL, cid);
            ModelManager.instance.modelGame.event(ModelGame.EVENT_TASK_RED);
        }        
        private function get_or_del_gtask(re:NetPackage):void
        {
            var task_id:String = re.sendData.task_id;
            var cid:String = ModelTask.gTask_self_task_city(task_id);
            var param:Object = this.getMapData(re);
            var type:int = re.otherData;
            ModelManager.instance.modelUser.updateData(re.receiveData);
            //
            this.checkListData(task_id);
            //
            if(param){
                ModelManager.instance.modelGame.event(ModelGame.EVENT_TASK_WORK_CHANGE,param);
            }
            ModelManager.instance.modelGame.event(ModelGame.EVENT_TASK_WORK_GET_OR_DEL, cid); 
            ModelManager.instance.modelGame.event(ModelGame.EVENT_TASK_RED);
        }
        private function getMapData(re:NetPackage,dele:Boolean = false):Object
        {
            var task_id:String = re.sendData.task_id;
            var taskType:String = ModelTask.gTask_type(task_id);
            var type:int = re.otherData;
            
            var obj:Object = ModelTask.gTask_self_take()[task_id];
            var param:Object = null;
            if(taskType == ModelTask.GTASK_TYPE_GTASK_COLLECT){
                var cids:* = obj.city_id;
                var str:* = obj.bot_hero.hid;
                if(type>-1 && !dele){
                    param = {cid:cids,icon:ModelItem.getItemIconAssetUI(obj.reward_key),id:task_id};
                }
                else{
                    param = {cid:cids,id:task_id};
                }
            }  
            return param;          
        }
    }
}