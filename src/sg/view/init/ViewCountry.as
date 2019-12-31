package sg.view.init
{
    import ui.init.viewCountryUI;

    public class ViewCountry extends viewCountryUI
    {
        private var model:ChooseCountry = null;
        public function ViewCountry() {
            model = new ChooseCountry(this);
        }
        
		override public function initData():void{
            model.initUI();
        }

        override public function onRemoved():void{
        }
    }
}