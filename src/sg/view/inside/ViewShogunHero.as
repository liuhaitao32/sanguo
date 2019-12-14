package sg.view.inside
{
	import ui.inside.shogunHeroUI;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import laya.events.Event;
	import sg.model.ModelHero;
	import sg.manager.ModelManager;
	import sg.cfg.ConfigServer;
	import sg.model.ModelUser;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.utils.Tools;
	import sg.boundFor.GotoManager;
	import sg.utils.StringUtil;
	import sg.model.ModelGame;


	/**
	 * ...
	 * @author
	 */
	public class ViewShogunHero extends shogunHeroUI{

		public var hero_str_arr:Array=[];
		public var total_score:Number=0;
		public var persent_num:int=0;
		public var curIndex:int=0;
		public var curLv:int=0;
		public var listLen:Number=0;
		public function ViewShogunHero(){
			this.list.scrollBar.visible=false;
			this.list.itemRender=Item;
			this.list.renderHandler=new Handler(this,listRender);
			this.upBtn.on(Event.CLICK,this,this.upClick);
			this.joinBtn.on(Event.CLICK,this,this.joinClick);
			ModelManager.instance.modelUser.on(ModelUser.EVENT_USER_UPDATE, this, eventCallBack);
			this.joinBtn.label = Tools.getMsgById("ViewShogunHero_1");
			this.upBtn.label = Tools.getMsgById("ViewShogunHero_2");

			this.askBtn.on(Event.CLICK,this,function():void{
				ViewManager.instance.showTipsPanel(Tools.getMsgById("_shogun_text12"));
			});
		}

		public function eventCallBack():void{
			//trace("shogunHero收到刷新消息");
			setData();
			setUI();
		}



		override public function onAdded():void{
			curIndex=this.currArg;
			persent_num=0;
			var s:String=ModelHero.shogun_name[curIndex+1];
			
			this.text1.text = Tools.getMsgById("_shogun_text02");
			
			
			this.text2.text = Tools.getMsgById("_public233",[s,Tools.getMsgById("_public53")]);
			this.text3.text = Tools.getMsgById("_public233",[s,Tools.getMsgById("_public54")]);
			this.text4.text = Tools.getMsgById("_public233",[s,Tools.getMsgById("_public55")]);
			this.text5.text = Tools.getMsgById("_public233",[s,Tools.getMsgById("_public56")]);
			setData();
			setUI();
		}

		public function setData():void{
			curLv=ModelManager.instance.modelUser.shogun[curIndex].lv;
			hero_str_arr=(ModelManager.instance.modelUser.shogun[curIndex].hids as Array).concat();
			listLen=0;
			total_score=0;
			for(var i:int=0;i<hero_str_arr.length;i++){
				if(hero_str_arr[i] is String && (hero_str_arr[i]+"").indexOf("hero")!=-1){
					var hmd:ModelHero=ModelManager.instance.modelGame.getModelHero(hero_str_arr[i]);
					total_score+=hmd.getShogunScore(curLv).score;
				}
				if(hero_str_arr[i]!="block"){
					listLen+=1;
				}
			}
			if(total_score!=0){
				var shogun_value:Array=ConfigServer.shogun.shogun_value;
				var max_arr:Array = shogun_value[shogun_value.length-1];
				if(total_score >= max_arr[0]){//最大值
					persent_num = max_arr[1];
				}else{
					for(var j:int=0;j<shogun_value.length;j++){
						if(j==shogun_value.length){
							persent_num=shogun_value[j][1];
						}else{
							if(total_score>=shogun_value[j][0] && total_score<shogun_value[j+1][0]){
								persent_num=shogun_value[j][1];
								break;
							}
						}
					}
				}	
			}
			else{
				persent_num = 0;
			}
			ModelGame.redCheckOnce(upBtn,ModelManager.instance.modelUser.isCanLvUpShogunByIndex(curIndex));
			//trace("persent: ",persent_num);
		}

		public function setUI():void{
			//this.titleLabel.text=Tools.getMsgById("_building40",[ModelHero.shogun_name[curIndex+1],ModelManager.instance.modelUser.shogun[curIndex].lv]);
			this.comTitle.setViewTitle(Tools.getMsgById("_building40",[ModelHero.shogun_name[curIndex+1],ModelManager.instance.modelUser.shogun[curIndex].lv]));
			// ModelHero.shogun_name[curIndex+1]+"府"+ModelManager.instance.modelUser.shogun[curIndex].lv+"级";
			setTopLabel();
			this.list.array=hero_str_arr;
		}

		public function setTopLabel():void{
			this.text01.text=total_score+"";
			if(persent_num==0){
				this.text02.text=this.text03.text=this.text04.text=this.text05.text="0";
			}else{
				var s:String=StringUtil.numberToPercent(persent_num,0,true,true);
				this.text02.text=this.text03.text= '+' + s;
				var a:Array=s.split('');				
				var ss:String="";
				for(var i:int=0;i<a.length;i++){
					if(i==a.length-2){
						ss+="."+a[i];
					}else{
						ss+=a[i];
					}
				}
				if(a[a.length-2]=="0"){
					ss=ss.replace(".0","");
				}
				if(ss.indexOf(".")==0){
					ss=0+ss;
				}
				this.text04.text=this.text05.text= '+' + ss;
			}
		}

		public function listRender(cell:Item,index:int):void{
			cell.setData(this.list.array[index],index,curLv);
			cell.itemBtn.off(Event.CLICK,this,this.itemClick);
			cell.itemBtn.on(Event.CLICK,this,this.itemClick,[cell,index]);
			cell.upBtn.off(Event.CLICK,this,this.heroUpClick);
			cell.upBtn.on(Event.CLICK,this,this.heroUpClick,[index]);
			cell.downBtn.off(Event.CLICK,this,this.downClick);
			cell.downBtn.on(Event.CLICK,this,this.downClick,[index]);
		}

		public function itemClick(cell:Item,index:int):void{
			switch(cell.status){
				case 0:
					ViewManager.instance.showView(ConfigClass.VIEW_SHOGUN_CHOOSE,[curIndex,index,this.list.array[index],curLv]);
				break;
				case 1:
					ViewManager.instance.showView(ConfigClass.VIEW_SHOGUN_CHOOSE,[curIndex,index,"",curLv]);
				break;
				case 2:
					if(index==listLen){
						var n:Number=ConfigServer.shogun.shogun_limit[index][1];
						ViewManager.instance.showView(ConfigClass.VIEW_UNLOCK,[curIndex,index,Tools.getMsgById("_building41"),n]);//是否永久开启此栏位
					}else{
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_shogun_tips03"));
					}
				break;
				case 3:
					return;
				break;
				default:
				break;
			}
		}

		public function heroUpClick(index:int):void{
			var md:ModelHero=ModelManager.instance.modelGame.getModelHero(this.list.array[index]);
			GotoManager.boundForPanel(GotoManager.VIEW_HERO_FEATURES,"",[md,[],0],{type:2,child:true});
		}

		public function upClick():void{
			if(curLv>=ConfigServer.shogun.shogun_levelup.length){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_public12"));//已经是最高等级
				return;
			}
			ViewManager.instance.showView(ConfigClass.VIEW_SHOGUN_LVUP,curIndex);
		}

		public function downClick(index:int):void{
			var hs:Array=ModelManager.instance.modelUser.shogun[curIndex].hids;
			hs[index]=null;
			NetSocket.instance.send("shogun_install_hid",{"shogun_index":curIndex,"hids":hs},Handler.create(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
			}));
		}

		public function joinClick():void{
			// trace("一键上阵！");
			var hs:Array=ModelManager.instance.modelUser.shogun[curIndex].hids;
			var b:Boolean=false;
			for(var j:int=0;j<hs.length;j++){
				if(hs[j]==null){
					b=true;
					break;
				}
			}
			if(!b){
				// trace("这个幕府满了已经！");
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_shogun_tips01"));
				return;
			}
			var a:Array=ModelHero.getUpShogun(curIndex,curLv);
			if(a.length==0){
				// trace("没有可以上阵的了！");
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_shogun_tips02"));
				return;
			}
			var n:Number=0;
			for(var i:int=0;i<hs.length;i++){
				if(hs[i]==null && a[n]){
					hs[i]=a[n].id;
					n+=1;
				}
			}	
			NetSocket.instance.send("shogun_install_hid",{"shogun_index":curIndex,"hids":hs},Handler.create(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				//ModelManager.instance.modelUser.event(ModelUser.EVENT_UPDATE_SHOGUN_HERO);
			}));
		}


		override public function onRemoved():void{

		}
	}

}


import ui.inside.shogunHeroItemUI;
import sg.model.ModelHero;
import sg.manager.ModelManager;
import sg.manager.AssetsManager;
import sg.cfg.ConfigServer;
import sg.model.ModelUser;
import sg.model.ModelBuiding;
import sg.utils.Tools;

class Item extends shogunHeroItemUI{
	

	public var status:Number=0;//0 有 1 空  2 解锁  3 等级不够
	public function Item(){

	}

	public function setData(s:*,index:int,lv:int):void{
		this.limitLabel.text=Tools.getMsgById("_shogun_text01");
		this.text0.text=Tools.getMsgById("_public52");
		this.text1.text=Tools.getMsgById("_shogun_text07");
		this.text2.text=Tools.getMsgById("_shogun_text09");
		this.text3.text=Tools.getMsgById("_shogun_text10");
		this.box1Label.text=Tools.getMsgById("_shogun_text08");


		var shogun_limit:Array=ConfigServer.shogun.shogun_limit;
		this.upBox.visible=this.box0.visible=this.box1.visible=this.box2.visible=this.box3.visible=false;
		this.itemBtn.width=437;
		if(s is String){
			if(s=="block"){//需要解锁
				var blv:Number=ModelManager.instance.modelInside.getBase().lv;
				if(shogun_limit[index][0]>blv){
					status=3;
					this.box3.visible=true;
					this.box3Text.text=Tools.getMsgById("_public47",[shogun_limit[index][0]]);//"官邸等级到达"+shogun_limit[index][0]+"级开启";
				}else{
					status=2;
					this.box1.visible=true;
					var n:Number=shogun_limit[index][1];
					var colorType:int=ModelManager.instance.modelUser.coin>=n?0:1;
					this.box1Com.setData(AssetsManager.getAssetItemOrPayByID("coin"),n,colorType);
				}
			}else if(s.indexOf("hero")!=-1){
				status=0;
				this.box0.visible=true;
				var hmd:ModelHero=ModelManager.instance.modelGame.getModelHero(s);
				this.nameLabel.text=hmd.getName();
				this.comHeroIcon.setHeroIcon(hmd.getHeadId());
				this.comHeroStar.setHeroStar(hmd.getStar());
				this.comHeroType.setHeroType(hmd.getType());

				this.army0.setArmyIcon(hmd.army[0],ModelBuiding.getArmyCurrGradeByType(hmd.army[0]));
				this.army1.setArmyIcon(hmd.army[1],ModelBuiding.getArmyCurrGradeByType(hmd.army[1]));
				this.tArmy0.text=hmd.getMyarmyName()[0];
				this.tArmy1.text=hmd.getMyarmyName()[1];

				this.imgRatity.skin=hmd.getRaritySkin(true);
				//this.shogunLabel.text="";
				var o:Object=hmd.getShogunScore(lv);
				this.limitLabel.visible=o.rank==0;     

				this.rankImg.skin=ModelHero.shogun_rank_color[o.rank];
				this.upBtn.visible=!(o.rank==0);
				this.scoreLabel.text=o.score;//"评分："+o.score;
				this.lvLabel.text=hmd.getLv()+"";
			}else{
				// trace("shogun  error:  ",s);
			}
		}else if(s==null){//空
			this.itemBtn.width=this.width;
			status=1;
			this.box2.visible=true;
			this.box2Text.text=Tools.getMsgById("_public57");//"点击选择上任英雄";
		}
		this.boxMid.visible=(status!=0);
	}
}