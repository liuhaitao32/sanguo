package sg.view.map
{
	import laya.events.Event;
	import laya.utils.Handler;
	import ui.map.estateMainUI;
	import ui.map.estateItemUI;
	import sg.manager.ModelManager;
	import sg.model.ModelOfficial;
	import sg.cfg.ConfigServer;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.model.ModelUser;
	import sg.utils.Tools;
	import sg.model.ModelOffice;
	import sg.model.ModelScience;
	import sg.manager.AssetsManager;
	import sg.model.ModelEstate;
	import sg.map.utils.ArrayUtils;
	import sg.scene.view.MapCamera;
	import sg.guide.view.GuideFocus;
	import sg.boundFor.GotoManager;

	/**
	 * ...
	 * @author
	 */
	public class ViewEstateMain extends estateMainUI{

		private var config_estate:Object = {};
		private var config_cities:Object = {};
		private var server_cities:Object = {};
		private var user_estate:Array = [];

		private var all_estate_arr:Array = [];
		private var my_estate_arr:Array = [];
		private var my_estate_obj:Object = {};
		//private var total_num:Number=0;
		private var my_estate_arr_clone:Array = [];
		private var all_estate_arr_clone:Array = [];
		private var check_arr:Array = [];//
		private var is_can_harverst:Boolean = false;

		private var isQuick:Boolean = false;//是否可以快捷操作

		public function ViewEstateMain(){
			this.tab.on(Event.CLICK,this,this.tabChange);
			this.list.scrollBar.visible = false;
			this.list.itemRender = Item;
			this.list.renderHandler = new Handler(this,listRender);
			this.testBtn.on(Event.CLICK,this,testClick);
			this.btnCheck.on(Event.CLICK,this,function():void{
				ViewManager.instance.showView(["ViewEstateCheck",ViewEstateCheck],check_arr);
			});
			ModelManager.instance.modelUser.on(ModelUser.EVNET_ESTATE_MAIN,this,checkEvnetCallBack);
			this.checkLv.on(Event.CLICK,this,function():void{
				if(checkLv.text!=""){
					checkEvnetCallBack([check_arr[0],-1]);
				}
			});
			this.checkName.on(Event.CLICK,this,function():void{
				if(checkName.text!=""){
					checkEvnetCallBack([-1,check_arr[1]]);
				}
			});
			this.btnCheck.label = Tools.getMsgById("_star_text20");

			this.titlelabel.text = Tools.getMsgById("_estate_text27");
			Tools.textLayout(titlelabel,numLabel,titleImg,titleBox);
			titleBox.centerX = 0;
			titleBg.width = titleBox.width + 100;

			this.text0.text = Tools.getMsgById("_estate_text02");
			Tools.textLayout2(text0,text0Img);
		}

		public function checkEvnetCallBack(arr:Array):void{
			//trace("产业筛选",arr);//[type,lv]
			check_arr=arr;
			if(arr[0]==-1 && arr[1]==-1){
				my_estate_arr=my_estate_arr_clone;
				all_estate_arr=all_estate_arr_clone;
			}else{
				var a:Array=[];
				for(var i:int=0;i<my_estate_arr_clone.length;i++){
					var aa:Array=my_estate_arr_clone[i];
					
					if(arr[1]==-1){
						if(aa[1]==(arr[0]+1)+""){
							a.push(aa);
						}
					}else if(arr[0]==-1){
						if(aa[2]==(arr[1]+1)){
							a.push(aa);
						}
					}else if(arr[0]!=-1 && arr[1]!=-1){
						if(aa[1]==(arr[0]+1)+"" && aa[2]==(arr[1]+1)){
							a.push(aa);
						}
					}
				}
				my_estate_arr=a;

				var b:Array=[];
				for(var j:int=0;j<all_estate_arr_clone.length;j++){
					var bb:Array=all_estate_arr_clone[j];
					if(arr[1]==-1){
						if(bb[1]==(arr[0]+1)+""){
							b.push(bb);
						}
					}else if(arr[0]==-1){
						if(bb[2]==(arr[1]+1)){
							b.push(bb);
						}
					}else if(arr[0]!=-1 && arr[1]!=-1){
						if(bb[1]==(arr[0]+1)+"" && bb[2]==(arr[1]+1)){
							b.push(bb);
						}
					}
				}
				all_estate_arr=b;
			}
			setCheckLabel();
			tabChange();
		}

		public function setCheckLabel():void{
			this.checkName.text=check_arr[0]==-1?"":Tools.getMsgById(ConfigServer.estate.estate[(check_arr[0]+1)+""].name);
			this.checkLv.text=check_arr[1]==-1?"":Tools.getMsgById("100001",[(check_arr[1]+1)]);// (check_arr[1]+1)+"级";
			if(check_arr[0]==-1 && check_arr[1]==-1){
				this.txtBg.width = 160;
			}else{
				this.checkName.width = check_arr[0]==-1 ? 0 : checkName.textField.textWidth;
				this.checkLv.width = check_arr[1]==-1 ? 0 : checkLv.textField.textWidth;
				this.txtBg.width = this.checkName.width + this.checkLv.width + 72;
				if(check_arr[0]==-1){
					this.checkLv.x = this.txtBg.x + (this.txtBg.width - this.checkLv.width)/2;
				}else if(check_arr[1]==-1){
					this.checkName.x = this.txtBg.x + (this.txtBg.width - this.checkName.width)/2;
				}else{
					this.checkName.x = this.txtBg.x + 24;
					this.checkLv.x = this.checkName.x + this.checkName.width + 24;
				}
				
			}
			
		}

		public function testClick():void{
			if(!is_can_harverst){
				return;	
			}
			NetSocket.instance.send("estate_harvest",{},new Handler(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				if(np.receiveData.gift_dict.length!=0){	
					ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
					setData();		
					tabChange();
				}
			}));
		}



		override public function onAdded():void{
			isQuick = ModelEstate.isQuick();
			
			this.tab.labels=Tools.getMsgById("_estate_text25")+","+Tools.getMsgById("_estate_text26");
			this.testBtn.visible=this.testLabel.visible=false;
			config_estate=ConfigServer.estate;
			server_cities=ModelOfficial.cities;
			config_cities=ConfigServer.city;
			//total_num=ConfigServer.estate.frequency;//每日挂机次数
			setData();
			this.tab.selectedIndex=0;
			tabChange();
			ModelManager.instance.modelUser.on(ModelUser.EVENT_USER_UPDATE,this,this.eventCallBack);
			check_arr=[-1,-1];
			setCheckLabel();
		}

		public function eventCallBack(re:Object):void{
			if(re && re.user && re.user.estate){
				setData();
				checkEvnetCallBack(check_arr);
			}
		}

		public function setData():void{
			user_estate=ModelManager.instance.modelUser.estate;
			getMyestateObj();
			getMyestateArr();
			getAllEstateArr();
			
			this.numLabel.text=user_estate.length+"/"+ModelEstate.getTotalVacancy();//(ConfigServer.estate.vacancy+ModelOffice.func_indcount());
			var n:Array=ModelManager.instance.modelUser.getEstateHarverst();
			if(n.length==0){
				this.testLabel.text=Tools.getMsgById("msg_ViewEstateMain_0");
				is_can_harverst=false;
			}else{
				var s:String="";
				for(var i:int=0;i<n.length;i++){
					s+=n[i]+",";
				}
				this.testLabel.text=Tools.getMsgById("msg_ViewEstateMain_1")+s;
				is_can_harverst=true;
			}


			this.com0.setData(AssetsManager.getAssetItemOrPayByID("gold"),Tools.getMsgById("_estate_text20",[getProduceByKey("gold")]));
			this.com1.setData(AssetsManager.getAssetItemOrPayByID("food"),Tools.getMsgById("_estate_text20",[getProduceByKey("food")]));
			this.com2.setData(AssetsManager.getAssetItemOrPayByID("wood"),Tools.getMsgById("_estate_text20",[getProduceByKey("wood")]));
			this.com3.setData(AssetsManager.getAssetItemOrPayByID("iron"),Tools.getMsgById("_estate_text20",[getProduceByKey("iron")]));
			
		}

		public function setMidText():void{
			this.textMid.text="";
			if(tab.selectedIndex==0){
				if(this.my_estate_arr_clone.length==0){
					this.textMid.text=Tools.getMsgById("_estate_text10");//"占领产业可增加资源收益，快去占领更多产业吧";
				}else if(this.my_estate_arr.length==0){
					this.textMid.text=Tools.getMsgById("_estate_text09");//"暂无此类产业";
				}
			}else if(tab.selectedIndex==1){
				if(this.all_estate_arr_clone.length==0){
					//this.textMid.text="领产业可增加资源收益，快去占领更多产业吧";
				}else if(this.all_estate_arr.length==0){
					this.textMid.text=Tools.getMsgById("_estate_text09");//"暂无此类产业";
				}
			}

			boxMid.visible = this.list.array.length==0;
		}

		private function getProduceByKey(key:String):Number{
			var n:Number=0;
			var estate:Object=config_estate.estate;
			var e_arr:Array=[];
			for(var s:String in estate){
				var o:Object=estate[s];
				if(o.produce==key){
					e_arr.push(s);
				}
			}
			for(var i:int=0;i<my_estate_arr_clone.length;i++){
				var a:Array=my_estate_arr_clone[i];
				if(e_arr.indexOf(a[1])!=-1){
					var nn:Number=Math.floor(config_estate.passive[a[2]-1]*config_estate.estate[a[1]].ratio);
					var nnn:Number=ModelUser.estate_produce_add(a[1]);
					nn=Math.floor(nn*(1+nnn));
					n+=nn;
				}
			}
			return n;
		}

		public function getAllEstateArr():void{
			all_estate_arr=[];
			var reO:Object=ModelEstate.recommandEstate();
			for(var s:String in server_cities){
				var o:Object=server_cities[s];
				if(o.country==ModelUser.getCountryID()){
					if(config_cities[s].estate){						
						var a:Array=config_cities[s].estate;
						for(var i:int=0;i<a.length;i++){
							var e_id:String=a[i][0];
							if(!my_estate_obj.hasOwnProperty(s) || my_estate_obj[s].indexOf(i)==-1){
								var sort1:Number=10-Number(e_id);//id
								var sort2:Number=a[i][1];//lv
								var sort3:Number=0;
								if(reO.hasOwnProperty(e_id)){
									if(reO[e_id][1]==s && reO[e_id][2]==i){
										sort3=reO[e_id][0];
									}
								} 
								var sort4:Number=ModelEstate.isGold(s,i) ? 1 : 0;//是否是黄金矿
								var aaa:Array=[s,e_id,a[i][1],0,0,i,sort1,sort2,sort3,sort4];
								all_estate_arr.push(aaa);
							}
						}
					}
				}
			}
			ArrayUtils.sortOn([9,8,7,6],all_estate_arr,true);
			all_estate_arr_clone=[];
			all_estate_arr_clone=all_estate_arr.concat();
		}

		public function getMyestateArr():void{
			my_estate_arr=[];			
			for(var i:int=0;i<user_estate.length;i++){
				var o:Object = user_estate[i];
				var n:Number = Tools.isNewDay(o.active_time)?0:o.active_times;	
				var tn:Number = ModelManager.instance.modelGame.getModelEstate(o.city_id,o.estate_index).total_time;	
				var _id:String = ConfigServer.city[o.city_id].estate[o.estate_index][0];
				var _lv:Number = ConfigServer.city[o.city_id].estate[o.estate_index][1];
				var a:Array=[o.city_id,_id,_lv,n,tn,i,o.estate_index,tn-n>0?1:0,0,ModelEstate.isGold(o.city_id,o.estate_index)?1:0];
				my_estate_arr.push(a);
			}
			ArrayUtils.sortOn([9,2,7],my_estate_arr,true);
			my_estate_arr_clone=[];
			my_estate_arr_clone=my_estate_arr.concat();
			
			//trace("my_estate_arr",my_estate_arr);
		}

		public function getMyestateObj():void{
			my_estate_obj={};
			for(var i:int=0;i<user_estate.length;i++){
				var o:Object=user_estate[i];
				if(my_estate_obj.hasOwnProperty(o.city_id)){
					var a:Array=my_estate_obj[o.city_id];
					a.push(o.estate_index);
					a.sort();
				}else{
					my_estate_obj[o.city_id]=[o.estate_index];
				}
			}
			//trace("my_estate_obj",my_estate_obj);
		}

		public function listRender(cell:Item,index:int):void{
			var a:Array = this.list.array[index];//["cid","eid","lv","act_times","total_times","user_index","config_index"]
			cell.setData(a,index,tab.selectedIndex);
			cell.btn.off(Event.CLICK,this,this.itemClick);
			cell.btn.on(Event.CLICK,this,this.itemClick,[index,this.tab.selectedIndex]);

			cell.btnDel.visible = this.tab.selectedIndex == 0 && isQuick;
			cell.btnDo.visible = isQuick ? (this.tab.selectedIndex == 0 ? (a[1] != "2" && a[4] != 0) : true) : false;

			cell.btnDel.mouseThrough = cell.btnDo.mouseThrough = false;

			var cfg_index:int = this.tab.selectedIndex == 0 ? ModelManager.instance.modelUser.estate[a[5]].estate_index : a[5];
			var emd:ModelEstate = ModelManager.instance.modelGame.getModelEstate(a[0], cfg_index);

			var doName:String = ModelEstate.getEstateName(emd.id)
			cell.btnDo.label = this.tab.selectedIndex==0 ? doName : Tools.getMsgById('_estate_text30');

			if(a[4] == 0){
				cell.statusLabel.text = '';
			}else{
				var t:Number = emd.active_harvest_time;
				var now:Number=ConfigServer.getServerTimer();
				if(t==0){
					cell.statusLabel.text = '';//Tools.getMsgById("_estate_text14");//"空闲中";
				}else{
					if(t-now<=0){
						cell.statusLabel.text = Tools.getMsgById("_estate_text15",[doName]);// doName+"完成";
						cell.btnDo.visible = false;
					}else{
						cell.statusLabel.text = Tools.getMsgById("_estate_text16",[doName]);//doName+"中";
						cell.btnDo.visible = false;
					}
				}
			}
			

			cell.btnDel.off(Event.CLICK,this,this.delClick);
			cell.btnDel.on(Event.CLICK,this,this.delClick,[index]);
			cell.btnDo.off(Event.CLICK,this,this.doClick);
			cell.btnDo.on(Event.CLICK,this,this.doClick,[index]);

		}

		private function delClick(index:int):void{
			var o:* = this.list.array[index];
			var emd:ModelEstate = ModelManager.instance.modelGame.getModelEstate(o[0], o[6]);
			if(!emd.isCanDrop()){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_estate_tips04",[ConfigServer.system_simple.material_gift_cd[0]]));// "1小时之内不能放弃");
				return;
			}
			if(emd.status == 1){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_estate_tips10"));
				return;
			}
			ViewManager.instance.showAlert(Tools.getMsgById('_estate_tips08'),function(yesOrNo:int):void{
				if(yesOrNo == 0){
					NetSocket.instance.send("drop_estate",{"estate_index":o[5]},new Handler(null,function(np:NetPackage):void{
						//放弃
						var n:Number=emd.config_index;
						ModelManager.instance.modelUser.updateData(np.receiveData);
						ModelManager.instance.modelGame.removeEstate(emd.city_id,n);					
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_estate_tips03"));// "放弃产业成功");
					}));
				}
			});
			
		}

		private function doClick(index:int):void{
			var o:* = this.list.array[index];
			var emd:ModelEstate = ModelManager.instance.modelGame.getModelEstate(o[0], o[5]);
			if(this.tab.selectedIndex == 0){//产业挂机
			    var cost_item_arr:Array = ConfigServer.estate.estate[o[1]].active_prop;
				if(!Tools.isCanBuy(cost_item_arr[0],cost_item_arr[1])){
						return;
					}
					if(o[4]-o[3]<=0){
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_estate_tips02"));// "次数不足");
						return;
					}
					ViewManager.instance.showView(ConfigClass.VIEW_ESTATE_HERO,[0,o[5],0]);
			}else{//占领
				if(!ModelManager.instance.modelUser.isFinishFtask(o[0])){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_ftask_tips01"));
					return;
				}
				var cur_num:Number = ModelManager.instance.modelUser.estate.length;
				var total_times:Number = ConfigServer.estate.vacancy + ModelOffice.func_indcount();
				if(cur_num>=total_times){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_estate_tips01"));//"超出占领总数上限");
					return;
				}
				var sendData:Object = {"city_id":o[0],"estate_index":o[5],"fight":0,"v":null};
				var b:Number = !ModelOffice.func_flyestate() ? 0 : -2;
				ModelManager.instance.modelGame.checkTroopToAction(o[0],["ViewEstateHeroSend",ViewEstateHeroSend],sendData,true,b,-emd.getPower());
					
			}
		}


		public function itemClick(index:int,type:int):void{			
			var arr:Array=[];
			arr=this.list.array[index];		
			//MapCamera.lookAtEstate(arr[0],Number(arr[1]));
			var cid:String=arr[0];
			var e_index:int=0;
			if(type==0){
				e_index=arr[6];
			}else{
				e_index=arr[5];
			}			
			GotoManager.instance.boundForEstate(cid,e_index);
			//trace("=================",cid,e_index);
			this.closeSelf();
			return;
			//if(this.tab.selectedIndex==0){
			//	ViewManager.instance.showView(ConfigClass.VIEW_ESTATE_HERO,[0,index]);
			//}else if(this.tab.selectedIndex==1){
				
				//var b:Boolean=type==0;
				//arr.push(b);
				//ViewManager.instance.showView(ConfigClass.VIEW_ESTATE_DETAILS,arr);
			//}
		}

		public function tabChange():void{
			if(this.tab.selectedIndex==0){
				this.list.array = my_estate_arr;
				//boxMid.visible = !Boolean(this.list.array.length);
			}else if(this.tab.selectedIndex==1){
				this.list.array = all_estate_arr;
				//boxMid.visible = false;
			}
			setMidText();
		}




		override public function onRemoved():void{
			this.tab.selectedIndex=-1;
			ModelManager.instance.modelUser.off(ModelUser.EVENT_USER_UPDATE,this,this.eventCallBack);
		}

	}

}

import ui.map.estateItemUI;
import sg.cfg.ConfigServer;
import sg.utils.Tools;
import sg.manager.AssetsManager;
import sg.model.ModelItem;
import sg.manager.ModelManager;
import sg.model.ModelUser;
import laya.display.Animation;
import sg.manager.EffectManager;
import sg.model.ModelEstate;
import sg.utils.StringUtil;

class Item extends estateItemUI{

	public var config_estate:Object={};
	var ani:Animation;
	public function Item(){
		config_estate=ConfigServer.estate;
	}

	public function setData(arr:Array,index:int,tabSelect:int):void{//arr=["cid","eid","lv","act_times","total_times","user_index","config_index"]
		this.imgJ.visible=false;
		var aname:String=config_estate.estate[arr[1]].shape[arr[2]-1];
		if(ani==null){
			ani=EffectManager.loadAnimation(aname);
			this.aniPan.addChild(ani);
			ani.pos(this.img.width/2,this.img.height/2);
		}else{
			ani=EffectManager.loadAnimation(aname,"",0,ani);
		}
		
		var o:Object=config_estate.estate[arr[1]];
		var doName:String=Tools.getMsgById(o.active_name);
		this.text0.text=Tools.getMsgById(ConfigServer.city[arr[0]+""].name);
		this.text1.text=Tools.getMsgById("_estate_text13",[arr[2],Tools.getMsgById(o.name)]);// arr[2]+"级 "+Tools.getMsgById(o.name);
		this.text2.text=(arr[4]-arr[3])+"/"+arr[4];
		this.nameLabel.text=Tools.getMsgById("_estate_text03",[doName]);
		var m:Number=config_estate.passive[arr[2]-1]*o.ratio;//基础收益		
		var n:Number=Math.floor(m*(ModelUser.estate_produce_add(arr[1])));//额外收益
		this.text3.text = Tools.getMsgById("_estate_text02");//"产量";
		/*
		if(arr[4]==0){
			this.statusLabel.text="";
		}else{
			var user_estate:Object;
			for(var i:int=0;i<ModelManager.instance.modelUser.estate.length;i++){
				var obj:Object=ModelManager.instance.modelUser.estate[i];
				if(obj.city_id==arr[0]+"" && obj.estate_index==arr[6]){
					user_estate=obj;
					break;
				}
			}
			var t:Number=Tools.getTimeStamp(user_estate.active_harvest_time);
			var now:Number=ConfigServer.getServerTimer();
			if(t==0){
				this.statusLabel.text=Tools.getMsgById("_estate_text14");//"空闲中";
			}else{
				if(t-now<=0){
					this.statusLabel.text=Tools.getMsgById("_estate_text15",[doName]);// doName+"完成";
				}else{
					this.statusLabel.text=Tools.getMsgById("_estate_text16",[doName]);//doName+"中";
				}
			}
		}*/
		this.text4.wordWrap = true;
		this.com0.setData(AssetsManager.getAssetItemOrPayByID(o.produce),Tools.getMsgById("_estate_text05",[m,n]));// m+"(+"+n+")/时"
		this.text4.text=Tools.getMsgById("_estate_text04",[doName]);// doName+"收益";
		this.com1.setChipIcon(o.hero_debris==1);

		var e_index:Number=tabSelect==0?ModelManager.instance.modelUser.estate[arr[5]].estate_index:arr[5];
		var emd:ModelEstate = ModelManager.instance.modelGame.getModelEstate(arr[0], e_index);
		if(o.hero_debris==1){
			this.com1.setIcon("ui/icon_zhenbao06.png");
			this.com1.setSpecial(true);
			this.com1.setNum("");
			this.com1.setName("");
			this.getLabel.text=Tools.getMsgById("_estate_text07");// "概率获得";
		}else{
			
			
			this.getLabel.text = emd ? emd.getActiveNum().toString() : "";
			
			if(o.active_get){
				var it:ModelItem=ModelManager.instance.modelProp.getItemProp(o.active_get);
				//this.com1.setData(it.icon,it.ratity,"","");
				this.com1.setData(it.id,-1,-1);
				this.com2.visible=true;
			}else{
				this.com2.visible=false;
				this.text4.text=Tools.getMsgById("_estate_text08");// "暂未开放 敬请期待";
				this.text4.wordWrap = false;
				//trace("没有active_get  ",o);
			}
		}

		if (arr[8] && arr[8] != 0){
			this.comPower.visible = true;
			this.comPower.setNum(arr[8]);
			//this.text5.text=Tools.getMsgById("_estate_text24",[arr[8]]);
			this.box1.visible=false;
			this.imgJ.visible=true;
			//this.imgJ.x=this.text5.x-this.imgJ.width;
		}else{
			this.comPower.visible = false;
			//this.text5.text="";
			this.box1.visible=tabSelect==0;
		}

		if(arr[1]+""=="2"){
			this.box1.visible=false;
			this.statusLabel.text="";
		}

		//=====上面是之前写的逻辑就不管了
		this.comCoin.visible=emd ? emd.isGoldEstate() : false; 
		if(this.comCoin.visible){
			this.coinNum.text=ConfigServer.country_pvp.active_add.coin_add;
			this.coinIcon.setData("coin",-1,-1);
		}

		Tools.textLayout(nameLabel,text2,text2Img,box1);
		Tools.textLayout(text3,com0,text3Img,box2);

	}
}

