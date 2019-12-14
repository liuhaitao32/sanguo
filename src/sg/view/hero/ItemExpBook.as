package sg.view.hero
{
    import ui.bag.bagItemUI;
    import laya.events.Event;
    import sg.model.ModelItem;
    import sg.net.NetSocket;
    import sg.net.NetMethodCfg;
    import laya.utils.Handler;
    import sg.net.NetPackage;
    import sg.model.ModelHero;
    import sg.manager.ModelManager;
    import sg.utils.Tools;
    import laya.maths.Rectangle;
    import sg.manager.ViewManager;

    public class ItemExpBook extends bagItemUI{
        private var mModel:ModelItem;
        private var mModelHero:ModelHero;
        public function ItemExpBook():void{
            super();
            
        }
        public function init(hero:ModelHero,md:ModelItem):void{
            this.hitArea = new Rectangle(0,0,this.width,this.height);
            this.mModelHero = hero;
            this.mModel = md;
            
            //
            this.changeUI();
        }
        private function changeUI():void{
            // this.labelNum.text = this.mModel.num+"";
            // this.labelName.text = this.mModel.id;
            // trace("-----------------------------------------",this.mModel.icon);
            //this.setData(this.mModel.icon,this.mModel.ratity,Tools.getMsgById(this.mModel.name));
            //this.setNum(this.mModel.num+"");
            this.setData(this.mModel.id,this.mModel.num);
        }
    }
}