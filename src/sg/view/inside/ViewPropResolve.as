package sg.view.inside
{
	import ui.inside.propResolveUI;
	import laya.events.Event;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.manager.ModelManager;
	import sg.model.ModelHero;
	import laya.utils.Handler;
	import sg.cfg.ConfigServer;
	import laya.maths.MathUtil;
	import ui.com.hero_resolveUI;
	import ui.bag.bagItemUI;
	import sg.model.ModelItem;
	import sg.manager.AssetsManager;
	import sg.utils.Tools;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.model.ModelUser;
	import sg.model.ModelSkill;
	import sg.model.ModelScience;
	import sg.model.ModelBuiding;
	import sg.map.utils.ArrayUtils;
	import laya.display.Animation;
	import sg.manager.EffectManager;
	import sg.boundFor.GotoManager;
	import laya.utils.Tween;
	import laya.utils.Ease;
	import sg.utils.MusicManager;
	import sg.manager.LoadeManager;
	import laya.maths.Point;

	/**
	 * ...
	 * @author
	 */
	public class ViewPropResolve extends propResolveUI{

		public var curPropId:String="";
		public var curHeroId:String="";
		public var curIndex:int=-1;
		public var heroListData:Array=[];
		public var awardListData:Array=[];
		public var configData:Object=ConfigServer.system_simple.resolve_cost;
		public var cost_arr:Array=[];
		public var skillID:String="";
		public var reward_gift_dict:Object={};
		private var mRunClick:Boolean=false;
		public var ani:Animation;
		private var t1:Tween;

		private var mClickDownTime:Number=0;
        private var mTime:Number=0;
        private var cfgLvSpeed:Array;
		private var mReNum:Number=0;

		public function ViewPropResolve(){
			this.heroList.scrollBar.hide=true;
			this.heroList.itemRender=Item;
			this.heroList.selectHandler=new Handler(this,heroListOnselect);
			this.heroList.renderHandler=new Handler(this,heroListRender);
			this.heroList.selectEnable = true;
			this.rewardList.itemRender=awardItem;
			this.rewardList.scrollBar.visible=false;
			this.rewardList.scrollBar.touchScrollEnable=false;
			this.rewardList.renderHandler=new Handler(this,awardListRender);

			this.btnBuy.on(Event.MOUSE_DOWN,this,this.btnClick,[0]);
			this.btnBuyTen.on(Event.MOUSE_DOWN,this,this.btnClick,[1]);
 
			this.btnBlock.on(Event.CLICK,this,this.onClick,[this.btnBlock]);
			this.btnCheck.on(Event.CLICK,this,this.onClick,[this.btnCheck]);
			this.btnText.on(Event.CLICK,this,this.clickClear);
			//this.btnBlock.toggle=true;
			ModelManager.instance.modelUser.on(ModelUser.EVENT_PROP_CHECK,this,listenCallBack);

			this.btnShop.on(Event.CLICK,this,function():void{
				GotoManager.boundForPanel("shop","soul_shop");
			});

			Laya.stage.on(Event.MOUSE_OUT,this,function():void{
				mRunClick = false;
			});

			this.text0.text=Tools.getMsgById("_star_text17");

			
			this.textLabel1.text=Tools.getMsgById("_star_text18");
			this.textLabel2.text=Tools.getMsgById("_star_text19");
			this.textLabel3.text=Tools.getMsgById("_star_text22");
			this.textLabel4.text=Tools.getMsgById("_star_text23");

			this.btnCheck.label=Tools.getMsgById("_star_text20");
			this.textLabel1.width = this.textLabel1.textField.textWidth;
			this.textBg1.width = this.textLabel1.width + 20;
		}

		public function listenCallBack(a:String):void{
			skillID=a;
			setBtnText(true);
			curIndex=this.heroList.selectedIndex=-1;
			getHeroData();
		}

		public function setBtnText(b:Boolean):void{
			this.btnText.visible=b;
			if(b){
				var s:ModelSkill=ModelManager.instance.modelGame.getModelSkill(skillID);
				this.btnText.label=s.getName();
			}
			
		}

		public function clickClear():void{
			skillID="";
			this.btnText.visible=false;
			getHeroData();
		}

		override public function onAdded():void{
			this.setTitle(Tools.getMsgById("lvup08_1_name"));
			cfgLvSpeed=ConfigServer.system_simple.lv_speed;

			if(!ani){
				ani=EffectManager.loadAnimation("glow031");
				this.boxNum.addChild(ani);
				ani.pos(this.boxNum.width/2,this.boxNum.height/2);
				ani.name="ani";
				ani.visible=false;
			}

			skillID=this.currArg ? this.currArg : "";			
			skillID=skillID=="" ? "" : ModelSkill.isCanResolve(skillID) ? skillID : "";
			setBtnText(skillID!="");
			reward_gift_dict={};
			curIndex=this.heroList.selectedIndex=-1;
			getHeroData();
			
		}

		public function heroListOnselect(index:int):void{
			if(t1){
				t1.complete();
			}

			if(index>-1 && heroListData.length>0){
				reward_gift_dict=null;
				curIndex=this.heroList.selectedIndex;
				curPropId=heroListData[curIndex].id.replace("hero","item");
				curHeroId=heroListData[curIndex].id;
				getAwardData(heroListData[index].id);
				setNumLabel(heroListData[index].num);
				setBtnBlock(heroListData[curIndex].block);

				var hmd:ModelHero=ModelManager.instance.modelGame.getModelHero(curHeroId);
				this.comHero.setHeroIcon(curHeroId,false);
				t1=Tween.from(this.comHero,{x:this.comHero.x-50,alpha:0},500,Ease.quadOut);
				if(hmd.rarity==4){
					this.heroIconBg.visible=false;
					this.imgSuper.visible=true;
					LoadeManager.loadTemp(this.imgSuper,AssetsManager.getAssetsAD(ModelHero.super_hero_bg));
					EffectManager.changeSprColor(this.imgSuper,hmd.getStarGradeColor(),false);
				}else{
					this.heroIconBg.visible=true;
					this.imgSuper.visible=false;
					EffectManager.changeSprColor(this.heroIconBg,hmd.getStarGradeColor(),false);
				}
				this.imgAwaken.visible=hmd.getAwaken()==1;
				LoadeManager.loadTemp(imgAwaken, ModelHero.awakenImgUrl(hmd.id,true));
				if(this.imgAwaken.visible){
					if(hmd.rarity < 4) EffectManager.changeSprColor(imgAwaken,hmd.getStarGradeColor());
					else EffectManager.changeSprColorFilter(imgAwaken, null);
				}
				setBtnBuy();
			}
		}


		public function setNumLabel(n:Number):void{
			this.numLabel.text=n+"";
		}
		public function setBtnBlock(b:int):void{
			//this.btnBlock.label=b==0?"开":"关";
			//if(b==0){
				//trace("开");
				//if(this.btnBlock.selected==false)
				//	return;
			//}else{
				//trace("关");
			//}
			//this.btnBlock.selected=b==0;
			this.btnBlock.skin= AssetsManager.getAssetsUI(b==0?"btn_suo.png":"btn_suo1.png");
		}

		public function setBtnBuy():void{
			this.btnBuy.setData(AssetsManager.getAssetItemOrPayByID(cost_arr[0]),cost_arr[1]+" "+Tools.getMsgById("lvup08_1_name"));
			this.btnBuyTen.setData(AssetsManager.getAssetItemOrPayByID(cost_arr[0]),Math.round(cost_arr[1]*10)+" "+Tools.getMsgById("lvup08_1_name"));

			var item_num:Number = ModelItem.getMyItemNum(curPropId);
			var cost_num:Number = ModelItem.getMyItemNum(cost_arr[0]);
			this.btnBuy.gray = cost_arr[1]>cost_num || item_num<=0;
			this.btnBuyTen.gray = Math.round(cost_arr[1]*10)>cost_num || item_num<10;
		}

		public function heroListRender(cell:Item,index:int):void{
			cell.setData(this.heroList.array[index].id);
			cell.setSelcetion(this.heroList.selectedIndex==index);
			cell.setBlock(this.heroList.array[index].block);
			cell.off(Event.CLICK,this,this.heroClick);
			cell.on(Event.CLICK,this,this.heroClick,[index]);
		}

		public function heroClick(index:int):void{
			this.heroList.selectedIndex = index;
		}

		public function awardListRender(cell:awardItem,index:int):void{
			//var o:ModelItem=awardListData[index];
			var a:Array=awardListData[index];
			//cell.setData(o.icon,o.ratity,o.name,"");
			cell.setMidText(-1);
			if(index==0){
				//cell.setData(o.icon,o.ratity,o.name,o.addNum+"");
				//cell.setBtmText(o.addNum);
				cell.setData(a[0],a[1],-1);
			}else{
				if(reward_gift_dict){
					if(reward_gift_dict.hasOwnProperty(a[0])){
						cell.setMidText(reward_gift_dict[a[0]]);
					}
				}
				cell.setData(a[0],-1,-1);
			}
		}


		public function getHeroData():void{
			var skillModel:ModelSkill=null;
			if(skillID!=""){
				skillModel=ModelManager.instance.modelGame.getModelSkill(skillID);
			}
			heroListData=[];
			var o:Object=ModelManager.instance.modelUser.hero;
			for(var v:String in o)
			{
				var t:Object={};
				var h:ModelHero=ModelManager.instance.modelGame.getModelHero(v);
				t["id"]=v;
				t["num"]=h.getMyItemNum();
				t["ratity"]=h.rarity;
				t["name"]=h.getName();
				t["block"]=o[v].lock==0?1:0;
				t["skill"]=h.getMySkills();
				t["resolve"]=h.resolve;
				t["star"]=h.getStar();
				t["lv"]=h.getLv();
				t["have"]=skillModel==null?true:skillModel.isResolve(h);
				if(t["have"]){
					heroListData.push(t);
				}				
			}
			setHeroList();
				
			
			
		}

		public function setHeroList():void{
			ArrayUtils.sortOn(["block","num","star","ratity","lv"],heroListData,true,true);
			//heroListData.sort(MathUtil.sortByKey("lv",true,true));
			//heroListData.sort(MathUtil.sortByKey("ratity",true,true));
			//heroListData.sort(MathUtil.sortByKey("star",true,true));
			//heroListData.sort(MathUtil.sortByKey("num",true,true));
			//heroListData.sort(MathUtil.sortByKey("block",false,true));
			this.heroList.array=heroListData;	
			this.heroList.selectedIndex = -1;		
			this.heroList.selectedIndex = 0;
			this.heroList.tweenTo(0,200);
		}

		public function getAwardData(id:String):void{
			awardListData=[];
			var o:ModelHero=ModelManager.instance.modelGame.getModelHero(id);
			//var hun:ModelItem=ModelManager.instance.modelProp.getItemProp("item801");
			var n:Number=ModelBuiding.get_soul_value();//建筑等级加成
			var nn:Number=ModelScience.func_sum_type("hero_resolve",1+"");//科技增加固定值
			var addNum:Number=Tools.toCeil(configData[o.rarity][1]*(n+1)) + nn;
			//trace("将魂  ",o.rarity,n,nn);
			awardListData.push(["item801",addNum]);//将魂
			if(o.resolve){
				for(var i:int=0;i<o.resolve.length;i++){
					var a:Array=o.resolve[i][0];
					var v:ModelItem=ModelManager.instance.modelProp.getItemProp(a[0]);
					if(v){
						//trace("==================================error:无效道具id",a[0]);
						//v.addNum=1;
						awardListData.push([a[0],0]);
					}
				}
			}else{
				// trace("error ",o.id,"没有resolve");
			}
			this.rewardList.array=awardListData;
			this.cost_arr=["gold",configData[o.rarity][0]];
		}

		public function onClick(obj:Object):void{
			switch(obj)
			{
				case this.btnBuy:
					//buyFunc();
					break;
				case this.btnBlock:
					blockClick();
					break;
				case this.btnCheck:
					checkClick();
					break;
				default:
					break;
			}
		}

		public function checkClick():void{
			ViewManager.instance.showView(ConfigClass.VIEW_PROP_CHECK);
		}

		private function btnClick(type:Number):void{
			if(type==0){
				mReNum=1;
			}else{
				var n:Number=ModelItem.getMyItemNum(curPropId);
				mReNum = 10;//n<10 ? n : 10;
				if(n<10){
					ViewManager.instance.showTipsTxt(Tools.getMsgById("_star_text24"));
					return;
				}
			}
			mouseDown();
		}

		private function mouseDown():void{
            this.mRunClick = true;
			mClickDownTime=0;
            timeTick();
            timer.frameLoop(1,this,timeTick);
			Laya.stage.once(Event.MOUSE_UP,this,this.mouseUp);
			buyFunc();
        }
        private function mouseUp():void{
            this.mRunClick = false;
			timer.clear(this,timeTick);
        }  

		public function buyFunc():void{
			var n:Number=mReNum==1 ? cost_arr[1] : Math.round(cost_arr[1]*10)
			if(!Tools.isCanBuy(cost_arr[0],n)){
				return;
			}
			if(heroListData[curIndex].num==0){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_building28"));//碎片不足
				return;
			}
			if(heroListData[curIndex].block==0){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_building29"));//该英雄锁定
				return;
			}
			var sendData:Object={};
			sendData["item_id"]=curPropId;
			sendData["resolve_num"]=mReNum;
			NetSocket.instance.send("hero_resolve",sendData,Handler.create(this,this.SocketCallBack));
		}

		public function blockClick():void{
			var sendData:Object={};
			sendData["hid"]=curHeroId;
			NetSocket.instance.send("block_hero",sendData,Handler.create(this,this.SocketCallBack2));
		}

		public function SocketCallBack(np:NetPackage):void{
			MusicManager.playSoundUI(MusicManager.SOUND_PROP_RESOLVE);
			if(this.boxNum.getChildByName("ani")){
				var ani:Animation=this.boxNum.getChildByName("ani") as Animation;
				ani.play();
				ani.visible=true;
				ani.on(Event.COMPLETE,this,function():void{
					ani.visible=false;
				});
			}
			ModelManager.instance.modelUser.updateData(np.receiveData);
			
			for(var i:int=0;i<heroListData.length;i++){
				var o:Object=heroListData[i];
				if(o.id==curHeroId){
					o["num"]=ModelManager.instance.modelGame.getModelHero(curHeroId).getMyItemNum();
					break;
				}
			}			
			if(this.heroList.selection){
			(this.heroList.selection as Item).setData(heroListData[this.heroList.selectedIndex].id);
			}
			//this.heroList.refresh();
			setNumLabel(heroListData[curIndex].num);
			reward_gift_dict=np.receiveData.gift_dict;
			showAward(np.receiveData.gift_dict);
			this.timer.once(mTime,this,function():void{
                if(this.mRunClick){
                    //this.buyFunc();//取消长按
                }
            });
			setBtnBuy();
		}

		public function showAward(obj:Object):void{
			if(obj==null)
				return;
			
			//var posX:Number=this.rewardList.x;
			//var posY:Number=this.rewardList.y+this.rewardList.height + 20;
			for(var i:int=0;i<awardListData.length;i++){
				var ri:Array=awardListData[i];
				if(obj.hasOwnProperty(ri[0])){
					var d:Object={};
					d[ri[0]]=obj[ri[0]];
					var cell:* = this.rewardList.getCell(i);
					var pos:Point = Point.TEMP.setTo(cell.x + cell.width/2, cell.y + cell.height/2);
					pos = cell['parent'].localToGlobal(pos, true);
					ViewManager.instance.showIcon(d,pos.x - 10,pos.y - 10);
					//ViewManager.instance.showIcon(d,60+posX+135*i,posY);
				}
			}
			this.rewardList.array=awardListData;
		}

		public function SocketCallBack2(np:NetPackage):void{
			ModelManager.instance.modelUser.updateData(np.receiveData);
			//getHeroData();//列表重新刷一遍 /*测试让改成不刷列表*/
			var a:Object=heroListData[this.heroList.selectedIndex];
			a["block"]=ModelManager.instance.modelUser.hero[a["id"]].lock==0?1:0;
			this.heroList.array=heroListData;
			setBtnBlock(heroListData[curIndex].block);
			
			
			/*
			for(var i:int=0;i<heroListData.length;i++){
				var o:Object=heroListData[i];
				if(o.id==curHeroId){
					o["block"]=ModelManager.instance.modelUser.hero[o.id].block;
					o["block"]=o["block"]==0?1:0;
					break;
				}
			}
			if(this.heroList.getCell(curIndex)){
				(this.heroList.getCell(curIndex) as Item).selectImg.visible=false;
			}
			this.heroList.selectedIndex=-1;
			curIndex=-1;
			setHeroList();
			*/
		}

		private function timeTick():void{
            mClickDownTime+=1;
            if(mClickDownTime<30){
                mTime=cfgLvSpeed[0];
            }else{
                mTime=cfgLvSpeed[0] * (Math.pow(cfgLvSpeed[1],Math.floor(mClickDownTime/30)));
            }
            mTime=mTime<10?10:mTime;
            
        }

		override public function onRemoved():void{
			this.heroList.selectedIndex = -1;
			this.heroList.scrollBar.value=0;
			this.mRunClick = false;
			if(t1){
				t1.complete();
			}
			ModelManager.instance.modelUser.event(ModelUser.EVENT_UPDATE_SKILL_NUM);
		}
	}
}

import ui.bag.bagItemUI;
import laya.ui.Label;
import ui.com.hero_resolveUI;
import sg.model.ModelHero;
import sg.manager.ModelManager;
import sg.utils.Tools;
import sg.manager.EffectManager;
import laya.display.Animation;
import laya.events.Event;
import sg.manager.AssetsManager;

class Item extends hero_resolveUI
{
	public function Item()
	{
		this.selectImg.visible=false;
		this.btnLock.mouseEnabled=false;
	}

	public function setData(s:String):void{
		
		var h:ModelHero=ModelManager.instance.modelGame.getModelHero(s);		
		this.nameLabel.text=h.getName();
		this.addLabel.text=h.getMyItemNum()+"";
		this.heroImg.visible=false;
		this.comHero.setHeroIcon(h.id,true);		
		this.imgRatity.skin=h.getRaritySkin(true);

		this.imgAwaken.visible = h.getAwaken()==1;
		if(this.imgAwaken.visible){
			this.imgAwaken.skin = ModelHero.awakenImgUrl(h.id);
			if(h.rarity < 4) EffectManager.changeSprColor(imgAwaken,h.getStarGradeColor());
			else EffectManager.changeSprColorFilter(imgAwaken, null);
		} 


		EffectManager.changeSprColor(this.heroStarBg,h.getStarGradeColor(),false);
		//this.raIcon.skin="";
	}

	public function setSelcetion(b:Boolean):void{
		this.selectImg.visible=b;
	}

	public function setBlock(b:int):void{
		//this.imgLock.visible=b==1;
		//this.btnLock.selected=b==0;
		this.btnLock.skin=AssetsManager.getAssetsUI(b==0?"btn_suo.png":"btn_suo1.png");
	}
}

class awardItem extends bagItemUI
{
	
	public function awardItem()
	{
		this.scale(0.8,0.8);
		var ani:Animation=EffectManager.loadAnimation("glow011");
		ani.visible=false;
		ani.name="ani";
		this.addChild(ani);
		ani.pos(this.width/2,this.height/2);
	}

	public function setTopText():void{

	}

	public function setMidText(n:Number):void{
		if(n==-1){
			if(this.getChildByName("midText")){
				this.removeChild(this.getChildByName("midText"));
			}
			return;
		}
		var l:Label=new Label();
		l.align="center";
		l.width=0;
		l.height=0;
		l.fontSize=50;
		l.centerX=0;
		l.centerY=0;
		l.color="#ffffff";
		l.strokeColor="#000000";
		l.stroke=2;
		l.name="midText";
		l.text=n+"";
		this.addChild(l);
		if(this.getChildByName("ani")){
			var count:Number=0;
			var ani:Animation=this.getChildByName("ani") as Animation;
			
			var fun:Function=function():void{
				count+=1;				
				ani.visible=true;
				ani.play(0,false);
				ani.on(Event.COMPLETE,this,function():void
				{
					/*
					if(count>=n){
						ani.visible=false;
						ani.stop();
					}else{
						fun();
					}*/
					ani.visible=false;
					ani.stop();
				});
			}
			fun();
		}
	}

	public function setBtmText(n:Number):void{
		if(this.getChildByName("bottomText")){
			this.removeChild(this.getChildByName("bottomText"));
		}
		var l:Label=new Label();
		l.align="center";
		l.left=0;
		l.right=0;
		l.y=this.height-60;
		l.fontSize=24;
		l.color="#ffffff";
		l.name="bottomText";
		l.text=n+"";
		this.addChild(l);
	}
	
}