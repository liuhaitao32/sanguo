package sg.view.inside
{
	import ui.inside.pubShowHeroUI;
	import sg.manager.ModelManager;
	import sg.utils.Tools;
	import laya.events.Event;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.manager.ViewManager;
	import sg.model.ModelItem;
	import sg.model.ModelProp;
	import sg.model.ModelHero;
	import laya.maths.MathUtil;
	import laya.utils.Tween;
	import laya.utils.Ease;
	import sg.manager.AssetsManager;
	import sg.cfg.ConfigServer;
	import sg.utils.MusicManager;


	/**
	 * ...
	 * @author
	 */
	public class ViewPubShowHero2 extends pubShowHeroUI{

		private var listData:Array;
		private var mIndex:Number;
		private var itemData:Object;
		private var card_arr:Array=[];
		private var t_arr:Array;
		private var posY_arr:Array;
		private var countNum:Number=0;
		private var ratity_arr:Array;
		private var step:Number=0;
		private var countNum2:Number=0;		
		private var clickNum:Number=0;

		private var isLimit:Boolean=false;//第一个的限制
		private var limitNum:Number=ConfigServer.pub.draw_limit;//酒馆总共的限制
		private var draw_times:Number=0;
		private var reData:Object;

		private var title_arr:Array=[
			Tools.getMsgById("hero_box1"),Tools.getMsgById("hero_box2"),Tools.getMsgById("hero_box3")];

		public function ViewPubShowHero2(){
			this.list.visible=false;
			this.btnBuy.on(Event.CLICK,this,this.click);
			this.btn.on(Event.CLICK,this,this.clickBG);
		}


		public override function onAdded():void{
			mIndex=this.currArg[0];
			itemData=this.currArg[1];
			this.setTitle(title_arr[mIndex]);
			this.btn.alpha=0;
			reData=this.currArg[2];
			setData();
		}

		public function setData():void{

			var gift_dict:Object=reData.gift_dict;
			var random_prop_dict:Object=reData.random_prop_dict;
			var arr:Array=ModelManager.instance.modelProp.getRewardProp([gift_dict,random_prop_dict]);
			listData=[];
			for(var i:int=0;i<arr.length;i++){
				var it:ModelItem=ModelManager.instance.modelProp.getItemProp(arr[i][0]);
				if(it.type==7){
					listData.push(it);
				}else{
					var o:Object={};
					o[it.id]=arr[i][1];
					ViewManager.instance.showIcon(o,Laya.stage.width/2,Laya.stage.height/2);
				}
			}
			this.btnBuy.visible=false;
			this.btn.visible=false;
			ratity_arr=[0,0,0];
			draw_times=Tools.isNewDay(ModelManager.instance.modelUser.pub_records.draw_time)?0:ModelManager.instance.modelUser.pub_records.draw_times;
			var b:Boolean=false;
			var costStr:Array=[itemData.cost[0],itemData.cost[1]];
			if(itemData.prop_cost){
				isLimit=false;		
				b=ModelManager.instance.modelProp.isHaveItemProp(itemData.prop_cost[0],itemData.prop_cost[1]);
				if(b){
					costStr=[itemData.prop_cost[0],itemData.prop_cost[1]];
				}
				this.btnBuy.setData(AssetsManager.getAssetItemOrPayByID(costStr[0]),costStr[1]);
			}else{
				var n1:Number=itemData.free+ModelManager.instance.modelInside.getBuildingModel("building005").lv;
				var n2:Number=ModelManager.instance.modelUser.pub_records.free_times;
				this.btnBuy.setData(AssetsManager.getAssetItemOrPayByID(costStr[0]),costStr[1]+"("+(n1-n2)+"/"+n1+")");
				if(n2>=n1){
					isLimit=true;
				}else{
					isLimit=false;
				}
			}


			posY_arr=listData.length<=3?[this.pan.height/2,this.pan.height/2]:[this.pan.height/2 - 160,this.pan.height/2 + 120];
			//this.btnBuy.y=posY_arr[0] + 200;
			for(var j:int = 0; j < listData.length; j++)
			{
				var e:ModelItem = listData[j];
				var h:ModelHero=ModelManager.instance.modelGame.getModelHero(e.id.replace("item","hero"));
				e["paixu"]=h.rarity;
				if(h.rarity==0){
					ratity_arr[0]+=1;
				}else if(h.rarity==1){
					ratity_arr[1]+=1;
				}else if(h.rarity>=2){
					ratity_arr[2]+=1;
				}
			}
			listData.sort(MathUtil.sortByKey("paixu",true,true));
			initCard();
		}

		public function initCard():void{
			countNum=0;
			card_arr=[];
			t_arr=[];			
			var n:int=listData.length;
			for(var i:int = 0; i < n; i++)
			{
				var card:Item=new Item();
				//card.cardBG.visible=true;
				var value:Object=listData[i];
				card.setData(value.id.replace("item","hero"),value.addNum);
				card.pivotX=card.width/2;
				card.pivotY=card.height/2;
				//card.setNum(value.addNum);
				card.addGlow();
				card.visible=true;
				this.itemBox.addChild(card);
				card_arr.push(card);
				var oneWidth:Number=card.width+8;
				card.x=(i<=2)?4+oneWidth*i+card.width/2:4+oneWidth*(i-3)+card.width/2;
				if(i==1 || i==4){
					card.x=this.pan.width/2;
				}else if(i==0 || i==3){
					card.x=this.pan.width/2 - oneWidth;
				}else if(i==2 || i==5){
					card.x=this.pan.width/2 + oneWidth;
				}
				card.x-=(this.pan.width)*1.5;
				card.y=(i<=2)?posY_arr[0]:posY_arr[1];
				card.rotation=-50;
				card.skewY=180;
				//card.y=listY+this.list.height/4;
				//var t:Tween=Tween.to(card,{x:card.x},100,null,Handler.create(this,tweenFunc,[i,card]),i*100);//延迟
				//t_arr.push(t);
			}
			//this.pan.setChildIndex(this.btn,this.numChildren-1);

			//for(var k:int=card_arr.length-1;k>=0;k--){
			//	this.addChild(card_arr[k]);
			//}

			for(var j:int=0;j<=2;j++){
				if(card_arr[j]){
					tweenFunc0(j);
				}
				if(card_arr[j+3]){
					tweenFunc0(j+3);
				}
				
			}
			
		}

		public function tweenFunc0(n1:Number):void{//移动
			var duration:Number=0;
			if(n1==0 || n1==3){
				duration = 800;
			}else if(n1==1 || n1==4){
				duration = 500;
			}else if(n1==2 || n1==5){
				duration = 600;
			}
			MusicManager.playSoundUI(MusicManager.SOUND_PUB_GET);
			var delay:Number=(n1>=3)?0:100;
			var card:*=card_arr[n1];
			var t:Tween=Tween.to(card,{x:card.x+this.width*1.5,rotation:0},duration,Ease.cubicOut,Handler.create(this,tweenFunc0_over,[n1]),delay);
			t_arr.push(t);
		}
		

		public function tweenFunc0_over(num:Number):void{
			countNum+=1;
			if(countNum==card_arr.length){
				countNum=0;
				tweenFunc1_start();
			}
		}

		public function tweenFunc1_start():void{
			if(step==2){
				if(ratity_arr[2]>0){
					this.btn.visible=true;
					timer.once(1000,this,clickBG);
				}
				return;
			}
			if(ratity_arr[step]!=0){
				countNum2=0;
				var posX:Number=0;
				var posY:Number=0;
				var n:Number=0;
				if(step<2){
					for(var j:int=0;j<ratity_arr[step];j++){
						if(step==0){
							n=card_arr.length-j-1;
							tweenFunc1(n);
						}else if(step==1){
							n=card_arr.length-j-1-ratity_arr[0];
							tweenFunc1(n,0,0,1.2);	
						}
						//else{
						//	n=card_arr.length-j-1-ratity_arr[0]-ratity_arr[1];
						//}
						//posX=(card_arr[n].x<this.width/2)?100:((card_arr[n].x>this.width/2)?-100:0);
						//posY=(card_arr[n].y<this.height/2)?200:((card_arr[n].y>this.height/2)?-100:0);
					}
				}else{
					n=card_arr.length-ratity_arr[0]-ratity_arr[1]-clickNum;
					if(n<0){
						//trace("======================",ratity_arr);
						return;
					}
					posX=(card_arr[n].x<this.width/2)?100:((card_arr[n].x>this.width/2)?-100:0);
					posY=(card_arr[n].y<this.height/2)?200:((card_arr[n].y>this.height/2)?-100:0);
					tweenFunc1(n,posX,posY,1.5);	
				}
				
			}else{
				step+=1;
				tweenFunc1_start();
			}
		}

		public function tweenFunc1(num:Number,x:Number=0,y:Number=0,scale:Number=1.2):void{//翻牌1		
			var card:*=card_arr[num];
			if(card==null){
				return;
			}
			//this.setChildIndex(card,this.numChildren-1);	
			this.itemBox.setChildIndex(card,this.itemBox.numChildren-1);
			
			countNum2+=1;				
			var t:Tween=Tween.to(card,{x:card.x-100,
						y:card.y-100,
						scaleX:0.1,
						scaleY:scale,
						skewY:270},250,null,Handler.create(this,tweenFunc2,[num,x,y,scale]),countNum2*100);
			t_arr.push(t);
			//Tween.to(card,{skewY:360},500,null,null);
		}

		public function tweenFunc2(num:Number,x:Number,y:Number,scale:Number):void{//翻牌2  正面
			var card:*=card_arr[num];
			if(card==null){
				return;
			}
			card.cardBG.visible=false;
			card.imgRa.visible=card.box.visible=card.bigHero.visible=true;
			var t:Tween=Tween.to(card,{x:card.x+100+x,
							y:card.y+y,
							scaleX:scale,
							scaleY:scale,
							skewY:360},250,null,Handler.create(this,tweenFunc3,[num,x,y]));	
			t_arr.push(t);					
		}

		public function tweenFunc3(num:Number,x:Number,y:Number):void{//翻牌3
			var card:*=card_arr[num];
			if(card==null){
				return;
			}
			card.getGlow(-1);
			if(step<2){
				card.getGlow(step);
			}else{
				card.getGlow(2);
			}
			
			var t:Tween=Tween.to(card,{x:card.x-x,
					   	y:card.y+100-y,
						scaleX:1,
						scaleY:1},500,Ease.backInOut,Handler.create(this,tweenFunc3_over),500);
			t_arr.push(t);
		}

		public function tweenFunc3_over():void{	
			MusicManager.playSoundUI(MusicManager.SOUND_PUB_DOWN);
			countNum+=1;	
			if(step==0 && ratity_arr[0]==countNum){
				step+=1;
				tweenFunc1_start();	
			}else if(step==1 && ratity_arr[1]+ratity_arr[0]==countNum){
				step+=1;
				tweenFunc1_start();	
			}
			this.btn.mouseEnabled=true;
			if(countNum==this.listData.length){
				this.btnBuy.visible=true;
				return;
			}
			if(step>2){
				timer.once(1000,this,clickBG);
			}
		}


		public function clickBG():void{
			timer.clear(this,clickBG);
			clickNum+=1;
			step=3;
			this.btn.mouseEnabled=false;
			tweenFunc1_start();
			if(clickNum+ratity_arr[0]+ratity_arr[1]==listData.length){
				this.btn.mouseEnabled=true;
				this.btn.visible=false;
			}
		}




		public function clearCard():void{
			timer.clear(this,clickBG);
			//for(var i:int=0;i<card_arr.length;i++){
			//	this.removeChild(card_arr[i]);
			//}
			this.itemBox.removeChildren();
			
			card_arr=[];
			countNum=0;
			step=0;
			clickNum=0;
		}

		public function clearTween():void{
			if(t_arr.length!=0){
				for(var j:int=0;j<t_arr.length;j++){
					var tween:Tween = t_arr[j] as Tween;
					if (tween.target is Item){
						tween.complete();
					}
				}
			}
			t_arr=[];
		}


		public function click():void{
			/*
			clearTween();
			clearCard();
			initCard();
			return;
			*/
			/*
			if(isLimit){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_public42"));//今日次数用完
				return;
			}
			if(draw_times>=limitNum){
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_public42"));//今日次数用完
				return;
			}*/
			if(!ModelManager.instance.modelUser.isPubCanBuy(mIndex)){
				return;
			}
			var sendData:Object={};
			sendData["pid"]=itemData.id;
			NetSocket.instance.send("pub_hero",sendData,new Handler(this,this.SocketCallBack));
		}

		public function SocketCallBack(np:NetPackage):void{
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
			
			clearCard();
			clearTween();	
			reData=np.receiveData;
			setData();
			//ObjectSingle.getObjectByArr(ConfigClass.VIEW_PUB_MAIN).event(ModelProp.event_updatePub);
			ModelManager.instance.modelProp.event(ModelProp.event_updatePub);
		}



		public override function onRemoved():void{
			timer.clear(this,clickBG);
			clearTween();
			clearCard();
			
			var s:String="";
			for(var k:int=0;k<listData.length;k++){
				var o:ModelItem=listData[k];
				var ss:String=k==listData.length-1?"":",";
				s+=o.name+"x"+o.addNum+ss;
			}
			ViewManager.instance.showTipsTxt(Tools.getMsgById("_building31",[s]));//获得了
			//trace(s);
		}
	}

	

}


import ui.inside.pubHeroItemUI;
import sg.model.ModelHero;
import sg.manager.ModelManager;
import sg.utils.Tools;
import ui.com.hero_awardUI;
import ui.com.hero_icon_runeUI;
import sg.manager.EffectManager;
import laya.display.Animation;

class Item extends hero_awardUI
{
	public var num:Number=0;
	public var addNum:Number=0;
	public function Item(){

	}
	
	public function setData(id:String,addNum:Number):void
	{
		this.imgRa.visible=this.box.visible=this.bigHero.visible=false;
		num=addNum;
		var heroModel:ModelHero=ModelManager.instance.modelGame.getModelHero(id);
		this.addLabel.text="+"+addNum;
		this.nameLabel.text=heroModel.getName()+Tools.getMsgById("_public45");
		this.barLabel.text=heroModel.getMyItemNum()+"/"+heroModel.getStarUpItemNum();
		this.pro.value=heroModel.getMyItemNum()/heroModel.getStarUpItemNum();
		this.cardBG.skin=heroModel.getCardBg();
		this.heroBg.skin=heroModel.getCardBg();		
		//EffectManager.changeSprColor(this.cardBG,heroModel.getStarGradeColor(),false);
		this.imgRa.skin=heroModel.getRaritySkin();
		this.bigHero.setHeroIcon(heroModel.id);
		this.heroImg.setHeroIcon(heroModel.id);
	}

	public function setNum(n:Number):void{
		this.addLabel.text="+"+n;
		addNum=n;
	}

	public function addGlow():void{
		EffectManager.loadAnimation("glow002","",1);
		EffectManager.loadAnimation("glow003","",1);
		//EffectManager.loadAnimation("glow004","",1);
		//EffectManager.loadAnimation("glow005","",1);
		EffectManager.loadAnimation("glow045","",1);

	}
	public function getGlow(t:int):void{
		//Trace.log("tttttttttttttttt  "+t);
		if(t==-1){
			var ani:Animation=EffectManager.getAnimation("glow002","",1);
			ani.pos(this.width/2,this.height-25);
			this.addChild(ani);
		}
		if(t==1){
			var ani1:Animation=EffectManager.getAnimation("glow003","",1);
			ani1.pos(this.width/2,this.height/2);
			this.addChild(ani1);
		}else if(t==2||t==3){
			//var ani2:Animation=EffectManager.getAnimation("glow004","",1);
			var ani3:Animation=EffectManager.getAnimation("glow045","",1);
			//ani2.pos(this.width/2,this.height/2);
			ani3.pos(this.width/2,this.height/2);
			//ani3.blendMode="lighter";
			//this.addChild(ani2);
			this.addChild(ani3);
		}
	}

	public function aniFunc():void{

	}
}