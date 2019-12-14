package sg.view.chat
{
	import ui.chat.chatCheckUI;
	import laya.ui.Box;
	import laya.ui.CheckBox;
	import laya.ui.Label;
	import sg.model.ModelChat;
	import laya.events.Event;
	import laya.ui.Button;
	import laya.utils.Handler;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.utils.Tools;
	import sg.model.ModelGame;

	/**
	 * ...
	 * @author
	 */
	public class ViewChatCheck extends chatCheckUI{

		public var arr:Array=[];
		public var mData:Array=[{"text":Tools.getMsgById("_chat_text18"),"visible":true,"index":0},
								{"text":Tools.getMsgById("_chat_text03"),"visible":true,"index":1},
								{"text":Tools.getMsgById("_chat_text04"),"visible":true,"index":2},
								{"text":Tools.getMsgById("_country74"),"visible":true,"index":3}];
		public function ViewChatCheck(){
			this.list.renderHandler=new Handler(this,listRender);
			this.btn.on(Event.CLICK,this,function():void{
				closeSelf();
			});
		}


		public override function onAdded():void{
			//this.text0.text=Tools.getMsgById("_star_text20");
			this.comTitle.setViewTitle(Tools.getMsgById("_star_text20"));
			var listData:Array=[];
			if(ModelGame.unlock(null,"chat_world").stop){
				mData[1].visible=false;
			}
			for(var i:int=0;i<mData.length;i++){
				if(mData[i].visible){
					listData.push(mData[i]);
				}
			}
			arr = ModelChat.channel_seleted;
			this.list.repeatY = listData.length;
			this.list.array   = listData;
			this.list.centerY = 0;
			this.btn.label    = Tools.getMsgById("_public183");
		}

		public function listRender(cell:Box,index:int):void{
			var o:Object     = this.list.array[index];
			var btn:Button   = cell.getChildByName("btn") as Button;
			var label:Label  = cell.getChildByName("label") as Label;
			label.text       = o.text;
			btn.mouseEnabled = false;
			btn.selected=arr[o.index] == 1;
			cell.off(Event.CLICK,this,click);
			cell.on(Event.CLICK,this,click,[o.index]);
			
		}

		public function listSelect(index:int):void{

		}

		public function click(index:int):void{			
			this.list.selectedIndex=index;
			arr[index]=arr[index]==1?0:1;
			ModelManager.instance.modelChat.event(ModelChat.EVENT_UPDATE_CHANNEL);
			this.list.selectedIndex=-1;
		}




		public override function onRemoved():void{
			
		}
	}

}