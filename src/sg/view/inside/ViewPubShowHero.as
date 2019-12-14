package sg.view.inside
{
	import ui.inside.pubShowHeroUI;
	import laya.events.Event;
	import sg.manager.ViewManager;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.manager.ModelManager;
	import sg.cfg.ConfigClass;
	import ui.bag.bagItemUI;
	import sg.model.ModelItem;
	import sg.cfg.ConfigServer;
	import sg.utils.ObjectSingle;
	import sg.model.ModelProp;
	import sg.manager.AssetsManager;
	import ui.com.hero_awardUI;
	import laya.utils.Tween;
	import ui.com.t_bar_tUI;
	import sg.model.ModelHero;
	import laya.display.Animation;
	import laya.maths.MathUtil;
	import sg.utils.Tools;

	/**
	 * ...
	 * @author//弃用
	 */
	public class ViewPubShowHero extends pubShowHeroUI{

		public static var data:Object={};
		public static var title_index:Number=0;
		private var listData:Array=[];
		private var isLimit:Boolean=false;//第一个的限制
		private var limitNum:Number=ConfigServer.pub.draw_limit;//酒馆总共的限制
		private var draw_times:Number=0;
		private var card_arr:Array=[];
		private var cardCount:int=0;
		private var cardCount2:int=0;
		private var listY:Number=0;
		private var t_arr:Array=[];
		private var isAniOver:Boolean=false;
		private var title_arr:Array=[
			Tools.getMsgById("hero_box1"),Tools.getMsgById("hero_box2"),Tools.getMsgById("hero_box3")];
		public function ViewPubShowHero(){
			this.list.itemRender=Item;
			//this.btnBack.on(Event.CLICK,this,this.onClick,[this.btnBack]);
			this.btnBuy.on(Event.CLICK,this,this.onClick,[this.btnBuy]);
			this.list.scrollBar.visible=false;
			this.list.renderHandler=new Handler(this,updateItem);
		}

		override public function onAdded():void{
			this.btn.visible=false;
			this.setTitle(title_arr[title_index]);
			//listData=ModelManager.instance.modelProp.rewardProp;
			if(listData.length<=3){
				//this.list.y+=this.list.height/4;
				this.list.repeatY=1;
			}else{
				this.list.repeatY=2;
			}
			// trace(this.list.height);
			this.list.y=(this.height-this.list.height)/2-100;
			listY=this.list.y;
			this.btnBuy.y=this.list.y+this.list.height+150;
			//trace("===============",listData);
			setData();
		}

		public function setData():void{
			isAniOver=false;
			draw_times=Tools.isNewDay(ModelManager.instance.modelUser.pub_records.draw_time)?0:ModelManager.instance.modelUser.pub_records.draw_times;
			//listData=ModelManager.instance.modelProp.rewardProp;
			for(var i:int = 0; i < listData.length; i++)
			{
				var e:ModelItem = listData[i];
				var h:ModelHero=ModelManager.instance.modelGame.getModelHero(e.id.replace("item","hero"));
				e["paixu"]=h.rarity;
			}
			listData.sort(MathUtil.sortByKey("paixu",true,true));
			//list.array=listData;
			this.list.visible=false;
			var costStr:Array=[data.cost[0],data.cost[1]];
			var b:Boolean=false;

			if(data.prop_cost){
				isLimit=false;
				b=ModelManager.instance.modelProp.isHaveItemProp(data.prop_cost[0],data.prop_cost[1]);
				if(b){
					costStr=[data.prop_cost[0],data.prop_cost[1]];
				}
				this.btnBuy.setData(AssetsManager.getAssetItemOrPayByID(costStr[0]),costStr[1]);
			}else{
				var n1:Number=data.free+ModelManager.instance.modelInside.getBuildingModel("building005").lv;
				var n2:Number=ModelManager.instance.modelUser.pub_records.free_times;
				this.btnBuy.setData(AssetsManager.getAssetItemOrPayByID(costStr[0]),costStr[1]+"("+(n1-n2)+"/"+n1+")");
				if(n2>=n1){
					isLimit=true;
				}else{
					isLimit=false;
				}
			}
			
			sendCard();
			//this.mouseEnabled=false;
			this.btnBuy.visible=false;
		}
		public function updateItem(cell:Item,index:int):void{
			//if(index>listdata.length) return;
			//var value:ModelItem=listData[index];
			//Trace.log("render-",data.num,data);
			//Trace.log("render-",this.list.repeatX,this.list.repeatY);
			//cell.setData("","",value.id+"|"+value.type,value.addNum+"");
			//var h:ModelHero=ModelManager.instance.modelGame.getModelHero(value.id.replace("item","hero"));
			//cell.setData(value.id.replace("item","hero"),value.addNum);
			//if(h.rarity==2 || h.rarity==3){
			//	cell.addGlow();
			//	cell.getGlow(2);
			//}
			
		}

		public function onClick(obj:*=null):void{
			switch(obj)
			{
				//case this.btnBack:
				//	ViewManager.instance.closeScenes();
				//	break;
				
				case this.btnBuy:
					if(isLimit){
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_public42"));//今日次数用完
						return;
					}
					if(draw_times>=limitNum){
						ViewManager.instance.showTipsTxt(Tools.getMsgById("_public42"));//今日次数用完
						return;
					}
					var sendData:Object={};
					sendData["pid"]=data.id;
					//Trace.log("酒馆发消息",sendData.pid);
					NetSocket.instance.send("pub_hero",sendData,Handler.create(this,this.SocketCallBack));
					break;
				default:
					break;
			}
		}

		public function SocketCallBack(np:NetPackage):void{
			//Trace.log("酒馆收到消息--",np.receiveData);
			ModelManager.instance.modelUser.updateData(np.receiveData);
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
					//ModelManager.instance.modelProp.rewardProp.push(im);
				}
			}
			setData();
			ModelManager.instance.modelProp.event(ModelProp.event_updatePub);
		}


		public function sendCard():void{
			if(card_arr.length!=0){
				for(var i:int=0;i<card_arr.length;i++){
					this.removeChild(card_arr[i]);
				}
			}
			this.list.visible=false;
			var n:int=listData.length;
			cardCount=0;
			cardCount2=0;
			card_arr=[];
			t_arr=[];
			for(i = 0; i < n; i++)
			{
				var card:Item=new Item();
				//card.cardBG.visible=true;
				var value:Object=listData[i];
				card.setData(value.id.replace("item","hero"),value.addNum);
				card.setNum(0);
				card.addGlow();
				card.x=this.width/2+30;/////////////
				card.y=listY+this.list.height/4;
				this.addChild(card);
				card_arr.push(card);
				card.visible=false;
				var t:Tween=Tween.to(card,{x:card.x},100,null,Handler.create(this,tweenFunc,[i,card]),i*100);//延迟
				t_arr.push(t);
				//trace("11111111111111111111111111111");
			}
		}

		private function tempFun():void{
			//Trace.log("1111111111111111111111111111111");
		}

		private function tweenFunc(index:int,card:Item):void{////1左移		
			card.visible=true;
			card.anchorX=1;
			var t:Tween=Tween.to(card,{x:10+index*10+card.width},300,null,Handler.create(this,tweenFunc2,[index,card]));
			t_arr.push(t);
		}

		private function tweenFunc2(index:int,card:Item):void{////2
			var t:Tween=Tween.to(card,{y:card.y},1500*(listData.length-index-1),null,Handler.create(this,tweenFunc3,[index,card]));//延迟
			t_arr.push(t);
		}
		private function tweenFunc3(index:int,card:Item):void{////2翻牌1
			var t:Tween=Tween.to(card,{scaleX:0},150,null,Handler.create(this,tweenFunc4,[index,card]));
			t_arr.push(t);
		}

		private function tweenFunc4(index:int,card:Item):void{/////3翻牌2
			card.cardBG.visible=false;
			card.imgRa.visible=card.box.visible=card.bigHero.visible=true;
			card.anchorX=0;
			var t1:Tween=Tween.to(card,{y:card.y},100,null,Handler.create(this,tweenFunc7,[index,card]));//延迟
			var t2:Tween=Tween.to(card,{scaleX:1},150,null,Handler.create(this,tweenFunc5,[index,card]));
			t_arr.push(t1);
			t_arr.push(t2);
		}
		private function tweenFunc5(index:int,card:Item):void{/////4右移
			var h:ModelHero=ModelManager.instance.modelGame.getModelHero(listData[index].id.replace("item","hero"));
			card.getGlow(h.rarity);
			this.setChildIndex(card,this.numChildren-1);
			var t:Tween=Tween.to(card,{x:this.width-card.width-(listData.length-index-1)*10-10},200,null,Handler.create(this,tweenFunc6,[index,card]),1000);
			t_arr.push(t);
		}
		
		private function tweenFunc6(index:int,card:Item):void{/////5延迟
			cardCount+=1;
			if(cardCount==listData.length){
				for(var i:int = 0; i < listData.length; i++)
				{
					var t:Tween=Tween.to(card,{y:card.y},300,null,Handler.create(this,tweenFunc9,[i,card_arr[i]]));//延迟
					t_arr.push(t);
				}
			}
		}
		private function tweenFunc7(index:int,card:Item):void{//卡牌内的动画
			timer.loop(100,this,tweenFunc8,[card],false);
			card.getGlow(-1);
		}
		private function tweenFunc8(card:Item):void{//卡牌内的动画回调
			//Trace.log(card.addNum,card.num);
			card.addNum+=Math.ceil(card.num/4)>=card.num?card.num:Math.ceil(card.num/4);
			card.setNum(card.addNum);
			if(card.addNum>=card.num){
				timer.clear(this,tweenFunc8);
				card.setNum(card.num);
			}
		}
		private function tweenFunc9(index:int,card:Item):void{//平铺
			if(listData.length<=3){
				var posX:Number=(index==0)?0:this.list.x+((card.width+10)*index);
				var t:Tween=Tween.to(card,{x:posX},300,null,Handler.create(this,tweenFunc10,[index,card]));	
				t_arr.push(t);
			}else{
				var n1:Number=index<3?index:(index-3);
				var posX1:Number=n1==0?0:this.list.x+(card.width+10)*n1;
				var n2:Number=0;
				if(index>=3)
					n2=1;
				
				var sY:Number=n2==0?0:24;
				var posY:Number=this.list.y+card.height*n2+sY;
				var t1:Tween=Tween.to(card,{x:posX1,y:posY},300,null,Handler.create(this,tweenFunc10,[index,card]));
				t_arr.push(t1);
				//trace(posX1,posY);
			}
			
		}

		private function tweenFunc10(index:int,card:Item):void{
			cardCount2+=1;
			if(cardCount2!=listData.length){
				return;
			}
			//for(var i:int=0;i<card_arr.length;i++){
			//	this.removeChild(card_arr[i]);
			//}
			//this.list.visible=true;
			//this.mouseEnabled=true;
			this.btnBuy.visible=true;
			if(t_arr.length!=0){
				for (var j:int = 0; j < t_arr.length; j++){
					var tween:Tween = t_arr[j] as Tween;
					if (tween.target is Item){
						tween.complete();
					}
					//Tween.clear(t_arr[j]);
				}
			}
			t_arr.length = 0;
			isAniOver=true;
		}

		override public function onRemoved():void{
			this.list.y=listY;
			if(card_arr.length!=0){
				for(var i:int=0;i<card_arr.length;i++){
					this.removeChild(card_arr[i]);
				}
			}
			this.mouseEnabled=true;
			//if(t_arr.length!=0){
			//	for(var j:int=0;j<t_arr.length;j++){
			//		Tween.clear(t_arr[j]);
			//	}
			//}
			if(!isAniOver){
				var s:String="";
				for(var k:int=0;k<listData.length;k++){
					var o:ModelItem=listData[k];
					var ss:String=k==listData.length-1?"":",";
					s+=o.name+"x"+o.addNum+ss;
				}
				ViewManager.instance.showTipsTxt(Tools.getMsgById("_building31",[s]));//获得了
				// trace(s);
			}
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
		EffectManager.loadAnimation("glow004","",1);
		EffectManager.loadAnimation("glow005","",1);

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
			var ani2:Animation=EffectManager.getAnimation("glow004","",1);
			var ani3:Animation=EffectManager.getAnimation("glow005","",0);
			ani2.pos(this.width/2,this.height/2);
			ani3.pos(this.width/2,this.height/2);
			//ani3.blendMode="lighter";
			this.addChild(ani2);
			this.addChild(ani3);
		}
	}

	public function aniFunc():void{

	}
}