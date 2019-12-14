package sg.view.map 
{
	import laya.events.Event;
	import laya.html.dom.HTMLDivElement;
	import laya.resource.Texture;
	import laya.ui.Button;
	import laya.ui.Image;
	import laya.ui.Label;
	import laya.utils.Handler;
	import sg.boundFor.GotoManager;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import sg.model.ModelCityBuild;
	import sg.model.ModelItem;
	import sg.model.ModelOfficial;
	import sg.model.ModelUser;
	import sg.task.model.ModelTaskBase;
	import sg.task.model.ModelTaskCountry;
	import sg.utils.StringUtil;
	import sg.utils.Tools;
	import sg.view.com.comIcon;
	import ui.com.country_task_buildUI;
	import ui.map.country_task_mainUI;
	import laya.ui.Box;
	import sg.manager.AssetsManager;
	import sg.manager.ViewManager;
	import sg.activities.view.RewardItem;
	import sg.utils.MusicManager;
	import sg.net.NetSocket;
	import sg.net.NetMethodCfg;
	import sg.net.NetPackage;
	
	/**
	 * ...
	 * @author jiaxuyang
	 */
	public class CountryTaskMain extends country_task_mainUI 
	{
		private var modelTask:ModelTaskCountry = ModelTaskCountry.instance;
		private var taskIndex:int = 1;
		private var country:int = 0;
		private var cityIdArr:Array;
		private var cityNameArr:Array;
		private var taskArr:Array = this.modelTask.getTaskData() as Array;
		private var reGetIndex:int = 0; // 当前索引对应的任务有问题，记录重新获取时的索引（为了避免死循环）
		public function CountryTaskMain() 
		{
            this.on(Event.ADDED,this,this.onAdd);
            this.on(Event.REMOVED,this,this.onRemove);
			this.country = ModelUser.getCountryID();
			this.taskIndex = Math.min(this.modelTask.rewardIndex, this.modelTask.currentTaskIndex, this.taskArr.length);
			this.btn_left.on(Event.CLICK, this, this._changeTask);
			this.btn_right.on(Event.CLICK, this, this._changeTask);
			this.btn_reward.on(Event.CLICK, this, this._getReward);
			this.modelTask.on(ModelTaskBase.UPDATE_DATA, this, this._onUpdateData);
			this.nameList.itemRender = country_task_buildUI;
			this.nameList.scrollBar.hide = true;
			this.nameList.renderHandler = new Handler(this, this.updateItem);
			this.nameList.selectEnable = true;
			this.nameList.selectHandler = new Handler(this, this.onSelect);
			this.progressBar_total.value = 0;
			this.img_build.on(Event.CLICK, this, this._onClickBuild);
			this.rewardList.itemRender = RewardItem;
			this.rewardList.renderHandler = new Handler(this, this.updateItemList);
			var title:HTMLDivElement = this.taskTitle as HTMLDivElement;
			title.style.fontSize = 22;
			title.style.leading = 8;
			title.style.align = 'center';
			txt_hint_progress.text = Tools.getMsgById('_jia0055');

			// 创建建筑按钮
			var buildArr:Array = this.modelTask.miracleArr;
			var i:int = 0;
			var len:int = buildArr.length;
			var buildBtn:Button = this.btn_build;
			var barLength:int = this.progressBar_total.width;
			var singleTaskWidth:Number = barLength / this.taskArr.length;
			var tempCheckBtn:Button = null;
			buildBtn.name = 'buildBtn_0';
			buildBtn.toggle = true;
			buildBtn.x = buildArr[0] * singleTaskWidth;
			buildBtn['taskName'] = 'country_' + buildArr[0];
			for(i = 1; i < len; i++)
			{
				tempCheckBtn = new Button(buildBtn.skin);
				tempCheckBtn.name = 'buildBtn_' + i;
				tempCheckBtn.stateNum = 2;
				tempCheckBtn.pos(buildArr[i] * singleTaskWidth, buildBtn.y);
				tempCheckBtn['taskName'] = 'country_' + buildArr[i];
				buildBtn.parent.addChildAt(tempCheckBtn, buildBtn.zOrder + 1);
			}
			for(i = 0; i < len; i++)
			{
				tempCheckBtn= this.btn_build.parent.getChildByName('buildBtn_' + i) as Button;
				tempCheckBtn.offAll(Event.MOUSE_OVER);
				tempCheckBtn.offAll(Event.MOUSE_OUT);
				tempCheckBtn.offAll(Event.MOUSE_DOWN);
				tempCheckBtn.offAll(Event.MOUSE_UP);
				tempCheckBtn.offAll(Event.CLICK);
				tempCheckBtn.on(Event.MOUSE_DOWN, this, this._onClickBuildButton);
			}
            this.setUI();
		}

		private function _onClickBuildButton(event:Event):void {
			var tempCheckBtn:Button = event.currentTarget as Button;
			var data:Object = this.modelTask.getSingleTaskConfig(tempCheckBtn['taskName']);
			var introduce:String = Tools.getMsgById(data.miracle_info);
			ViewManager.instance.showTipsPanel(introduce, 400);
		}

		private function onAdd():void
		{
			this.reGetIndex = 0;
		}
		
        private function onRemove():void{
            this.destroyChildren();
            this.destroy(true);
			this.modelTask.off(ModelTaskBase.UPDATE_DATA, this, this._onUpdateData);
        }
		
		private function setUI():void {
			var title:HTMLDivElement = this.taskTitle as HTMLDivElement;
			var titlePrent:Box = title.parent as Box;
			var taskData:Object = this.taskArr[this.taskIndex - 1];
			var state:int = taskData['taskState'];
			if (state === 0 && modelTask.allFinished) {
				state = 1;
			}
			this.btn_left.visible = this.btn_right.visible = true;
			this.kingImg.setHeroIcon(ConfigServer.country_king_icon[this.country]);

			if (this.taskIndex === 1) {
				this.btn_left.visible = false;
			}
			if (this.taskIndex === taskArr.length) {
				this.btn_right.visible = false;
			}
			this.getCityArray();
			this.taskName.text = Tools.getMsgById(taskData.name);
			this.formatHtmlStr(title, taskData, taskData.type);
			title.y = (titlePrent.height - title.contextHeight) * 0.5;
			this.taskDescription.text = Tools.getMsgById(taskData.explain_info);

			taskData.value = taskData.value < 0 ? 0 : taskData.value;
			this.progressBar.value = modelTask.allFinished ? 1 : (taskData.value / taskData.need[0]);
			this.progressTxt.text = (modelTask.allFinished ? taskData.need[0] : taskData.value) + '/' + taskData.need[0];
			this.progressContainer.visible = state < 2;
			this.shouyu.visible = state === 2;
			this.btn_reward.gray = state !== 1;

			this.btn_reward.label = Tools.getMsgById('_public103');
			this.nameList.visible = cityIdArr && cityIdArr.length && (state < 2);
			this.wordsTxt.visible = false;
			this.words_bg2.visible = false;
			state === 2 && this.setWords(taskData.complete_info);

			this.rewardList.array = ModelManager.instance.modelProp.getRewardProp(taskData.reward);
			this.img_build.skin = '';
			this.img_build['buildID'] = '';
			if (taskData['precondition']) {
				var bId:* = taskData['precondition'];
				(bId is Array) && (bId = bId[this.country]);
				var config_cb:Object = ConfigServer.city_build.buildall[bId];
				this.img_build['buildID'] = bId;
				this.img_build.skin=AssetsManager.getAssetsAD(config_cb.background);
				this.img_build['explain'] = config_cb.explain;
			}

			// 刷新进度条
			this.progressBar_total.value = (this.modelTask.currentTaskIndex - 1) / this.taskArr.length;
			var buildArr:Array = this.modelTask.miracleArr;
			var len:int = buildArr.length;
			while(len--) {
				var buildBtn:Button = this.btn_build.parent.getChildByName('buildBtn_' + len) as Button;
				buildBtn.selected = this.modelTask.miracleArr[len] < this.modelTask.currentTaskIndex;
			}

			if (state < 2) {
				if (cityIdArr && cityIdArr.length)	this._showCityName(); // 显示列表
				else if(taskData.persona_info){
					this.setWords(taskData.persona_info);
				}
			}
		}

		/**
		 * 获取城市Id数组和城市名称数组
		 */
		private function getCityArray():void {			
			this.cityIdArr = modelTask.getCityArray(this.taskIndex);
			this.cityNameArr = [];

			// 根据ID获取名称数组
			for(var i:int = 0, len:int = this.cityIdArr.length; i < len; i++) {
				this.cityNameArr[i] = '【' + Tools.getMsgById('c_' + this.cityIdArr[i]) + '】';
			}
		}

		/**
		 * 显示城市名称
		 */
		private function _showCityName():void {
			var taskData:* = this.taskArr[this.taskIndex - 1];
			var needArr:Array = taskData['need'];
			var type:String = taskData['type'];
			var needValue:int = type === 'country_build' ? needArr[1] : (type === 'city_build_up' ? needArr[3] : 1);			
			var dataSource:Array = []; // 数据源
			var completeNum:int = 0;
			var needNum:int = needArr[0];
			var complete:Boolean = this.taskIndex < this.modelTask.currentTaskIndex;

			// 初始化数据源
			var i:int = 0, len:int = this.cityIdArr.length;
			var obj:Object = null;
			var buildArr:Array = needArr[2];
		
			if (type === 'city_build_up' && len === 1 && buildArr is Array) { // 建设都城
				len = buildArr.length;		
				for(; i < len; i++)
				{
					obj = {};
					obj.id = this.cityIdArr[0];
					obj.name = this.toChinese(buildArr[i]);
					obj.value = ModelCityBuild.getBuildLv(obj.id, buildArr[i]);
					obj.needValue = needArr[3];
					obj.value = obj.value < 0 ? 0 : obj.value;
					complete && (obj.value = obj.needValue);
					dataSource.push(obj);
					obj.value >= obj.needValue && completeNum++;			
				}				
			}
			else {		// 建设城市		
				for(; i < len; i++)
				{
					obj = {};
					obj.id = this.cityIdArr[i];
					obj.name = this.cityNameArr[i];
					var isMyCity:Boolean = ModelOfficial.checkCityIsMyCountry(obj.id);
					// var isMyCity:Boolean = (ModelOfficial.checkCityIsMyCountry(obj.id) && ModelManager.instance.modelUser.isFinishFtask(obj.id));
					if (type === 'city_build_up' || type === 'country_build') {
						obj.value = ModelCityBuild.getBuildLv(obj.id, needArr[2]);
						obj.value = isMyCity ? obj.value : 0;
					}
					else {
						obj.value = isMyCity ? 1 : 0;
					}
					obj.needValue = needValue;
					complete && (obj.value = obj.needValue);
					dataSource.push(obj);
					obj.value = obj.value < 0 ? 0 : obj.value;
					obj.value >= obj.needValue && completeNum++;			
				}
			}
			this.nameList.dataSource = dataSource;
			(needNum === 1 && dataSource.length > 1) && (needNum = dataSource.length);
			(completeNum > needNum) && (completeNum = needNum);
			this.progressBar.value = completeNum / needNum;
			this.progressTxt.text = completeNum + '/' + needNum;
			if (this.btn_reward.visible && this.btn_reward.gray && this.progressBar.value >= 1 && this.modelTask.rewardIndex === this.taskIndex && this.reGetIndex !== this.taskIndex) {
				// 任务进度对不上
				this.reGetIndex = this.taskIndex;
				NetSocket.instance.send(NetMethodCfg.WS_SR_GET_TASK, null, new Handler(this, this.getTaskCB));
			}
		}
		
		/**
		 * 主动获取任务的回调
		 * @param	re
		 */
		private function getTaskCB(re:NetPackage):void
		{
			ModelManager.instance.modelUser.updateData(re.receiveData);
		}

		private function updateItem(item:country_task_buildUI, index:int):void
		{
			var source:Object = item['dataSource'];
			var titleLabel:Label = item.getChildByName('title') as Label;
			var progressLabel:Label = item.getChildByName('progress') as Label;
			var completeLabel:Label = item.getChildByName('completeTxt') as Label;
			titleLabel.text = source.name;
			progressLabel.text = (source.value >= source.needValue ? source.needValue : source.value) + '/' + source.needValue;
			completeLabel.text = source.value >= source.needValue ? Tools.getMsgById('_jia0024') : '';
			titleLabel.color = progressLabel.color = completeLabel.color = source.value >= source.needValue ? '#71ff4e' : '#ffffff';
		}


		private function updateItemList(cell:RewardItem, index:int):void
		{
			cell.setReward(cell['dataSource']);
		}
		
		private function onSelect(index:int):void
		{
			var cId:int = this.cityIdArr[index > this.cityIdArr.length - 1 ? 0 : index];
			GotoManager.boundFor({type:1,cityID:cId});
		}

		private function _onUpdateData():void {
			this.taskIndex = this.modelTask.rewardIndex;
			this.setUI();
		}
		
		private function _changeTask(event:Event):void {
			var offset:int = event.currentTarget === btn_left ? -1 : 1;
			var tempIndex:int = this.taskIndex + offset;

			if (tempIndex >= 1 && tempIndex <= Math.min(taskArr.length, modelTask.currentTaskIndex)) {
				this.taskIndex = tempIndex;
				this.setUI();
			}
		}
		
		/**
		 * 获取标题的html字符串
		 */
		private function formatHtmlStr(htmlDiv:HTMLDivElement, data:*, type:String):void {
			var needArr:Array = data.need;
			var html:String = Tools.getMsgById(data.info);
			var i:int = 0;
			var len:int = 0;
			
			var tempArr:Array = [];
			switch(type) {
				case 'occupation_city':
					needArr = this.cityNameArr.slice(0);
					needArr.unshift(null);
					break;
				case 'city_build_up':
					tempArr.push(needArr[0]);
					needArr = tempArr.concat(this.cityNameArr, needArr.slice(2));
					needArr[4] =  this.toChinese(needArr[4]);
					break;
				case 'country_build':
					needArr = needArr.slice(0);
					needArr[2] = this.toChinese(needArr[2]);
					break;
				default:
					needArr = data.need;
					needArr = needArr.slice(0);
					break;
			}
			len = needArr.length;
			for(i = 0; i < len; i++) {
				needArr[i] = '[' + needArr[i] + ']';
			}
			html = StringUtil.substitute(html, needArr);
			StringUtil.setHtmlText(htmlDiv, Tools.getMsgById('add_task') + this.taskIndex + ': ' + html, ['#e7b818']);
		}

		private function _onClickBuild(event:Event):void
		{
			var targ:* = event.currentTarget;
			var explain:String = Tools.getMsgById(targ['explain']);
			var title:String = Tools.getMsgById(targ['buildID']);
			explain && ViewManager.instance.showTipsPanel(explain, 400, title);
		}

		private function _getReward(event: Event):void {
			var item:* = this.taskArr[this.taskIndex - 1];
			if (modelTask.allFinished && item.taskState === 0) {
				item.taskState = 1;
			}
			if (item.taskState !== 1) return;
			this.modelTask.getTaskReward('country', item.task_id, item.reward);
		}

		private function setWords(words:String):void {
			this.wordsTxt.visible = true;
			this.wordsTxt.text = Tools.getMsgById(words);
			this.words_bg2.visible = true;
		}

		private function toChinese(str: String):String {
			return '【' + Tools.getMsgById(str) + '】';			
		}
	
	}

}