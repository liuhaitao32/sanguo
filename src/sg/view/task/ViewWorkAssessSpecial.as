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
    import sg.utils.ArrayUtil;

    public class ViewWorkAssessSpecial extends work_assessUI
    {
        protected var times:int = 0;
        protected var reward:Object = null;
        public function ViewWorkAssessSpecial()
        {
            this.onlyCloseByBtn(true);
            this.list.itemRender = bagItemUI;
            this.list.renderHandler = new Handler(this,this.list_render);  
            this.list.scrollBar.hide = true;
            this.btn.label = Tools.getMsgById("_lht10");
        }
        override public function initData():void{
            this.isAutoClose = false;
            LoadeManager.loadTemp(this.adImg,AssetsManager.getAssetsUI("bg_17.png"));
            //this.tTitle.text = Tools.getMsgById("_gtask5");//政务评定
            this.comTitle.setViewTitle(Tools.getMsgById("_gtask5"));

            (this.panelBg.getChildByName("btn_close") as Button).visible = false;
            this.heroIcon.setHeroIcon("hero747");
            this.bar.value = this.bar2.value = 0;
            this.s0.alpha = this.s1.alpha = this.tName.alpha = 0;
            this.tInfo.text = Tools.getMsgById("gtask_ui_acc05"); // 说话
            reward = {};
            this._initPanel(this.currArg);
        }
        
        /**
         * 设置奖励 奖励展示
         */
        protected function _initPanel(dataArr:Array):void {
            var gift_dict:Object = dataArr[0];
            var num_list:Object = dataArr[1];
            for(var key:String in gift_dict)
            {
                reward[key] = Math.floor(parseInt(gift_dict[key]) / 3);
            }
            
			var buy_gtask:Object = ConfigServer.ploy['buy_gtask'];
            var mulit:Array = buy_gtask['mulit'];
            times = mulit[1];
            var index:int = ArrayUtil.findIndex(ConfigServer.gtask.reward_mulit, function(array:Array):Boolean{return array[0] === mulit[0];});
            this.setName(ConfigServer.gtask.reward_mulit[index][1]);
            this.setColor(index);
            var merit:int = num_list[1];
            var meritExtra:int = Math.floor(parseInt(gift_dict['merit']) / times - merit);
            this.setMerit(merit, meritExtra);
            this.bar.value = this.bar2.value = 1;
            this.clip1();
            var arr:Array = [[buy_gtask['reward_key'], 1]];
            var sum:int = 0;
            for(var i:int = 4; i < num_list.length - 1; i++)
            {
                var value:int = num_list[0] * num_list[i];
                arr.push(['gold', value]);
                sum += value;
            }
            arr.push(['gold', Math.floor(parseInt(gift_dict['gold']) / times - sum)]);
            this.list.dataSource = arr;
            this.btn.on(Event.CLICK,this,this._onClickReward);
        }

        /**
         * 设置政务评级名称 马马虎虎、居功至伟等
         */
        protected function setName(nameId:String):void {
            
            this.tName.text = Tools.getMsgById(nameId);
        }

        /**
         * 设置颜色
         */
        protected function setColor(index:int):void {
            
            EffectManager.changeSprColor(this.s0,index);
            EffectManager.changeSprColor(this.s1,index);
            EffectManager.changeSprColor(this.bar,0);
            EffectManager.changeSprColor(this.bar2,4);
            this.tName.color = ConfigColor.FONT_COLORS[index];
        }

        /**
         * 设置功勋以及额外功勋
         */
        protected function setMerit(merit:int, meritExtra:int):void {
            this.award.setData(ModelBuiding.getMaterialTypeUI("merit"), merit);
            this.tAdd.text = "+" + meritExtra;
        }

        private function list_render(item:bagItemUI,index:int):void
        {
            var data:Array = this.list.array[index];
            item.scale(0.8,0.8);
            item.setData(data[0],data[1]);
            item.setName("");
        }

        private function clip1():void{
            var x0:Number = this.s0.x;
            var x1:Number = this.s1.x;
            this.s0.x+=50;
            this.s1.x-=50
            this.s0.alpha = 0;
            this.s1.alpha = 0;
            this.tName.alpha = 0;
            Tween.to(this.s0,{alpha:1,x:x0},300);
            Tween.to(this.s1,{alpha:1,x:x1},400);
            Tween.to(this.tName,{alpha:1},300,null,Handler.create(this, this.setFinishedText, ['gtask_talk11']),400);
        }

        /**
         * 提示文本
         */
        protected function setFinishedText(str:String):void
        {
            //this.tTitle.text = Tools.getMsgById("_gtask6");//政务完成
            this.comTitle.setViewTitle(Tools.getMsgById("_gtask6"));
            
            this.tInfo.text = Tools.getMsgById(str);
            this.isAutoClose = true;
        }

        private function _onClickReward():void
        {
            var poi:Point = this.btn.localToGlobal(new Point(0,0));
            ViewManager.instance.showIcon(reward, poi.x, poi.y);
            times--;
            if (times <= 0) {
                this.closeSelf();
            }
            else {
                this.s0.alpha = this.s1.alpha = this.tName.alpha = 0;
                this.clip1();
            }
        }

        override public function onRemoved():void{
            Tween.clearTween(this.s0);
            Tween.clearTween(this.s1);
            Tween.clearTween(this.tName);
            Tween.clearTween(this.bar);
            Tween.clearTween(this.bar2);
        }
    }
}