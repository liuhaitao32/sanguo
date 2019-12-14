package sg.view.inside
{
    import ui.inside.buildingInfoUI;
    import sg.model.ModelBuiding;
    import laya.utils.Handler;
    import ui.inside.itemInfoUI;
    import sg.utils.Tools;
    import laya.display.Animation;

    public class ViewBuildingInfo extends buildingInfoUI{
        private var mModel:ModelBuiding;
        public function ViewBuildingInfo():void{
        }
        override public function initData():void{
            this.mModel = this.currArg as ModelBuiding;
            //
            //this.tName.text = this.mModel.getName();
            this.comTitle.setViewTitle(this.mModel.getName());
            this.tInfo.text = this.mModel.getInfo();
            this.tLv.text = Tools.getMsgById("_public6",[this.mModel.lv]);//"等级: "+this.mModel.lv+"";
            //
 			this.bIcon.destroyChildren();
            var anm:Animation = this.mModel.getAnimation();
            anm.x = (this.bIcon.width - anm.width)*0.5;
            anm.y = (this.bIcon.height - anm.height)*0.5;
			this.bIcon.addChild(anm);           
        }
        override public function onAdded():void{
            this.tInfo2.style.fontSize = 18;
            this.tInfo2.style.align = "center";
            this.tInfo2.style.valign = "middle";
            this.tInfo2.style.color = "#c3ebff";
            this.tInfo2.style.leading = 5;
            this.tInfo2.innerHTML = this.mModel.getIntroduceStr();
        }
    }   
}