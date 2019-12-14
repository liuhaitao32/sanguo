package sg.view.mail
{
	import ui.mail.mailPersonalUI;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import laya.events.Event;
	import sg.cfg.ConfigServer;
	import sg.manager.ModelManager;
	import ui.mail.chatItemUI;
	import laya.maths.MathUtil;
	import sg.utils.Tools;
	import sg.model.ModelUser;
	import sg.utils.SaveLocal;
	import sg.manager.FilterManager;
	import sg.manager.ViewManager;
	import sg.model.ModelGame;
	import laya.ui.VBox;
	import sg.model.ModelChat;

	/**
	 * ...
	 * @author
	 */
	public class ViewMailPersonal extends mailPersonalUI{

		public var mdata:Object={};
		public var listData:Array=[];
		public var chatData:Array=[];

		private var mTime:Number=0;
		public function ViewMailPersonal(){
			this.list.itemRender=Item;
			this.list.scrollBar.visible=false;
			this.list.renderHandler=new Handler(this,listRender);
			this.sendBtn.on(Event.CLICK,this,this.sendClick);
			

			this.panel.vScrollBar.visible=false;
			
		}

		public function eventCallBack(a:Array):void{
			//trace("callback    ",a);
			if(a){
				var o:Array=a[0];
				if(o && o.uid+""==mdata.uid+""){
					this.mdata.data=o;
					setListData(a);
					this.comTitle.setViewTitle(mdata.data.uname);
				}
			}
		}

		override public function onAdded():void{
			this.vb.destroyChildren();
			this.panel.visible=false;
			this.panel.vScrollBar.changeHandler=null;
			ModelManager.instance.modelUser.on(ModelUser.EVENT_UPDATE_MAIL_CHAT_MAIN,this,eventCallBack);
			chatData=[];
			this.inputLabel.prompt = Tools.getMsgById("_chat_text14");//"请输入你想说的话";
			this.inputLabel.text="";
			this.inputLabel.maxChars=100;
			this.mdata=this.currArg;
			mdata.data.read=true;
			var localData:Object=SaveLocal.getValue(SaveLocal.KEY_CHAT+ModelManager.instance.modelUser.mUID,true);
			if(Tools.isNullString(localData)){
				localData = {};
			}
			localData[mdata.data.uid]=mdata;
			SaveLocal.save(SaveLocal.KEY_CHAT+ModelManager.instance.modelUser.mUID,localData,true);
			getListData();
			//this.nameLabel.text=mdata.data.uname;
			//this.nameBG.width=this.nameLabel.width+80;
			this.comTitle.setViewTitle(mdata.data.uname);
			mTime=ConfigServer.getServerTimer();
		}

		public function getListData():void{
			listData=[];
			listData=this.mdata.content;
			listData.sort(MathUtil.sortByKey("time",false,false));

			for(var i:int=0;i<listData.length;i++){
				var n:Number = listData[i-1] ? listData[i-1].time : 0;
				chatHandler(listData[i],n);
			}
			this.list.array=listData;
			this.list.scrollBar.value=this.list.scrollBar.max;
			//trace("-----------------",listData);			
			//initPanel();
			//this.panel.vScrollBar.changeHandler=new Handler(this,panelScrollChange);
		}

		public function setListData(a:Array):void{
			chatData.push(a);
			var n:Number=a[2] is Number ? a[2]:Tools.getTimeStamp(a[2]);
			var me:Boolean=a.length==4 && a[3];
			var o:Object={"time":n,"text":a[1],"me":me,"uid":a.uid};
			var nn:Number = listData.length > 0 ? listData[listData.length-1].time : 0;
			chatHandler(o,nn);

			listData.push(o);
			listData.sort(MathUtil.sortByKey("time",false,false));
			this.list.array=listData;
			this.list.scrollBar.value=this.list.scrollBar.max;
		}

		/**
		 * o 聊天数据  n 上一条的时间
		 */
		private function chatHandler(o:Object,n:Number):void{
			var t:Number = o.time;
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


		private function initPanel():void{
			var len:Number=listData.length > 10 ? listData.length-10 : 0;
			for(var i:int=len;i<listData.length;i++){
				if(vb.numChildren>=10){
					break;
				}
				var item:Item=new Item();
				item.name="item"+i;
				var d:Object=mdata.data;
				item.setData(listData[i],d);
				vb.addChild(item);
			}			
			this.panel.vScrollBar.max=vb.height;
			this.panel.vScrollBar.value=this.panel.vScrollBar.max;
		}

		private function panelScrollChange(v:Number):void{
			if(ConfigServer.getServerTimer()>mTime+100){
				mTime=ConfigServer.getServerTimer();
			}else{
				return;
			}
			
			// trace("===========",v);
			if(v==0 && vb.numChildren<listData.length){
				
				var n:Number=listData.length-vb.numChildren-1;
				// trace("添加聊天内容",listData.length,vb.numChildren);
				var item:Item=new Item();
				item.name="item"+(n);
				var d:Object=mdata.data;
				item.setData(listData[n],d);
				vb.addChild(item);
				for(var i:int=0;i<listData.length;i++){
					var com:Item=vb.getChildByName("item"+i) as Item;
					if(com) com.zOrder=i;
				}

				var _y:Number=0;
				for(var j:int=0;j<vb.numChildren;j++){
					var c:Item=vb.getChildAt(j) as Item;
					_y=c.y+c.height;
					if(j==0) c.y=0;
					else c.y=_y;
				}
				
			}
		}

		

		public function listRender(cell:Item,index:int):void{
			var d:Object=mdata.data;
			cell.setData(listData[index],d);
		}

		public function sendClick():void{
			if(this.inputLabel.text==""){
				return;
			}
			if(ModelGame.unlock(null,"person_limit",true).stop) return;
			if(FilterManager.instance.isLegalWord(this.inputLabel.text)){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("193005"));
				return;
			}
			var s:String=inputLabel.text.replace(/[<>&]/g,"");
			NetSocket.instance.send("send_user_msg",{"uid":Number(mdata.uid),"msg":s},Handler.create(this,function(np:NetPackage):void{
				var o:Array=[mdata.data,
							inputLabel.text,
							ConfigServer.getServerTimer(),
							true
							];
				setListData(o);
				ModelManager.instance.modelUser.setChatData([o]);
				ModelManager.instance.modelUser.event(ModelUser.EVENT_UPDATE_MAIL_CHAT,"");
				inputLabel.text="";
			}));

		}

		override public function onRemoved():void{
			ModelChat.mCurUid = "";
			ModelManager.instance.modelUser.off(ModelUser.EVENT_UPDATE_MAIL_CHAT_MAIN,this,eventCallBack);
		}
	}

}


import ui.mail.chatItemUI;
import ui.mail.chatItem0UI;
import ui.mail.chatItem1UI;
import sg.manager.ModelManager;
import sg.model.ModelUser;
import laya.events.Event;

class Item extends chatItemUI{

	public function Item(){

	}

	public function setData(obj:Object,data:Object):void{
		if(obj.hasOwnProperty("me") && obj.me){
			var it:chatItem0UI
			if(this.getChildByName("item")) this.removeChild(this.getChildByName("item"));	
			
			if(this.getChildByName("itemMe")){
				it = this.getChildByName("itemMe") as chatItem0UI;
			}else{
				it=new chatItem0UI();
				this.addChild(it);
			}

			it.name="itemMe";
			it.text0.text=obj.text;
			it.lvLabel.text=ModelManager.instance.modelInside.getBase().lv+"";
			it.com0.setHeroIcon(ModelManager.instance.modelUser.getHead());
			it.tTime.text = obj.showTime;
		}else{
			var it2:chatItem1UI;
			if(this.getChildByName("itemMe")) this.removeChild(this.getChildByName("itemMe"));	
			
			if(this.getChildByName("item")){
				it2 = this.getChildByName("item") as chatItem1UI;
			}else{
				it2 = new chatItem1UI();
				this.addChild(it2);
			}

			it2.text0.text=obj.text;
			it2.name="item";
			it2.lvLabel.text=data.lv;
			it2.com0.setHeroIcon(ModelUser.getUserHead(data.head));
			it2.com0.off(Event.CLICK,this,headClick);
			it2.com0.on(Event.CLICK,this,headClick,[data.uid]);
			it2.tTime.text = obj.showTime;
			
		}

	}

	private function headClick(uid:*):void{
		ModelManager.instance.modelUser.selectUserInfo(uid);
	}
}