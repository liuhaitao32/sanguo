package sg.view.com
{
	import laya.display.Node;
	import laya.events.Event;
	import laya.ui.Button;
	import sg.view.ViewPanel;

	/**
	 * ...
	 * @author
	 */
	public class sgCloseBtn {
		private var btn_close:Button;
		public function sgCloseBtn(){
		}

		public function set owner(value:Button):void{
			this.btn_close = value;
            this.btn_close.on(Event.DISPLAY, this, this._onAdded);
        }

		private function _onAdded():void
        {
			this.findPanel(this.btn_close.parent);
        }

		private function findPanel(sp:Node):void
		{
			if (sp is ViewPanel) {
				sp['sg_btn_close'] = this.btn_close;
			}
			else if (sp.parent) {
				this.findPanel(sp.parent);
			}
		}
	}

}