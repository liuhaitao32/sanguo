package sg.view.map
{
	import ui.map.cityBuildMainUI;
	import ui.map.item_city_buildUI;
	import laya.ui.Box;
	import laya.events.Event;
	import laya.ui.Label;
	import laya.utils.Handler;
	import sg.cfg.ConfigServer;
	import sg.utils.Tools;
	import sg.manager.ModelManager;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.model.ModelUser;
	import sg.model.ModelCityBuild;
	import sg.utils.StringUtil;
	import sg.task.model.ModelTaskCountry;
	import sg.model.ModelOffice;
	import sg.model.ModelOfficial;
	import laya.maths.MathUtil;
	import sg.map.utils.ArrayUtils;
	import sg.model.ModelGame;

	/**
	 * ...
	 * @author
	 */
	public class ViewCityBuildMain extends cityBuildMainUI{


		private var mData:Object={};
		private var mCid:String="";
		private var config_city_build:Object={};
		private var config_city:Object={};
		private var config_cb_build:Object={};
		private var all_city_build:Object={};
		private var list_data:Array=[];
		private var mEffcetData:Array=[];
		private var condition_list_data:Array=[];
		private var is_condition:Boolean=false;
		private var is_show_effect:Boolean=false;
		private var tab_arr:Array=[];
		private var curBlv:Number=0;
		private var user_cb:Object={};
		private var effectObj:Object={};
		private var isFrist:Boolean=true;
		private var isPlayAni:Boolean=false;
		public function ViewCityBuildMain(){
			//this.conditionList.itemRender=Box;
			this.conditionList.renderHandler=new Handler(this,conditionListRender);
			//this.effectList.itemRender=Box;
			//this.effectList.renderHandler=new Handler(this,effectListRender);
			//this.effectList.scrollBar.visible=false;
			this.effcetPanel.vScrollBar.visible=false;

			this.itemList.scrollBar.visible=false;
			this.itemList.itemRender=Item;	
			this.itemList.renderHandler=new Handler(this,itemListRender);
			this.itemList.selectHandler=new Handler(this,itemListSelect);

			this.btnChange.on(Event.CLICK,this,this.changeClick);
			this.btn.on(Event.CLICK,this,this.btnClick);
			this.tab.on(Event.CHANGE,this,this.tabChange);
			this.btn.setData("",Tools.getMsgById("_city_build_text01"),-1,1);
			this.text0.text = Tools.getMsgById("_city_build_text11");
			this.comTitle.setViewTitle(Tools.getMsgById("ViewCityBuildMain_1"));
		}


		override public function onAdded():void{

			this.btnChange.visible = !ModelGame.unlock(null,"text_unlock").stop;
			effectObj={};
			config_city_build=ConfigServer.city_build;
			config_city=ConfigServer.city;
			config_cb_build=config_city_build.buildall;
			mData=this.currArg[0];
			mCid=this.currArg[1];
			setTab();
			isFrist=true;
			isPlayAni=false;
			//setData();
			itemClick(0);
			//changeClick();
			ModelManager.instance.modelUser.on(ModelUser.EVENT_CITY_BUILD_MAIN,this,eventCallBack);
		}

		public function eventCallBack(obj:Array=null):void{
			if(obj){
				var arr1:Array=list_data.concat();
				mData=obj[0];
				setData();
				setBtn();
				var arr:Array=list_data;
				var cb:Object=obj[1];
				for(var i:int=0;i<arr.length;i++){
					var item:Item=(this.itemList.getCell(i) as Item);
					if(item){
						if(arr[i].id+""==cb.bid+""){
							isPlayAni=true;
							var n1:Number=0;
							if(arr1[i].max){
								n1=arr1[i].exp/arr1[i].max;
							}
							n1=n1>1 ? 1 : (n1<0 ? 0 : n1);
							var n2:Number=0;
							if(arr[i].max){
								n2=arr[i].exp/arr[i].max;
							}
							if(n2>1) n2 = 1;
							if(n2>=0.98 && n2<1) n2 = 0.98;
							if(n2<0) n2 = 0;
							item.playAni([n1,n2],arr[i]);
							item.playFly(Tools.getMsgById("_guild_text97")+"+"+obj[2]);
							curBlv=arr[i].lv;
							updateEffectColor();
							break;
						}
					}
				}
			}else{
				mData=ModelOfficial.cities[mCid].build;
				isFrist=true;
				setData();
				
				if(this.itemList.array[this.itemList.selectedIndex]){
					curBlv=this.itemList.array[this.itemList.selectedIndex].lv;
					updateEffectColor();
				}
				setBtn();
			}
			
		}

		public function setTab():void{
			var s:String="";
			tab_arr=[];
			tab_arr=((config_city_build.infrastructure[config_city[mCid].cityType+""]) as Array).concat();
			//trace("==============城市默认显示的建筑等级",tab_arr);
			all_city_build={};
			for(var ss:String in config_cb_build){
				var oo:Object=config_cb_build[ss];
				if(tab_arr.indexOf(oo.build_lv)!=-1){
					all_city_build[ss]=oo;
				}
			}

			for(var key:String in mData){
				if(!all_city_build.hasOwnProperty(key)){
					all_city_build[key]=config_cb_build[key];
				}
				var o:Object=config_cb_build[key];
				if(tab_arr.indexOf(o.build_lv)==-1){
					tab_arr.push(o.build_lv);
					//trace("==============后来增加的建筑等级",o.build_lv,key);
				}
			}
			tab_arr.sort();

			for(var i:int=0;i<tab_arr.length;i++){
				if(tab_arr[i]==5){
					//s+=Tools.getMsgById("_city_build_text10");
				}else{
					s+=Tools.getMsgById("_city_build_text05",[tab_arr[i]])+",";// tab_arr[i]+"级建筑";
				}
				
			}
			s=s.substr(0,s.length-1);
			this.tab.labels=s;
			this.tab.selectedIndex=0;

			//trace("==============服务器数据",mData);
			//trace("==============所有建筑",all_city_build);			
		}

		public function setData():void{
			list_data=[];
			var taskBuild:Array=ModelTaskCountry.getTaskBuild(Number(mCid));
			var blv:int=tab_arr[this.tab.selectedIndex];
			var blv2:int=blv==1 ? 5 : -1;
			user_cb=ModelManager.instance.modelUser.city_build;
			for(var s:String in all_city_build){
				var o:Object=all_city_build[s];
				if(o.build_lv==blv || o.build_lv==blv2){
					var oo:Object={};
					if(mData.hasOwnProperty(s)){
						oo["lv"]=mData[s][0];
						oo["exp"]=mData[s][1];
					}else{
						oo["lv"]=0;
						oo["exp"]=0;
					}
					var max:Number=ConfigServer.city_build["exp"+o.build_lv][oo.lv];
					var max_more:Number=0;
					if(o.more_exp && o.more_exp[oo.lv]){
						max_more=o.more_exp[oo.lv];
					}
					max+=max_more;
					oo["max"]=max;
					oo["id"]=s;
					oo["lock"]=isLock(s);
					if(user_cb[mCid] && user_cb[mCid][s]){
						oo["work"]=1;
					}else{
						oo["work"]=0;
					}
					oo["hasTask"]=taskBuild.indexOf(s)!=-1;
					oo["sort2"]=1000-Number(s.substr(1,s.length-1));//id排序
					oo["sort1"]=isLock(s)?1:0;//是否解锁

					list_data.push(oo);
				}
			}
			ArrayUtils.sortOn(["sort1","sort2"],list_data,true);
			this.itemList.array=list_data;
			
		}

		public function isLock(bid:String):Boolean{
			var prec:Object=config_cb_build[bid].precondition;
			var b1:Boolean=true;
			var b2:Boolean=true;
			for(var s:String in prec){
				if(s=="country_task"){
					b1=(ModelTaskCountry.instance.currentTaskIndex-1)>=prec[s];
				}else if(s=="build_add"){
					var a:Array=prec[s];
					for(var i:int=0;i<a.length;i++){	
						var aa:Array=a[i];	
						if(mData.hasOwnProperty(aa[0])){
							b2=mData[aa[0]][0]>=aa[1];
							if(!b2){
								return false;
							}
						}else{
							return false;
						}
					}
				}
			}
			return (b1&&b2);
		}

		public function setCondition(bid:String):void{
			var prec:Object=config_cb_build[bid].precondition;
			condition_list_data=[];
			var _lock:Boolean=false;
			var _text:String="";
			for(var s:String in prec){
				if(s=="country_task"){					
					_text=Tools.getMsgById("_city_build_text07",[prec[s]]);// "完成国家任务"+a[1];
					_lock=(ModelTaskCountry.instance.currentTaskIndex-1)>=prec[s];
					condition_list_data.push({"text":_text,"lock":_lock});
				}else if(s=="build_add"){
					var a:Array=prec[s];
					for(var i:int=0;i<a.length;i++){	
						var aa:Array=a[i];	
						if(mData.hasOwnProperty(aa[0])){
							_text=Tools.getMsgById("_city_build_text06",[Tools.getMsgById(config_cb_build[aa[0]].name),aa[1]]); 
							_lock=mData[aa[0]][0]>=aa[1];
							condition_list_data.push({"text":_text,"lock":_lock});
						}else{
							_text=Tools.getMsgById("_city_build_text06",[Tools.getMsgById(config_cb_build[aa[0]].name),aa[1]]); 
							condition_list_data.push({"text":_text,"lock":false});
						}
					}
				}
			}

			if(condition_list_data.length==0){
				this.boxCondition.visible=false;
				this.btn.visible=true;
			}else{
				if(this.itemList.array[this.itemList.selectedIndex].lock){
					this.boxCondition.visible=false;
					this.btn.visible=true;
				}else{
					this.boxCondition.visible=true;
					this.conditionList.array=condition_list_data;
					this.btn.visible=false;
				}
			}
			
		}

		public function setEffect(bid:String):void{
			
			var effect:Array=config_cb_build[bid].effect;
			var type:Array=config_cb_build[bid].type;
			var unlock:Object=config_cb_build[bid].unlock;
			
			if(effectObj.hasOwnProperty(bid)){
				mEffcetData=effectObj[bid];
			}else{
				mEffcetData=[];
				
				if(unlock){
					var lock_arr:Array=[];
					for(var k:String in unlock){
						lock_arr.push(Number(k));
					}
					lock_arr.sort();
				}
				var n1:Number=lock_arr[lock_arr.length-1];
				var n2:Number=effect.length;
				var len:Number=n1>n2?n1:n2;
				for(var i:int=0;i<len;i++){
					var s:String="";				
					var e_num:Number;
					if(effect[i]){
						if(effect[i] is Array){
							var e_arr:Array=effect[i];
							for(var j:int=0;j<e_arr.length;j++){
								e_num=e_arr[j];
								if(type[j]>=17 && type[j]<=19){
									s+=Tools.getMsgById("city_build"+type[j],
									[Tools.getMsgById("country_"+ModelOfficial.getCityFaith(this.mCid)[0]),
									StringUtil.numToPercentStr(e_num)]);	
								}else{
									s+=Tools.getMsgById("city_build"+type[j],[StringUtil.numToPercentStr(e_num)]);
								}
								s+=j==e_arr.length-1?"":",";
							}
						}else{
							e_num=effect[i];
							s=Tools.getMsgById("city_build"+type[0],[StringUtil.numToPercentStr(e_num)]);
						}
					}
					
					if(unlock){
						var key:String=(i+1)+"";
						if(unlock.hasOwnProperty(key)){
							var b_str:String="";
							var b_str2:String="";
							var b_arr:Array=unlock[key];
							var funx:Function=function(arr:Array):String{
								var s:String="";
								for(var k:int=0;k<arr[1].length;k++){
									s+=ModelCityBuild.getCityName(arr[1][k]);
									s+=k==arr[1].length-1?"":",";
								}
								return s;
							}

							var str_arr:Array=[];
							if(unlock[key][0]=="1"){//长城
								b_str=funx(b_arr);
								str_arr=[Tools.getMsgById("country_"+ModelOfficial.getCityFaith(this.mCid)[0]),b_str];
							}else if(unlock[key][0]=="2"){//城防军大将
								b_str=funx(b_arr);
								b_str2=StringUtil.numToPercentStr(unlock[key][2]);
								str_arr=[Tools.getMsgById("country_"+ModelOfficial.getCityFaith(this.mCid)[0]),b_str,b_str2];
							}else if(unlock[key][0]=="3"){//城防军精英
								b_str2=StringUtil.numToPercentStr(unlock[key][1]);
								str_arr=[b_str2];
							}
							if(s==""){
								s=Tools.getMsgById("city_build_type"+unlock[key][0],str_arr);	
							}else{
								s+=","+Tools.getMsgById("city_build_type"+unlock[key][0],str_arr);
							}
						}
					}
					var o:Object={};
					o["text"]=Tools.getMsgById("_city_build_text08",[i+1,s]);// "等级"+(i+1)+"："+s;
					o["lv"]=i;
					mEffcetData.push(o);
					effectObj[bid]=mEffcetData;
				}
			}
			
			//trace("----------------",mEffcetData);
			
			//this.effectList.array=mEffcetData;
			setEffcetUI();
			this.infoLabel.text=Tools.getMsgById(config_cb_build[bid].explain);
		}

		public function getUnlockStr(bid:String):String{

			return "";
		}
		/*
		public function setEffect(bid:String):void{
			return;//需求改了 需要重写
			var effect:Array=config_cb_build[bid].effect;
			mEffcetData=[];
			for(var i:int=0;i<effect.length;i++){
				var o:Object={};
				var a:Array=effect[i];
				var s:String="";
				var ss:String="";
				ss=(a[1] is String)?a[1]:(a[1]<0)?Math.floor(a[1]*100)+"%":a[1]+"";
				if(a.length==2){
					s=Tools.getMsgById("city_build"+a[0],[ss]); 
				}else if(a.length==3){
					s=Tools.getMsgById("city_build"+a[0],[ss])+","+Tools.getMsgById("city_build"+a[2]); 
				}else if(a.length==4){
					var sss:String=(a[3]<0)?Math.floor(a[3]*100)+"%":a[3]+"";
					s=Tools.getMsgById("city_build"+a[0],[ss])+","+Tools.getMsgById("city_build"+a[2],[sss]); 
				}
				o["text"]=s;
				mEffcetData.push(o);
			}
			//trace("----------------",mEffcetData);
			this.effectList.array=mEffcetData;
			this.infoLabel.text=Tools.getMsgById(config_cb_build[bid].explain);
		}*/

		

		public function tabChange():void{
			if(this.tab.selectedIndex>=0){
				isFrist=true;
				setData();
				itemClick(0);
				if(isPlayAni){
					clearList();
				}
			}
		}

		public function changeClick():void{
			is_show_effect=!is_show_effect;
			//this.effectList.visible=is_show_effect;
			this.effcetPanel.visible=is_show_effect;
			this.infoLabel.visible=!is_show_effect;
		}

		public function btnClick():void{
			if(ModelManager.instance.modelUser.office<config_city_build.lock[1]){
				//ViewManager.instance.showTipsTxt("爵位等级不足"+config_city_build.lock[2]);
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_office4",[ModelOffice.getOfficeName(config_city_build.lock[1])]));
				return;
			} 
			if(!ModelManager.instance.modelUser.isFinishFtask(mCid)){
				ViewManager.instance.showTipsTxt("_ftask_tips01");
				return;
			}
			var o:Object={};
			o["cid"]=mCid;
			o["bid"]=this.itemList.array[this.itemList.selectedIndex].id;
			o["lv"]=this.itemList.array[this.itemList.selectedIndex].lv;
			o["exp"]=this.itemList.array[this.itemList.selectedIndex].exp;
			//ViewManager.instance.showView(ConfigClass.VIEW_ESTATE_HERO,[0,o,2]);

			var arr:Array = ModelManager.instance.modelUser.getMyEstateHeroArr(2);
			if(arr.length > 0){
				if(ModelManager.instance.modelGame.getModelHero(arr[0].hid).getHeroEstate().status == 0){
					ViewManager.instance.showView(ConfigClass.VIEW_ESTATE_TASK,[arr[0].hid,o,2]);
				}else{
					ViewManager.instance.showTipsTxt(Tools.getMsgById('_estate_tips09'));
				}
				
			}
			

		}

		public function conditionListRender(cell:Box,index:int):void{
			var label:Label=cell.getChildByName("label") as Label;
			var o:Object=this.conditionList.array[index];
			label.text=o.text;
			label.color=o.lock?"#acff75":"#ff7358";
		}

		public function itemListRender(cell:Item,index:int):void{
			if(isFrist){
				cell.setData(this.itemList.array[index]);
			}
			if(index==this.itemList.array.length-1){
				isFrist=false;
			}
			cell.setHeroCom(mCid,this.itemList.array[index]);	
			cell.setSelect(index==this.itemList.selectedIndex);
			cell.off(Event.CLICK,this,this.itemClick);
			cell.on(Event.CLICK,this,this.itemClick,[index]);
			//cell.setRatityImg(this.tab.selectedIndex);
		}


		public function itemListSelect(index:int):void{

		}

		public function itemClick(index:int):void{
			this.itemList.selectedIndex=index;
			this.effcetPanel.vScrollBar.value=0;
			curBlv=this.itemList.array[index].lv;
			setCondition(this.itemList.array[index].id);
			setEffect(this.itemList.array[index].id);
			setBtn();
			is_show_effect=true;
			this.effcetPanel.visible=is_show_effect;
			this.infoLabel.visible=!is_show_effect;
		}

		public function setBtn():void{
			if(this.itemList.array[this.itemList.selectedIndex].work==1){
				this.btn.mouseEnabled=false;
				this.btn.gray=true;
			}else{
				this.btn.mouseEnabled=true;
				this.btn.gray=false;
			}
		}

		public function effectListRender(cell:Box,index:int):void{
			var label:Label=cell.getChildByName("label") as Label;
			//label.text=this.effectList.array[index].text;
			var n:Number=index+1;
			if(n==curBlv){
				label.color="#acff75";
			}else if(n>curBlv){
				label.color="#828282";
			}else if(n<curBlv){
				label.color="#ffffff";
			}
		}

		public function setEffcetUI():void{
			if(effcetBox){
				effcetBox.removeChildren();
			}
			for(var i:int=0;i<mEffcetData.length;i++){
				var label:Label=new Label();
				label.fontSize=20;
				label.wordWrap=true;
				label.leading=5;
				label.valign="left";
				label.stroke=1;
				label.strokeColor="#000000";
				label.width=553;
				label.name="label"+i;
				label.text=mEffcetData[i].text;
				label.x=0;
				effcetBox.addChild(label);
			}

			var m:Number=0;
			for(var j:int=0;j<effcetBox.numChildren;j++){
				var _label:Label=effcetBox.getChildByName("label"+j) as Label;
				
				if(j==0){
					_label.y=0;
				}else{
					var _label2:Label=effcetBox.getChildByName("label"+(j-1)) as Label;
					_label.y=_label2.y+_label2.height;//+5;
					m = _label.y+_label.height;
				}
				var n:Number=j+1;
				if(n==curBlv){
					_label.color="#acff75";
				}else if(n>curBlv){
					_label.color="#828282";
				}else if(n<curBlv){
					_label.color="#ffffff";
				}
			}
			this.effcetBox.autoSize=true;
			//this.effcetBox.height=m;
		}

		public function updateEffectColor():void{
			if(effcetBox && effcetBox.numChildren!=0){
				for(var j:int=0;j<effcetBox.numChildren;j++){
					var _label:Label=effcetBox.getChildByName("label"+j) as Label;
					var n:Number=j+1;
					if(n==curBlv){
						_label.color="#acff75";
					}else if(n>curBlv){
						_label.color="#828282";
					}else if(n<curBlv){
						_label.color="#ffffff";
					}
				}
			}
			
		}


		override public function onRemoved():void{
			clearList();
			ModelManager.instance.modelUser.off(ModelUser.EVENT_CITY_BUILD_MAIN,this,eventCallBack);
			this.effcetPanel.vScrollBar.value=0;
			this.tab.selectedIndex=-1;
			this.itemList.scrollBar.value=0;
			
		}

		public function clearList():void{
			for(var i:int=0;i<this.itemList.array.length;i++){
				var item:Item=(this.itemList.getCell(i) as Item);
				if(item){
					item.clearItem();
				}
			}
			isPlayAni=false;
		}

	}
}


import ui.map.item_city_buildUI;
import sg.cfg.ConfigServer;
import sg.utils.Tools;
import sg.manager.EffectManager;
import sg.model.ModelCityBuild;
import sg.manager.ModelManager;
import sg.manager.AssetsManager;
import laya.events.Event;
import laya.display.Animation;
import laya.maths.Point;
import laya.ui.Label;
import sg.task.model.ModelTaskCountry;

class Item extends item_city_buildUI{

	private var config_cb:Object={};
	private var ani:Animation;
	private var mLabel:Label;
	public function Item(){

	}

	public function setData(obj:Object):void{
		config_cb=ConfigServer.city_build.buildall[obj.id];
		this.imgCorner.visible=obj.lv==config_cb.max_lv;
		this.imgLock.visible=!obj.lock;
		this.gray=!obj.lock;
		this.imgWork.visible=false;//obj.work==1;
		this.imgTask.visible=obj.hasTask ? obj.hasTask : false;//新加的 有国家任务时显示
		this.img.skin=AssetsManager.getAssetsAD(config_cb.background);
		this.label.text=Tools.getMsgById(config_cb.name)+" "+Tools.getMsgById("100001",[obj.lv]);// obj.lv+"级";
		if(obj.lv==config_cb.max_lv){
			this.pro.visible=false;
		}else{
			this.pro.visible=true;
			this.pro.value=obj.exp/obj.max;
		}
		//if(bRatity!=-1){
			if(config_cb.build_lv<4){
				EffectManager.changeSprColor(this.imgRatity,0,false);
			}else{
				EffectManager.changeSprColor(this.imgRatity,5,false);
			}
		//}
	}

	public function setHeroCom(cid:String,obj:Object):void{
		this.comHero.off(Event.CLICK,this,this.heroClick);
		if(obj.work==1){
			this.comHero.visible=true;
			var bcm:ModelCityBuild=ModelCityBuild.getCityBuild(cid,obj.id);
			if(bcm){
				bcm.off(ModelCityBuild.EVENT_UPDATE_CITY_BUILD,this,updateHero);
				bcm.on(ModelCityBuild.EVENT_UPDATE_CITY_BUILD,this,updateHero,[cid,obj]);
				bcm.off(ModelCityBuild.EVENT_REMOVE_CITY_BUILD,this,removeHero);
				bcm.on(ModelCityBuild.EVENT_REMOVE_CITY_BUILD,this,removeHero);
				var showObj:Object=bcm.showObj;
				updateHero(cid,obj);
				comHero.setBuildingTipsIcon3(showObj.hid);
				this.comHero.on(Event.CLICK,this,this.heroClick,[cid,obj]);
			}
			
		}else{
			this.comHero.visible=false;
		}
	}

	public function removeHero():void{
		this.comHero.visible=false;
	}

	public function updateHero(cid:String,obj:Object):void{
		var bcm:ModelCityBuild=ModelCityBuild.getCityBuild(cid,obj.id);
		var showObj:Object=bcm.showObj;
		this.comHero.img1.visible=showObj.event;
		this.comHero.img0.visible=!this.comHero.img1.visible;
		this.comHero.img2.visible=showObj.finish;
		this.comHero.heroBox.gray=!showObj.finish;
	}

	public function heroClick(cid:String,obj:Object):void{
		var bcm:ModelCityBuild=ModelCityBuild.getCityBuild(cid,obj.id);
		bcm.click();
	}

	public function setRatityImg(lv:int):void{
		
		
	}

	public function setSelect(b:Boolean):void{
		this.imgSelect.visible=b;
	}

	public function playAni(arr:Array,obj:Object):void{
		ani=EffectManager.loadAnimation("glow019","",1);
		this.addChild(ani);
		
		ani.on(Event.COMPLETE,this,function():void{
			if(obj.lv==config_cb.max_lv){
				setData(obj);
			}else{
				pro.value=arr[0];
				playTween(arr,arr[0]>arr[1],obj);
			}
		});
		ani.pos(this.width/2,this.height/2);
	}

	public function playTween(arr:Array,b:Boolean,obj:Object):void{
		pro.value+=0.01;
		if(pro.value>=1){
			pro.value=0;
			b=false;
		}
		var n:Number=arr[1];
		if(pro.value>=n && b==false){
			setData(obj);
			return;
		}
		timer.frameOnce(1,this,playTween,[arr,b,obj]);
	}

	public function playFly(str:String):void{
		var pos:Point = Point.TEMP.setTo(this.x + this.width/2, this.y+this.height/2);
        pos = this['parent'].localToGlobal(pos, true);
		mLabel=EffectManager.createLabelRise(str,pos.x,pos.y,2000,28);
	}

	public function clearItem():void{
		if(ani){
			ani.clear();
		}
		if(mLabel){
			mLabel.removeSelf();
		}
		timer.clear(this,playTween);
	}
}