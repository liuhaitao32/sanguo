package sg.festival.view
{
    import sg.festival.model.ModelFestivalDial;
    import sg.activities.view.DialMain;
    import sg.manager.ViewManager;

    public class FestivalDial extends DialMain {
        public function FestivalDial() {
            super();
        }

		override public function onDisplay():void {
			setModel(ModelFestivalDial.instance);
		}

		override protected function chooseClick():void{
			ViewManager.instance.showView(["FestivalDialChoose",FestivalDialChoose], mModel.awardCfg);
		}
    }
}