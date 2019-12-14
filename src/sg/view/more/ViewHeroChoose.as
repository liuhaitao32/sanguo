package sg.view.more
{
    import laya.events.Event;
    import sg.manager.LoadeManager;
    import sg.manager.AssetsManager;
    import sg.model.ModelGame;
    import sg.manager.ModelManager;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import ui.activities.heroChooseUI;
    import sg.utils.ObjectUtil;
    import sg.model.ModelItem;
    import laya.utils.Handler;
    import laya.ui.Box;
    import sg.view.com.ComPayType;
    import laya.ui.Image;
    import sg.model.ModelHero;
    import laya.ui.Label;
    import sg.utils.Tools;
    import sg.model.ModelProp;
    import sg.utils.ObjectSingle;
    import sg.net.NetPackage;
    import sg.net.NetSocket;

    public class ViewHeroChoose extends heroChooseUI
    {
		public var listData:Array;
		public var curIndex:int;
		public var numArr:Array;
        private var itemId:String;
		public var itemModel:ModelItem;
        public function ViewHeroChoose()
        {
            isAutoClose = false;
			list.scrollBar.visible = false;
            list.renderHandler = new Handler(this, this._updateItem);
            this.btn.on(Event.CLICK,this,this.click);
            var gift:Object = ModelManager.instance.modelProp.buildUpGift;
            itemId = ObjectUtil.keys(gift)[0];
			itemModel = ModelManager.instance.modelProp.getItemProp(itemId);
            txt_title.text = itemModel.name;
            txt_description.text = Tools.getMsgById('_bag_text21');
            this.btn.label = Tools.getMsgById("_jia0035");
            
            Tools.textLayout2(txt_title,img_title,378,150);
        } 
        override public function initData():void {
			listData=[];
			numArr=[];
			for(var i:int = 0; i < itemModel.boxT.length; i++) {
				var value:Array=itemModel.boxT[i];
				listData.push(ModelManager.instance.modelProp.getItemProp(value[0]));
				numArr.push(value[1]);
			}
			list.array=listData;
            this.curIndex = -1;
        }

        private function _updateItem(item:Box, index:int):void {
            var mItem:ModelItem = item.dataSource;
            var heroId:String = mItem.id.replace('item', 'hero');
            (item.getChildByName('characterBox').getChildByName('character') as ComPayType).setHeroIcon(heroId);
            var heroModel:ModelHero=ModelManager.instance.modelGame.getModelHero(heroId);
            (item.getChildByName('heroIcon') as Image).skin = heroModel.getRaritySkin(false);
            (item.getChildByName('heroName') as Label).text = Tools.getMsgById(heroModel.name);
            (item.getChildByName('img_border') as Image).visible = index === list.selectedIndex;
            item.clearEvents();
            item.on(Event.CLICK, this, this._selectHero, [index]);
        }

        private function _selectHero(index:int):void {
            if (curIndex >= 0) {
                (list.getCell(curIndex).getChildByName('img_border') as Image).visible = false;
            }
            curIndex = index;
            (list.getCell(curIndex).getChildByName('img_border') as Image).visible = true;
        }

        private function click():void {
			if(curIndex==-1) {
                ViewManager.instance.showTipsTxt(Tools.getMsgById('_jia0108'));
                return;
            }
			var obj:Object={};
			obj["item_id"] = itemModel.id;
			obj["item_num"] = 1;
			obj["range_index"]=curIndex;
			NetSocket.instance.send("use_prop",obj,Handler.create(this,this.socketCallBack));
		}
		public function socketCallBack(np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);
			ViewManager.instance.closePanel();
			// ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
            ViewManager.instance.showIcon(np.receiveData.gift_dict, Laya.stage.width * 0.5, Laya.stage.height * 0.5);
			ModelManager.instance.modelProp.event(ModelProp.event_updateprop);
		}
        override public function onRemoved():void{
            ModelGame.checkBaseBuildUpgradeGuide(ModelManager.instance.modelInside.getBase());
        }
    }
}