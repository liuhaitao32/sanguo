package sg.map.view {
	import sg.utils.Tools;
	import ui.mapScene.MarchInfoUI;
	
	/**
	 * ...
	 * @author light
	 */
	public class MarchInfo extends MarchInfoUI {
		
		
		private var countDown:Number;
		private var totalTime:Number;
		
		public function MarchInfo() {
			
		}
		
		public function initUI(countDown:Number, totalTime:Number):void {			
			this.countDown = countDown;
			this.totalTime = totalTime;
			this.countDown++;
			this.troopRunning();
			this.timer.loop(1000, this, this.troopRunning);
		}
		
		
		private function troopRunning():void {
			if (this.destroyed)
				return;
			this.countDown--;			
			if(this.countDown > 0 ) {
				this.countDown_txt.text = Tools.getTimeStyle(this.countDown * 1000);
				this.time_pro.value = 1 - this.countDown / this.totalTime;
			}else {
				this.timer.clear(this,this.troopRunning);
			}
		}
	}

}