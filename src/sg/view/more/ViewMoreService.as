package sg.view.more
{
	import ui.mail.mailPersonalUI;
	import laya.utils.Handler;
	import laya.events.Event;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.net.NetHttp;
	import sg.manager.ModelManager;
	import sg.cfg.ConfigServer;
	import sg.model.ModelGame;
	import sg.utils.Tools;
	import sg.model.ModelUser;

	/**
	 * ...
	 * @author
	 */
	public class ViewMoreService extends mailPersonalUI{//TODO:
		public var mData:Array;
		public var arr:Array;
		public function ViewMoreService(){
			this.list.itemRender=Item;
			this.list.scrollBar.visible=false;
			this.list.renderHandler=new Handler(this,listRender);
			this.sendBtn.on(Event.CLICK,this,this.sendClick);
			ModelManager.instance.modelGame.on(ModelGame.EVENT_UPDAET_BUG_MSG,this,eventCallBack);
		}

		public function eventCallBack():void{
			var sendData:Object={"uid":ModelManager.instance.modelUser.mUID,
															"sessionid":ModelManager.instance.modelUser.mSessionid,
															"zone":ModelManager.instance.modelUser.zone};
                    
			NetHttp.instance.send("bug_msg.get_bug_msg",sendData,Handler.create(this,function(re:Object):void{
				mData=re as Array;
				setData();
			}));
		}


		public override function onAdded():void{
			ModelManager.instance.modelGame.on(ModelGame.EVENT_UPDAET_BUG_MSG,this,eventCallBack);
			//this.nameLabel.text=Tools.getMsgById("_country40");//"客服";
			//this.nameBG.width=this.nameLabel.width+80;
			//trace(this.nameLabel.width,this.nameBG.width);
			this.comTitle.setViewTitle(Tools.getMsgById("_country40"));
			this.inputLabel.prompt = Tools.getMsgById("_chat_text14");//"请输入你想说的话";
			this.inputLabel.text="";
			this.inputLabel.maxChars=100;
			mData=this.currArg;
			//trace("=================",mData);
			setData();
			ModelManager.instance.modelUser.event(ModelUser.EVENT_USER_UPDATE,[{"user":""},true]);//通知红点刷新
		}

		public function setData():void{
			arr=[];
			for(var i:int=0;i<mData.length;i++){
				if(mData[i].st==0 || mData[i].st==1){
					arr.push(mData[i]);
				}
			}
			this.list.array=arr;
			this.list.scrollBar.value=this.list.scrollBar.max;
		}

		public function listRender(cell:Item,index:int):void{
			cell.setData(this.list.array[index]);
		}

		public function sendClick():void{
			if(this.inputLabel.text==""){
				return;
			}
			NetHttp.instance.send("bug_msg.send_bug_msg",{"content":this.inputLabel.text,
															"uid":ModelManager.instance.modelUser.mUID,
															"sessionid":ModelManager.instance.modelUser.mSessionid,
															"zone":ModelManager.instance.modelUser.zone		
									},Handler.create(this,function(np:NetPackage):void{
				mData=np as Array;
				setData();
				inputLabel.text="";
				
			}));
		}



		public override function onRemoved():void{
			ModelManager.instance.modelGame.off(ModelGame.EVENT_UPDAET_BUG_MSG,this,eventCallBack);
			ModelManager.instance.modelChat.isNewBugMSG=false;
			ModelManager.instance.modelUser.event(ModelUser.EVENT_USER_UPDATE,[{"user":""},true]);//通知红点刷新
		}

		
	}

}


import ui.mail.chatItemUI;
import ui.mail.chatItem0UI;
import ui.mail.chatItem1UI;
import sg.manager.ModelManager;
import sg.model.ModelUser;
import sg.cfg.ConfigServer;

class Item extends chatItemUI{

	public function Item(){

	}

	public function setData(obj:Object,data:Object=null):void{
		if(this.getChildByName("item")){
			this.removeChild(this.getChildByName("item"));
		}
		if(obj.st==0){//我
			var it:chatItem0UI=new chatItem0UI();
			it.name="item";
			it.text0.text=obj.content;
			it.lvLabel.text=ModelManager.instance.modelInside.getBase().lv+"";
			it.com0.setHeroIcon(ModelManager.instance.modelUser.getHead());
			it.img0.visible=it.lvLabel.visible=false;
			this.addChild(it);
		}else if(obj.st==1){
			var it2:chatItem1UI=new chatItem1UI();
			var cid:String = obj.content;
            var cidi:int = obj.content.indexOf("|");
            if(cidi>-1){
                cid = obj.content.substring(cidi+1,obj.content.length);
            }
			
			it2.text0.text=cid;
			it2.name="item";
			it2.img0.visible=it2.lvLabel.visible=false;
			//it2.lvLabel.text=data.lv;
			it2.com0.setHeroIcon(ModelUser.getUserHead(ConfigServer.system_simple.auto_reply_bug_msg[2]));

			this.addChild(it2);
		}
	}
}