package sg.view.task
{
    import ui.task.work_assessUI;
    import laya.events.Event;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.manager.ModelManager;
    import sg.model.ModelTask;
    import sg.utils.Tools;
    import sg.model.ModelBuiding;
    import sg.cfg.ConfigServer;
    import ui.bag.bagItemUI;
    import sg.model.ModelItem;
    import sg.manager.EffectManager;
    import sg.cfg.ConfigColor;
    import laya.utils.Tween;
    import laya.ui.Button;
    import sg.manager.AssetsManager;
    import sg.manager.LoadeManager;
    import sg.model.ModelGame;
    import sg.manager.ViewManager;
    import laya.maths.Point;
    import laya.utils.Ease;
    import sg.festival.model.ModelFestival;

    public class ViewWorkAssess extends work_assessUI
    {
        private var mTask:Object;
        private var isCost:Boolean;
        private var barClip:Boolean =false;
        public function ViewWorkAssess()
        {
            this.onlyCloseByBtn(true);
            this.btn.on(Event.CLICK,this,this.click);
            //
            this.list.itemRender = bagItemUI;
            this.list.renderHandler = new Handler(this,this.list_render);  
            this.list.scrollBar.hide = true;         
            //
            this.btn.label = Tools.getMsgById("_lht10");
        }
        override public function initData():void{
            this.isAutoClose = false;
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("bg_17.png"));
            //this.tTitle.text = Tools.getMsgById("_gtask5");//政务评定
            this.comTitle.setViewTitle(Tools.getMsgById("_gtask5"));
            
            (this.panelBg.getChildByName("btn_close") as Button).visible = false;
            this.heroIcon.setHeroIcon("hero747");
            //
            this.mTask = this.currArg[0];
            this.isCost = (this.currArg[1] ==1);
            //
            var re:Array = ModelTask.gTask_need(this.mTask.id);
            var max:Number = this.isCost?re[1]:this.mTask.rate;
            var score:Number = this.isCost?1:(max/re[0]/ModelTask.gTask_gtask_exceed_need(this.mTask.id));
            //
            this.bar.value = 0;//score;
            this.bar2.value = 0;//(score>=1)?(score-1):0;
            //
            if(score>=0){
                Tween.to(this.bar2,{value:this.isCost?1:score},1000,null,null,2000);
            }
            // trace(score,score2,ct);
            
            Tween.to(this.bar,{value:max/re[0]},1000,null,Handler.create(this,this.clip1),1000);
            // 领取任务结束
            var sArray:Array = ModelTask.gTask_reward_mulit(score);
            var scoreAward:Array = sArray[0];
            var sIndex:int = sArray[1];
            //
            this.s0.alpha = 0;
            this.s1.alpha = 0;
            this.tName.alpha = 0;
            //
            this.barClip = true;
            // this.timer.clear(this,this.frameLoopFun);
            // this.timer.frameLoop(2,this,this.frameLoopFun,[score]);
            //
            EffectManager.changeSprColor(this.s0,sIndex);
            EffectManager.changeSprColor(this.s1,sIndex);
            EffectManager.changeSprColor(this.bar,0);
            EffectManager.changeSprColor(this.bar2,4);
            
            //
            this.tName.color = ConfigColor.FONT_COLORS[sIndex];
            this.tName.text = Tools.getMsgById(scoreAward[1]);
            //
            var arr:Array = ModelTask.gTask_reward_mer(this.mTask.id);
            //
            var meritScore:Number = score;
            meritScore = meritScore>=ConfigServer.gtask.reward_mulitmer?ConfigServer.gtask.reward_mulitmer:meritScore;
            this.award.setData(ModelBuiding.getMaterialTypeUI("merit"),arr[1]+"");
            this.tAdd.text = "+"+Math.ceil(arr[1]*meritScore);
            //奖励展示
            var listArr:Array = [];
            var goldIndex:Number = 2;
            var goldBase:Number = arr[2];
            if(this.mTask.reward_key == "gold"){
                listArr.push([this.mTask.reward_key,goldBase]);
                //
                goldIndex = 2;
            }
            else{
                listArr.push([this.mTask.reward_key,1]);
                //
                goldIndex = 3;
            }
            var otherArr:Array = ModelTask.gTask_reward_mulit_arr(score);
            var len:int = otherArr.length;
            var ra:Number = 0;
            for(var i:int = 0; i < len; i++)
            {
                ra = otherArr[i][goldIndex];
                if(ra>0){
                    listArr.push(["gold",Math.ceil(goldBase*ra)]);
                }
                
            }
            var fest:Array=ModelFestival.getRewardInterfaceByKey("gtask");
            if(fest.length!=0)
                listArr.unshift([fest[0],fest[1]]);

            this.list.dataSource = listArr;
            //说话
            this.tInfo.text = ModelTask.gTask_get_talk2();//Tools.getMsgById("gtask_ui_acc05");
            //更新数据
            ModelManager.instance.modelUser.updateData(this.currArg[2]);
        }
        private function list_render(item:bagItemUI,index:int):void
        {
            var data:Array = this.list.array[index];
            //
            item.scale(0.8,0.8);
            //item.setIcon(ModelItem.getItemIcon(data[0]));
            //item.setNum(data[1]);
            item.setData(data[0],data[1]);
            item.setName("");
        }
        private function click():void
        {
            this.closeSelf();
        }
        override public function onRemoved():void{
            this.isAutoClose = true;
            //
            this.barClip = false;
            //
            Tween.clearTween(this.s0);
            Tween.clearTween(this.s1);
            Tween.clearTween(this.tName);
            Tween.clearTween(this.bar);
            Tween.clearTween(this.bar2);
            //
            ModelManager.instance.modelGame.event(ModelTask.EVENT_GTASK_UPDATE);
            //
            var poi:Point = this.btn.localToGlobal(new Point(0,0));
            ViewManager.instance.showIcon(this.currArg[2].gift_dict,poi.x,poi.y);
        }
        private function clip1():void{
            var _this:* = this;
            this.barClip = false;
            var x0:Number = this.s0.x;
            var x1:Number = this.s1.x;
            this.s0.x += 150;
            this.s1.x -= 150;
            this.s0.alpha = 0;
            this.s1.alpha = 0;
            this.tName.alpha = 0;
            Tween.to(s0,{alpha:1,x:x0},300, Ease.circIn);
            Tween.to(s1,{alpha:1,x:x1},300, Ease.circIn);
            Tween.to(this.tName,{alpha:1},300,null,Handler.create(this,function():void{
                //_this.tTitle.text = Tools.getMsgById("_gtask6");//政务完成
                _this.comTitle.setViewTitle(Tools.getMsgById("_gtask6"));
                // _this.tInfo.text = Tools.getMsgById(this.isCost?"gtask_talk01":"gtask_talk11");
                this.isAutoClose = true;
            }),400);
        }
    }
}