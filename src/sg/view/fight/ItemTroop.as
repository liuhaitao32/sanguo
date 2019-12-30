package sg.view.fight
{
    import ui.fight.itemTroopUI;
    import ui.inside.pubHeroItemUI;
    import sg.model.ModelHero;
    import laya.ui.Label;
    import sg.manager.ModelManager;
    import sg.model.ModelBuiding;
    import laya.events.Event;
    import sg.utils.Tools;

    public class ItemTroop extends itemTroopUI{
        public var mSelected:Boolean = false;
        public var mModel:ModelHero;
        public function ItemTroop():void{

        }

        override public function set dataSource(source:*):void {
            if (!source) return;
			this._dataSource = source;
            this.setData(source.selected, source.md);
            this.setIndex(Tools.getMsgById("_public88")); // 空闲
        }

        public function setData(b:Boolean,hmd:ModelHero,armyNum:Boolean = false):void{
            this.tPowerInfo.text=Tools.getMsgById("_country67");
            this.tPowerInfo.visible=false;
            this.select2.visible = false;
            this.mSelected = b;
            this.select.visible = b;
            //
            this.heroIcon.offAll(Event.CLICK);
            //
            if(hmd){
                var changeIcon:Boolean = true;
                if(this.mModel){
                    if(this.mModel.id == hmd.id){
                        changeIcon = false;
                    }
                }
                this.mModel = hmd;
                //显示ui
                if(changeIcon){
                    this.heroIcon.setHeroIcon(hmd.getHeadId(),true,hmd.getStarGradeColor());
                }
                this.tName.text = hmd.getName();
				this.comPower.setNum(hmd.getPower());
                //this.tPower.text = hmd.getPower()+"";
                this.heroType.setHeroType(hmd.getType());
                this.heroStar.setHeroStar(hmd.getStar());
                //
                this.tArmy0.text = this.mModel.getMyarmyName()[0];//.getArmyHpm(0,this.mModel.getPrepare())+"";
                this.tArmy1.text = this.mModel.getMyarmyName()[1];//this.mModel.getArmyHpm(1,this.mModel.getPrepare())+"";
                this.army0.setArmyIcon(hmd.army[0],ModelBuiding.getArmyCurrGradeByType(hmd.army[0]));
                this.army1.setArmyIcon(hmd.army[1],ModelBuiding.getArmyCurrGradeByType(hmd.army[1]));
                // this.armyLv0.setArmyLv(ModelBuiding.getArmyCurrGradeByType(hmd.army[0]));
                // this.armyLv1.setArmyLv(ModelBuiding.getArmyCurrGradeByType(hmd.army[1]));
                //
                this.barArmy0.value = 1;
                this.barArmy1.value = 1;
                //
				this.heroLv.setNum(hmd.getLv());
                //this.tlv.text = hmd.getLv()+"";
                //
                var armyPerc:Array = this.mModel.getArmyHpmPerc(this.mModel.getPrepare());
                this.tArmyNum0.text = armyNum?armyPerc[0][1]:(armyPerc[0][1]+"/"+armyPerc[0][1]);
                this.barArmy0.value = armyPerc[0][1]/armyPerc[0][1];
                //
                this.tArmyNum1.text = armyNum?armyPerc[1][1]:(armyPerc[1][1]+"/"+armyPerc[1][1]);
                this.barArmy1.value = armyPerc[1][1]/armyPerc[1][1];           
                
            }
        }
        public function setIndex(str:String):void{

            if(this["tIndex"]){
                this["tIndex"].text = str;
            }
        }
    }
}