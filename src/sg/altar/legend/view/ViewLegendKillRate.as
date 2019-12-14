package sg.altar.legend.view
{
    import sg.activities.view.RewardItem;
    import ui.fight.legendKillRateUI;
    import sg.manager.ModelManager;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import laya.maths.Point;
    import laya.display.Sprite;

    public class ViewLegendKillRate extends legendKillRateUI
    {
        public function ViewLegendKillRate() {
            list.itemRender = RewardItem;
            var spr:Sprite = new Sprite();
            spr.width = Laya.stage.width;
            spr.height = Laya.stage.height;
            this.addChild(spr);
            spr.on(Event.CLICK, this, this.closeSelf);
        }
		override public function initData():void {
            txt_kill.text = currArg[0];
            list.array = ModelManager.instance.modelProp.getRewardProp(currArg[1]);
        }

		override public function onAdded():void {
        }

		override public function onRemoved():void {
            list.cells.forEach(function(item:RewardItem):void {
                if (item.rewardID) {
                    var pos:Point = (item.parent as Sprite).localToGlobal(new Point(item.x, item.y));
                    var gift_dict:Object = {};
                    gift_dict[item.rewardID] = item.rewardNum;
                    ViewManager.instance.showIcon(gift_dict, pos.x, pos.y);
                }
            }, this);
        }
    }
}