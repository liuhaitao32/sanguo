package sg.achievement.view
{
    import sg.utils.StringUtil;
    import sg.utils.Tools;

    import ui.inside.achievement_describeUI;

    public class ViewAchievementDetail extends achievement_describeUI
    {
        public function ViewAchievementDetail()
        {
            this.titleLabel.text = Tools.getMsgById('_jia0020');
            this.titleLabel2.text = Tools.getMsgById('_jia0021');
        }

        override public function set currArg(v:*):void {
			this.mCurrArg = v;
            this._initDetail(v);           
		}

        private function _initDetail(data:*):void {
            //this.achieveName.text = Tools.getMsgById(data.name);
            this.comTitle.setViewTitle(Tools.getMsgById(data.name));
            this.titleTxt.text = StringUtil.substitute(Tools.getMsgById(data.info), data.need);
            this.descriptionTxt.text = Tools.getMsgById(data.einfo);
            // this.indexTxt.text = data.index;
            // this.difficultyList.repeatX = Math.floor(data.score);
            this.achieveDate.text = Tools.getMsgById('_jia0019') + Tools.dateFormat(data.time, 1).substring(0, 10);
            
            this.effectRecord.visible = data.quality === 3;
            this.effectRecord.getChildByName('recordTxt')['text'] = Tools.getMsgById(data.cinfo);
        }
    }
}