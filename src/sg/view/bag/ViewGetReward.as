package sg.view.bag
{
	import laya.maths.Point;
	import sg.utils.Tools;
	import ui.bag.getRewardUI;
	import laya.ui.Button;
	import sg.manager.ViewManager;
	import laya.events.Event;
	import ui.bag.bagItemUI;
	import sg.model.ModelItem;
	import sg.manager.ModelManager;
	import laya.utils.Handler;
	import sg.model.ModelUser;
	import laya.display.Animation;
	import sg.manager.EffectManager;
	import laya.utils.Tween;
	import laya.utils.Ease;
	import sg.utils.MusicManager;
	import sg.view.hero.ViewAwakenHero;	

	/**
	 * ...
	 * @author
	 */
	public class ViewGetReward extends getRewardUI{
		public var btnBG:Button;
		public var listData:Array=[];
		public var pageNum:Number;
		public var curIndex:Number;
		public var clickNum:Number=0;
		public var flyData:Object;
		private var fun:*;
		public var is_preview:Boolean=false;
		public var gift_dict:*;
		private var t:Tween;
		public function ViewGetReward(){
			btnBG=new Button();
			btnBG.alpha=0;
			//btnBG.x=0;
			//btnBG.y=0;
			//btnBG.width=this.stage.width;
			//btnBG.height=this.stage.height;
			//trace(btnBG.width,btnBG.height);
			btnBG.on(Event.CLICK,this,this.bgClick);
			this.addChild(btnBG);
			//btnBG.top=btnBG.bottom=btnBG.left=btnBG.right=0;
			btnBG.height=this.height;
			btnBG.width=this.width;
			btnBG.centerX=btnBG.centerY=0;
			this.list.scrollBar.visible=false;
			this.list.mouseEnabled=true;
			this.list.itemRender=bagItemUI;
			this.list.renderHandler = new Handler(this, updateItem);
			this.text.text = Tools.getMsgById("_public114");
		}

		public function bgClick():void{			
			clickNum+=1;
			curIndex+=4;
			if(clickNum>=pageNum){
				itemFly(false);
				//this.mouseEnabled=false;
			    //timer.once(1000,this,closePanel);
				closePanel();
			}else{
				itemFly();
			}
			//ModelManager.instance.modelUser.event(ModelUser.EVENT_TOP_UPDATE);
		}

		public function closePanel():void{
			//ViewManager.instance.closePanel(this);
			this.list.visible=false;
			Tween.to(this.box,{alpha:0.5,scaleX:0.8,scaleY:0.8},200,null,new Handler(this,function():void{
				closeSelf();
				mouseEnabled=true;
			}));
			
		}

		override public function onAdded():void{
			MusicManager.playSoundUI(MusicManager.SOUND_GET_REWARD);
			this.list.visible=true;
			this.box.pivotX=0.5;
			this.box.pivotY=0.5;
			this.box.alpha=1;
			this.box.scaleX=this.box.scaleY=this.box.alpha=1;
			fun=this.currArg[0];
			is_preview=this.currArg[1];
			gift_dict=this.currArg[2];
			
			listData=[];
			listData=ModelManager.instance.modelProp.getRewardProp(gift_dict,true);	
			if(is_preview){
				this.img0.visible=this.img1.visible=false;
				img2.visible=true;
				btnBG.visible=false;
			}else{
				this.img0.visible=this.img1.visible=true;
				img2.visible=false;
				btnBG.visible=true;
				var ani:Animation=EffectManager.loadAnimation("glow030","",1);
				this.box.addChild(ani);
				ani.pos(this.img1.x,this.img1.y);
			}
					
			//listData=ModelManager.instance.modelProp.rewardProp;
			var n:Number=is_preview ? 5 : 4;
			this.list.repeatX=listData.length < n ? listData.length : n;
			
			pageNum=Math.ceil(listData.length/4);
			clickNum=0;
			curIndex=0;
			if(is_preview){
				this.list.dataSource=listData;
			}else{
				updateList();
			}
			
			this.list.scrollBar.value=0;
			//trace(listData.length,n,this.list.length);
		}

		public function updateList():void{
			var n:Number=clickNum*4;
			var arr:Array=[];
			for(var i:int=0;i<4;i++){
				if(listData[i+n]){
					arr.push(listData[i+n]);
				}
			}
			this.list.dataSource=arr;

		}

		public function updateItem(cell:bagItemUI,index:int):void{
			//if(listData[index]==null){
			//	return;
			//}
			//if(listData[index].id==-1){
			//	cell.visible=false;
			//	return;
			//}
			//cell.scaleX=0.8;
			//cell.scaleY=0.8;
			cell.visible=true;
			var data:Array=this.list.array[index];
			//var isIcon:Boolean=data.id == "food" || data.id == "wood" || data.id == "iron" || data.id == "gold";
			//cell.setData(data.icon, ratity, data.name, gift_dict[data.id]?gift_dict[data.id]+"":data.addNum+"", data.type);
			cell.setData(data[0],data[1]);
		}

		public function itemFly(b:Boolean=true):void{
			//trace(list.length,curIndex);
			flyData={};
			if(b){
				updateList();
				//this.mouseEnabled=false;
				if(t){
					t.complete();
				}
				t=Tween.from(this.list,{centerX:90},500,Ease.cubicOut,new Handler(this,function():void{
					//mouseEnabled=true;
				}));
			}
			//this.list.scrollTo(curIndex);
			var n:Number = (clickNum - 1) * 4;
			
			for(var i:int = 0; i < 4; i++)
			{
				var e:Object={};
				//if(clickNum==1){
					e=listData[i+n];
				//}else{
				//	e=listData[i+4*(clickNum-1)];
				//}
				if(e){
					if(e.id!=-1){
						flyData[e[0]] = e[1];
						//trace(startX,this.listData.length);
						var itemCell:* = this.list.getCell(i);
						var pos:Point = Point.TEMP.setTo(itemCell.x + itemCell.width/2, itemCell.y + itemCell.height/2);
            			pos = itemCell['parent'].localToGlobal(pos, true);
						var nn:Number = clickNum>=pageNum ? 0 : 90;
						ViewManager.instance.showIcon(flyData, pos.x - nn, pos.y, false, '', i==0);
						flyData={};
					}
				}
			}


			
		}
		
		override public function onRemoved():void{
			if(t){
				t.complete();
			}
			listData=[];
			if(this.fun){
				if(this.fun is Handler){
					(this.fun as Handler).runWith(null);
				}
				else{
					var handler:Handler = Handler.create(this,this.fun);
					handler && handler.run();
				}
			}
			ViewAwakenHero.checkRecruitOrAwaken();
		}
	}

}