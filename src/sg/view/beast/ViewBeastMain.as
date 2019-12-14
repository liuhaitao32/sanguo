package sg.view.beast
{
	import ui.beast.beastMainUI;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.utils.Handler;
	import sg.model.ModelHero;
	import sg.model.ModelBeast;
	import sg.manager.ViewManager;
	import sg.manager.ModelManager;
	import sg.map.utils.ArrayUtils;
	import sg.cfg.ConfigServer;
	import laya.ui.Image;
	import sg.manager.EffectManager;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.model.ModelGame;
	import sg.utils.Tools;
	import laya.display.Animation;
	import laya.utils.Tween;
	import sg.boundFor.GotoManager;
	import sg.utils.ArrayUtil;
	import laya.html.dom.HTMLElement;
	import laya.display.Sprite;

	/**
	 * ...
	 * @author
	 */
	public class ViewBeastMain extends beastMainUI{
		
		private var mHmd:ModelHero;
		private var mItem:ItemBeast;
		private var mBeastArr:Array;

		private var mType:String = "";
		private var mPos:int = 0;
		private var mList:Array;		

		private var mCurNum:Number;
		private var mTotalNum:Number;

		private var mMoveOut:Boolean = false;
		
		private var mIsResolving:Boolean = false;
		private var mSeletedArr:Array;

		private var mCheck0Slected:Boolean = false;
		private var mCheck1Slected:Boolean = false;

		private var aniArr4:Array;
		private var aniArr8:Array;

		private var mResonanceNum:Number = 0;//0 4 8
		private var mHeroResonanceData:Array;

		public function ViewBeastMain(){
			this.comTitle.setViewTitle(Tools.getMsgById('_beast_text0'));// "兽灵");
			this.btnAll.label = Tools.getMsgById('_beast_text1');//"全部";
			this.btnPos.label = Tools.getMsgById('_beast_text2');//"位置";
			this.btnType.label = Tools.getMsgById('_beast_text3');//"类型";

			this.text0.text = Tools.getMsgById('_beast_text4');//"一键卸下";
			this.text1.text = Tools.getMsgById('_beast_text5');//"查看属性";

			this.btnRes1.label = this.btnRes2.label = Tools.getMsgById('_beast_text6');//"分解";

			this.on(Event.MOUSE_DOWN,this,this.onDown);
            this.on(Event.MOUSE_UP,this,this.onUp);

			this.list.scrollBar.visible = false;
			this.list.itemRender = ItemBeast;
			this.list.renderHandler = new Handler(this,listRender);

			this.btnAdd.on(Event.CLICK,this,this.btnClick,[btnAdd]);
			this.btnCheck.on(Event.CLICK,this,this.btnClick,[btnCheck]);
			this.btnPos.on(Event.CLICK,this,this.btnClick,[btnPos]);
			this.btnRes1.on(Event.CLICK,this,this.btnClick,[btnRes1]);
			this.btnRes2.on(Event.CLICK,this,this.btnClick,[btnRes2]);
			this.btnAll.on(Event.CLICK,this,this.btnClick,[btnAll]);
			this.btnAsk.on(Event.CLICK,this,this.btnClick,[btnAsk]);
			this.btnType.on(Event.CLICK,this,this.btnClick,[btnType]);
			this.btnSort.on(Event.CLICK,this,this.btnClick,[btnSort]);
			this.btnUninstall.on(Event.CLICK,this,this.btnClick,[btnUninstall]);

			this.check0.on(Event.CLICK,this,this.btnClick,[check0]);
			this.check1.on(Event.CLICK,this,this.btnClick,[check1]);	

			check0.label = Tools.getMsgById('_beast_text7');//"绿色品质全选";
			check1.label = Tools.getMsgById('_beast_text8');//"蓝色品质全选";

			this.tHtml.style.fontSize = 18;
			this.tHtml.style.color = '#b2d6ff';
			this.tHtml.style.align = 'center';
			this.tHtml.innerHTML = Tools.getMsgById('new_task_text8');

			this.tTips.text = Tools.getMsgById('_beast_text39');

			this.tHtml.off(Event.LINK,this,htmlClick);
			this.tHtml.on(Event.LINK,this,htmlClick);
		}

		private function htmlClick(data:*):void{
			if(data == 'new_task'){
				if(ModelManager.instance.modelNewTask.isOpen()){
					this.closeSelf();
					GotoManager.boundForPanel(GotoManager.VIEW_NEW_TASK);
				}
			}
		}

		override public function onAdded():void{
			
			mResonanceNum = 0;
			aniArr4 = [];
			aniArr8 =[];

			mIsResolving = false;
			this.btnRes1.label = Tools.getMsgById('_beast_text6');
			this.btnRes1.selected = false;
			imgBlack.visible = false;
			mCheck0Slected = mCheck1Slected = false;
			check0.selected = check1.selected = false;
			this.box1.visible = true;
			this.box2.visible = false;

			ModelManager.instance.modelUser.on(ModelBeast.EVENT_BEAST_FILTER,this,eventCallBack1);
			ModelManager.instance.modelUser.on(ModelBeast.EVENT_BEAST_SORT,this,eventCallBack2);
			ModelManager.instance.modelUser.on(ModelBeast.EVENT_BEAST_UPDATE,this,eventCallBack3);
			ModelManager.instance.modelGame.on(ModelGame.EVENT_PK_TIMES_CHANGE,this,eventCallBack4);
			ModelManager.instance.modelGame.on(ModelBeast.EVENT_BEAST_LIST_REFRESH,this,eventCallBack5);
			
			if(this.currArg==null) return;

			mType = "";
			mPos = -1;

			mHmd = this.currArg;
			initMyBeast();
			
			setData();
			setBtnUI();

			this.mItem = new ItemBeast();
            this.mItem.mouseEnabled = false;
            this.mItem.mouseThrough = true;
            this.mItem.visible = false;
			this.mItem.scale(0.65,0.65);
            this.allBox.addChild(this.mItem);

		}

		

		private function setData():void{
			mSeletedArr = [];
			mList = ModelBeast.getBeastArr(mType,mPos);
			mCurNum = ModelBeast.getBagCurNum();
			mTotalNum = ModelBeast.getBagTotalNum();
			setUI();
			var n:Number = mHmd.getBeastResonanceNum();
			if(n != mResonanceNum){
				mResonanceNum = n;
				this.aniBox0.removeChildren();
				if(n!=0){
					var ani:Animation = EffectManager.loadAnimation("beast_background",n==4 ? '1':'10');
					ani.pos(this.aniBox0.width/2,this.aniBox0.height/2);
					this.aniBox0.addChild(ani);
				}
			}
		}

		private function setUI():void{
			this.list.array = mList;

			this.tNum.text = mCurNum + "/" + mTotalNum;

			this.tHtml.visible = mCurNum == 0;

			this.tTips.visible = mCurNum > 0 && this.list.array.length == 0;

			this.btnAdd.visible = ModelBeast.buyBagNumNeedCoin() != 0;

			this.tResNum.text =Tools.getMsgById('_beast_text9',[mSeletedArr.length]);// "合计：" + mSeletedArr.length;
		}

		private function setBtnUI():void{
			this.btnPos.label = mPos==-1 ? Tools.getMsgById('_beast_text2') : ModelBeast.getPosName(mPos);
			this.btnType.label = mType=="" ? Tools.getMsgById('_beast_text3') : ModelBeast.getTypeName(mType);

			this.btnAll.selected = mPos == -1 && mType == "";
			this.btnPos.selected = mPos != -1;
			this.btnType.selected = mType != "";
		}

		private function eventCallBack1(obj:Object):void{
			if(obj["type"]!=null) mType = obj["type"];
			if(obj["pos"]!=null) mPos = obj["pos"];
			mList = ModelBeast.getBeastArr(mType,mPos);
			this.list.array = mList;
			this.tTips.visible = mCurNum > 0 && this.list.array.length == 0;

			for(var i:int=0;i<8;i++){
				(this["beastBg"+i] as Image).visible = mPos == i;
			}

			setBtnUI();
		}


		private function eventCallBack2(obj:Object):void{
			var _bigFirst:int = obj.bigFirst;
			var _sortKey:int = obj.sortKey;

			var s:String = obj.sortKey == "" ? "" : obj.sortKey;
			mList = ModelBeast.getBeastArr(mType,mPos,s,_bigFirst==0 ? false : true);
			this.list.array = mList;
			this.list.scrollBar.value = 0;
			this.tTips.visible = mCurNum > 0 && this.list.array.length == 0;

		}

		private function eventCallBack3():void{
			setData();
			updateMyBeast();
		}

		private function eventCallBack4():void{
			//mCurNum = ModelBeast.getBagCurNum();
			mTotalNum = ModelBeast.getBagTotalNum();
			this.tNum.text = mCurNum + "/" + mTotalNum;
			this.tHtml.visible = mCurNum == 0;
			this.tTips.visible = mCurNum > 0 && this.list.array.length == 0;

			this.btnAdd.visible = ModelBeast.buyBagNumNeedCoin() != 0;
		}

		private function eventCallBack5():void{
			list.refresh();
		}

		private function initMyBeast():void{
			var beastData:Array = mHmd.getBeastIds();
			mBeastArr = [];
			mHeroResonanceData = mHmd.getBeastResonanceData();
			for(var i:int=0;i<=7;i++){
				var beast:ItemBeast = new ItemBeast();
				mBeastArr.push(beast);
				this["beastBg"+i].visible = false;
				beast.anchorX = beast.anchorY = 0.5;
				beast.x = this["beastBg"+i].x;
				beast.y = this["beastBg"+i].y;
				beast.scale(0.65,0.65);
				if(beastData[i]) beast.setMyData(beastData[i]);
				else beast.setEmpty(i);
				beast.isUp = true;
				this.beastBox.addChild(beast);
				beast.on(Event.MOUSE_OVER,this,this.onOver,[beast]);
				beast.on(Event.MOUSE_OUT,this,this.onOut,[beast]);

				beast.off(Event.CLICK,this,itemClick);
				beast.on(Event.CLICK,this,itemClick,[i]);
				
				setAni(i,[beast.x,beast.y]);
				
			}
			playTween(true);
			imgBlack.zOrder = 100;
		}

		private function setAni(index:int,_pos:Array):void{
			
			if(mHeroResonanceData.length > 0){
				var ani1:Animation;
				var _star:int = 0;
				if(mHeroResonanceData[0][0] == 8){
					ani1 = EffectManager.loadAnimation("beast_level8");
					_star = mHeroResonanceData[0][1];
				}
				setAni2(ani1,_pos,_star);
				if(ani1) aniArr8.push(ani1);


				var ani2:Animation;
				for(var i:int=0;i<mHeroResonanceData.length;i++){
					var a:Array = mHeroResonanceData[i];
					_star = a[1];
					if(a[0] == 4 && a[2].indexOf(index)!=-1){
						ani2 = EffectManager.loadAnimation("beast_level4");
						break;
					}
				}
				setAni2(ani2,_pos,_star);
				if(ani2) aniArr4.push(ani2);
			}
			
		}

		private function setAni2(_ani:Animation,_pos:Array,_star:int):void{
			if(_ani){
				var n:int = parseInt((Math.random() * 48).toString());
				_ani.play(n);
				_ani.blendMode = 'light';
				aniBox1.addChild(_ani);
				_ani.pos(_pos[0],_pos[1]);
				//aniArr.push(_ani);
				EffectManager.changeSprColor(_ani,_star+1);
				_ani.visible = false;
			}
		}

		private function playTween(b:Boolean):void{
			if(aniArr8.length!=0){
				for(var i:int=0;i<aniArr8.length;i++){
					aniArr8[i].visible = b;
				}

				for(var j:int=0;j<aniArr4.length;j++){
					aniArr4[j].visible = !b;
				}

				Tween.to(this,{alpha:1},3000,null,new Handler(this,function():void{
					playTween(!b);
				}),0,true,true);

			}else{
				for(var k:int=0;k<aniArr4.length;k++){
					aniArr4[k].visible = true;
				}
			}
		}

		private function itemClick(index:int):void{
			if(mHmd.getBeastIds()[index]){
				ViewManager.instance.showView(["ViewBeastDetail",ViewBeastDetail],{"bid":mHmd.getBeastIds()[index],"hid":mHmd.id});
				eventCallBack1({"pos":index});
			}else{
				eventCallBack1({"pos":index});
			}
		}


		private function updateMyBeast():void{
			aniArr4 = [];
			aniArr8 = [];
			aniBox1.removeChildren();
			mHeroResonanceData = mHmd.getBeastResonanceData();
			var beastData:Array = mHmd.getBeastIds();
			for(var i:int=0;i<=7;i++){
				var beast:ItemBeast = mBeastArr[i];
				if(beast){
					if(beastData[i]) beast.setMyData(beastData[i]);
					else beast.setEmpty(i);
					beast.isUp = true;
					setAni(i,[beast.x,beast.y]);
				}
			}
			playTween(true);
			
			//告知面板更新战力属性
			mHmd.event(ModelHero.EVENT_HERO_BEAST_CHANGE);
		}

		private function listRender(cell:ItemBeast,index:int):void{
			var o:Object = this.list.array[index];
			cell.setMyData(o.data.id);
			cell.setLock();
			cell.btnChoose.visible = mIsResolving;

			cell.off(Event.CLICK,this,itemSelect);
			cell.off(Event.CLICK,this,itemClick2);
			if(mIsResolving){
				cell.btnChoose.selected = mSeletedArr.indexOf(o.data.id+"")!=-1;
				cell.on(Event.CLICK,this,itemSelect,[o.data.id]);
			}else{
				cell.on(Event.CLICK,this,itemClick2,[o.data.id]);
			}
			
		}

		private function itemClick2(id:String):void{
			ViewManager.instance.showView(["ViewBeastDetail",ViewBeastDetail],{"bid":id,"hid":mHmd.id});
		}


		private function itemSelect(id:String):void{
			if(ModelBeast.getModel(id+"").isLock()) return;
			
			if(mSeletedArr.indexOf(id+"")!=-1){
				mSeletedArr.splice(mSeletedArr.indexOf(id+""),1);
			}else{
				mSeletedArr.push(id+"");
			}
			this.tResNum.text = Tools.getMsgById('_beast_text9',[mSeletedArr.length]);// "合计：" + mSeletedArr.length;
			list.refresh();
		}

		private function btnClick(obj:*):void{
			switch(obj){
				case btnAdd:
					ViewManager.instance.showBuyTimes(6,ConfigServer.beast.add_bag[2],0,ModelBeast.buyBagNumNeedCoin());
				break;

				case btnAll:
					eventCallBack1({"type":"","pos":-1});
				break;

				case btnType:
					if(mCurNum == 0){
						ViewManager.instance.showTipsTxt(Tools.getMsgById('_beast_tips4'));
						return;
					} 
					ViewManager.instance.showView(["ViewBeastCheck1",ViewBeastCheck1],mType);
				break;

				case btnPos:
					if(mCurNum == 0){
						ViewManager.instance.showTipsTxt(Tools.getMsgById('_beast_tips4'));
						return;
					} 
					ViewManager.instance.showView(["ViewBeastCheck2",ViewBeastCheck2],mPos);
				break;

				case btnAsk:
					ViewManager.instance.showTipsPanel(Tools.getMsgById(ConfigServer.beast.beast_info));
				break;

				case btnRes1:
					if(mCurNum == 0){
						ViewManager.instance.showTipsTxt(Tools.getMsgById('_beast_tips4'));
						return;
					} 
					mSeletedArr = [];
					this.tResNum.text = Tools.getMsgById('_beast_text9',[mSeletedArr.length]);
					mIsResolving = !mIsResolving;
					btnRes1.selected = mIsResolving;
					this.btnRes1.label = Tools.getMsgById(mIsResolving ? '_beast_text35' : '_beast_text6');//"分解";
					setResolve();
				break;

				case btnRes2:
					if(mSeletedArr.length == 0){
						ViewManager.instance.showTipsTxt(Tools.getMsgById('_beast_tips6'));
						return;
					}
					var s1:String = Tools.getMsgById('_beast_tips2',[mSeletedArr.length]);
					var s2:String = "";//Tools.getMsgById('_beast_tips3');
					for(var i:int=0;i<mSeletedArr.length;i++){
						if(ModelBeast.getModel(mSeletedArr[i]).star>=3){
							s2 = Tools.getMsgById('_beast_tips3');
							break;
						}
					}
					ViewManager.instance.showAlert(s1 +'\n'+ s2,function(index:int):void{
						if(index == 0){
							NetSocket.instance.send("beast_resolve",{"beast_id_list":mSeletedArr},Handler.create(null,function(np:NetPackage):void{
								ModelManager.instance.modelUser.updateData(np.receiveData);
								ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
								setData();
								mIsResolving = false;
								btnRes1.selected = false;
								setResolve();
								btnRes1.label = Tools.getMsgById(mIsResolving ? '_beast_text35' : '_beast_text6');//"分解";
							}));
						}
					},null,Tools.getMsgById('_beast_tips8'));

				break;

				case btnSort:
					if(mCurNum == 0){
						ViewManager.instance.showTipsTxt(Tools.getMsgById('_beast_tips4'));
						return;
					} 
					ViewManager.instance.showView(["ViewBeastCheck3",ViewBeastCheck3]);
				break;

				case btnCheck:
					if(!mHmd.hasBeast()) ViewManager.instance.showTipsTxt(Tools.getMsgById('_beast_tips5'));
					else ViewManager.instance.showView(["ViewBeastProperty",ViewBeastProperty],mHmd);
				break;

				case btnUninstall:
					if(mHmd.hasBeast()) 
						uninstallFun(-1);
				break;

				case check0:
					mCheck0Slected = !mCheck0Slected;
					checkClick(0,mCheck0Slected);
					check0.selected = mCheck0Slected;
				break;

				case check1:
					mCheck1Slected = !mCheck1Slected;
					checkClick(1,mCheck1Slected);
					check1.selected = mCheck1Slected;
				break;
			}
		}

		private function checkClick(index:int,selected:Boolean):void{
			var arr:Array = this.list.array;
			for(var i:int=0;i<arr.length;i++){
				var o:* =  arr[i].data;
				if(o.star == 0){
					if(index == 0){
						checkFun(o.id,selected);
					}		
				}else if(o.star == 1){
					if(index == 1){
						checkFun(o.id,selected);
					}
				}
			}
			
			this.tResNum.text = Tools.getMsgById('_beast_text9',[mSeletedArr.length]);//"合计：" + mSeletedArr.length;
			list.refresh();
		}

		private function checkFun(id:String,b:Boolean):void{
			if(ModelBeast.getModel(id+"").isLock()) return;
			if(b && mSeletedArr.indexOf(id+"")==-1){
				mSeletedArr.push(id+"");
			}else if(!b && mSeletedArr.indexOf(id+"")!=-1){
				mSeletedArr.splice(mSeletedArr.indexOf(id+""),1);
			}
		}

		private function setResolve():void{
			if(mIsResolving){
				this.imgBlack.visible = true;
				box1.visible = false;
				box2.visible = true;
			}else{
				this.imgBlack.visible = false;
				box1.visible = true;
				box2.visible = false;
			}
			check0.selected = check1.selected = mCheck0Slected = mCheck1Slected = false;
			this.list.refresh();
		}


		private function onDown(evt:Event):void{
			return;
            if(evt.target is ItemBeast){
				timer.once(250,this,onDownFun,[evt]);  
            }
			mMoveOut = false;
			//onDownFun(evt);
        }

		private function onDownFun(evt:Event):void{
			if(mIsResolving) return;

			if(evt.target is ItemBeast){
				var item:ItemBeast = evt.target as ItemBeast;
				if(item.isEmpty) return;



				var point:Point;
				if(item.isUp){
					point = Point.TEMP.setTo(item.x - item.width/4, item.y - item.height/4);
				}else{
					point = item['parent'].localToGlobal(Point.TEMP.setTo(item.x, item.y));
					point = this.allBox.globalToLocal(point);
				}
				this.mItem.x = point.x;
				this.mItem.y = point.y;
				this.mItem.setMyData(item.mUid);
				this.mItem.visible = true;
				this.mItem.startDrag();
				
				this.list.scrollBar.stopScroll();
			}

		}

        private function onUp(evt:Event):void{
			return;
			timer.clear(this,onDownFun);
            if(evt.target is ItemBeast){
                var item:ItemBeast = evt.target as ItemBeast;
				if(item.mPos!=-1 && item.mPos == mItem.mPos){
					if(item.mUid+"" != mItem.mUid+""){
						installFun(mItem.mUid);
						this["beastBg"+item.mPos].visible = false;
					}
				}
            }

			if(mMoveOut){
				uninstallFun(mItem.mPos);
				mMoveOut = false;
			}

            this.mItem.mPos = -1;
            this.mItem.stopDrag();
            this.mItem.visible = false;
			
        }  

		private function onOver(item:ItemBeast):void{
			return;
			if(this.mItem.mPos!=-1){
				var img:Image = this["beastBg"+item.mPos] as Image;
				img.visible = true;
				if(item.mPos == this.mItem.mPos){
					EffectManager.changeSprColor(img,1); 
					//trace("这个位置可以");
					mMoveOut = false;
				}else{
					EffectManager.changeSprColor(img,5); 
					//trace("这个位置不行 "+item.mPos);
					mMoveOut = false;
				}
			}
			
        }

		private function onOut(item:ItemBeast):void{
			return;
			if(item.mPos != mPos){
				this["beastBg"+item.mPos].visible = false;
			}
			if(item.isEmpty) return;
			if(item.mUid!="" && mItem.mPos != -1){
				mMoveOut = true;	
			}
			
		}


		private function installFun(id:String):void{
			NetSocket.instance.send("hero_install_beast",{"hid":mHmd.id,"beast_id":id+""},Handler.create(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				setData();
				updateMyBeast();
			}));
		}

		private function uninstallFun(index:int):void{
			NetSocket.instance.send("hero_uninstall_beast",{"hid":mHmd.id,"beast_index":index},Handler.create(this,function(np:NetPackage):void{
				ModelManager.instance.modelUser.updateData(np.receiveData);
				setData();
				updateMyBeast();
			}));
		}

		override public function onRemoved():void{
			for(var i:int=0;i<=7;i++){
				(mBeastArr[i] as ItemBeast).removeSelf();
			}

			mBeastArr = [];

			this.mItem.removeSelf();

			this.aniBox0.removeChildren();
			aniArr4 = [];
			aniArr8 =[];
			aniBox1.removeChildren();

			ModelManager.instance.modelUser.off(ModelBeast.EVENT_BEAST_FILTER,this,eventCallBack1);
			ModelManager.instance.modelUser.off(ModelBeast.EVENT_BEAST_SORT,this,eventCallBack2);
			ModelManager.instance.modelUser.off(ModelBeast.EVENT_BEAST_UPDATE,this,eventCallBack3);
			ModelManager.instance.modelGame.off(ModelGame.EVENT_PK_TIMES_CHANGE,this,eventCallBack4);
			ModelManager.instance.modelGame.off(ModelBeast.EVENT_BEAST_LIST_REFRESH,this,eventCallBack5);
		}

		/**
		 * 根据名字获取界面中的对象
		 * @param	name
		 * @return 	Sprite || undefined
		 */
		override public function getSpriteByName(name:String):* {
			var ele:HTMLElement = ArrayUtil.find(tHtml._childs, function(sp:HTMLElement):Boolean {
				return sp.numChildren && (sp.getChildAt(0) as HTMLElement).href === name;
			});
			if (ele) {
				var childs:Array = ele._childs[0]._childs;
				var spr:Sprite = new Sprite();
				var minX:Number = tHtml.x + tHtml.width;
				var maX:Number = 0;
				var h:Number = 0;

				childs && childs.length && childs.forEach(function(sp:Sprite):void {
					minX = sp.x < minX ? sp.x : minX;
					maX = (sp.x + sp.width) > maX ? (sp.x + sp.width) : maX;
					h = sp.height;
				});
				spr.x = minX + tHtml.x;
				spr.y = tHtml.y;
				spr.width = maX - minX;
				spr.height = h;
				allBox.addChild(spr);
				spr.on(Event.CLICK, this, this.finishGuide);
				return spr;
			}
            return super.getSpriteByName(name);
		}

		private function finishGuide(evt:Event):void {
			allBox.removeChild(evt.currentTarget);
			if(ModelManager.instance.modelNewTask.isOpen()){
				this.closeSelf();
				GotoManager.boundForPanel(GotoManager.VIEW_NEW_TASK);
			}
		}
	}

}