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
					var n:Number = mData[i-1] ? Tools.getTimeStamp(mData[i-1].time) : 0;
					var o:Object = mData[i];
					chatHandler(o,n);
					arr.push(mData[i]);
				}
			}

			this.list.array = arr;
			this.list.scrollBar.value=this.list.scrollBar.max;
		}
				/**
		 * o 聊天数据  n 上一条的时间
		 */
		private function chatHandler(o:Object,n:Number):void{
			var t:Number = Tools.getTimeStamp(o.time);
			var tDt:Date = new Date(t);
			var nDt:Date = new Date(ConfigServer.getServerTimer());
			if(n == 0 || t - n > 1800 * 1000){
				var str0:String = '';
				if(tDt.getFullYear()!=nDt.getFullYear() || tDt.getMonth()!=nDt.getMonth() || tDt.getDate()!=nDt.getDate()){
					var _month:String = (tDt.getMonth()+1) < 10 ? "0"+(tDt.getMonth()+1) : (tDt.getMonth()+1)+"";
					var _Date:String  = tDt.getDate()<10 ? "0"+tDt.getDate() : tDt.getDate()+"";
					str0 = tDt.getFullYear() + '/' + _month + '/' + _Date;
				}
				var _hour:String    = tDt.getHours()<10   ? "0"+tDt.getHours()   : tDt.getHours()+"";
				var _min:String     = tDt.getMinutes()<10 ? "0"+tDt.getMinutes() : tDt.getMinutes()+"";
				var _secend:String  = tDt.getSeconds()<10 ? "0"+tDt.getSeconds() : tDt.getSeconds()+"";
				var str1:String = _hour + ":" + _min + ":" + _secend;
				o["showTime"] = str0 + ' '+ str1;
			}else{
				o["showTime"] = '';
			}
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

		if(obj.st == 0){//我
			var it:chatItem0UI
			if(this.getChildByName("item")) this.removeChild(this.getChildByName("item"));	
			if(this.getChildByName("itemMe")){
				it = this.getChildByName("itemMe") as chatItem0UI;
			}else{
				it=new chatItem0UI();
				this.addChild(it);
			}
			it.name = "itemMe";
			it.text0.text = obj.content;
			it.lvLabel.text = ModelManager.instance.modelInside.getBase().lv+"";
			it.com0.setHeroIcon(ModelManager.instance.modelUser.getHead());
			it.img0.visible = it.lvLabel.visible = false;
			it.tTime.text = obj.showTime;
		}else if(obj.st == 1){
			var it2:chatItem1UI;
			if(this.getChildByName("itemMe")) this.removeChild(this.getChildByName("itemMe"));	
			if(this.getChildByName("item")){
				it2 = this.getChildByName("item") as chatItem1UI;
			}else{
				it2 = new chatItem1UI();
				this.addChild(it2);
			}
			it2.name = "item";

			var cid:String = obj.content;
            var cidi:int = obj.content.indexOf("|");
            if(cidi>-1){
                cid = obj.content.substring(cidi+1,obj.content.length);
            }
			it2.text0.text = cid;
			it2.img0.visible = it2.lvLabel.visible = false;
			it2.com0.setHeroIcon(ModelUser.getUserHead(ConfigServer.system_simple.auto_reply_bug_msg[2]));
			it2.tTime.text = obj.showTime;

		}
	}
}