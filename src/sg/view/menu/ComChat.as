package sg.view.menu
{
	import ui.menu.comChatUI;
	import sg.manager.ModelManager;
	import sg.model.ModelChat;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.view.chat.ViewChatMain;
	import laya.utils.Handler;

	/**
	 * ...
	 * @author
	 */
	public class ComChat extends comChatUI{
		public function ComChat(){
			this.list.itemRender = ItemChat;
			this.list.renderHandler = new Handler(this,listRender);
			ModelManager.instance.modelChat.on(ModelChat.EVENT_UPDATE_BOTTOM,this,setData);	
			this.on(Event.CLICK,this,btnClick);

			setData();
		}

		private function btnClick():void{
			ViewManager.instance.showView(["ViewChatMain",ViewChatMain]);
		}

		private function setData():void{
			var newMsg:Array=ModelManager.instance.modelChat.newMSG;
			this.list.array = newMsg;
		}

		private function listRender(cell:ItemChat,index:int):void{
			cell.setData(this.list.array[index]);
		}

		
	}

}