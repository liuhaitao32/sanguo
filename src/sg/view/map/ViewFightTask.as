package sg.view.map
{
	import ui.map.country_fight_taskUI;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.utils.Tools;
	import sg.outline.view.OutlineViewMain;
	import sg.cfg.ConfigServer;
	import sg.model.ModelUser;
	import sg.model.ModelFightTask;
	import sg.utils.TimeHelper;

    public class ViewFightTask extends country_fight_taskUI
    {
        private var _info:String = '';
        private var model:ModelFightTask = ModelFightTask.instance;
        public function ViewFightTask() {
            txt_title.text = Tools.getMsgById('fight_task01');
            txt_tips.text = Tools.getMsgById('fight_task03');
            this._setBuffTxt();
        }

        override public function onAdded():void{
            this._refreshTime();
            this.timerLoop(Tools.oneMillis, this, this._refreshTime);

            model.on(ModelFightTask.HIDE_FIGHT_TASK, this, this.closeSelf);

            outline.initCitys(model.citys);
            this._refreshCityState();
            model.on(ModelFightTask.FIGHT_TASK_CHANGE, this, this._refreshCityState);
        }

        private function _refreshCityState():void {
            mc_city_0.initCity(model.taskData[0]);
            mc_city_1.initCity(model.taskData[1]);
            var currentTime:int = ConfigServer.getServerTimer();
			var msg:String = Tools.getMsgById('fight_task04');
            box_time_hint.visible = true;
			if (currentTime > model.task_end_time) {
				if (model.taskData.some(function(obj:Object):Boolean {return obj.state === 1}, this)) {
				    msg = Tools.getMsgById('fight_task11').split('\n')[0];
                }
                else {
                    box_time_hint.visible = false;
                }
			}
            txt_time_hint.text = msg;
        }

        private function _refreshTime():void {
            txt_time.text = TimeHelper.formatTime(model.remainTime);
        }

        private function _setBuffTxt():void {
            var merit_add:Array = model.cfg.merit_add;
            var args:Array = merit_add.slice(0, 2).map(function(arr:Array):String {
                var timeStr:String = arr[0] + Tools.getMsgById('_public108');
                arr[1] && (timeStr += arr[1] + Tools.getMsgById('_public109'))
                return timeStr;
            });
            args.push(merit_add[2]);
            txt_merit_add.text = Tools.getMsgById('fight_task02', args);
        }

        override public function onRemoved():void{
            outline.clear();
            mc_city_0.clear();
            mc_city_1.clear();
            model.off(ModelFightTask.HIDE_FIGHT_TASK, this, this.closeSelf);
            model.off(ModelFightTask.FIGHT_TASK_CHANGE, this, this._refreshCityState);
        }
    }   
}