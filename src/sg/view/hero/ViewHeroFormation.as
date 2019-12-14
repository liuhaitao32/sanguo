package sg.view.hero
{
	import ui.hero.heroFormationUI;
	import sg.model.ModelHero;
	import sg.model.ModelFormation;
	import laya.events.Event;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.manager.ModelManager;
	import laya.ui.Button;
	import laya.ui.Box;
	import laya.ui.Label;
	import ui.hero.formationItemUI;
	import laya.ui.Image;
	import sg.manager.AssetsManager;
	import sg.manager.EffectManager;
	import sg.cfg.ConfigServer;
	import sg.model.ModelItem;
	import sg.manager.ViewManager;
	import sg.utils.Tools;
	import sg.view.com.EquipInfoAttr;
	import laya.display.Animation;
	import sg.cfg.ConfigColor;
	import laya.display.Sprite;
	import sg.utils.MusicManager;
	import laya.media.SoundChannel;

	/**
	 * ...
	 * @author
	 */
	public class ViewHeroFormation extends heroFormationUI{

		private var mHmodel:ModelHero;
		private var mFmodelArr:Array;
		private var mSelect:Number;
		private var mFormationIndex:int;
		private var mLvItem:Array;
		private var mRarityItem:Array;
		private var mLv:Number;
		private var mId:int;
		private var mRarity:Number;
		private var mFmodel:ModelFormation;

		private var mInfoAttr:EquipInfoAttr;
		private var cfgArrLevel:Array;
		private var cfgArrQuality:Array;
		private var cfgArrCost:Array;
		private var mIsChange:Boolean=false;

		public function ViewHeroFormation(){
			
			this.bLv.on(Event.CLICK,this,onClick,[this.bLv]);
			this.bRarity.on(Event.CLICK,this,onClick,[this.bRarity]);

			this.bLv.label=Tools.getMsgById("_hero_formation1");//"升级";
			this.bRarity.label=Tools.getMsgById("_hero_formation3");//"进阶";

			this.cTitle.setViewTitle(Tools.getMsgById("_hero_formation0"));//"武将阵法");
			this.cTitle1.setSamllTitle(Tools.getMsgById("_hero_formation5"));//"被动属性");
			this.cTitle2.setSamllTitle(Tools.getMsgById("_hero_formation6"));//"激活属性");

			this.btnCheck0.mouseEnabled=this.btnCheck1.mouseEnabled=false;
			this.btnCheck0.selected=this.btnCheck1.selected=true;

			this.btnAsk.on(Event.CLICK,this,function():void{
				ViewManager.instance.showView(["ViewFormationInfo",ViewFormationInfo],mHmodel);
			});

			this.btnForget.label = Tools.getMsgById('_hero_formation27');
			this.btnForget.on(Event.CLICK,this,forgetFun);
		}


		override public function onAdded():void{
			mIsChange=false;
			mHmodel=this.currArg as ModelHero;
			mFmodelArr=mHmodel.getFormationArr();
			cfgArrLevel   = ConfigServer.system_simple.arr_level;
			cfgArrQuality = ConfigServer.system_simple.arr_quality;
			cfgArrCost    = ConfigServer.system_simple.arr_cost;
			setData();
			mSelect=-1;
			selectClick(mFormationIndex==-1 ? 0 : mFormationIndex);

			mHmodel.on(ModelHero.EVENT_HERO_FORMATION_DELETE,this,deleteCallBack);
		}

		private function deleteCallBack():void{
			mFmodelArr=mHmodel.getFormationArr();
			setData();
			var n:Number = mSelect;
			mSelect=-1;
			selectClick(n);
		}

		private function setData():void{
			mFormationIndex=mHmodel.formation_index;
			this.btnForget.visible = Tools.getDictLength(mHmodel.forgetFormationObj())>0;
			for(var i:int=0;i<3;i++){
				var com:Box=this["com"+i];
				var btn:Button=com.getChildByName("btn") as Button;
				var btn_s:Button=com.getChildByName("btn_s") as Button;
				var name:Label=com.getChildByName("name") as Label;
				var icon:formationItemUI=com.getChildByName("icon") as formationItemUI;
				var bg:Image=com.getChildByName("bg") as Image;
				
				btn.gray=(this.mHmodel.isMine()==false);
				btn.off(Event.CLICK,this,chooseClick);
				btn.on(Event.CLICK,this,chooseClick,[i]);
				btn_s.off(Event.CLICK,this,selectClick);
				btn_s.on(Event.CLICK,this,selectClick,[i]);

				btn.skin=AssetsManager.getAssetsUI(mFormationIndex==i ? "btn_no_s.png" : "btn_ok_s.png");
				btn.label=mFormationIndex==i ? Tools.getMsgById("_hero_formation7"):Tools.getMsgById("_hero_formation8");//"取消" : "激活";
				btn.labelColors=mFormationIndex==i ?  "#c1fffa" : "#fff18e";
				bg.skin=AssetsManager.getAssetsUI(mSelect==i ? "icon_chenghao04.png" : "bar_18_1.png");

				var m:ModelFormation=mFmodelArr[i];
				name.text=m.curLv(mHmodel)==0 ? m.getName() : m.getName()+" "+Tools.getMsgById("_hero_formation9",[m.curLv(mHmodel)]);
				icon.imgIcon.skin=AssetsManager.getAssetsICON("formation"+m.id+".png");

				var n:Number=m.curStar(mHmodel);
				name.color=n==0 ? "#ffffff" : ConfigColor.FONT_COLORS[n];
				EffectManager.changeSprColor(icon.imgBg,n,true);


				var aniBox2:Box=com.getChildByName("aniBox2") as Box;
				var ani:Animation;
				if(aniBox2.getChildByName("ani2")){
					ani=(aniBox2.getChildByName("ani2") as Animation);
					EffectManager.loadAnimation("glow_arr_breath","",0,ani);   
					ani.visible=false; 
				}else{
					ani=new Animation();
					EffectManager.loadAnimation("glow_arr_breath","",0,ani); 
					ani.visible=false;
					ani.scaleX=1;
					ani.scaleY=1;

					ani.x=aniBox2.width/2;
					ani.y=aniBox2.height/2;

					ani.name="ani2";
					aniBox2.addChild(ani);
				}
				if(i==mFormationIndex) ani.visible=true;

			}
		}

		private function chooseClick(index:int):void{
			selectClick(index);
			if(this.mHmodel.isMine()==false){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_hero_formation20"));
				return;
			}
			var n:Number = index==mFormationIndex ? -1 : index;
			var _this:*=this;
			NetSocket.instance.send("choose_hero_formation",{"hid":this.mHmodel.id,"form_index":n},new Handler(this,function(np:NetPackage):void{
				mIsChange=true;
				if(n!=-1){
					MusicManager.playSoundUI(MusicManager.SOUND_FORMATION_CHOOSE);
				}
				ModelManager.instance.modelUser.updateData(np.receiveData);
				mFormationIndex=mHmodel.formation_index;
				for(var i:int=0;i<3;i++){
					var com:Box=_this["com"+i];
					var btn:Button=com.getChildByName("btn") as Button;
					var aniBox:Box=com.getChildByName("aniBox") as Box;

					btn.skin=AssetsManager.getAssetsUI(mFormationIndex==i ? "btn_no_s.png" : "btn_ok_s.png");
					btn.label=mFormationIndex==i ? Tools.getMsgById("_hero_formation7"):Tools.getMsgById("_hero_formation8");//"取消" : "激活";
					btn.labelColors=mFormationIndex==i ?  "#c1fffa" : "#fff18e";	

					var icon:formationItemUI=com.getChildByName("icon") as formationItemUI;					
					if(i==mFormationIndex){
						var ani:Animation;
						if(aniBox.getChildByName("ani")){
							ani=(aniBox.getChildByName("ani") as Animation);
							EffectManager.loadAnimation("glow_arr_chose","",1,ani);    
						}else{
							ani=new Animation();
							EffectManager.loadAnimation("glow_arr_chose","",1,ani); 
							ani.x = aniBox.width/2;
							ani.y = aniBox.height/2;
							ani.name="ani";
							aniBox.addChild(ani);
						}
					}

					var aniBox2:Box=com.getChildByName("aniBox2") as Box;
					var ani2:Animation=aniBox2.getChildByName("ani2") as Animation;
					ani2.visible=i==mFormationIndex;
					
				}
				setProp();
			}));
		}

		private function selectClick(index:int):void{
			if(mSelect==index) return;
			mSelect=index;
			for(var i:int=0;i<3;i++){
				var com:Box=this["com"+i];
				var bg:Image=com.getChildByName("bg") as Image;
				bg.skin=AssetsManager.getAssetsUI(mSelect==i ? "icon_chenghao04.png" : "bar_18_1.png");
				var icon:formationItemUI=com.getChildByName("icon") as formationItemUI;

				if(i==mSelect){
					mFmodel=mFmodelArr[i];
					mId         = mFmodel.id;
					mLv         = mFmodel.curLv(mHmodel);
					mRarity     = mFmodel.curStar(mHmodel);
					mLvItem     = [cfgArrCost[mId+""][1], cfgArrLevel[mLv] ? cfgArrLevel[mLv][1] : -1];
					mRarityItem = [cfgArrCost[mId+""][0], cfgArrQuality[mRarity] ? cfgArrQuality[mRarity][2] : -1];
				}
			}
			
			setUI();

			

		}

		private function setUI():void{
			this.tLvTitle.text=mLvItem[1]==-1 ? Tools.getMsgById("_hero_formation16") : Tools.getMsgById("_hero_formation2");//"升级消耗";
			this.tRaTitle.text=mRarityItem[1]==-1 ? Tools.getMsgById("_hero_formation17") : Tools.getMsgById("_hero_formation4");//"进阶消耗";

			this.tName.text=mFmodel.curLv(mHmodel)==0 ? mFmodel.getName() : mFmodel.getName()+" "+Tools.getMsgById("_hero_formation9",[mFmodel.curLv(mHmodel)]);//mFmodel.getName()+" "+mFmodel.curLv(mHmodel)+"级";
			Tools.textLayout2(tName,imgTitle,400,150);
			
			this.tLvNum.text=ModelItem.getMyItemNum(mLvItem[0])+"/"+(mLvItem[1]==-1 ? "-" : mLvItem[1]);
			this.tLvNum.color=ModelItem.getMyItemNum(mLvItem[0])>=mLvItem[1] ? "#acff75" : "#ff7358";
			this.cLv.setData(mLvItem[0],-1,-1);
			this.bLv.gray=!mFmodel.checkLv(mHmodel,mSelect);

			this.tRaNum.text=ModelItem.getMyItemNum(mRarityItem[0])+"/"+(mRarityItem[1]==-1 ? "-" : mRarityItem[1]);
			this.tRaNum.color=ModelItem.getMyItemNum(mRarityItem[0])>=mRarityItem[1] ? "#acff75" : "#ff7358";
			this.cRa.setData(mRarityItem[0],-1,-1);
			this.bRarity.gray=!mFmodel.checkStar(mHmodel,mSelect);

            
            if(lvBox.getChildByName("aniLv")){
				(lvBox.getChildByName("aniLv")as Animation).visible=!this.bLv.gray;
			}else{
				var aniLv:Animation = EffectManager.loadAnimation("glow006");
				aniLv.scaleX = 1.32;
				aniLv.scaleY = 1;            
				aniLv.x = this.bLv.x;
				aniLv.y = this.bLv.y;
				aniLv.name="aniLv";
				aniLv.visible=!this.bLv.gray;
				this.lvBox.addChild(aniLv);
			}

			if(raBox.getChildByName("aniRa")){
				(raBox.getChildByName("aniRa")as Animation).visible=!this.bRarity.gray;
			}else{
				var aniRa:Animation = EffectManager.loadAnimation("glow006");
				aniRa.scaleX = 1.32;
				aniRa.scaleY = 1;            
				aniRa.x = this.bRarity.x;
				aniRa.y = this.bRarity.y;
				aniRa.name="aniRa";
				aniRa.visible=!this.bRarity.gray;
				this.raBox.addChild(aniRa);
			}

			if(this.mInfoAttr){
                this.mInfoAttr.initFormation(mFmodelArr[mSelect],mHmodel);    
            }else{
                this.mInfoAttr = null;
                this.mInfoAttr = new EquipInfoAttr(this.boxArr,this.boxArr.width,this.boxArr.height);
                this.mInfoAttr.initFormation(mFmodelArr[mSelect],mHmodel);
                this.boxArr.addChild(this.mInfoAttr);
            }


			var m:Number=cfgArrQuality[mRarity] ? cfgArrQuality[mRarity][0] : 0;
			var n:Number=ModelFormation.serchFormationObj(mId,cfgArrQuality[mRarity] ? cfgArrQuality[mRarity][1] : 0);
			if(n==-1 || m==0){
				this.bInfo.visible=false;
			}else{
				this.bInfo.visible=true;
				this.tInfo.text=Tools.getMsgById("_hero_formation10",[m,Tools.getColorInfo(cfgArrQuality[mRarity][1]),mFmodelArr[mSelect].getName(),n,m]);
				//this.tInfo.text="进阶需要"+m+"名英雄拥有"+Tools.getColorInfo(cfgArrQuality[mRarity][1])+"品质的"+mFmodelArr[mSelect].getName()+"，当前"+n+"/"+m;
			}

			setProp();
		}

		private function setProp():void{
			setFormationItem(0,AssetsManager.getAssetsUI("icon_paopao43.png"),mFmodel.getLvInfo(mLv,false),false);
			setFormationItem(1,AssetsManager.getAssetsUI("icon_paopao43.png"),mFmodel.getLvInfo(mLv,true),false);
			setFormationItem(2,AssetsManager.getAssetsUI("icon_paopao44.png"),mFmodel.getAdeptInfo());
			//this.btnCheck0.visible=this.btnCheck1.visible=mSelect==mFormationIndex;
			this.btnCheck1.gray = mSelect != mFormationIndex;
		}


		/**
		 * 设置阵法的组件
		 */
		public function setFormationItem(index:int,imgSkin:String,str:String,isGray:Boolean=false):void{
			this["prop"+index].img.skin=imgSkin;
			var label:Label = this["prop"+index].info as Label;
			label.fontSize = 20;
			label.text=str;
			if(label.textField.textWidth > 350)
				label.fontSize = 18;
			//this["prop"+index].info.color=isGray ? "#999999" : "#ffffff";
			this["prop"+index].gray=isGray;
		}


		private function onClick(obj:*):void{
			switch(obj){
				case this.bLv:
					lvFunction();
					break;
				case this.bRarity:
					rarityFunction();
					break;
			}
		}

		private function lvFunction():void{
			if(!mFmodel.checkLv(mHmodel,mSelect,true)){
				return;
			}
			NetSocket.instance.send("hero_formation_lv_up",{"hid":this.mHmodel.id,"form_index":mSelect},new Handler(this,function(np:NetPackage):void{
				mIsChange=true;
				ModelManager.instance.modelUser.updateData(np.receiveData);
				//ViewManager.instance.showTipsTxt(Tools.getMsgById("_hero_formation13"));//"升级成功");
				MusicManager.playSoundUI(MusicManager.SOUND_FORMATION_LV_UP);
				setData();
				for(var i:int=0;i<3;i++){
					var com:Box=this["com"+i];
					var m:ModelFormation=mFmodelArr[i];
					var name:Label=com.getChildByName("name") as Label;
					name.text=m.curLv(mHmodel)==0 ? m.getName() : m.getName()+" "+Tools.getMsgById("_hero_formation9",[m.curLv(mHmodel)]);
					if(i==mSelect){
						mLv         = m.curLv(mHmodel);
						mLvItem     = [cfgArrCost[mId+""][1], cfgArrLevel[mLv] ? cfgArrLevel[mLv][1] : -1];
					}
				}
				setUI();
				var ani:Animation;
				if(aniTitle.getChildByName("ani")){
					ani=(aniTitle.getChildByName("ani") as Animation);
					EffectManager.loadAnimation("glow_arr_up_title","",1,ani);    
				}else{
					ani=new Animation();
					EffectManager.loadAnimation("glow_arr_up_title","",1,ani); 
					ani.name="ani";
					aniTitle.addChild(ani);
				}

				var ani2:Animation;
				if(lvBox.getChildByName("aniArr")){
					ani2=(lvBox.getChildByName("aniArr") as Animation);
					EffectManager.loadAnimation("glow_arr_up_item","",1,ani2);    
				}else{
					ani2=new Animation();
					EffectManager.loadAnimation("glow_arr_up_item","",1,ani2); 
					ani2.name="aniArr";
					ani2.x=cLv.x;
					ani2.y=cLv.y;
					lvBox.addChild(ani2);
				}
			}));
		}

		private function rarityFunction():void{
			var m:ModelFormation=mFmodelArr[mSelect];
			if(!m.checkStar(mHmodel,mSelect,true)){
				return;
			}
			NetSocket.instance.send("hero_formation_rarity_up",{"hid":this.mHmodel.id,"form_index":mSelect},new Handler(this,function(np:NetPackage):void{
				mIsChange=true;
				ModelManager.instance.modelUser.updateData(np.receiveData);
				MusicManager.playSoundUI(MusicManager.SOUND_FORMATION_STAR_UP);
				//ViewManager.instance.showTipsTxt(Tools.getMsgById("_hero_formation14"));//"进阶成功");
				setData();
				for(var i:int=0;i<3;i++){
					var com:Box=this["com"+i];
					var name:Label=com.getChildByName("name") as Label;
					var m:ModelFormation=mFmodelArr[i];
					if(i==mSelect){
						mRarity     = m.curStar(mHmodel);
						mRarityItem = [cfgArrCost[mId+""][0],cfgArrQuality[mRarity] ? cfgArrQuality[mRarity][2] : -1];
					}	
					var icon:formationItemUI=com.getChildByName("icon") as formationItemUI;

					var n:Number=m.curStar(mHmodel);
					name.color=n==0 ? "#ffffff" : ConfigColor.FONT_COLORS[n];
					EffectManager.changeSprColor(icon.imgBg,n,true);

				}
				
				ModelFormation.addFormationObj(mId,mRarity);
				setUI();
				var ani:Animation;
				if(raBox.getChildByName("aniArr")){
					ani=(raBox.getChildByName("aniArr") as Animation);
					EffectManager.loadAnimation("glow_arr_rarity","",1,ani);    
				}else{
					ani=new Animation();
					EffectManager.loadAnimation("glow_arr_rarity","",1,ani); 
					ani.name="aniArr";
					ani.x=cRa.x;
					ani.y=cRa.y;
					raBox.addChild(ani);
				}

				var ani2:Animation=EffectManager.loadAnimation("glow_arr_rarity_title","",1); 
				ani2.x=this.mInfoAttr.width/2;
				ani2.scaleX=0.9;
				ani2.y=mFmodel.curStar(mHmodel)*37;
				this.mInfoAttr.addChild(ani2);

			}));
		}

		private function forgetFun():void{
			ViewManager.instance.showView(["ViewHeroFormationDelete",ViewHeroFormationDelete],mHmodel);
			
		}



		override public function onRemoved():void{
			mHmodel.off(ModelHero.EVENT_HERO_FORMATION_DELETE,this,deleteCallBack);
			if(mIsChange)
				this.mHmodel.event(ModelHero.EVENT_HERO_FORMATION_CHANGE);
		}
	}

}