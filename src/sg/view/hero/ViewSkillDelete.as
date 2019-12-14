package sg.view.hero
{
    import ui.hero.heroSkillDeleteUI;
    import sg.model.ModelHero;
    import sg.model.ModelSkill;
    import laya.events.Event;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.manager.ModelManager;
    import sg.utils.Tools;
    import sg.model.ModelItem;
    import sg.cfg.ConfigServer;
    import sg.model.ModelGame;
    import sg.manager.ViewManager;
    import sg.utils.StringUtil;

    public class ViewSkillDelete extends heroSkillDeleteUI{
        public var mModel:ModelHero;
        public var mModelSkill:ModelSkill;
        private var mBackItems:Object;
        public function ViewSkillDelete():void{
            this.btn_del.on(Event.CLICK,this,this.click);
            this.cb.clickHandler = new Handler(this,this.click_cb);
            this.btn_del.label = Tools.getMsgById("ViewSkillUpgrade_1");
            this.tText.text = Tools.getMsgById("ViewSkillUpgrade_1");
        }
        override public function initData():void{
            this.mModel = this.currArg[0] as ModelHero;
            this.mModelSkill = this.currArg[1] as ModelSkill;
            this.cb.selected = false;
            this.cb.visible = false;
            this.setUI();
        }
        private function setUI():void{
            var r:Number = ConfigServer.system_simple.skill_forget[1];
            //
            var p:Number = ModelItem.getMyItemNum(ConfigServer.system_simple.skill_forget[0]);
            //
            this.cb.visible = true;//p>0;
            this.cb.mouseEnabled=p>0;
            //
            this.tReel.text = "";//Tools.getMsgById("_skill2",[p]);//使用遗忘卷轴,当前拥有遗忘返还的碎片和铜币

            this.comPic.setTextWithPic(Tools.getMsgById("_skill20",[p]));
            this.checkBox.width=this.cb.width+this.comPic.width+6;
            this.checkBox.centerX=0;
            //
            var reArr:Array = this.mModelSkill.getDeleteItemsAndGold(this.mModel);
            var gold:Number = reArr[1];
            var items:Number = reArr[0];
            if(!this.cb.selected){
                gold = Math.ceil(gold*r);
                items = Math.ceil(items*r);
            }
            this.tBack.text = Tools.getMsgById("_lht63",[StringUtil.numberToPercent(this.cb.selected?1:r)]);
            // this.tItemNum.text = "返还碎片 "+items+" gold "+gold;
            // this.mItem.setNum(items+"");
            this.mItem.setData(this.mModelSkill.itemID,items);
            this.mItem.setName("");
            this.mGold.setData("gold",gold);
            this.mGold.setName("");
            // this.mItem.setNum("");
            // this.mItem.setData(this.mModelSkill.id);
            this.mItem.setBgColor(this.mModelSkill.getColor(this.mModel));
            this.mBackItems = {};
            this.mBackItems[this.mModelSkill.itemID] = items;
            // "是否遗忘等级"+this.mModelSkill.getLv(this.mModel)+"技能 "+this.mModelSkill.getName();
            var s1:String = Tools.getMsgById("_skill3",[this.mModelSkill.getLv(this.mModel),this.mModelSkill.getName()]);
            var delete_lv:Number = this.mModel.getMySkillInitLv(this.mModelSkill.id);
            var s2:String = delete_lv == 0 ? "" : Tools.getMsgById("_skill22",[delete_lv]);
            this.tInfo.text = s1+s2; 
        }
        private function click_cb():void{
            var p:Number = ModelItem.getMyItemNum(ConfigServer.system_simple.skill_forget[0]);
            if(p>0){
                this.setUI();
            }
            else{
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_lht46"));
            }
        }
        private function click():void{
            ViewManager.instance.showAlert(this.tInfo.text,Handler.create(this,this.click_ok));
        }
        private function click_ok(type:int):void
        {
            if(type == 0){
                var used:int = this.cb.selected?1:0;
                NetSocket.instance.send(NetMethodCfg.WS_SR_HERO_SKILL_FORGET,{hid:this.mModel.id,skill_id:this.mModelSkill.id,forget_item:used},Handler.create(this,this.ws_sr_hero_skill_forget));
            }
        }
        private function ws_sr_hero_skill_forget(re:NetPackage):void{
            // Trace.log("ws_sr_hero_skill_forget",re.receiveData);
            ModelManager.instance.modelUser.updateData(re.receiveData);
            //
            this.mModel.event(ModelGame.EVENT_HERO_SKILL_CHANGE);
            //
            this.closeSelf();
            //
            //ViewManager.instance.showRewardPanel(this.mBackItems);
            ViewManager.instance.showRewardPanel(re.receiveData.gift_dict);
        }
    }
}