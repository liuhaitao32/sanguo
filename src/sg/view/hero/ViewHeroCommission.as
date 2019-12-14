package sg.view.hero
{
    import sg.model.ModelHero;
    import sg.model.ModelGame;
    import sg.model.ModelUser;
    import laya.events.Event;
    import sg.manager.ModelManager;
    import ui.hero.heroCommissionUI;
    import sg.utils.ObjectUtil;
    import laya.maths.MathUtil;
    import sg.utils.Tools;
    import laya.utils.Handler;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import sg.net.NetPackage;
    import sg.model.ModelPrepare;

    public class ViewHeroCommission extends heroCommissionUI
    {
        private var mModel:ModelHero;
        private var modelGame:ModelGame = ModelManager.instance.modelGame;
        private var modelUser:ModelUser = ModelManager.instance.modelUser;
        private var heros:Object;
        private var armyPos:int;
        private var armyType:int;
        public function ViewHeroCommission(md:ModelHero):void{
            this.mModel = md as ModelHero;
            txt_tips.text = Tools.getMsgById('_jia0086');

            // 设置标题
			list.itemRender = CommissionBase;
			list.selectEnable = true;
			list.scrollBar.hide = true;
            btn.on(Event.CLICK, this, this._onClickCommission);
        }

        override public function onAddedBase():void {
            super.onAddedBase();
            mModel = this.currArg[0];
            armyPos = this.currArg[1];
            armyType = mModel.army[armyPos];
            heros = ObjectUtil.clone(modelUser.hero, true);
            var arr:Array = []; // 可作为副将的英雄列表

            var posStr:String = ModelHero.army_seat_name[armyPos];
            var armyStr:String = ModelHero.army_type_name[mModel.army[armyPos]];
            //txt_title.text = Tools.getMsgById('_jia0077') + posStr + armyStr + Tools.getMsgById('_jia0076'); // 选择前军弓兵副将
            var s:String = Tools.getMsgById('_jia0077') + posStr + armyStr + Tools.getMsgById('_jia0076'); // 选择前军弓兵副将
            this.comTitle.setViewTitle(s);
            
            // 将当前英雄移除
            heros[mModel.id] && delete heros[mModel.id];
            var troops:Object = ModelManager.instance.modelTroopManager.troops;
            var currentAdjutantData:Object = null;
            for(var hid:String in heros)
            {
                // 移除主将
                if (heros[hid]['isCommander']) {
                    delete heros[hid];
                    continue;
                }

                var hmd:ModelHero = modelGame.getModelHero(hid);  

                // 移除已编组的英雄
                if (troops[modelUser.mUID + "&" + hid]) {
                    delete heros[hid];
                    continue;
                }
                
                // 移除兵种类型不同的英雄,且不是拥有特殊能力的副将英雄,且不是特殊可安装的副将
                var adjs:Array = mModel.adjs;
                if (armyType !== hmd.army[armyPos] && !hmd.isFreeAdjutant && !(adjs && (adjs.indexOf(hid) !== -1))) {
                    delete heros[hid];
                    continue;
                }

                // 记录英雄的战力
                hmd["sortPower"] = hmd.getPower();
                var state:String = CommissionBase.STATE_NULL;
                var adjData:Object = modelUser.hero[hid];
                var commander:String = adjData.commander;
                if (commander) {
                    state = CommissionBase.STATE_IN_USE;
                    var commanderData:Object = modelUser.hero[commander];
                    if (commander === mModel.id && commanderData.adjutant.indexOf(hid) === armyPos) {
                        state = CommissionBase.STATE_CURRENT;
                    }
                }
                
                var obj:Object = {'id': hmd.id, 'model': mModel, 'panel': this, 'commander': commander, 'state': state, 'fb': armyPos, 'power': hmd["sortPower"]};
                if (obj.state === CommissionBase.STATE_CURRENT) {
                    currentAdjutantData = obj;
                }
                else {
                    arr.push(obj);
                }
            }
            
            arr.length && arr.sort(MathUtil.sortByKey("power",true));
            currentAdjutantData && arr.unshift(currentAdjutantData);
            list.array = arr;
            list.scrollTo(0);
            list.selectedIndex = 0;
        }

        private function _onClickCommission():void {
            var obj:Object = list.selectedItem;
            var adj_hid:String = obj.id;
            var commander:String = modelUser.getCommander(adj_hid);
            var commanderData:Object = modelUser.hero[commander];
            switch(obj.state) {
                case CommissionBase.STATE_NULL:
                    // 检测当前是否有副将
                    var currnetAdj:String = modelUser.hero[mModel.id].adjutant[armyPos];
                    if (currnetAdj) {
                        NetSocket.instance.send(NetMethodCfg.WS_SR_UNINSTALL_ADJUTANT, {hid: mModel.id, adj_index: armyPos}, Handler.create(this,this._uninstallAdjutantCB), mModel.id);
                    }
                    else {
                        NetSocket.instance.send(NetMethodCfg.WS_SR_INSTALL_ADJUTANT,{hid: mModel.id, adj_hid: adj_hid, adj_index: armyPos},Handler.create(this,this._installAdjutantCB));
                    }
                    break;
                case CommissionBase.STATE_IN_USE:
                case CommissionBase.STATE_CURRENT:
                    var pos:int = commanderData.adjutant.indexOf(adj_hid);
                    var sendData:Object = {hid: commander, adj_index: pos};
                    var otherData:Object = obj.state === CommissionBase.STATE_CURRENT ? '': commander;
                    NetSocket.instance.send(NetMethodCfg.WS_SR_UNINSTALL_ADJUTANT, sendData, Handler.create(this,this._uninstallAdjutantCB), otherData);
                    break;
            }
        }

        private function _uninstallAdjutantCB(re:NetPackage):void {
            var adj_hid:String = list.selectedItem['id'];
            var commander:String = re.otherData;
            modelUser.updateData(re.receiveData);
            if (commander) {
                list.selectedItem.state = CommissionBase.STATE_NULL;
                this._onClickCommission();
            }
            else {
                this.mModel.event(ModelHero.EVENT_HERO_ADJUTANT_CHANGE);
                this.closeSelf();
            }
        }

        private function _installAdjutantCB(re:NetPackage):void{
            modelUser.updateData(re.receiveData);
            this.mModel.event(ModelHero.EVENT_HERO_ADJUTANT_CHANGE);
            this.closeSelf();
        }
    }
}