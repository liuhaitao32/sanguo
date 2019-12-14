package sg.view.chat
{
	import ui.chat.chatBlackListUI;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.Label;
	import sg.view.com.ComPayType;
	import laya.events.Event;
	import laya.utils.Handler;
	import sg.manager.ModelManager;
	import sg.model.ModelUser;
	import sg.net.NetSocket;
	import sg.manager.ViewManager;
	import sg.net.NetPackage;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;

	/**
	 * ...
	 * @author
	 */
	public class ViewChatBlackList extends chatBlackListUI{

		public var arr:Array;
		public function ViewChatBlackList(){
			this.list.scrollBar.visible=false;
			this.list.renderHandler=new Handler(this,this.listRender);
		}

		
		public override function onAdded():void{
			setData();
			this.text1.text=Tools.getMsgById("_chat_text10");
			this.comTitle.setViewTitle(Tools.getMsgById("_chat_text10"));
		}

		public function setData():void{
			var o:Object=ModelManager.instance.modelUser.banned_users;
			arr=[];
			var m:Number=0;
			for(var s:String in o){
				var a:Array=o[s];
				var b:Array=[s,a[0],a[1]];
				this.arr.push(b);
				m+=1;
			}
			this.list.array=arr;
			
			var n:Number=ConfigServer.system_simple.blacklist_limit;
			this.numLabel.text=m+"/"+n;
			this.imgText.width=this.numLabel.width+30;
			this.numLabel.x=this.imgText.x+15;
		}


		public function listRender(cell:Box,index:int):void{
			var btn:Button=cell.getChildByName("btn") as Button;
			var name:Label=cell.getChildByName("name") as Label;
			var hero:ComPayType=cell.getChildByName("comHero") as ComPayType;
			var a:Array=this.list.array[index];
			name.text=a[1];
			hero.setHeroIcon(ModelUser.getUserHead(a[2]));
			btn.label=Tools.getMsgById("_chat_text13");
			btn.off(Event.CLICK,this,this.click);
			btn.on(Event.CLICK,this,this.click,[index]);
		}

		public function click(index:int):void{
			NetSocket.instance.send("cancel_ban_user",{"uid":Number(this.list.array[index][0])},new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				setData();
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_chat_tips06"));
			}));
		}


		public override function onRemoved():void{
			
		}
	}

}