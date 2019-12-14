package sg.activities.view
{
    import ui.activities.auction.auctionRefundUI;
    import sg.utils.Tools;
    import laya.events.Event;
    import sg.net.NetSocket;
    import sg.manager.ModelManager;
    import sg.model.ModelUser;
    import sg.manager.ViewManager;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.utils.ObjectUtil;
    import sg.model.ModelItem;

    public class AuctionRefund extends auctionRefundUI
    {
        public function AuctionRefund()
        {
            comTitle.setViewTitle(Tools.getMsgById("550039"));
            btn.label = Tools.getMsgById('_public183');
            txt_hint2.text = Tools.getMsgById('550042');
            txt_hint1.text = Tools.getMsgById('550040');
            btn.on(Event.CLICK, this, this._onClick);
        }

        override public function set currArg(v:*):void {
			this.mCurrArg = v;
            txt_hint0.text = mCurrArg.tips;
            var iid:String = ObjectUtil.keys(mCurrArg.gift)[0];
            icon_cost.setData(ModelItem.getIconUrl(iid), mCurrArg.gift[iid]);
		}

        override public function initData():void {
        }

        override public function onAdded():void {
        }

        override public function onRemoved():void {
            this._getreWard();
        }

        private function _onClick():void {
            this.closeSelf();
        }

        private function _getreWard():void {
            NetSocket.instance.send("accept_sys_gift_msg",{"msg_index":mCurrArg.index},Handler.create(this,function(np:NetPackage):void{
            	ModelManager.instance.modelUser.updateData(np.receiveData);
            	ViewManager.instance.showIcon(np.receiveData.gift_dict_list[0], Laya.stage.width * 0.5, Laya.stage.height * 0.5);
            	ModelManager.instance.modelUser.event(ModelUser.EVENT_UPDATE_MAIL_SYSTEM);
            }));
        }
    }
}