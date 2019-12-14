package sg.task
{
	import laya.events.EventDispatcher;
	import laya.utils.Handler;

	import sg.boundFor.GotoManager;
	import sg.cfg.ConfigServer;
	import sg.guide.model.ModelGuide;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.model.ModelGame;
	import sg.model.ModelTask;
	import sg.model.ModelUser;
	import sg.net.NetMethodCfg;
	import sg.net.NetPackage;
	import sg.net.NetSocket;
	import sg.task.model.ModelTaskBase;
	import sg.task.model.ModelTaskBuild;
	import sg.task.model.ModelTaskCountry;
	import sg.task.model.ModelTaskDaily;
	import sg.task.model.ModelTaskMain;
	import sg.task.model.ModelTaskOrder;
	import sg.task.model.ModelTaskPromote;
	import sg.task.model.ModelTaskTrain;
	import sg.utils.ObjectUtil;
	import sg.utils.StringUtil;
	import sg.utils.Tools;
	import sg.guide.view.GuideFocus;
	import sg.view.menu.ViewMenuMain;
	import laya.display.Sprite;
	
	/**
	 * ...
	 * @author jiaxuyang
	 */
	public class TaskHelper extends EventDispatcher
	{
		
		public static const GET_REWARD:String = 'get_reward';
		public static const REFRESH_TASK_STORY:String = 'refresh_task_story';
		public static const REFRESH_MAIN_TASK_VIEW:String = 'refresh_main_task_view';
		
		private var taskMain:ModelTaskMain;
		private var taskDaily:ModelTaskDaily;
		private var taskTrain:ModelTaskTrain;
		private var taskBuild:ModelTaskBuild;
		private var taskOrder:ModelTaskOrder;
		private var taskPromote:ModelTaskPromote;
		private var taskCountry:ModelTaskCountry;
		
		private var stroyTask:Object;
		
		// 单例
		public static var sTaskHelper:TaskHelper = null;
		
		public static function get instance():TaskHelper
		{
			return sTaskHelper ||= new TaskHelper();
		}
		
		public function TaskHelper()
		{
		}
		public static function clear():void{
			sTaskHelper.clearEvents();
            sTaskHelper = null;
        }		
		public function initTaskModel():void {
			this.taskDaily = ModelTaskDaily.instance;
			this.taskDaily.typeIndex = 0;
			this.taskDaily.on(TaskHelper.GET_REWARD, this, this.getReward);

			this.taskMain = ModelTaskMain.instance;
			this.taskMain.typeIndex = 1;
			this.taskMain.on(TaskHelper.GET_REWARD, this, this.getReward);
			
			this.taskTrain = ModelTaskTrain.instance;
			this.taskTrain.typeIndex = 2;
			this.taskTrain.on(TaskHelper.GET_REWARD, this, this.getReward);
			
			this.taskBuild = ModelTaskBuild.instance;
			this.taskBuild.typeIndex = 3;
			this.taskBuild.on(TaskHelper.GET_REWARD, this, this.getReward);
			
			this.taskOrder = ModelTaskOrder.instance;
			this.taskOrder.typeIndex = 4;
			this.taskOrder.on(TaskHelper.GET_REWARD, this, this.getReward);
			
			this.taskPromote = ModelTaskPromote.instance;
			this.taskPromote.typeIndex = 5;
			this.taskPromote.on(TaskHelper.GET_REWARD, this, this.getReward);
			
			this.taskCountry = ModelTaskCountry.instance;
			this.taskCountry.typeIndex = 6;
			this.taskCountry.on(TaskHelper.GET_REWARD, this, this.getReward);
			
            // 刷新数据
            var modelUser:ModelUser = ModelManager.instance.modelUser;
            modelUser.on(ModelUser.EVENT_IS_NEW_DAY, this, this.getTask);
			this.onTaskProgressChange(modelUser.task);
			this.on(REFRESH_TASK_STORY, this, this.refreshMainTask);
		}
		
		/**
		 * 主动获取任务
		 */
		private function getTask():void {
			NetSocket.instance.send(NetMethodCfg.WS_SR_GET_TASK, null, new Handler(this, this.getTaskCB));
		}
		
		/**
		 * 主动获取任务的回调
		 * @param	re
		 */
		private function getTaskCB(re:NetPackage):void {
			ModelManager.instance.modelUser.updateData(re.receiveData);
		}
		
		/**
		 * 当任务进度改变任务进度改变
		 * @param	taskType 任务大类型
		 */
		public function onTaskProgressChange(task:*):void {
			if (!this.taskDaily) return;
			this.taskDaily.refreshTaskData(task.daily);
			this.taskTrain.refreshTaskData(task.common);
			this.taskBuild.refreshTaskData(task.common);
			this.taskOrder.refreshTaskData(task.common);
			this.taskPromote.refreshTaskData(task.common);
			this.taskCountry.refreshTaskData(task);
			this.taskMain.refreshTaskData(task.main);
			this.refreshMainTask();
            ModelManager.instance.modelGame.event(ModelGame.EVENT_TASK_RED);
		}
		
		/**
		 * 领取奖励
		 * @param	type
		 * @param	id
		 */
		private function getReward(data:*):void {
			//领取奖励，告知服务器
			NetSocket.instance.send(NetMethodCfg.WS_SR_GET_TASK_REWARD, {kind: data.kind, task_id: data.task_id}, Handler.create(this, this.getRewardCB), data.gift_dict);

		}
		
		/**
		 * 领奖的回调
		 * @param	re
		 */
		private function getRewardCB(re:NetPackage):void {			
			var receiveData:* = re.receiveData;
			var otherData:* = re.otherData;
			var gift_dict:* = receiveData && receiveData.gift_dict || otherData;
			ModelManager.instance.modelUser.updateData(receiveData);
			gift_dict && ViewManager.instance.showRewardPanel(gift_dict);
		}
		
		/**
		 * 点击剧情面板
		 */
		public function onClickStory():void {
			var task:ModelTaskBase = this.stroyTask as ModelTaskBase;
			var goto_cfg:* = null;
			if(task is ModelTaskBase) {
				var data:* = ModelTaskMain(task).getFirstData();
				var state:int = data['taskState'];
				if (state === 1 && task['type'] === ModelTaskBase.TASK_MAIN) {
					this.getReward({kind:task['type'], task_id:data['task_id'], gift_dict: data['reward']});
				}
				else if (task['type'] === ModelTaskBase.TASK_MAIN){
					goto_cfg = data['goto_cfg'];
					if (data['task_id'] === 'main_2') {
						var sp:Object = ViewMenuMain.getTroop(0);
						if (sp.mModel) {
							sp = ViewMenuMain.getTroop(1);
						}
						GotoManager.instance.boundForMap();
						GuideFocus.focusInSprite(sp as Sprite);
					}
					else if (data['type'] === 'ts_catch') { // 进行3次切磋
						GotoManager.instance.boundForHeroCatche();
					}
					else if (goto_cfg.type === 1 && data['need'][1] is Array && data['need'][1].length === 3) {
						GotoManager.boundFor(ObjectUtil.mergeObjects([{'cityID': data['need'][1][ModelUser.getCountryID()]}, goto_cfg]));
					}
					else GotoManager.boundFor(goto_cfg);
				}
				else if (task is ModelTaskBase){
					GotoManager.boundForPanel(GotoManager.VIEW_TASK, task['typeIndex']);
				}
			}
			else if(task is String) { // 跳转到政务
				GotoManager.boundForPanel(GotoManager.VIEW_TASK);
			}
			else {
				trace("No task!!!");
			}
		}
		
		/**
		 * 提示完成任务会获得的奖励
		 */
		public function hintReward():void {
			if (this.stroyTask) {
				var gift_dict:* = this.stroyTask.getFirstData()['reward'];
				ViewManager.instance.showRewardPanel(gift_dict, null, true);
			}
		}
		
		/**
		 * 检测任务进度，根据显示规则刷新剧情显示
		 */
		public function refreshMainTask():void {
			var taskType:String = "";
			var html:String = "";
			var hintGet:Boolean = false;
			var task:ModelTaskBase = null;
			var tempTask:ModelTaskBase = null;
			var taskData:* = null;
			var state:int = 0;
			var i:int = 0;
			var len:int = 0;
			
			var taskArray:Array = [];
			var gtask:Object = 'gtask';
			var taskRulesObj:* = { // 按照顺序检测任务进度
				'main': this.taskMain,
				'gtask': gtask,
				'common': [this.taskTrain, this.taskBuild, this.taskOrder, this.taskPromote],
				'daily': this.taskDaily
			};
			var show_rules:Array = ConfigServer.task.show_rule;
			for (i = 0, len = show_rules.length; i < len; i++) {
				taskArray = taskArray.concat(taskRulesObj[show_rules[i]]);
			}

			if (ModelGuide.isNewPlayerGuide()) {
				taskArray = [taskArray[0]];
			}
			
			for (i = 0, len = taskArray.length; i < len; i++)
			{
				task = taskArray[i];
				if (task === gtask) { // 政务检测
					if (this._checkGTask()) {
						this.stroyTask = gtask;
						this._showGTask();
						return;
					}
					else {
						continue;
					}
				}
				taskData = task.getFirstData();
				if (!taskData || !taskData.task_id) continue;
				state = taskData['taskState'];
				if (state === 1) {
					tempTask = task as ModelTaskBase;
					hintGet = true;
					break;
				}
				else if (tempTask === null && state === 0) {
					tempTask = task as ModelTaskBase;
				}
			}
			
			if (tempTask !== null) {
				taskType = tempTask.chineseName;
				taskData = tempTask.getFirstData();
				html = tempTask.getHTMLByData(taskData);
				this.event(TaskHelper.REFRESH_MAIN_TASK_VIEW, [taskType, html, hintGet]);
				this.stroyTask = tempTask;
			}
			else {
				this.stroyTask = null;
				trace("======================  Task all finished   ==========================");
			}
		
		}

		/**
		 * 检测政务是否达到居功至伟
		 */
		private function _checkGTask():Boolean {
            var arr:Array = ModelTask.gTask_self_take_arr();
			for(var i:int = 0, len:int = arr.length; i < len; i++) {
				var ele:Object = arr[i];
				if (ele.status === 0) continue;
				var re:Array = ModelTask.gTask_need(ele.id);
            	var score:Number = ele.rate/re[0]/ModelTask.gTask_gtask_exceed_need(ele.id);
				if (score >= 1)	return true;
			}
			return false;
		}

		/**
		 * 展示政务
		 */
		private function _showGTask():void {
			this.event(TaskHelper.REFRESH_MAIN_TASK_VIEW, [Tools.getMsgById('add_task0'), StringUtil.substituteWithColor(Tools.getMsgById('gtask_hint04')), true]);
		}
	}

}