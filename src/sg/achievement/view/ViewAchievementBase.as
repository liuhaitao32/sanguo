package sg.achievement.view
{
    import laya.display.Animation;
    import laya.events.Event;

    import sg.achievement.model.ModelAchievement;
    import sg.boundFor.GotoManager;
    import sg.manager.EffectManager;
    import sg.manager.ViewManager;
    import sg.utils.ObjectUtil;
    import sg.utils.Tools;

    import ui.inside.achievement_baseUI;

    public class ViewAchievementBase extends achievement_baseUI
    {
        private var modelAchieve:ModelAchievement = ModelAchievement.instance;
        private var aniExp:Animation = null;
        private var _type:int;
        private var _index:int;
        public function ViewAchievementBase()
        {
            this.aniExp = new Animation();
            this.aniExp.x = this.namePanel.x + this.namePanel.width * 0.5;
            this.aniExp.y = this.namePanel.y + this.namePanel.height * 0.5;
            this.addChild(this.aniExp);
        }

        override public function set dataSource(source:*):void {
            if (!source) return;
			this._dataSource = source;
            this._type = source.type;
            this._index = source.index;
            var achieveCfg:* = this.modelAchieve.getEffortConfigById(source.id);
            this.achieveName.text = Tools.getMsgById(achieveCfg['name']);
            this.difficultyList.repeatX = achieveCfg['score'];
            if (source.state === 0) {
                this.indexTxt.text = Tools.getMsgById('_jia0016') + '?';
                this.achieveDate.text = Tools.getMsgById('_jia0017');
                this.setState(0);
            }
            else {
                this.indexTxt.text = Tools.getMsgById('_jia0016') + (_index + 1);
                this.achieveDate.text = Tools.dateFormat(source.time, 1).slice(0, 10);
                this.setState(achieveCfg.quality);
            }
            this.off(Event.CLICK, this, this._selectItem);
            this.on(Event.CLICK, this, this._selectItem);
            this.getChildByName('icon_new')['visible'] = source.state === 1;
        }

        private function _selectItem(event:Event):void {
			var source:Object = this.modelAchieve.getEffortsByIndex(_type)[_index];
            var state:int = source.state;
            var achieveCfg:* = this.modelAchieve.getEffortConfigById(source.id);
            var data:* = ObjectUtil.mergeObjects([ObjectUtil.clone(achieveCfg), source]);
            state === 0 && ViewManager.instance.showTipsTxt(Tools.getMsgById('_jia0018'));
            state === 1 && this.modelAchieve.getReward(source.id);
            state === 2 && this.showDescription(data);
        }
        
        private function showDescription(data:Object):void {
            GotoManager.boundForPanel(GotoManager.VIEW_ACHIEVEMENT_DETAIL, '', data);
        }

        /**
         * 设置状态
         */
        public function setState(state:int):void
        {
            this.gray = state === 0;
            this.difficultyList.gray = (state === 1 ? true : false);
            this.achieveName.gray = (state === 1 ? true : false);
            this.namePanel.gray = (state === 1 ? true : false);
            this.frame.gray = (state === 1 ? true : false);
            state === 1 && EffectManager.loadAnimation("glow042", '', 0, this.aniExp);
            state === 2 && EffectManager.loadAnimation("glow042", '', 0, this.aniExp);
            state === 3 && EffectManager.loadAnimation("glow043", '', 0, this.aniExp);
            state === 0 && this.aniExp.clear();
        }
    }
}