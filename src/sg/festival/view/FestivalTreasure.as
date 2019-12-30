package sg.festival.view
{
    import sg.festival.model.ModelFestivalTreasure;
    import sg.activities.view.TreasureMain;

    public class FestivalTreasure extends TreasureMain {
        public function FestivalTreasure() {
            super();
        }

		override public function onDisplay():void {
			setModel(ModelFestivalTreasure.instance);
		}
    }
}