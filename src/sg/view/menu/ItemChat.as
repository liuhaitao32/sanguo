package sg.view.menu
{
	import ui.menu.itemChatUI;
	import sg.manager.ModelManager;
	import sg.manager.FilterManager;
	import sg.utils.Tools;
	import sg.model.ModelChat;

	/**
	 * ...
	 * @author
	 */
	public class ItemChat extends itemChatUI{
		public function ItemChat(){
			
		}

		public function setData(arr:Array):void{
			var b:Boolean = arr[1]==0;
			this.chat_btn.visible=this.chat_info.visible=true;
			this.chat_info.style.color="#ffffff";
			this.chat_info.style.fontSize=this.chat_name.fontSize;
			this.chat_btn.skin=ModelChat.channel_skin[arr[0]];
			this.chat_btn.label=arr[0]==0 && arr[1]!=0 ? Tools.getMsgById("_chat_text18") : ModelChat.channel_arr[arr[0]];

			if(b){
				this.chat_name.text=arr[3][1][1]+":  ";
				this.chat_info.innerHTML=arr[3][0];//FilterManager.instance.wordBan(arr[3][0]);
				this.chat_country.setCountryFlag(arr[3][1][2]);
				this.chat_name.visible=this.chat_country.visible=true;
				this.chat_pan.x=this.chat_name.x+this.chat_name.width;
			}else{
				this.chat_name.visible=this.chat_country.visible=false;
				this.chat_pan.x=this.chat_btn.x+this.chat_btn.width+4;
				var s:String=ModelManager.instance.modelChat.sysMessage(arr);
				this.chat_info.innerHTML=s;
			}
			
			
			this.chat_info.x=this.chat_info.y=0;
			this.chat_pan.width=this.width-this.chat_pan.x;
			this.chat_info.width=this.chat_pan.width;
			this.chat_name.y=this.chat_pan.y=(this.height-this.chat_pan.height)/2;		
		}

		public function reStart():void{
			this.chat_name.text="";
			this.chat_info.innerHTML="";
		}
	}

}