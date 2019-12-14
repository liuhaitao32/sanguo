package sg.view.map
{
    import laya.ui.Box;
    import sg.view.fight.ItemPKhero;
    import laya.events.Event;
    import sg.model.ModelHero;
    import laya.maths.Point;
    import sg.manager.ModelManager;
    import laya.display.Sprite;
    import sg.utils.Tools;
    import sg.model.ModelUser;
    import sg.explore.model.ModelTreasureHunting;
    import sg.manager.ViewManager;
    import laya.utils.Handler;
    import sg.cfg.ConfigClass;
    import sg.utils.SaveLocal;
    import ui.explore.pve_fightUI;

    public class ViewPVETroop extends pve_fightUI
    {
        private var mSelectItem:ItemPKhero;
        private var isDrag:Boolean = false;
        private var hidArr_mine:Array;
        protected var saveKey:String = '';
        protected var mMaxTroop:int = 1;
        protected var handler:Handler;
        protected var enemyData:Object;
        public function ViewPVETroop() {
            box_pray_mine.visible = false;
            list_mine.itemRender = list_enemy.itemRender = ItemPKhero;
            this.mSelectItem = new ItemPKhero();
            this.mSelectItem.mouseEnabled = false;
            this.mSelectItem.mouseThrough = true;
            this.mSelectItem.visible = false;
            this.mBox.addChild(this.mSelectItem);
            
            btn_fight.label = Tools.getMsgById('_lht65');
            this.on(Event.MOUSE_DOWN,this,this.onDown);
            this.on(Event.MOUSE_UP,this,this.onUp);
            this.on(Event.CLICK,this,this.onClick);
            btn_fight.on(Event.CLICK, this, this._onClickFight);
        }

		override public function initData():void {
            currArg.title && comTitle.setViewTitle(currArg.title);
            currArg.saveKey && (saveKey = currArg.saveKey);
            currArg.mMaxTroop && (mMaxTroop = currArg.mMaxTroop);
            currArg.enemyData && (enemyData = currArg.enemyData);
            currArg.handler && (handler = currArg.handler);
            list_mine.repeatY = list_enemy.repeatY = mMaxTroop;
            mBox.height = 500 + (mMaxTroop - 3) * 100;
            bar1.width = bar2.width = 366 + (mMaxTroop - 3) * 100;
            hidArr_mine = SaveLocal.getValue(saveKey) as Array;
            this.refreshMineList();
            if (enemyData.country) {
                var modelUser:ModelUser = ModelManager.instance.modelUser;
                name_mine.text = modelUser.uname;
                name_enemy.text = enemyData.uname;
                icon_mine.visible = icon_enemy.visible = true;
                icon_mine.setCountryFlag(modelUser.country);
                icon_enemy.setCountryFlag(enemyData.country);
            }
            else {
                var enemy_num:int = enemyData.troop.length;
                name_mine.text = Tools.getMsgById("_building32",[list_mine.array.length + "/" + enemy_num]);
                name_enemy.text = Tools.getMsgById("_building33",[enemy_num + "/" + enemy_num]); // 敌方部队(5/5);
                icon_mine.visible = icon_enemy.visible = false;
            }
            list_enemy.array = enemyData.troop;
        }

        private function refreshMineList():void {
            var heroArr:Array = ModelManager.instance.modelUser.getMyHeroArr(true,"",null,true);
            heroArr = heroArr.map(function(md:ModelHero):Object { return md.id }, this);
            if (hidArr_mine is Array) {
                hidArr_mine = hidArr_mine.filter(function(hid:String):Boolean { return heroArr.indexOf(hid) !== -1; });
                if (hidArr_mine.length < mMaxTroop && heroArr.length >= hidArr_mine.length) {
                    hidArr_mine = heroArr.slice(0, mMaxTroop);
                }
            }
            else {
                hidArr_mine = heroArr.slice(0, mMaxTroop);
            }
            var mineArr:Array = hidArr_mine.map(function(hid:String, index:int, arr:Array):Object { return {index: index, data: ModelManager.instance.modelGame.getModelHero(hid), mine: true} }, this);
            list_mine.array = mineArr;
        }

        private function onDown(evt:Event):void{
            if(evt.target is ItemPKhero){
                var item:ItemPKhero = evt.target as ItemPKhero;
				if(!item.isMe || item.mStatus !== 1) return;
                var point:Point = (mSelectItem.parent as Sprite).globalToLocal((item.parent as Sprite).localToGlobal(Point.TEMP.setTo(item.x, item.y)));
                this.mSelectItem.pos(point.x, point.y);
                this.mSelectItem.setDataMe(item.mIndex, item.mModel);
                this.mSelectItem.visible = true;
                this.mSelectItem.mDropItem = item;
                this.mSelectItem.startDrag();
            }
        }
       
        private function onUp(evt:Event):void{
            if(evt.target is ItemPKhero){
                var item:ItemPKhero = evt.target as ItemPKhero;
                if(item.isMe && item.mStatus == 1){
                    if(item.mIndex!=this.mSelectItem.mIndex){
                        var dIndex:int = item.mIndex;
                        var dModel:ModelHero = item.mModel;
                        if(this.mSelectItem.mDropItem){
                            item.setDataMe(dIndex, mSelectItem.mModel);
                            hidArr_mine[dIndex] = mSelectItem.mModel.id;
                        }
                        if(this.mSelectItem.mDropItem){
                            this.mSelectItem.mDropItem.setDataMe(mSelectItem.mIndex, dModel);
                            hidArr_mine[mSelectItem.mIndex] = dModel.id;
                        }
                    }
                }
            }
            this.mSelectItem.mDropItem = null;
            this.mSelectItem.stopDrag();
            this.mSelectItem.visible = false;
        }

        private function onClick(evt:Event):void{
            if(evt.target is ItemPKhero){
                var self:ViewPVETroop = this;
                var item:ItemPKhero = evt.target as ItemPKhero;
				if(!item.isMe || item.mStatus !== 1) return;
                ViewManager.instance.showView(ConfigClass.VIEW_CHANGE_HERO, {
                    filterHeros: hidArr_mine,
                    handler: Handler.create(this, function(hid:String):void {
                        self.hidArr_mine[self.hidArr_mine.indexOf(item.mModel.id)] = hid;
                        self.refreshMineList();
                    })
                });
            }
        }

        private function _onClickFight(event:Event):void {
            var hids:Array = (list_mine.cells.slice(0, hidArr_mine.length) as Array).map(function(item:ItemPKhero):String {return item.mModel.id}, this);
            SaveLocal.save(saveKey, hids);
            ViewManager.instance.closePanel();
            handler.runWith([hids]);
        }
    }
}