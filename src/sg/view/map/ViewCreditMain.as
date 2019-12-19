package sg.view.map
{
	import ui.map.creditMainUI;
	import sg.cfg.ConfigServer;
	import laya.utils.Tween;
	import laya.utils.Handler;
	import laya.maths.MathUtil;
	import laya.events.Event;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.utils.Tools;
	import sg.manager.AssetsManager;
	import sg.manager.EffectManager;
	import sg.model.ModelUser;
	import sg.utils.SaveLocal;
	import sg.view.effect.CreditResult;
	import laya.display.Animation;
	import ui.map.item_creditUI;
	import sg.utils.StringUtil;
	import sg.guide.model.ModelGuide;
	import laya.maths.Point;

	/**
	 * ...
	 * @author
	 */
	public class ViewCreditMain extends creditMainUI{

		private var c_lv:Number=0;//当前等级
		private var c_num:Number=0;//当前进度
		private var c_max:Number=0;//当前等级最大值
		private var cur_lv:Number=0;//界面里显示等级
		private var config_credit:Object={};
		private var is_add:Boolean=false;
		private var list_data:Array=[];
		private var next_credit:Number=0;
		private var user_credit_get:Array=[];
		private var day_refresh_arr:Array=[];
		private var year_refresh_arr:Array=[];
		private var next_time_day:Number=0;
		private var next_time_year:Number=0;
		private var user_list_data:Array=[];
		public var gift_dict:Array=[];
		public var myCom:Item_User;
		public var getNum:Number=0;//已领奖数
		public var yetArr:Array=[];//未领取列表

		public var add_max:Number;
		public var rool_arr:Array;
		public var rool_num:Number;
		public var mRool:Number=0;
		public var userRool:Number;

		public var mIsMerge:Boolean=false;
		
		public function ViewCreditMain(){
			this.btnUp.on(Event.CLICK,this,click,[0]);
			this.btnDown.on(Event.CLICK,this,click,[1]);

			this.btn1.on(Event.CLICK,this,click,[3]);
			this.tab.labels = Tools.getMsgById("_credit_text01") + "," + Tools.getMsgById("_credit_text02");
			this.tab.on(Event.CHANGE,this,this.tabChange);

			this.userList.scrollBar.visible=false;
			this.userList.itemRender=Item_User;
			this.userList.renderHandler=new Handler(this,userListRender);
			this.btnInfo.on(Event.CLICK,this,function():void{
				ViewManager.instance.showTipsPanel(Tools.getMsgById(ConfigServer.credit.credit_info));
			});

			this.btn.on(Event.CLICK,this,getCrditGift);
			this.btn.label = Tools.getMsgById("_jia0036");
			this.btn1.label = Tools.getMsgById("_credit_text11");

			this.btntest.on(Event.CLICK,this,function():void{
				SaveLocal.deleteObj(SaveLocal.KEY_CREDIT_RESULT+ModelManager.instance.modelUser.mUID,true);
			});

			this.comNum.on(Event.CLICK,this,function():void{
				ViewManager.instance.showItemTips("item041",ModelManager.instance.modelUser.year_credit);
			});

			this.label0.text=Tools.getMsgById("_country14");
			this.label1.text=Tools.getMsgById("_more_rank07");
			this.label2.text=Tools.getMsgById("_lht18");
			this.label3.text=Tools.getMsgById("_credit_text26");
			this.label4.text=Tools.getMsgById("_public207");

			ModelManager.instance.modelUser.on(ModelUser.EVENT_UPDATE_CREDIT,this,function():void{
				ViewManager.instance.closeScenes();			
			});

			this.text12.text=Tools.getMsgById("_credit_text07");// "后重置战功，结算战功等级";
			this.text21.text=Tools.getMsgById("_credit_text09");//"排名重置计时";

			Tools.textLayout(this.text12,this.text11,this.text11BG,this.timeBox);
			Tools.textLayout(this.text21,this.text22,this.text21BG,this.box2Top);

		}

		override public function onAdded():void{
			mIsMerge=ModelManager.instance.modelUser.isMerge;
			this.btnUp.label=Tools.getMsgById("_credit_text03");
			this.btnDown.label=Tools.getMsgById("_credit_text04");
			this.btntest.visible=false;
			this.setTitle(Tools.getMsgById("200041"));
			chackUpLv();
			config_credit=mIsMerge ? ConfigServer.credit['merge_'+ModelManager.instance.modelUser.mergeNum] : ConfigServer.credit;
						
			textBottom.text=Tools.getMsgById("_credit_text10",[ConfigServer.credit.list_reward_time[0][0],ConfigServer.credit.list_reward_long]);
			setData();
			setUI();
			
			this.tab.selectedIndex=this.currArg?this.currArg:0;
			this.box2.visible=false;
			var n:Number=ModelManager.instance.modelUser.getGameSeason();
			tab.mouseEnabled=false;
			rewardGift();
			NetSocket.instance.send("get_credit_rank",{"is_year":true},new Handler(this,function(np:NetPackage):void{
				tab.mouseEnabled=true;
				user_list_data=np.receiveData;//[uid,uname,head,country,guild_name,year_credit,credit]
				userList.array=user_list_data;
				setMyCom();
			}));
			day_refresh_arr=[ModelManager.instance.modelUser.getGameSeason(),ConfigServer.credit.list_reward_time[0]];
			year_refresh_arr=[3,ConfigServer.credit.list_reward_time[1]];
			
			next_time_day=Tools.getNextDayStamp(day_refresh_arr[1]);
			next_time_year=Tools.getYearDis(year_refresh_arr[0],year_refresh_arr[1]);

			time_tick();
			timer.loop(1000,this,time_tick);
			tabChange();

			this.midLabel.text=Tools.getMsgById("_credit_text18");
			this.midLabel.visible=false;

			c_lv || mIsMerge || ModelGuide.executeGuide('credit_guide');
		}

		public function setMyCom():void{
			if(myCom==null){
				myCom=new Item_User();
				this.box2.addChild(myCom);
				myCom.pos((this.imgUser.width-myCom.width)/2,this.imgUser.y+(this.imgUser.height-myCom.height)/2);
			}
			var b:Boolean=false;
			for(var i:int=0;i<user_list_data.length;i++){
				if(user_list_data[i][0]+""==ModelManager.instance.modelUser.mUID){
					myCom.setData(user_list_data[i],i);
					myCom.setReward(gift_dict[i]);
					b=true;
					break;
				}
			}
			if(!b){
				myCom.list.visible=false;
				myCom.indexLabel.text="";
				myCom.comIndex.setRankIndex(0,Tools.getMsgById("_public101"),true);
				myCom.nameLabel.text=ModelManager.instance.modelUser.uname;
				myCom.comHead.setHeroIcon(ModelUser.getUserHead(ModelManager.instance.modelUser.head));
				myCom.comCountry.setCountryFlag(ModelManager.instance.modelUser.country);
				myCom.comNum.text=ModelManager.instance.modelUser.year_credit+"";
			}
		}

		public function setData():void{
			user_credit_get=ModelManager.instance.modelUser.credit_get_gifts;
			this.comNum.setData(AssetsManager.getAssetItemOrPayByID("item041"),ModelManager.instance.modelUser.year_credit+"");
			c_lv=ModelManager.instance.modelUser.credit_lv;
			c_num=ModelManager.instance.modelUser.year_credit;
			c_max=c_lv<config_credit.clv_up.length-1 ? config_credit.clv_up[c_lv] : config_credit.clv_max;
			userRool=ModelManager.instance.modelUser.credit_rool_gifts_num;
			is_add=c_num>=c_max;
			add_max=config_credit.clv_added[c_lv]*config_credit.clv_added_ratio[config_credit.clv_added_ratio.length-1];
			rool_arr=config_credit.clv_rool_reward[c_lv];
			rool_num=rool_arr[1];
			if(is_add){
				if(c_num>add_max){
					mRool=Math.floor((c_num-add_max)/rool_num);
				}
			}
			getCurData(c_lv);
			
			
		}

		private function getCurData(lv:int):void{
			if(lv<0){
				return;
			}
			list_data=[];
			
			getGetNum();
			if(getNum!=15){
				is_add=false;//非额外未领完
			}
			yetArr=[];
			
			var n:Number     = (lv==c_lv) && is_add ? config_credit.clv_added[lv]        : config_credit.clv_first[lv];
			var reward:Array = (lv==c_lv) && is_add ? config_credit.clv_added_reward[lv] : config_credit.clv_first_reward[lv];
			var b:Boolean=false;
			for(var i:int=0;i<15;i++){
				var o:Object={};
				o["item"]=reward[i];
				o["credit"] = (lv==c_lv) && is_add ? Math.floor(n*config_credit.clv_added_ratio[i]) : Math.floor(n*config_credit.clv_first_ratio[i]);
				var is_get:Number=-1;
				var nn:Number=i;
				if(i<5){
					nn+=10;
				}else if(i>=10){
					nn-=10;
				}				
				//o["sort"]=nn;//列表排序
				o["index"]=i;//真正的索引值
				if(lv==c_lv){
					if(!b && o["credit"]>=ModelManager.instance.modelUser.year_credit){
						next_credit=o["credit"];
						b=true;
					}

					if(o["credit"]<=ModelManager.instance.modelUser.year_credit){
						is_get=0;
					}
				
					if(user_credit_get.indexOf(i+"_"+Number(is_add))!=-1){
						is_get=1;
						if(is_add){
							getNum+=1;
						}
						
					}
					o["is_get"]=is_get;//-1不可领   0可领   1已领
				}else{
					o["is_get"]=-1;
				}
				if(is_get==0){
					yetArr.push(i);
				}
				list_data.push(o);

			}

			this.btn.gray=yetArr.length==0 && userRool==mRool;			
			cur_lv=lv;
			this.curBox.visible  = c_lv==cur_lv;
			this.btnUp.visible   = lv!=0;
			this.btnDown.visible = lv<c_lv+1 && lv<=config_credit.clv_up.length-1;
			if(mIsMerge) this.btnDown.visible=this.btnUp.visible=false;
			
			if(is_add){
				this.roolBox.visible=c_lv==cur_lv;
				this.upBox.visible=false;
				this.panel.width=400;
			}else{
				this.img.visible = (lv==c_lv);

				this.upBox.visible=true;
				this.panel.width=500;
				if(config_credit.clv_up[cur_lv]){
					this.upNum.setData(AssetsManager.getAssetItemOrPayByID("item041"),config_credit.clv_up[cur_lv]+"");
					this.upNum.visible=true;
					this.upLabel.text=this.upBox.visible?cur_lv+2+"":"";
				}else{
					this.upNum.visible=false;
					this.upLabel.text=Tools.getMsgById("_credit_text25");
				}
				Tools.textFitFontSize(this.upLabel, null, 70);
			}
			if(mIsMerge)
				this.titleLabel.text= Tools.getMsgById("_credit_text27");
			else
				this.titleLabel.text= (lv==c_lv) && is_add ? Tools.getMsgById("_credit_text06",[lv+1]) : Tools.getMsgById("_credit_text05",[lv+1]);
			
		}

		public function getGetNum():void{
			getNum=0;
			for(var j:int=0;j<15;j++){
			if(user_credit_get.indexOf(j+"_"+Number(false))!=-1){
					getNum+=1;
				}
			}
		}


		public function setUI():void{
			this.setItemCom();
			var n:Number=ModelManager.instance.modelUser.year_credit;
			var nn:Number=config_credit.clv_first[c_lv]*config_credit.clv_first_ratio[config_credit.clv_first_ratio.length-1];
			var m:Number=c_max;
			n-=nn;
			m-=nn;
			this.img.width = this.upBox.width;
			if(n>0 && n<m && c_lv==cur_lv){
				this.img.visible = true;
				this.img.width *= (n/m < 0.1 ? 0.1 : n/m>=1 ? 1 : n/m > 0.9 ? 0.9 : n/m);
			}else{
				this.img.visible = false;
			}

			if(c_num >= c_max){
				this.img.visible = true;
			}
			setRoolCom();

		}

		public function setRoolCom():void{
			this.roolBox.visible=false;
			this.roolCom.off(Event.CLICK,this,getRoolGift);

			if(is_add){
				this.roolBox.visible=true;
				this.roolLabel.text=(mRool-userRool<0?0:mRool-userRool)+"";
				var n1:Number=rool_num-((add_max+(mRool+1)*rool_num)-c_num);
				var n2:Number=rool_num;
				this.roolImg.height=n1/n2 > 1 ? 1 : (n1/n2<0 ? 0 : n1/n2) * 90;
				this.roolNum.setData(AssetsManager.getAssetItemOrPayByID("item041"),rool_num+"");
				var rool_obj:Object=rool_arr[0];
				this.roolCom.setMoreData(rool_obj);
				this.roolCom.visibleOnlyIcon(false);
				this.roolCom.setNum("");
				if(Tools.getDictLength(rool_obj)==1){
					for(var key:String in rool_obj){
						this.roolGet.text="x"+rool_obj[key];
						break;
					}
					this.roolGet.visible=this.roolBG.visible=true;
				}else{
					this.roolGet.visible=this.roolBG.visible=false;
				}

				var ani:Animation;
				if(this.roolBox.getChildByName("roolAni")){
					ani=this.roolBox.getChildByName("roolAni") as Animation;
					ani=EffectManager.loadAnimation("glow_credit_rool","",0,ani);
				}else{
					ani=EffectManager.loadAnimation("glow_credit_rool");
					ani.blendMode="light";
					ani.name="roolAni";
					this.roolBox.addChild(ani);
					ani.pos(roolBox.width/2,78);
				}
				ani.visible=false;
				if(userRool < mRool){
					this.roolCom.on(Event.CLICK,this,getRoolGift);
					ani.visible=true;
				}
			}
		}

		public function tabChange():void{
			if(tab.selectedIndex==0){
				this.box1.visible=true;
				this.box2.visible=false;
				this.midLabel.visible=false;
			}else if(tab.selectedIndex==1){
				this.box1.visible=false;
				this.box2.visible=true;
				this.midLabel.visible=this.userList.array.length==0;
			}
		}

		public function click(type:int):void{
			switch(type)
			{
				case 0:
					getCurData(cur_lv-1);
					this.setItemCom();
					break;
				case 1:
					getCurData(cur_lv+1);
					this.setItemCom();
					break;
				case 2:					
					break;
				case 3:
					ViewManager.instance.showView(["ViewCreditGift",ViewCreditGift],[1,0]);
					break;
				default:
					break;
			}
		}


		public function get_credit_rank(type:int):void{
			var b:Boolean=type==0;
			NetSocket.instance.send("get_credit_rank",{"is_year":!b},new Handler(this,socketCallBack,[type]));
		}

		private function socketCallBack(type:int,np:NetPackage):void{
			var arr:Array=np.receiveData;//[uid,uname,head,country,guild_name,year_credit,credit]
			var n:Number=-1;
			for(var i:int=0;i<arr.length;i++){
				if(arr[i][0]+""==ModelManager.instance.modelUser.mUID){
					n=i;
					break;
				}
			}			
			ViewManager.instance.showView(["ViewCreditGift",ViewCreditGift],[type,n+1]);
		}

		public function setItemCom():void{
			var credit_num:Number=ModelManager.instance.modelUser.year_credit;
			for (var i:int = 0; i < 15; i++){
				var cell:item_creditUI = this["com" + i] as item_creditUI;
				var obj:Object=list_data[i];
				var ani:Animation;
				if(cell.getChildByName("ani")){
					ani=cell.getChildByName("ani") as Animation;
				}else{
					ani=null;
				}
				cell.imgGet.visible=obj.is_get==1;
				cell.numLabel.text="x"+Tools.textSytle(obj.item[1]);
				cell.imgIcon.skin=AssetsManager.getAssetPayIconBig(obj.item[0]);
				cell.comPay.setData(AssetsManager.getAssetItemOrPayByID("item041"),obj.credit);	
				cell.imgBg.visible=true;
				cell.imgCircle.skin=!is_add?"ui/bg_zhangong11.png":"ui/bg_zhangong11_1.png";
				cell.imgIcon.gray=true;
				var n:Number = cell.width;
				if(cur_lv==ModelManager.instance.modelUser.credit_lv){
					if(obj.credit<=credit_num){
						cell.imgIcon.gray=false;
						cell.imgBg.width=n;
						if(ani!=null){
							ani.visible=true;
						}
						if(ani==null && obj.is_get!=1){
							ani=EffectManager.loadAnimation("glow041");
							ani.scaleX=1.2;
							ani.scaleY=1.2;
							cell.addChild(ani);
							ani.name="ani";
							ani.pos(cell.width/2,48);
						}
					}else if(obj.credit==next_credit){
						if(i==0 || i==1 || i==2 || i==6 || i==7 || i==8 || i==12 || i==13 || i==14){
							cell.imgBg.scaleX=1;
							cell.imgBg.x=0;
						}else{
							cell.imgBg.scaleX=-1;
							cell.imgBg.x=n;
						}
						var temp:Number=i>0 ? list_data[i-1].credit : 0;
						cell.imgBg.width=credit_num==0?0:n*((credit_num-temp)/(obj.credit-temp));
					}else{
						cell.imgBg.visible=false;
					}
				}else{
					if(ani!=null){
						ani.visible=false;
					} 
					cell.imgBg.visible=false;
				}				
				cell.off(Event.CLICK,this,this.itemClick);
				cell.on(Event.CLICK,this,this.itemClick,[list_data[i].index,list_data[i].is_get]);		
			}
		}

		public function setGet(index:int):void{
			var cell:item_creditUI = this["com" + index] as item_creditUI;
			cell.imgGet.visible=true;
			
			if(cell.getChildByName("ani")){
				cell.removeChild(cell.getChildByName("ani"));				
			}
		}

		public function userListRender(cell:Item_User,index:int):void{
			cell.setData(this.userList.array[index],index);
			cell.userBtn.off(Event.CLICK,this,userClick);
			cell.userBtn.on(Event.CLICK,this,userClick,[this.userList.array[index][0]]);
			cell.setReward(this.gift_dict[index]);
		}

		private function userClick(_id:*):void{
			ModelManager.instance.modelUser.selectUserInfo(_id);
		}

		public function rewardGift():void{
			gift_dict=[];
			var list_length:Number=ConfigServer.credit.list_reward_long;
			var config_list_data:Array=ConfigServer.credit.list_reward_day;
			
			for(var i:int=0;i<config_list_data.length;i++){
				var o:Array=config_list_data[i];
				var n:Number=0;
				n=(i==config_list_data.length-1)?list_length+1:config_list_data[i+1][0];
				for(var j:int=o[0];j<n;j++){
					var a:Array= o.concat();
					a[0]=j;
					gift_dict.push(a);
				}	
			}

		}


		public function itemClick(index:int,get:Number):void{
			if(get!=0){
				ViewManager.instance.showItemTips(list_data[index].item[0]);
				return;
			}
			var sendData:Object={};
			sendData["level"]=[index];
			sendData["is_add"]=is_add;
			var cell:item_creditUI = this["com" + index] as item_creditUI;
			var pos:Point = Point.TEMP.setTo(cell.x + cell.width/2, cell.y+cell.height/2);
			pos = cell['parent'].localToGlobal(pos, true);
			NetSocket.instance.send("get_credit_gift",sendData,new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				user_credit_get=ModelManager.instance.modelUser.credit_get_gifts;
				ViewManager.instance.showIcon(np.receiveData.gift_dict_list[0],pos.x,pos.y);
				setGet(index);
				if(yetArr.indexOf(index)!=-1){
					yetArr.splice(yetArr.indexOf(index),1);
				}
				getGetNum();
				if(getNum==15){
					setData();
					setUI();
				}
			}));
		}

		public function getCrditGift():void{
			if(btn.gray){
				return;
			}
			
			if(yetArr.length!=0){
				var sendData:Object={};
				sendData["level"]=yetArr;
				sendData["is_add"]=is_add;
				NetSocket.instance.send("get_credit_gift",sendData,new Handler(this,function(np:NetPackage):void{
					ModelManager.instance.modelUser.updateData(np.receiveData);
					user_credit_get=ModelManager.instance.modelUser.credit_get_gifts;
					ViewManager.instance.showRewardPanel(np.receiveData.gift_dict_list);
					for(var i:int=0;i<15;i++){
						setGet(i);
					}
					setData();
					setUI();
				}));
			}else{
				getRoolGift();
			}
			
		}

		public function getRoolGift():void{
			NetSocket.instance.send("get_credit_rool_gift",{},new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
				setData();
				setRoolCom();
			}));
		}


		public function time_tick():void{
			next_time_day-=1000;
			next_time_year-=1000;
			if(this.tab.selectedIndex==0){
				this.text11.text=Tools.getTimeStyle(next_time_year);
			}else if(this.tab.selectedIndex==1){
				this.text22.text=Tools.getTimeStyle(next_time_year);
			}
		}

		private function chackUpLv():void{
			if(config_credit.clv_up && config_credit.clv_up.length!=0){//战功可升级时
				var o:Object=SaveLocal.getValue(SaveLocal.KEY_CREDIT_RESULT+ModelManager.instance.modelUser.mUID,true);
				if(Tools.isNullString(o)){
					o={};
				}else{
					var n:Number=ModelManager.instance.modelUser.credit_year;
					if(o["credit_year"]!=n){
						var oo:Object={};
						oo["num0"]=o["credit_lv"];
						oo["num1"]=ModelManager.instance.modelUser.credit_lv;
						oo["credit_num"]=o["credit_num"];
						ViewManager.instance.showViewEffect(CreditResult.getCreditResult(oo));
					}
				}
				setLocal(o);
			}
			
		}

		public function setLocal(obj:Object):void{
			obj["credit_year"]=ModelManager.instance.modelUser.credit_year;//年份
			obj["credit_lv"]=ModelManager.instance.modelUser.credit_lv;//战功等级
			obj["credit_num"]=ModelManager.instance.modelUser.year_credit;
			SaveLocal.save(SaveLocal.KEY_CREDIT_RESULT+ModelManager.instance.modelUser.mUID,obj,true);
		}


		override public function onRemoved():void{
			timer.clear(this,time_tick);
			this.tab.selectedIndex=-1;
		}

		/**
		 * 根据名字获取界面中的对象
		 * @param	name
		 * @return 	Sprite || undefined
		 */
		override public function getSpriteByName(name:String):* {
            var item:* = null;
			if (name.indexOf('tab') !== -1 && name.length === 5) {
				item = this.tab.items[parseInt(name[name.length - 1])];
				if (item)    return item;
            }
            return super.getSpriteByName(name);
		}
	}

}

import ui.map.item_creditUI;
import sg.manager.AssetsManager;
import sg.manager.ModelManager;
import ui.map.item_credit_userUI;
import sg.utils.Tools;
import sg.model.ModelUser;
import laya.ui.Image;
import laya.display.Animation;
import sg.manager.EffectManager;
import laya.utils.Handler;
import ui.bag.bagItemUI;
import sg.model.ModelItem;

class Item extends item_creditUI{


	private var bg_height:Number=0;
	private var is_get:Number=0;
	private var credit_num:Number=0;
	private var ani:Animation;
	public function Item(){
		bg_height=this.imgBg.height;
		
	}

	public function setData(obj:Object,next:int,curlv:int):void{
		//trace(obj);
		credit_num=ModelManager.instance.modelUser.year_credit;		
		is_get=obj.is_get;
		this.imgGet.visible=is_get==1;
		this.numLabel.text="x"+Tools.textSytle(obj.item[1]);
		this.imgIcon.skin=AssetsManager.getAssetPayIconBig(obj.item[0]);
		this.comPay.setData(AssetsManager.getAssetItemOrPayByID("item041"),obj.credit);		
		this.imgBg.visible=true;
		this.imgIcon.gray=true;
		if(curlv==ModelManager.instance.modelUser.credit_lv){
			if(obj.credit<=credit_num){
				this.imgIcon.gray=false;
				this.imgBg.height=bg_height;
				if(ani!=null){
					ani.visible=true;
				}
				if(ani==null && !is_get){
					ani=EffectManager.loadAnimation("glow041");
					ani.scaleX=1.2;
					ani.scaleY=1.2;
					this.addChild(ani);
					ani.pos(this.width/2,43);
				}
			}else if(obj.credit==next){
				this.imgBg.height=credit_num==0?0:bg_height*(credit_num/obj.credit);
			}else{
				this.imgBg.visible=false;
			}
		}else{
			if(ani!=null){
				ani.visible=false;
			} 
			this.imgBg.visible=false;
		}
		
	}

	public function setGet():void{
		this.imgGet.visible=true;
		if(ani){
			this.removeChild(ani);
			ani=null;
		}
	}
}



class Item_User extends item_credit_userUI{

	public function Item_User(){
		
	}

	public function setData(arr:Array,index:int):void{//[uid,uname,head,country,guild_name,year_credit,credit]
		this.indexLabel.text="";//(index+1)+"";
		this.comIndex.setRankIndex(index+1,"",true);
		this.nameLabel.text=arr[1];
		Tools.textFitFontSize(this.nameLabel);
		this.comHead.setHeroIcon(ModelUser.getUserHead(arr[2]));
		this.comCountry.setCountryFlag(arr[3]);
		this.comNum.text=arr[5]+"";
	}

	public function setReward(arr:Array):void{
		var a:Array=[];
		for(var i:int=1;i<arr.length;i++){
			if(arr[i].length!=0){
				a.push(arr[i]);
			}
		}
		this.list.renderHandler=new Handler(this,listRender);
		this.list.array=a;
	}

	public function listRender(item:bagItemUI,index:int):void{
		this.list.visible=true;
		var a:Array=this.list.array[index];
		var it:ModelItem=ModelManager.instance.modelProp.getItemProp(a[0]);
		if(it){
			var num:Number=a[1]==null?1:a[1];
			item.setData(it.id,num, -1);
		}else{
			item.setData(a[0]);	
		}
	}
}