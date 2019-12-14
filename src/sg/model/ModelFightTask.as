package sg.model
{
    import sg.cfg.ConfigServer;
    import sg.utils.Tools;
    import sg.utils.TimeHelper;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.manager.ModelManager;
    import sg.guide.model.ModelGuide;
    import sg.manager.ViewManager;
    import sg.net.NetSocket;
    import sg.scene.constant.EventConstant;
    import sg.cfg.ConfigClass;
    import sg.view.init.ViewHeroTalk;

    public class ModelFightTask extends ViewModelBase
    {
		public static const SHOW_FIGHT_TASK_BTN:String = 'fight_task';
		public static const HIDE_FIGHT_TASK:String = 'hide_fight_task';
		public static const FIGHT_TASK_CHANGE:String = 'fight_task_change';

		public static const TYPE_END:String = 'type_end';
		public static const TYPE_BEGIN:String = 'type_begin';
		public static var sModel:ModelFightTask = null;
		public static function get instance():ModelFightTask {
			return sModel ||= new ModelFightTask();
		}
        public var cfg:Object = ConfigServer.system_simple.fight_task;
		private var has_fight_task:Boolean = false;
		public var citys:Array = [];
		public var taskData:Array = [];
		private var task_begin_time:int = 0;
		public var task_end_time:int = 0;
		private var foreshow_time:int = 0;
		private var close_time:int = 0;
		public var needPush:Boolean = false;
		public var talkArgs:Array;
        public function ModelFightTask()
        {
			this._refreshTask();
			NetSocket.instance.on(NetSocket.EVENT_SOCKET_RECEIVE_FROM,this,this.event_socket_send_and_receive);
			// NetSocket.instance.registerHandler(EventConstant.FIGHT_END, new Handler(this, this._refreshTask)); // 对服务器消耗大  而且没啥用  现在不用了
		}

		private function event_socket_send_and_receive(method:String,b:Boolean, timeout:Boolean):void { // 处理数据不一致的问题
			timeout && method === NetMethodCfg.WS_SR_GET_FIGHT_TASK && Laya.timer.once(Tools.oneMillis * 6, this, this._refreshTask);
		}

		private function _refreshTask(nextState:String = ''):void {
			has_fight_task = false;
			this.sendMethod(NetMethodCfg.WS_SR_GET_FIGHT_TASK, null, Handler.create(this, this._sendCallBack), nextState);
		}

		private function _sendCallBack(ne:NetPackage):void {
			var receiveData:* = ne.receiveData;
			var nextState:String = ne.otherData;
			var task:Array = receiveData.country_fight_task.task || [];
			has_fight_task = receiveData.has_fight_task;
			
			citys = task.map(function(arr:Array):int { return parseInt(arr[0]); });
			taskData = task.map(function(arr:Array):Object {
				return {
					cid: parseInt(arr[0]),
					cfg: cfg,
					state: arr[1]
				};
			}, this);
			if (receiveData.has_fight_task) {
				has_fight_task && this._initListener();
				this.event(SHOW_FIGHT_TASK_BTN);
			}
			this.taskChanged(nextState);
		}

		private function _initListener():void {
			var currentTime:int = ConfigServer.getServerTimer();
			task_begin_time = Tools.getTodayMillWithHourAndMinute(cfg.time_begin) + Tools.oneMinuteMilli * 0.5;
			task_end_time = Tools.getTodayMillWithHourAndMinute(cfg.time_end) + Tools.oneMinuteMilli * 0.5;
			foreshow_time = task_begin_time - cfg.time_notice * Tools.oneMillis;
			close_time = task_end_time + cfg.task_buff[2] * Tools.oneMillis;
			talkArgs = [[cfg.show_talk1], Handler.create(ViewManager.instance, ViewManager.instance.showView, [ConfigClass.VIEW_FIGHT_TASK])];

			if (currentTime < foreshow_time) { // 任务开始预告，展示入口
				Laya.timer.once(foreshow_time - currentTime, this, this.taskForeShow);
			} else if (currentTime < task_begin_time) { // 任务开始时间
				Laya.timer.once(task_begin_time - currentTime, this, this.taskBegin);
			} else if (currentTime < task_end_time) { // 任务结算时间
				this.needPush = active;
				Laya.timer.once(task_end_time - currentTime, this, this.taskEnd);
			} else if (currentTime < close_time) { // 关闭入口时间
				Laya.timer.once(close_time - currentTime, this, this.hideEntrance);
			}
		}

		private function taskForeShow():void {
			this.event(SHOW_FIGHT_TASK_BTN);
		}

		private function taskBegin():void {
			this._refreshTask(TYPE_BEGIN);
			Laya.timer.once(Tools.oneMillis * 10, this, this._refreshTask);
		}

		private function taskEnd():void {
			this._refreshTask(TYPE_END);
			Laya.timer.once(Tools.oneMillis * 10, this, this._refreshTask);
		}

		private function taskChanged(type:String = null):void {
			if (!active)	return;
			switch(type) {
				case TYPE_BEGIN:
					ViewManager.instance.showView(["ViewHeroTalk",ViewHeroTalk], talkArgs);
					break;
				case TYPE_END:
					ViewManager.instance.showHeroTalk([taskData.some(function(obj:Object):Boolean {return obj.state === 1}, this) ? cfg.show_talk3: cfg.show_talk4]);
					break;
			}
			ModelManager.instance.modelGame.event(ModelOfficial.EVENT_UPDATE_ORDER_ICON);
			this.event(FIGHT_TASK_CHANGE);
		}

		private function hideEntrance():void {
			this.event(SHOW_FIGHT_TASK_BTN);
			this.event(HIDE_FIGHT_TASK);
		}

		/**
		 * 国战任务的城池ID
		 */
		public function get cids_map():Array {
            var currentTime:int = ConfigServer.getServerTimer();
			return (currentTime > task_begin_time && currentTime < task_end_time) ? citys : [];
		}

        public function get remainTime():int {
            var currentTime:int = ConfigServer.getServerTimer();
			if (currentTime < task_begin_time)	return task_begin_time - currentTime;
			if (currentTime < task_end_time)	return task_end_time - currentTime;
			if (currentTime < close_time)		return close_time - currentTime;
			return 0;
		}

		public function getTxt():String {
            var msgId:String = 'fight_task08';
            var currentTime:int = ConfigServer.getServerTimer();
			if (currentTime < task_begin_time) {
				msgId = 'fight_task08';
			} else if (currentTime < task_end_time) {
				msgId = 'fight_task09';
			} else if (currentTime < close_time) {
				msgId = taskData.some(function(obj:Object):Boolean {return obj.state === 1}, this) ? 'fight_task11' :'fight_task10';
			}
			return Tools.getMsgById(msgId, [TimeHelper.formatTime(this.remainTime)]);
		}
		
		/**
		 * 任务buff
		 * @return [0]伤害和免伤 [1]行军速度加成，[2]剩余时间（毫秒）
		 */
		public function get buff():Array {
            var currentTime:int = ConfigServer.getServerTimer();
			if (currentTime > task_end_time && currentTime < close_time) {
				var num:int = taskData.filter(function(obj:Object):Boolean {return obj.state === 1}, this).length;
				var arr:Array = cfg.task_buff;
				if (num === 0)	return [];
				return [arr[0] * num, arr[1] * num, close_time - currentTime];
			}
			return [];
		}

		/**
		 * 是否激活
		 */
		override public function get active():Boolean {
            var currentTime:int = ConfigServer.getServerTimer();
			var foreshow:Boolean = currentTime > foreshow_time && currentTime < task_begin_time;
			var inTask:Boolean = citys.length === 2 && currentTime > task_begin_time && currentTime < close_time; // 任务时间段（包含buff时间）
			return foreshow || inTask;
		}

		public function get canShow():Boolean {
            var currentTime:int = ConfigServer.getServerTimer();
			return currentTime > task_begin_time && currentTime < close_time; // 任务时间段（不包含预告, 包含buff时间）
		}

		public function foreshowTips():void {
			ViewManager.instance.showHeroTalk([cfg.show_talk2]);
		}

		/**
		 * 是否需要显示红点
		 */
		override public function get redPoint():Boolean {
			return false;
		}
    }
}