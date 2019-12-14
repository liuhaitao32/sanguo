package sg.map.view {
	import ui.ViewTestFightUI;
	
	/**
	 * ...
	 * @author light
	 */
	public class ViewTestFight extends ViewTestFightUI {
		
		public function ViewTestFight() {
			
		}
		
		override public function closeSelf(onlySelf:Boolean = true):void {
			super.closeSelf(onlySelf);
			MapViewMain.instance.outFight(this.currArg);
		}
		
	}

}