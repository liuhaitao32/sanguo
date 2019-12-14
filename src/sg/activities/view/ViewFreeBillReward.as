package sg.activities.view
{
    import laya.display.Animation;
    import laya.maths.Point;

    import sg.manager.EffectManager;
    import sg.manager.ViewManager;
    import sg.utils.MusicManager;
    import sg.utils.ObjectUtil;
    import sg.utils.Tools;

    import ui.activities.freeBill.freeBillRewardUI;

    public class ViewFreeBillReward extends freeBillRewardUI
    {
        public function ViewFreeBillReward()
        {
            this.img2.visible = false;
            this.closehint.text = Tools.getMsgById('_public114');
            this.txt_tips.text = Tools.getMsgById('_jia0064');
        }
        
		override public function onAddedBase():void{
            super.onAddedBase();
			MusicManager.playSoundUI(MusicManager.SOUND_GET_REWARD);
			var rewardData:Object = this.currArg;
            this.isAutoClose = false;
            var ani:Animation=EffectManager.loadAnimation("glow030","",1);
            this.box.addChild(ani);
            ani.pos(this.img1.x,this.img1.y);

            var rewardId:String = ObjectUtil.keys(rewardData)[0];
            this.reward.setData(rewardId, rewardData[rewardId], -1);
            Laya.timer.frameOnce(30, this, this._autoClose);
		}

        private function _autoClose():void
        {
            this.isAutoClose = true;
        }
		
		override public function onRemovedBase():void{
            super.onRemovedBase();
            Laya.timer.clear(this, this._autoClose);
            var pos:Point = reward['parent'].localToGlobal(Point.TEMP.setTo(reward.x, reward.y))
            ViewManager.instance.showIcon(this.currArg, pos.x, pos.y);
		}
    }
}