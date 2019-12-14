package sg.view.guild
{
	import ui.guild.guildMemberUI;
	import ui.guild.guildMemberItemUI;
	import laya.events.Event;
	import laya.maths.MathUtil;
	import sg.model.ModelUser;
	import sg.manager.ModelManager;
	import sg.utils.Tools;
	import laya.utils.Handler;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigServer;
	import sg.model.ModelGuild;
	import laya.ui.Box;
	import laya.ui.Button;
	import laya.ui.CheckBox;
	import sg.map.utils.ArrayUtils;
	import sg.cfg.ConfigClass;
	import laya.maths.Point;
	import laya.display.Sprite;

	/**
	 * ...
	 * @author
	 */
	public class ViewGuildMember extends guildMemberUI{

		public var listData:Array=[];
		public var data:Object={};
		public var userModel:ModelUser;
		public var configData:Object=ConfigServer.guild;
		//public var post_str:Array=["军团长","副团长","精英","普通成员"];
		public var curDeputyNum:int=0;//当前副团长数量
		public var curEliteNum:int=0;//当前精英数量
		public var myData:Object={};
		public var tab_arr:Array=[{id:"lv",text:Tools.getMsgById("_guild_text95")},//"官邸等级"
									{id:"atk",text:Tools.getMsgById("_guild_text96")},//"战斗力"
									{id:"build",text:Tools.getMsgById("_guild_text97")},//"建设值"
									{id:"kill",text:Tools.getMsgById("_guild_text98")},//"杀敌数"
									{id:"die",text:Tools.getMsgById("_guild_text99")}];//"战损"}];

		
		public var application_num:Number=0;//申请人数
		public function ViewGuildMember(){
			this.list.scrollBar.visible=false;
			this.list.itemRender=Item;
			this.list.renderHandler=new Handler(this,listRender);

			this.btnBG.on(Event.CLICK,this,this.bgClick);

			this.list1.renderHandler=new Handler(this,listRender2);
			this.list1.selectHandler=new Handler(this,tabChange);

		}

		override public function onAdded():void{
			//btn1.label="战斗力";
			//btn2.label="建设";
			//btn3.label="杀敌";
			//btn4.label="战损";
			//this.btnBG.width=this.width;
			//this.btnBG.height=this.height;
			//this.btnBG.centerX=this.btnBG.centerY=0;
			this.list1.array=tab_arr;
			userModel=ModelManager.instance.modelUser;
			data=this.currArg;
			
			getListData();
			tabClick(0);
			
		}
		public function getListData():void{
			application_num=0;
			listData=[];
			curDeputyNum=0;
			curEliteNum=0;
			myData={};
			var o:Object=this.currArg.application;//申请人列表
			var u:Object=this.currArg.u_dict;//成员列表
			if(ModelManager.instance.modelGuild.isLeadOrVice(ModelManager.instance.modelUser.mUID)){
				for(var s:String in o)
				{
					var d:Object={};
					d["id"]=Number(s);
					d["dt"]=Tools.getTimeStamp(o[s][0]);
					d["arr"]=o[s];//0.申请时间   1. 名字  2. 等级  3. 战斗力  4.是否太守  5 在线状态(1在线  时间是上次离线)   6.各种数据记录
					d["sort"]=1;
					d["time"]=o[s][5];
					d["lv"]=o[s][2];
					d["atk"]=o[s][3];
					d["kill"]=o[s][6]["kill_num"];
					d["build"]=o[s][6]["build_count"];
					d["die"]=o[s][6]["die_num"];
					//if(d["dt"]-ConfigServer.getServerTimer()<Tools.oneDayMilli){
						listData.push(d);
					//}else{
						//trace("guild_member warning:有一条入团申请超过24小时");
					//}
					application_num+=1;
				}
			}
			
			var n:Number=1;
			for(var ss:String in u)
			{
				
				var dd:Object={};
				dd["id"]=Number(ss);
				dd["arr"]=u[ss];//0. 职位   1. 名字  2. 等级  3. 战斗力  4.是否太守  5 在线状态(1在线  时间是上次离线)   6.各种数据记录
				dd["sort"]=0;
				dd["lv"]=u[ss][2];
				dd["atk"]=u[ss][3];
				dd["time"]=u[ss][5];
				dd["kill"]=u[ss][6]["kill_num"];
				dd["build"]=u[ss][6]["build_count"];
				dd["die"]=u[ss][6]["die_num"];
				dd["index"]=n;
				n+=1;
				if(u[ss][0]==1){
					curDeputyNum+=1;
				}else if(u[ss][0]==2){
					curEliteNum+=1;
				}
				if(ss==ModelManager.instance.modelUser.mUID){
					myData=dd;
				}
				listData.push(dd);
			}
			//this.list.array=listData;
			
		}

		public function listRender(cell:Item,index:int):void{
			if(this.list1.selectedIndex==-1){
				return;
			}
			var b:Boolean=myData.arr[0]<=1;
			b=listData[index].id==ModelManager.instance.modelUser.mUID?false:b;
			cell.setData(listData[index],b,index,application_num);
			//cell.btnUser.off(Event.CLICK,this,this.itemClick,[index]);
			//cell.btnUser.on(Event.CLICK,this,this.itemClick,[index]);
			cell.setSomeData(tab_arr[this.list1.selectedIndex].text,listData[index][tab_arr[this.list1.selectedIndex].id]);
			cell.btnSet.off(Event.CLICK,this,this.setClick);
			cell.btnSet.on(Event.CLICK,this,this.setClick,[index]);
			cell.btn.off(Event.CLICK,this,btnClick);
			cell.btn.on(Event.CLICK,this,btnClick,[listData[index].id]);
		}

		public function btnClick(uid:String):void{
			ModelManager.instance.modelUser.selectUserInfo(uid);
		}

		public function setMyCom(index:int):void{
			myCom.comIndex.setRankIndex(index,"",true);
			myCom.jobLabel.text=ModelGuild.post_name[myData.arr[0]];
			myCom.imgJob.visible=myData.arr[0]<2;
			myCom.imgCity.visible=myData.arr[4]==1;
			myCom.lvLabel.text=myData[tab_arr[this.list1.selectedIndex].id];
			myCom.typeLabel.text=tab_arr[this.list1.selectedIndex].text;
			myCom.nameLabel.text=userModel.uname;
			myCom.nameLabel.color="#FFFFFF";
			myCom.onLineLabel.text=Tools.getMsgById("_guild_text29");// "在线";
			myCom.onLineLabel.color="#10F010";
			myCom.btnSet.visible=false;
		}


		public function itemClick(index:int):void{
			ModelManager.instance.modelUser.selectUserInfo(listData[index].id);
		}

		public function setClick(index:int,e:Event):void{
			this.btnBG.visible=true;
			this.box1.visible=true;
			var btn:Button=e.target as Button;
			// trace(btn.x,btn.y);
			// var pos:Point = new Point(0,0);
			var pos:Point=(this.box1.parent as Sprite).globalToLocal((btn.parent as Sprite).localToGlobal(Point.TEMP.setTo(btn.x, btn.y)));
			this.box1.x=pos.x-this.box1.width;
			this.box1.y=pos.y;
			 //this.list.getCell(index).y+this.list.y+140;
			if(listData[index].hasOwnProperty("dt")){
				this.btnSet1.label=Tools.getMsgById("_guild_text90");//"通过";
				this.btnSet3.label=Tools.getMsgById("_guild_text91");//"拒绝";
				this.btnSet1.on(Event.CLICK,this,this.passOrRefuseClick,[1,index]);
				this.btnSet2.on(Event.CLICK,this,this.chatClick,[index]);
				this.btnSet3.on(Event.CLICK,this,this.passOrRefuseClick,[0,index]);
			}else{
				this.btnSet1.label=Tools.getMsgById("_guild_text92");//"升职";
				var n:Number=listData[index].arr[0];
				this.btnSet3.label=n==3?Tools.getMsgById("_guild_text94"):Tools.getMsgById("_guild_text93");//"开除":"降职";
				this.btnSet1.on(Event.CLICK,this,this.changePostClick,[0,index]);
				this.btnSet2.on(Event.CLICK,this,this.chatClick,[index]);
				this.btnSet3.on(Event.CLICK,this,this.changePostClick,[1,index]);
			}
		}

		public function bgClick():void{
			this.btnSet1.off(Event.CLICK,this,this.passOrRefuseClick);
			this.btnSet2.off(Event.CLICK,this,this.chatClick);
			this.btnSet3.off(Event.CLICK,this,this.passOrRefuseClick);
			this.btnSet1.off(Event.CLICK,this,this.changePostClick);
			this.btnSet2.off(Event.CLICK,this,this.chatClick);
			this.btnSet3.off(Event.CLICK,this,this.changePostClick);
			this.btnBG.visible=false;
			this.box1.visible=false;
			
		}

		public function chatClick(index:int):void{
			var uname:String=this.list.array[index].arr[1];

			NetSocket.instance.send("find_user",{"uname":uname},Handler.create(this,function(np:NetPackage):void{
				bgClick();
				if(np.receiveData is Boolean && !np.receiveData){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_guild_text100"));
				}else{
					var data:Object=ModelManager.instance.modelUser.getChatDataById(list.array[index].id);
					if(!data){
						var user:ModelUser=ModelManager.instance.modelUser;
						var a:Array=[];
						var b:Array=[np.receiveData,"",ConfigServer.getServerTimer(),true];
						a.push(b);
						ModelManager.instance.modelUser.setChatData(a);
						data=ModelManager.instance.modelUser.getChatDataById(list.array[index].id);
					}
					ViewManager.instance.showView(ConfigClass.VIEW_MAIL_PERSONAL,data);
				}
			}));
		}

		public function changePostClick(type:int,index:int):void{
			if(type==0){
				//trace("升职");
			}else{
				//trace("降职");
			}
			var sendData:Object={};
			sendData["uid"]=listData[index].id;
			var n:Number=listData[index].arr[0];
			var post:Number=0;
			if(type==0){
				if(n==1){
					//ViewManager.instance.showTipsTxt("不能再升了");
					ViewManager.instance.showAlert(Tools.getMsgById("_guild_tips07",[listData[index].arr[1]]),function(ind:int):void{
						if(ind==0){
							sendData["post"]=0;
							NetSocket.instance.send("guild_manage",sendData,Handler.create(this,function(np:NetPackage):void{
								bgClick();
								//trace("团长转让给了"+listData[index].arr[1]);
								ViewManager.instance.showTipsTxt(Tools.getMsgById("_guild_tips17",[listData[index].arr[1]]));
								NetSocket.instance.send("get_my_guild",{},Handler.create(this,function(re:NetPackage):void{
									currArg=re.receiveData;
									data=currArg;
									getListData();
									ModelManager.instance.modelGuild.event(ModelGuild.EVENT_UPDATE_RED);
									tabClick(list1.selectedIndex);
								}));
							}));
						}else if(ind==1){
							bgClick();
						}
						
					},null);
					return;
				}else{
					post=n-1;
				}
			}else{
				if(n==3){
					post=-1;
					//ViewManager.instance.showTipsTxt("开除成员");
				}else{
					post=n+1;
				}
			}
			if(post==1 && curDeputyNum==ModelGuild.job1_num){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_guild_tips08",[ModelGuild.post_name[1]]));//"副团长人数达到上限"
				return;
			}
			
			if(post==2 && curEliteNum==configData.configure.elite){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_guild_tips08",[ModelGuild.post_name[2]]));//"精英人数达到上限"
				return;
			}
			sendData["post"]=post;
			NetSocket.instance.send("guild_manage",sendData,Handler.create(this,socketCallBack1,[[1,index,type,post]]));
		}

		public function passOrRefuseClick(type:int,index:int):void{
			if(type==0){
				//trace("拒绝");
			}else{
				//trace("通过");
			}
			var sendData:Object={};
			sendData["uid"]=listData[index].id;
			sendData["if_pass"]=type;
			NetSocket.instance.send("guild_application_pass",sendData,Handler.create(this,socketCallBack1,[[0,index,type]]));
		}

		public function socketCallBack1(arr:Array,np:NetPackage):void{
			bgClick();
			var uname:String=listData[arr[1]].arr[1];
			var s:String="";
			if(np.receiveData){
				if(arr[0]==0){//通过或拒绝
					s=arr[2]==0?Tools.getMsgById("_guild_tips09",[uname]):Tools.getMsgById("_guild_tips10",[uname]);
					// "拒绝"+uname+"加入":"允许"+uname+"加入";
					ViewManager.instance.showTipsTxt(s);
				}else if(arr[1]==1){
					s=arr[2]==0?Tools.getMsgById("_guild_tips11",[uname,ModelGuild.post_name[arr[3]]]):Tools.getMsgById("_guild_tips12",[uname,ModelGuild.post_name[arr[3]]]);//
					//uname+"升为"+ModelGuild.post_name[arr[3]]:uname+"降为"+ModelGuild.post_name[arr[3]];
					if(arr[3]==-1){//开除
						s=Tools.getMsgById("_guild_tips13",[uname]);
					}
					ViewManager.instance.showTipsTxt(s);
				}
			}else{
				if(arr[0]==0){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_guild_tips15"));			
				}
			}

			NetSocket.instance.send("get_my_guild",{},Handler.create(this,this.socketCallBack2));
		}

		public function socketCallBack2(np:NetPackage):void{
			this.currArg=np.receiveData;
			data=this.currArg;
			getListData();	
			ModelManager.instance.modelGuild.updateData(np.receiveData);		
			ModelManager.instance.modelGuild.event(ModelGuild.EVENT_UPDATE_RED);
			
			tabClick(this.list1.selectedIndex);
		}

		public function listRender2(cell:Box,index:int):void{
			var _btn:Button=cell.getChildByName("btn") as Button;
			_btn.label=this.list1.array[index].text;
			_btn.selected=(this.list1.selectedIndex==index);
			//_btn.mouseEnabled=false;
			var _check:CheckBox=cell.getChildByName("check") as CheckBox;
			//cell.mouseEnabled=false;
			_check.selected=(this.list1.selectedIndex==index);

			cell.off(Event.CLICK,this,this.tabClick);
			cell.on(Event.CLICK,this,this.tabClick,[index]);
		}

		public function tabChange(index:int):void{
			
		}

		public function tabClick(index:int):void{
			this.list1.selectedIndex=index;
			if(index==0){

			}			
			ArrayUtils.sortOn(["sort",tab_arr[index].id],listData,true);
			this.list.array=listData;
			for(var i:int=0;i<listData.length;i++){
				var o:Object=listData[i];
				if(o.id==ModelManager.instance.modelUser.mUID){
					setMyCom(i+1-application_num);
				}
			}
			
		}



		override public function onRemoved():void{
			this.list1.selectedIndex=-1;
		}
	}

}



import ui.guild.guildMemberItemUI;
import laya.ui.Label;
import sg.model.ModelGuild;
import sg.utils.Tools;
import sg.manager.ModelManager;

class Item extends guildMemberItemUI{	
	public function Item(){

	}

	public function setData(obj:Object,b:Boolean,index:int,n:Number):void{
		//trace("===============",obj);
		if(obj.hasOwnProperty("dt")){
			this.comIndex.visible=false;
			this.onLineLabel.text="";
			this.imgJob.visible=false;
			this.jobLabel.text="";
			this.comApply.visible=true;
			this.nameLabel.text=obj.arr[1]+"";
			this.lvLabel.text="";
		}else{
			this.comApply.visible=false;
			this.comIndex.visible=true;			
			this.comIndex.setRankIndex(index+1-n,"",true);
			this.jobLabel.text=ModelGuild.post_name[obj.arr[0]];
			this.imgJob.visible=obj.arr[0]<2;
			this.btnSet.visible=!(obj.arr[0]==0);
			this.nameLabel.text=obj.arr[1]+"";
			this.nameLabel.color=obj.id==ModelManager.instance.modelUser.mUID?"#FFFFFF":"#d2e0fe";
			this.imgCity.visible=obj.arr[4]==1;
			//this.lvLabel.text=obj.arr[2]+"级";
		}
		
		if(obj.time==1){
			this.onLineLabel.text=Tools.getMsgById("_guild_text29");
			this.onLineLabel.color="#10F010";
		}else{
			this.onLineLabel.text=Tools.howTimeToNow(Tools.getTimeStamp(obj.time));
			this.onLineLabel.color="#828282";
		}
		if(!b){
			this.btnSet.visible=false;
		}
	}

	public function setSomeData(key:String,num:Number):void{
		this.typeLabel.text=key;
		this.lvLabel.text=num?num+"":"0";
	}
}