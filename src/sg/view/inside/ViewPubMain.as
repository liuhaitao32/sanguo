package sg.view.inside
{
	import ui.inside.pubMainUI;
	import laya.events.Event;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
	import laya.maths.MathUtil;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.model.ModelUser;
	import sg.model.ModelProp;
	import laya.utils.Timer;
	import sg.manager.EffectManager;
	import laya.display.Animation;
	import sg.model.ModelItem;
	import sg.boundFor.GotoManager;
	import sg.model.ModelOffice;
	import sg.achievement.model.ModelAchievement;
	import sg.manager.LoadeManager;
	import laya.display.Sprite;
	import sg.model.ModelScience;

	/**
	 * ...
	 * @author
	 */
	public class ViewPubMain extends pubMainUI{
		
		
		public var userModel:ModelUser=ModelManager.instance.modelUser;
		public var config_pub:Object=ConfigServer.pub;
		public var listData:Array=[];
		public var limitNum:Number;
		public var selcetIndex:int;
		public var isNewDay:Boolean=false;
		//public var dt:Date; 
		public var draw_times:Number;
		public var extra_times:Number;
		public var isTimerOver:Boolean=false;
		public var free_dt:Number=0;
		public var draw_dt:Number=0;
		public var isNewFree:Boolean=false;
		public function ViewPubMain(){
			this.list.itemRender=Item;
			this.list.scrollBar.visible=false;
			this.list.renderHandler=new Handler(this,updateItem);
			this.list.scrollBar.touchScrollEnable=false;
			this.on(ModelProp.event_updatePub,this,this.updateList);
			ModelManager.instance.modelProp.on(ModelProp.event_updatePub,this,this.updateList);
		}

		public function updateList():void{
			setData();
		}

		override public function onAdded():void{
			this.setTitle(Tools.getMsgById("60004"));
			//ModelManager.instance.modelProp.getUserProp(ModelManager.instance.modelUser.property);//不知道当初写这个干嘛
			setData();
			time_tick();
			Laya.timer.loop(1000,this,this.time_tick);
		}

		public function time_tick():void{
			if(Tools.isNewDay(draw_dt)){
				isNewDay=true;
				list.array=listData;
				this.limitText.text = Tools.getMsgById("_public41",[limitNum+"/"+limitNum]);//"每日限购:"+"("+limitNum+"/"+limitNum+")";//每日限购
				isTimerOver=true;
				Laya.timer.clear(this,time_tick);
			}
			if(!isNewFree && Tools.isNewDay(free_dt)){
				list.array=listData;
				isNewFree=true;
			}
		}

		public function setData():void{
			//dt=userModel.pub_records.free_time;
			draw_dt=Tools.getTimeStamp(userModel.pub_records.draw_time);
			free_dt=Tools.getTimeStamp(userModel.pub_records.free_time);
			isNewDay=Tools.isNewDay(draw_dt);
			isNewFree=Tools.isNewDay(free_dt);
			limitNum=config_pub.draw_limit;
			listData=[];
			for(var value:String in config_pub){
				if(value.substr(0,8)=="hero_box"){
					var data:Object=config_pub[value];
					data["index"]=value.substr(value.length-1,1);
					data["id"]=value;
					listData.push(data); 
				}
			}
			
			listData.sort(MathUtil.sortByKey("index",false,false));
			this.list.array=listData;
			draw_times=limitNum-userModel.pub_records.draw_times;
			extra_times=userModel.pub_records.extra_times;
			this.limitText.text=Tools.getMsgById("_public41",[draw_times+"/"+limitNum]);//"每日限购:"+"("+draw_times+"/"+limitNum+")";//每日限购
		}


		public function updateItem(cell:Item,index:int):void{
			var data:Object=listData[index];
			var costStr:Array=[data.cost[0],data.cost[1]];
			if(data["prop_cost"]){
				var b:Boolean=ModelManager.instance.modelProp.isHaveItemProp(data.prop_cost[0],data.prop_cost[1]);
				if(b) costStr=[data.prop_cost[0],data.prop_cost[1]];
			}
			cell.img1.visible=false;
			cell.img2.visible=false;
			cell.text5.text="";
			
			var effort_arr:Array=config_pub[list.array[index].id].effort_add;
			var effort_add_num:Number=ModelAchievement.getAchiAddNum(effort_arr);
			//if(effort_arr){
			//	for(var i:int=0;i<effort_arr.length;i++){
			//		var arr:Array=effort_arr[i];
			//		if(ModelAchievement.isGetAchi(arr[0])){
			//			effort_add_num+=arr[1];
			//		}
			//	}
			//}
			var science_add_num:Number=ModelScience.func_sum_type(ModelScience.more_number,data.id);
			var office_add_num:Number=ModelOffice.func_addhero(data.id)+ModelOffice.func_highbox(data.id);
			var nnn:Number = data.reward_hero + effort_add_num + science_add_num + office_add_num;
			
			cell.btnBuy.off(Event.CLICK,this,this.onCLick);
			cell.btnBuy.on(Event.CLICK,this,this.onCLick,[index]);
			cell.txt_check.text = Tools.getMsgById('_jia0109');
			cell.txt_check.off(Event.CLICK,this,this.checkClick);
			cell.txt_check.on(Event.CLICK,this,this.checkClick,[index]);
			
			if(index==0){
				var n1:Number=listData[index].free+ModelManager.instance.modelInside.getBuildingModel("building005").lv;
				var n2:Number=userModel.pub_records.free_times;
				if(isNewDay || isNewFree){
					n2=0;
				} 
				cell.setData(data.id,"",nnn+"",["gold",costStr[1]+"("+(n1-n2)+"/"+n1+")"],index);
			}else{
				cell.setData(data.id,data.reward_gold,nnn+"",costStr,index);
				if(index==2){
					var str:String="";//"已买"+extra_times;
					if(extra_times==0){
						//str+="  首次购买必出国士";
						cell.img1.visible=true;
					}else{
						var n:Number=extra_times%3;
						if(n==0){
							cell.img1.visible=true;
							// str+="  本次必出国士";
						}else{
							str=""+(3-n);//+"次后，必出国士";
							cell.img2.visible=true;
							cell.text5.text=str;
							
						}
						
					}
					cell.setOtherInfo(str);
				} 
			}
		}

		public function onCLick(index:int):void{
			if(!ModelManager.instance.modelUser.isPubCanBuy(index)){
				return;
			}
			var sendData:Object={};
			sendData["pid"]=listData[index].id;
			selcetIndex=index;
			//Trace.log("酒馆发消息",sendData.pid);
			ViewPubShowHero.title_index=index;
			NetSocket.instance.send("pub_hero",sendData,Handler.create(this,this.SocketCallBack));
		}

		public function checkClick(index:int):void{
			ViewManager.instance.showView(ConfigClass.VIEW_SHOW_PROBABILITY,[listData[index].id, listData[index].show_chance]);
		}

		public function SocketCallBack(np:NetPackage):void{
			//Trace.log("酒馆收到消息--",np.receiveData);
			ModelManager.instance.modelUser.updateData(np.receiveData);
			/*
			ModelManager.instance.modelProp.getRewardProp(np.receiveData.random_prop_dict);//gift_dict
			var o:Object=np.receiveData.gift_dict;
			for(var v:String in o)
			{
				if(v=="coin"|| v=="gold" || v=="food" || v=="wood" || v=="iron" || v=="merit"){
					var ooo:Object={};
					ooo[v]=o[v];
					ViewManager.instance.showIcon(ooo,this.width/2,this.height/2);
				}else{

					var im:ModelItem=new ModelItem();
					var im2:ModelItem=ModelManager.instance.modelProp.getItemProp(v);
					im.initData(im2.name,im2.id,im2.info,im2.type,im2.icon,im2.source,im2.ratity,im2.index,"");
					im.addNum=o[v];
					ModelManager.instance.modelProp.rewardProp.push(im);
				}
			}*/
			ViewPubShowHero.data=listData[selcetIndex];
			//GotoManager.boundForPanel(GotoManager.VIEW_PUB_SHOW_HERO);
			ViewManager.instance.showView(["ViewPubShowHero2",ViewPubShowHero2],[selcetIndex,listData[selcetIndex],np.receiveData]);
			setData();
			if(isTimerOver){
				Laya.timer.loop(3000,this,this.time_tick);
				isTimerOver=false;
			}
		}

		override public function onRemoved():void{
			Laya.timer.clear(this,this.time_tick);
		}

		/**
		 * 根据名字获取界面中的对象
		 * @param	name
		 * @return 	Sprite || undefined
		 */
		override public function getSpriteByName(name:String):*
		{
			var result:Array = name.match(/list_(\d)_(\w+)/);
            if(result) {
				var index:int = parseInt(result[1]);
				var btn_name:String = result[2];
				var cell:Sprite = this.list.getCell(index);
				if (cell && cell[btn_name]) {
					return cell[btn_name];
				}
            }
            return super.getSpriteByName(name);
		}
	}

}

import ui.inside.pubItemUI;
import sg.manager.AssetsManager;
import sg.utils.Tools;
import sg.model.ModelOffice;
import sg.manager.LoadeManager;
import sg.cfg.ConfigServer;

class Item extends pubItemUI
{
	public var ad_arr:Array=["pub_001.jpg","pub_002.jpg","pub_003.jpg"];
	public function Item(){
		//this.btnCheck.label = Tools.getMsgById("_star_text05");
		this.txt_check.text = Tools.getMsgById("_star_text05");
	}
	
	public function setData(_title:String,num1:String,num2:String,cost:Array,index:int):void
	{
		LoadeManager.loadTemp(this.bgImg,AssetsManager.getAssetsAD(ad_arr[index]));
		//
		this.imgBuy.visible=true;
		this.text4.text="x"+num2;
		this.imgBuy.skin=AssetsManager.getAssetItemOrPayByID("gold");
		this.text3.text=Tools.getMsgById("_public43");//"赠送";//赠送
		if(index==0){
			this.text1.text="";
			this.text2.text="";
			this.text4.text="x"+num2;
			this.imgBG0.visible=false;
			this.imgBuy.visible=false;
		}else{
			this.imgBuy.visible=true;
			this.text1.text=Tools.getMsgById("_public44");//"购买";
			this.text2.text=num1;
		}
		this.btnBuy.setData(AssetsManager.getAssetItemOrPayByID(cost[0]),cost[1]);
		//this.title.text=_title;
		//this.text5.text=num3;
	}

	public function setOtherInfo(s:String):void{
		this.text5.text=s;
	}
} 