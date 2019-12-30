package sg.task.view
{
    import laya.display.Sprite;
    import laya.events.Event;

    import sg.activities.view.RewardItem;
    import sg.activities.view.RewardItemPool;
    import sg.boundFor.GotoManager;
    import sg.manager.ModelManager;
    import sg.manager.ViewManager;
    import sg.task.model.ModelTaskBase;
    import sg.task.model.ModelTaskDaily;
    import sg.utils.Tools;

    import ui.task.task_baseUI;
    import laya.display.Node;

    public class TaskBase extends task_baseUI
    {
        private var modelTask:ModelTaskBase;
        public function TaskBase()
        {
            
        }

        override public function set dataSource(source:*):void {
            if (!source) return;
			this._dataSource = source;
            this.modelTask = ViewTask.model;
            
			//获取当前进度
			var currentV:int = source.value;
			var totalValue:int = source.need[0];
			
			this.taskName.text = Tools.getMsgById(source.name);
			this.taskInfo.style.fontSize = 15;
			
			var taskStr:String = this.modelTask.getHTMLByData(source);
			//taskStr = 'ABCDEFGH ' + taskStr;
			this.taskInfo.innerHTML = taskStr;
			//Tools.textFitFontSize(this.taskInfo, 325, 11, taskStr);
			
			//设置进度
			var progressValue:Number = currentV / totalValue;
			this.progressBar.value = progressValue;
			
			//获取奖励列表数据
			this.setReward(this.rewardBox, source.reward);

			//检测按钮状态
			this.btn_go.off(Event.CLICK, this, this._onClickTask);
			this.btn_reward.off(Event.CLICK, this, this._onClickTask);
			var state:int = source.taskState;
			this.btn_go.label = Tools.getMsgById(this.modelTask is ModelTaskDaily ? '_jia0032' :"_jia0033");
			this.btn_reward.label = Tools.getMsgById(state === 2 ? '_jia0034' :"_jia0035");
			this.btn_go.visible = state === 0;
			this.btn_reward.visible = state > 0;
			this.btn_reward.gray = state > 1;
			(state === 0) && this.btn_go.on(Event.CLICK, this, this._onClickTask);
			(state === 1) && this.btn_reward.on(Event.CLICK, this, this._onClickTask);
        }
        
		private function _onClickTask(event:Event):void
		{
			var item:* = this._dataSource;
			var kind:String = this.modelTask is ModelTaskDaily ? 'daily' : 'common';
			if (item.taskState === 1)
			{
				this.modelTask.getTaskReward(kind, item.task_id, item.reward);
			}
			else if (kind === 'daily')
			{
				GotoManager.boundFor(item.goto_cfg);
			}
			else {
				ViewManager.instance.showHeroTalk([['hero701', '700701', item.explain]], null);
			}
		}
        
		private function setReward(box:Sprite, reward:Object):void
		{
			box.removeChildren();
			var props:Object = ModelManager.instance.modelProp.getRewardProp(reward);
			var len:int = props.length;
			box.scale(0.82, 0.82);
			for(var i:int = 0; i < len; i++)
			{
				var source:Array=props[i];
				var rewardItem:RewardItem = RewardItemPool.borrowItem();
				rewardItem.setReward(source);
				box.addChild(rewardItem as Node);
				rewardItem.x = (rewardItem.width + 2) * (2 - i); // 向右便宜半个图标的距离
			}
		}
    }
}