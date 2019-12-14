package sg.view.init
{
    import laya.events.Event;
    import ui.init.viewAlert2UI;
    import sg.model.ModelAlert;
    import sg.manager.ModelManager;
    import sg.manager.ViewManager;
    import sg.utils.Tools;

    public class ViewAlert2 extends viewAlert2UI
    {
        public var md:ModelAlert;
        public function ViewAlert2()
        {
            this.btn.on(Event.CLICK,this,this.onClick);
        }
        override public function initData():void{
            this.text0.text=Tools.getMsgById("_public203");
            this.btn.label=Tools.getMsgById("_public183");
            this.md=ModelManager.instance.modelAlert;
            this.onlyCloseByBtn(true);
            this.txt.text=md.text;
            //
            // this.x = (Laya.stage.width - this.width)*0.5;
            // this.y = (Laya.stage.height - this.height)*0.5;
            this.width = Laya.stage.width;
            this.height = Laya.stage.height;
        }
        
        public function onClick(obj:*):void{
            md.execute(0);
			if(this.md.isWarn){
				ViewManager.instance.clearWarn();
			}
			else{
				ViewManager.instance.closePanel(this);
			}
        }
    }
}