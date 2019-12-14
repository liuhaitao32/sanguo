package sg.activities.view
{
    import laya.events.Event;
    import laya.ui.Button;

    import sg.manager.ModelManager;
    import sg.manager.ViewManager;
    import sg.utils.Tools;

    import ui.activities.rewardPreviewPanelUI;

    public class ViewRewardPreview extends rewardPreviewPanelUI
    {
	    private var btnBG:Button;
        private var rewardItemArr:Array = [];
        public function ViewRewardPreview() {
            btnBG=new Button;
            btnBG.alpha=0;
            btnBG.on(Event.CLICK,this,this._closePanel);
            this.mc.addChild(btnBG);
            btnBG.height=this.height;
            btnBG.width=this.width;
            btnBG.centerX=btnBG.centerY=0;
            this.previewTxt.text = Tools.getMsgById('_public113');
            this.closehint.text = Tools.getMsgById('_public114');
        }

		override public function set currArg(v:*):void {
            this._removeRewardItems();
			this.mCurrArg = v;
            this.setData(v);
		}

        private function setData(data:Object):void {
            var rewardArr:Array = ModelManager.instance.modelProp.getRewardProp(data);
            var len:int = rewardArr.length;
            var column:int = 5;
            var row:int = Math.ceil(len / 5);
            var i:int = 0;
            var j:int = 0;
            var tempLen:int = 0;
            var oriX:Number = this.panel.left;
            var oriY:Number = this.panel.top;
            var cellW:Number = 92;
            var cellH:Number = 108;
            var offsetX:Number = (this.mc.width - oriX * 2 - cellW * column) / (column + 1);
            var desX:Number = 0;
            var desY:Number = 0;
            var item:RewardItem = null;

            this.mc.height = row * cellH + 60;
            if (rewardArr.length < 5) {
                oriX += (cellW + offsetX) * (5 - rewardArr.length) * 0.5;
            }
            for (i = 0; i < row; ++i) {
                tempLen = len - column * i;
                tempLen = tempLen > column ? column : tempLen;
                for (j = 0; j < tempLen; ++j) {
                    item = RewardItemPool.borrowItem();
                    this.rewardItemArr.push(item);
                    this.mc.addChild(item);
                    item.setReward(rewardArr[column * i + j]);
                    desX = oriX + (cellW + offsetX) * j + offsetX;
                    desY = oriY + cellH * i;
                    item.pos(desX, desY);
                }
            }
        }

        private function _removeRewardItems():void {
            for(var index:int = 0, len:int = rewardItemArr.length; index < len; index++)
            {
                var item:RewardItem = rewardItemArr[index];
                item.destroy();
            }
            rewardItemArr = [];
        }

        private function _closePanel():void {
            this._removeRewardItems();
            ViewManager.instance.closePanel(this);
        }
    }
}