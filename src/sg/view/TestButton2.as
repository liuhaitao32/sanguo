package sg.view
{	
	import laya.events.Event;
	import laya.ui.Box;
	import laya.utils.Handler;
	import laya.ui.Label;	
	import ui.test.TestButton2UI;

	/**
	 * ...
	 * @author
	 */
	public class TestButton2 extends TestButton2UI{
		public var str:String;
		public function TestButton2(){
			this.btn.on(Event.MOUSE_OVER,this,btnEvent);
			this.btn.on(Event.MOUSE_OUT,this,btnEvent);
			this.btn.on(Event.MOUSE_DOWN,this,btnEvent);
			this.btn.on(Event.MOUSE_UP,this,btnEvent);
			this.btn.on(Event.FOCUS,this,btnEvent);
			this.btn.on(Event.FOCUS_CHANGE,this,btnEvent);
			this.btn.on(Event.BLUR,this,btnEvent);
			this.btn.on(Event.CHANGE,this,btnEvent);
			this.btn.on(Event.FRAME,this,btnEvent);
		}


		public function btnEvent(e:Event=null):void{
			switch(e.type){
				case Event.CLICK:				
				break;
				case Event.MOUSE_OVER:
				break;
				case Event.MOUSE_DOWN:
				break;
				case Event.MOUSE_OUT:
				break;
				case Event.MOUSE_UP:
				break;
				case Event.FOCUS:
				break;
				case Event.FOCUS_CHANGE:
				break;
				case Event.BLUR:
				break;
				case Event.CHANGE:
				break;
				case Event.FRAME:
				break;
			}

			str+=e.type+"   ";
			this.label.text=str;
		}

		override public function onAdded():void{
			this.label.wordWrap=true;
			this.label.text="";

		}
		

		override public function onRemoved():void{

		}
	}

}