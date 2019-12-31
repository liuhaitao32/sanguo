package sg.view.init
{
    import ui.init.viewCountryPCUI;

    public class ViewCountryPC extends viewCountryPCUI {
        private var model:ChooseCountry = null;
        public function ViewCountryPC() {
            model = new ChooseCountry(this as ViewCountry);
        }
        
		override public function initData():void{
            model.initUI();
        }

        override public function onRemoved():void{
        }
    }   
}