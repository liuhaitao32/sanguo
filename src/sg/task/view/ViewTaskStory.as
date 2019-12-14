package sg.task.view 
{
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.html.dom.HTMLDivElement;
	import laya.ui.Image;
	import laya.ui.Label;
	import sg.guide.model.ModelGuide;
	import sg.guide.view.GuideArrow;
	import sg.manager.EffectManager;
	import sg.task.TaskHelper;
	import laya.maths.Point;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	/**
	 * ...
	 * @author jiaxuyang
	 */
	public class ViewTaskStory 
	{
		private var title:Label;
		private var panel:Sprite;
		private var btn_reward:Image;
		private var btn_hintReward:Image;
		private var content:HTMLDivElement;
		private var aniExp:Animation;
		private var panel1:Sprite;
		private var panel2:Sprite;
		private var arrow:GuideArrow = new GuideArrow();

		public function ViewTaskStory(title:Label, panel:Sprite, btn_reward:Image, btn_hintReward:Image, content:HTMLDivElement) 
		{
			this.title = title;
			this.panel = panel;
			this.btn_reward = btn_reward;
			this.btn_hintReward = btn_hintReward;
			this.content = content;

			// 添加流光特效
			this.aniExp = EffectManager.loadAnimation("glow037");
			var titlePanel:Sprite = this.panel1 = title.parent.getChildByName('titlePanel') as Sprite;
			this.panel2 = title.parent.getChildByName('titlePanel2') as Sprite;
            this.aniExp.x = (panel.width - titlePanel.width) * 0.5;
            this.aniExp.y = panel.height * 0.5;
			this.aniExp.visible = false;
            panel.addChild(this.aniExp);
			this._initMainTaskView();
			panel.parent.parent.addChild(arrow);

			arrow['_reset'] = false;
			arrow.rotation = 90;
			Laya.stage.on(Event.MOUSE_DOWN,this,this.click_stage_down);
			this.click_stage_down();
		}

		private function click_stage_down():void
		{
			var lv:Number = ConfigServer.system_simple['storyHintLv'];
			if (ModelManager.instance.modelUser.getLv() >= lv) {
				arrow.hide();
				return;
			}

			// 添加倒计时
			arrow.hide();
			Laya.timer.clear(this, this._showArrow);
			var duration:Number = ConfigServer.system_simple['storyHintTime'];
			Laya.timer.once(duration * 1000, this, this._showArrow);
		}

		/**
		 * 提示点击剧情面板
		 */
		private function _showArrow():void
		{
			if (ModelGuide.forceGuide()) return; // 检测是不是强制引导
			if (ViewManager.instance.getCurrentScene()) return;
			if (arrow.visible) return;
			var pos:Point = Point.TEMP.setTo(panel.x + panel.width * 0.5, panel.y);
			pos = panel.parent['localToGlobal'](pos, true);
			pos = arrow.parent['globalToLocal'](pos);
			arrow.pos(pos.x, pos.y - 80);
			arrow.show(pos.x, pos.y, 90);
		}
		
		/**
		 * 初始化主线任务界面
		 */
		private function _initMainTaskView():void {
			this.title.text = "";
			this.content.style.fontSize = 16;
			this.btn_reward.visible = false;
			this.panel.on(Event.CLICK, this, this._onClickPanel);
			this.btn_hintReward.on(Event.CLICK, this, this.hintReward);
			TaskHelper.instance.on(TaskHelper.REFRESH_MAIN_TASK_VIEW, this, this.refreshMainTaskView);
			TaskHelper.instance.refreshMainTask();
		}
		
		/**
		 * 刷新主线任务界面
		 * @param	taskType
		 * @param	content
		 * @param	hintGet
		 */
		private function refreshMainTaskView(taskType:String, content:String, hintGet:Boolean = false):void {
			this.title.text = taskType;
			this.content.innerHTML = content;
			this.btn_reward.visible = hintGet;
			this.btn_hintReward.visible = !hintGet;
			this.aniExp.visible = hintGet;
			this.panel1.visible = this.panel2.visible = !this.aniExp.visible;
		}
		
		/**
		 * 点击剧情面板
		 */
		private function _onClickPanel():void {
			TaskHelper.instance.onClickStory();
		}
		
		/**
		 * 点击提示奖励
		 */
		private function hintReward():void {
			TaskHelper.instance.hintReward();
		}
		
	}

}