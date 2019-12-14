package sg.view.inside
{
	import ui.inside.pveMainUI;
	import laya.ui.Box;
	import ui.inside.pveItemUI;
	import laya.utils.Handler;
	import sg.manager.ViewManager;
	import laya.events.Event;
	import sg.cfg.ConfigClass;
	import laya.ui.Image;
	import sg.cfg.ConfigServer;
	import laya.maths.MathUtil;
	import sg.manager.ModelManager;
	import sg.utils.Tools;
	import sg.model.ModelUser;
	import laya.ui.Label;
	import sg.view.com.ComPayType;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.model.ModelGame;
	import laya.ui.ProgressBar;
	import ui.inside.pveItem01UI;
	import ui.inside.pveItem02UI;
	import ui.inside.pveItem03UI;
	import sg.view.ViewPanel;
	import ui.inside.pveItem04UI;
	import laya.display.Animation;
	import sg.manager.EffectManager;
	import sg.manager.LoadeManager;
	import sg.manager.AssetsManager;
	import sg.model.ModelAlert;

	/**
	 * ...
	 * @author
	 */
	public class ViewPVEMain extends pveMainUI{

		
		public var listData:Array=[];
		public var configData:Object={};
		public var userData:Object={};
		public var fight_battle_id:String="";//打到第几关的关卡名(唯一的)
		public var fight_battle_index:Number=0;//打到第几关卡的索引
		public var fight_chapter_index:Number=0;//打到第几章的索引
		public var fight_chapter_id:String="";//打到第几章的id
		public var select_chapter_id:String="";//选中章节id
		public var select_chapter_index:int=0;//选中的章节
		public var is_big_battle:Boolean=false;//是否大关
		
		public var _mouseX:Number=0;
		public var box_arr:Array=[];
		public var chapter_reward_limit:Array=[];
		public var combat_times_buy:Array=[];
		public var boxY:Number=0;
		public var ani:Animation;
		public var aniPosObj:Object={};
		
		public function ViewPVEMain(){
			
			this.list.scrollBar.visible=false;	
			//this.list.stopDrag();
			this.list.renderHandler=new Handler(this,this.listRender);
			this.list.scrollBar.touchScrollEnable=false;
			this.list.on(Event.MOUSE_DOWN,this,this.listOnDown);
			this.list.on(Event.MOUSE_UP,this,this.listOnUp);
			this.comLeft.on(Event.CLICK,this,leftClick);
			this.comRight.on(Event.CLICK,this,rightClick);
			this.box1.on(Event.CLICK,this,boxClick,[0]);
			this.box2.on(Event.CLICK,this,boxClick,[1]);
			this.box3.on(Event.CLICK,this,boxClick,[2]);
			box_arr=[this.comBox1,this.comBox2,this.comBox3];
			this.btnAdd.on(Event.CLICK,this,this.addClick);
			
			
		}

		public function eventCallBack(b:Boolean):void{
			if(!b){
				setData();
			}else{
				userData=ModelManager.instance.modelUser.pve_records;
				getCurStar();
				this.list.refresh();
				setNumText();
			}
		}

		public function eventCallBack2():void{
			userData=ModelManager.instance.modelUser.pve_records;
			setNumText();
		}

		override public function onAdded():void{	
			ModelManager.instance.modelUser.on(ModelUser.EVENT_PVE_UPDATE,this,eventCallBack);
			ModelManager.instance.modelGame.on(ModelGame.EVENT_PK_TIMES_CHANGE,this,eventCallBack2);

			this.text0.text=Tools.getMsgById("_pve_text01");
			this.setTitle(Tools.getMsgById("add_pve"));	
			ani=EffectManager.loadAnimation("glow023","",0);
			ani.name="ani";
			setData();
			//setTitleText();
			//getCurStar();
			this.list.y=Tools.getAdaptationY(-100,0);
			
		}

		public function setData():void{
			configData=ConfigServer.pve;
			combat_times_buy=configData.combat_times_buy;
			chapter_reward_limit=configData.chapter_reward_limit;
			userData=ModelManager.instance.modelUser.pve_records;
			setListData();
			select_chapter_index=fight_chapter_index;
			if(fight_battle_index==11 && listData[fight_chapter_index+1]){
				if(listData[fight_chapter_index+1].unlock_level){
					var n:Number=listData[fight_chapter_index+1].unlock_level;
					var nn:Number=ModelManager.instance.modelInside.getBase().lv;
					if(nn>=n){
						select_chapter_index=fight_chapter_index+1;
					}
				}else{
					select_chapter_index=fight_chapter_index+1;
				}
			}
			this.list.scrollTo(select_chapter_index);
			select_chapter_id=listData[select_chapter_index].id;
			
			setTitleText();//设置标题
			getCurStar();//设置奖励宝箱
			setNumText();//设置次数
			setComBtn();//设置左右按钮
		}

		public function addClick():void{
			var arr:Array=ModelManager.instance.modelUser.pveBuyArr();
			if(arr[1]==0){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_public46"));//"今天不能买了"
				return;
			}
			ViewManager.instance.showBuyTimes(2,arr[0],arr[1],arr[2]);
		}

		public function rightClick():void{

			if(fight_battle_index==11){
				if(select_chapter_index>fight_chapter_index){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_building38"));
					return;
				}
			}else{
				if(select_chapter_index>fight_chapter_index-1){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_building38"));
					return;
				}
			}
			var obj:Object=listData[select_chapter_index+1];
			var n:Number=obj && obj.unlock_level ? obj.unlock_level : 0;
			if(n>ModelManager.instance.modelInside.getBase().lv){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_public47",[n]));//官邸等级到达{}
				return;
			}

			if(select_chapter_index<this.list.array.length-1){
				select_chapter_index+=1;
				listTweenTo();
			}
			

		}

		public function leftClick():void{
			if(select_chapter_index>0){
				select_chapter_index-=1;
				listTweenTo();
			}
		}

		public function listTweenTo():void{
			list.tweenTo(select_chapter_index,200);
			select_chapter_id=listData[select_chapter_index].id;
			setTitleText();
			getCurStar();
			setComBtn();
		}

		public function setComBtn():void{
			comLeft.visible=!(select_chapter_index==0);
			comRight.visible=!(select_chapter_index==this.list.array.length-1);
			listData[select_chapter_index-1] && ModelGame.redCheckOnce(this.comLeft,ModelAlert.red_pve_reward(listData[select_chapter_index-1].id));
			listData[select_chapter_index+1] && ModelGame.redCheckOnce(this.comRight,ModelAlert.red_pve_reward(listData[select_chapter_index+1].id));
		}

		public function setNumText():void{
			this.numLabel.text=""+ModelManager.instance.modelUser.pveTimes()[0]+"";
		}




		public function listOnDown():void{
			_mouseX=this.list.mouseX;
		}

		public function listOnUp():void{
			if(this.list.mouseX-_mouseX>100){
				leftClick();
			}else if(_mouseX-this.list.mouseX>100){
				rightClick();
			}else{
				listTweenTo();
			}
			//trace(this.list.mouseX-_mouseX);
		}
		


		public function setListData():void{
			fight_battle_id=userData.battle_id;
			listData=[];
			var b:Boolean=false;
			for(var v:String in configData.chapter)
			{
				var o:Object=configData.chapter[v];
				o["id"]=v;
				o["index"]=v.substr(7,3);	
				var battle:Object=o.contain_battle;
				o["contain_battle"]=battle;					
				listData.push(o);
			}
			listData.sort(MathUtil.sortByKey("index",false,true));
			if(fight_battle_id=="battle000"){
				fight_battle_index=0;
				fight_chapter_index=0;
			}else{
				fight_chapter_index=Tools.getDictLength(userData.chapter)<=1?0:Tools.getDictLength(userData.chapter)-1;
				fight_battle_index=listData[fight_chapter_index].contain_battle.indexOf(fight_battle_id);
			}
			fight_chapter_id=listData[fight_chapter_index].id;
			this.list.array=listData;			
			select_chapter_id=listData[select_chapter_index].id;
			
			
		}

		public function setTitleText():void{
			this.titleLabel.text=Tools.getMsgById(listData[select_chapter_index].id);
			this.markLabel.text=listData[select_chapter_index].hasOwnProperty("skill_bag_limit")?Tools.getMsgById("_building39",[listData[select_chapter_index].skill_bag_limit]):"";//"满星通过可解锁"++"级技能":""
		}

		public function listRender(cell:Item,index:int):void{
			var b:Boolean=false;
			var o:Object=listData[index];
			
			var tm:ViewPanel;
			var box:Box;
			//trace("==============",index,o.type);
			if(cell.getChildByName("panel")){
				cell.removeChild(cell.getChildByName("panel"));	
			}else{
				//trace("222222222222222222");
				//tm=cell.getChildByName("panel") as ViewPanel;
			}
			var ad:String = "img_map01.jpg";
			if(o.type==1){
				tm=new pveItem01UI() as ViewPanel;
				ad = "img_map01.jpg";
			}else if(o.type==2){
				tm=new pveItem02UI() as ViewPanel;
				ad = "img_map02.jpg";
			}else if(o.type==3){
				tm=new pveItem03UI() as ViewPanel;
				ad = "img_map03.jpg";
			}else if(o.type==4){
				tm=new pveItem04UI() as ViewPanel;
				ad = "img_map04.jpg";
			}
			LoadeManager.loadTemp(tm["adImg"],AssetsManager.getAssetsAD(ad));
			tm.name="panel";
			cell.addChild(tm);			
			if(Tools.isNullObj(tm)){
				// trace("================",o);
			}
			
			box=tm.getChildByName("box0") as Box;			
			var pos_arr:Array=[];
			for(var i:int = 0; i < 12; i++)
			{
				var d:Object=configData.battle[o.contain_battle[i]];
				var img:Image=box.getChildByName("img"+i) as Image;
				pos_arr.push([img.x,img.y]);
				img.mouseEnabled=true;
				img.gray=true;
				//img.scale(1,1);
				img.alpha=1;
				img.off(Event.CLICK,this,this.itemClick);
				img.on(Event.CLICK,this,this.itemClick,[i]);
				if(d.battle_type==0){
					img.skin= AssetsManager.getAssetsUI("img_dian01.png");//img_dian03.png
				}
				
				if(fight_battle_id=="battle000"){
					if(i==0){
						//setAni();
						img.gray=false;
					}
				}else{
					if(index==fight_chapter_index){//当前章节
						if(fight_battle_index>=i){
							if(d.battle_type==0){
								img.mouseEnabled=false;
								img.skin=AssetsManager.getAssetsUI("img_dian03.png");
							}
							img.gray=false;
						}
						if(fight_battle_index!=11 && fight_battle_index+1==i){
								//img.alpha=0.5;
								//setAni();
								img.gray=false;
						}
					}else if(index<fight_chapter_index){//之前的章节
						if(d.battle_type==0){
							img.mouseEnabled=false;
							img.skin=AssetsManager.getAssetsUI("img_dian03.png");
						}
						img.gray=false;
					}else{//新章节
						if(i==0){
							//setAni();
							img.gray=false;
						}
					}
					if(img.gray){
						img.mouseEnabled=false;
					}
				}				
			}

			if(!aniPosObj.hasOwnProperty(listData[index].id)){
				aniPosObj[listData[index].id]=pos_arr;
			}
			if(box.getChildByName("ani")){
				box.removeChild(box.getChildByName("ani"));
			}
			var m:Number=fight_chapter_index;
			var n:Number=fight_battle_index+1;
			if(fight_battle_id=="battle000"){
				n=0;
			}
			m=n==12?m+1:m;
			n=n==12?0:n;
			
			if(index==m){
				box.addChild(ani);		
				var pos:Array=aniPosObj[listData[m].id][n];
				var _img:Image=box.getChildByName("img"+n) as Image;
				ani.pos(pos[0]+_img.width/2 - 10,pos[1]+_img.height/2 - 5);
			}



			for(var j:int=0;j<4;j++){
				var bo:Box=(tm.getChildByName("box0") as Box).getChildByName("box"+(j+1)) as Box;	
						
				var l:Label=bo.getChildByName("text0") as Label;
				var big_index:Number=2+3*j;
				var big_img:Image=box.getChildByName("img"+big_index) as Image;
				big_img.visible=true;
				big_img.alpha=0;
				
				bo.mouseEnabled=true;
				if(big_img.gray){
					bo.mouseEnabled=false;
				}
				bo.off(Event.CLICK,this,this.itemClick);	
				bo.on(Event.CLICK,this,this.itemClick,[big_index]);	
				var curId:String=o.contain_battle[big_index];
				var hid:String=configData.battle[curId].icon;
				if(box.getChildByName("hAni"+j)){
					box.removeChild(box.getChildByName("hAni"+j));
				}
				if(index<=m){
					var hAni:Animation=EffectManager.loadHeroAnimation(hid);
					if(big_img.gray){
						hAni.stop();
						EffectManager.changeSprSaturation(hAni,0);
					}else{
						//hAni.play();
					}					
					hAni.scaleX*=1.2;
					hAni.scaleY*=1.2;
					hAni.name="hAni"+j;					
					box.addChild(hAni);
					var hPos:Array=aniPosObj[listData[index].id][big_index];
					hAni.pos(hPos[0]+big_img.width/2,hPos[1]+big_img.height/2);
				}
				
				
				l.text=Tools.getMsgById(curId);
				var ic:ComPayType=bo.getChildByName("icon0") as ComPayType;
				var cpt:ComPayType=bo.getChildByName("com0") as ComPayType;			
				cpt.setPVEStar(0);
				ic.setHeroIcon(hid,true);
				if(userData.chapter.hasOwnProperty(o.id)){
					var star:Object=userData.chapter[o.id]["star"];
					var nn:Array;	
					if(star.hasOwnProperty(o.contain_battle[big_index])){
						nn=star[o.contain_battle[big_index]];
						var nnn:Number=0;
						for(var k:int=0;k<nn.length;k++){
							if(nn[k]==1){
								nnn+=1;
							}
						}
						cpt.setPVEStar(nnn);
					}
				}
				(tm.getChildByName("box0") as Box).setChildIndex(bo,(tm.getChildByName("box0") as Box).numChildren-1);
			}
		}




		public function itemClick(index:int):void{
			if(fight_battle_id=="battle000" && index>0){
				return;
			}
			//if(index-1>fight_battle_index){
			//	return;
			//}
			//if(fight_chapter_index+1==select_chapter_index && fight_battle_index==11 && index>0){
			//	return;
			//}
			ViewManager.instance.showView(ConfigClass.VIEW_PVE_INFO,[select_chapter_index,index]);
		}

		public function boxClick(index:int):void{
			var comBox:ComPayType = this['box' + (index+1)];
			var boxType:int = comBox['boxType'];
			if(boxType == 1){
				var sendData:Object={};
				sendData["chapter_id"]=select_chapter_id;
				sendData["reward_index"]=index;
				NetSocket.instance.send("get_pve_star_reward",sendData,Handler.create(this,openBoxCallBack));
			}else{
				ViewManager.instance.showRewardPanel(configData.chapter[select_chapter_id].reward[index],null,true);
			}
		}

		public function openBoxCallBack(np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);
			userData=np.receiveData.user.pve_records;
			ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
			getCurStar();
		}

		public function getCurStar():void{
			var n:Number=0;
			if(userData.chapter.hasOwnProperty(select_chapter_id)){
				var o:Object=userData.chapter[select_chapter_id].star;
				for(var v:String in o)
				{
					var nn:Number=0;
					for(var j:int=0;j<o[v].length;j++){
						if(o[v][j]==1){
							nn+=1;
						}
					}
					n+=nn;
				}
			}
			this.starNumLabel.text=n+"";
			(this.box_arr[0].getChildByName("pro0") as ProgressBar).value=n/chapter_reward_limit[0];
			(this.box_arr[1].getChildByName("pro0") as ProgressBar).value=(n-chapter_reward_limit[0])/(chapter_reward_limit[1]-chapter_reward_limit[0]);
			(this.box_arr[2].getChildByName("pro0") as ProgressBar).value=(n-chapter_reward_limit[1])/(chapter_reward_limit[2]-chapter_reward_limit[1]);
			for(var i:int=0;i<3;i++){
				box_arr[i].mouseEnabled=true;
				(this.box_arr[i].getChildByName("text0") as Label).text=chapter_reward_limit[i];
				//(this.box_arr[i].getChildByName("getIcon") as Image).visible=false;
				//(this.box_arr[i].getChildByName("img1") as Image).visible=true;
				//(box_arr[i].getChildByName("boxIcon") as Image).gray=false;
				var boxType:int = 0;
				if(userData.chapter.hasOwnProperty(select_chapter_id)){
					var a:Array=userData.chapter[select_chapter_id].reward;
					if(n>=chapter_reward_limit[i]){
						if (a.indexOf(i) !=-1){
							//已经领取
							//(this.box_arr[i].getChildByName("getIcon") as Image).visible=true;
							//(this.box_arr[i].getChildByName("img1") as Image).visible=false;
							//box_arr[i].mouseEnabled = false;
							boxType = 2;
						}
						else{
							//可领取
							boxType = 1;
						}
					}else{
						//不可领取
						//(box_arr[i].getChildByName("boxIcon") as Image).gray=true;
						//(this.box_arr[i].getChildByName("img1") as Image).visible=false;
					}
				}else{
					//不可领取
					//(box_arr[i].getChildByName("boxIcon") as Image).gray=true;
					//(this.box_arr[i].getChildByName("img1") as Image).visible=false;
				}
				var comBox:ComPayType = this['box' + (i+1)];
				comBox.setRewardBox(boxType);
			}
			
		}


		override public function onRemoved():void{
			ModelManager.instance.modelUser.off(ModelUser.EVENT_PVE_UPDATE,this,eventCallBack);
			ModelManager.instance.modelGame.off(ModelGame.EVENT_PK_TIMES_CHANGE,this,eventCallBack2);
			this.list.scrollTo(0);
		}
	}

}


import ui.inside.pveItem0UI;

class Item extends pveItem0UI{
	public function Item(){

	}

	public function setData():void
	{
		
	}
}