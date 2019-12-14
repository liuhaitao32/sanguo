package sg.view.beast
{
	import ui.beast.beastDetailUI;
	import sg.model.ModelBeast;
	import sg.utils.Tools;
	import sg.utils.StringUtil;
	import sg.cfg.ConfigColor;
	import sg.model.ModelHero;
	import laya.events.Event;
	import sg.manager.ModelManager;
	import sg.manager.AssetsManager;
	import sg.model.ModelItem;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.manager.ViewManager;
	import laya.display.Animation;
	import sg.manager.EffectManager;
	import sg.utils.MusicManager;

	/**
	 * ...
	 * @author
	 */
	public class ViewBeastDetail extends beastDetailUI{

		private var mItem:ItemBeast;
		private var mModelBeast:ModelBeast;
		private var mModelHero:ModelHero;
		private var mUpToLv:Number; //升至x级
		private var mCostObj:Object;//从当前等级到最大等级需要的材料
		private var mBigCostObj:Object;//从0到最大等级需要的材料
		private var mLockArr:Array;//解锁状态 做动画用

		public function ViewBeastDetail(){
			this.comTitle.setViewTitle(Tools.getMsgById('_beast_text12'));
			this.mItem = new ItemBeast();
            this.iconBg.addChild(this.mItem);
			this.mItem.centerX = 0;
			this.mItem.centerY = 0;

			for(var i:int=1;i<4;i++){
				this['tHtml'+i].style.fontSize = 16;
				//this['tHtml'+i].style.leading = 8;		
				this['tHtml'+i].style.color="#86abe5";
				this['tHtml'+i].innerHTML = '';
			}

			this.tHtml.style.fontSize = 16;		
			this.tHtml.style.color="#86abe5";
			

			//this.text0.text = Tools.getMsgById('_beast_text22');//"选择强化等级";
			this.text1.text = Tools.getMsgById('_beast_text21')//"消耗";

			lvSlider.showLabel = false;
			lvSlider.on(Event.CHANGE,this,sliderChange);

			this.btn0.on(Event.CLICK,this,btnClick,[btn0]);
			this.btn1.on(Event.CLICK,this,btnClick,[btn1]);
			this.btn2.on(Event.CLICK,this,btnClick,[btn2]);
			this.btnLock.on(Event.CLICK,this,btnClick,[btnLock]);
			this.btnRes.on(Event.CLICK,this,btnClick,[btnRes]);
			this.btnInstall.on(Event.CLICK,this,btnClick,[btnInstall]);

			this.btnRes.label = Tools.getMsgById('_beast_text6');

		}

		override public function onAdded():void{
			for(var i0:int=1;i0<4;i0++){
				this['tHtml'+i0].innerHTML = '';
			}

			if(this.currArg==null) return;

			//Tools.textLayout(this.text0,this.tLvNum,lvNumImg,lvBox);
			mModelBeast = ModelBeast.getModel(this.currArg["bid"]);
			mModelHero = ModelManager.instance.modelGame.getModelHero(this.currArg["hid"]);
			mUpToLv = mModelBeast.canUpToLv();
			mCostObj = {};
			if(mModelBeast.lv < mModelBeast.maxLv()){
				for(var i:int=mModelBeast.lv+1;i<=mModelBeast.maxLv();i++){
					var arr:Array = ModelManager.instance.modelProp.getRewardProp(mModelBeast.lvUpNeedObj(i));
					mCostObj[i]=arr;
				}
			}
			mBigCostObj = mModelBeast.lvUpNeedObj(mModelBeast.maxLv(),1);

			this.mItem.setMyData(mModelBeast.id+"");
			this.mItem.setLv(0);
			
			this.tName.text = mModelBeast.getName(true);
			this.tName.color = ConfigColor.FONT_COLORS[mModelBeast.star+1];

			
			com0.tText0.text = Tools.getMsgById('_beast_text10',[mModelBeast.typeName]); //mModelBeast.typeName + "四件套效果";
			com1.tText0.text = Tools.getMsgById('_beast_text11',[mModelBeast.typeName]); //mModelBeast.typeName + "八件套效果";

			var n0:Number = mModelBeast.getResonanceStar(4);
			var arr0:Array = ModelBeast.getResonanceInfoArr(mModelBeast.type,4,n0==-1 ? 0 : n0);
			com0.tText1.text = arr0.join('\n');
			com0.tText0.color = ConfigColor.FONT_COLORS[n0+1];

			var n1:Number = mModelBeast.getResonanceStar(8);
			var arr1:Array = ModelBeast.getResonanceInfoArr(mModelBeast.type,8,n1==-1 ? 0 : n1);
			com1.tText1.text = arr1.join('\n');
			com1.tText0.color = ConfigColor.FONT_COLORS[n1+1];

			com0.tText2.text = (n0>=0 && n0 < 4) ? Tools.getMsgById('_beast_text13',[ModelHero.star_lv_name[n0]]) : "";//"(4件套"+ModelHero.star_lv_name[mModelBeast.star-1]+"品质激活更强效果)" : "";
			com1.tText2.text = (n1>=0 && n1 < 4) ? Tools.getMsgById('_beast_text14',[ModelHero.star_lv_name[n1]]) : "";//"(8件套"+ModelHero.star_lv_name[mModelBeast.star-1]+"品质激活更强效果)" : "";
		
			com0.tText1.height = com0.tText1.textField.textHeight;
			com0.tText2.y = com0.tText1.y + com0.tText1.height + 2;

			com1.tText1.height = com1.tText1.textField.textHeight;
			com1.tText2.y = com1.tText1.y + com1.tText1.height + 2;

			mLockArr = [];
			var lockArr:Array = mModelBeast.getSuperData();
			for(var j:int=0;j<lockArr.length;j++){
				mLockArr.push(lockArr[j][1][1]);
			}
			setUI();
			setInfo1();
		}

		private function setUI():void{

			this.tLv.text = Tools.getMsgById("_public6",['']);
			this.tLv1.text = mModelBeast.lv + '/' + mModelBeast.maxLv();
			this.tLv1.x = this.tLv.x + this.tLv.width + 4;
			this.btnLock.skin = (mModelBeast.isLock() ? "ui/btn_suo.png":"ui/btn_suo1.png" );

			//var info1:String = "<Font color='" + (ConfigColor.FONT_COLORS[mModelBeast.star+1]) + "'>"+ Tools.getMsgById('_equip26') + mModelBeast.getLvInfo(mModelBeast.lv)+"</Font>";			
			//var info2:String = mModelBeast.getSuperHtmlInfo();
			//this.tHtml.innerHTML = info1;// info1 + "<br/>" + info2;

			var arr:Array = mModelBeast.getSuperData();
			var len:Number = arr.length;

			for(var i:int=0;i<3;i++){
				var data:Array = arr[i];
				var s:String = '';
				if(data){
					var s1:String = "<Font color='" + (ConfigColor.FONT_COLORS[data[0][1]]) + "'>"+Tools.getMsgById('_equip26') + data[0][0]+"</Font>";
					var s2:String = data[1][1]==0 ? "&nbsp;&nbsp;&nbsp;&nbsp;" + "<Font color='" + (data[1][1]==0 ? "#828282":"#ffffff") + "'>"+Tools.getMsgById('_beast_text34',[data[1][0]])+"</Font>" : "";
					s = s1 + s2;
					this['tHtml'+(i+1)].innerHTML = s;
				}
			}


			this.btn0.mouseEnabled = this.btn1.mouseEnabled = true;

			if(mModelBeast.lv == mModelBeast.maxLv()){
				this.btn0.mouseEnabled = this.btn1.mouseEnabled = false;
				this.lvSlider.setSlider(0,1,0);
				this.lvSlider.mouseEnabled = false;
			}else{
				if(mUpToLv == 0){
					this.btn0.mouseEnabled = this.btn1.mouseEnabled = false;
					this.lvSlider.setSlider(0,1,0);
					sliderChange();
					this.lvSlider.mouseEnabled = false;
				}else{
					lvSlider.setSlider(mModelBeast.lv,mUpToLv,mUpToLv);
					this.lvSlider.mouseEnabled = this.lvSlider.max - this.lvSlider.min > 1;
				}
			}

			this.btn2.gray = !mModelBeast.checkLv();
			if(mModelBeast.hid == ""){
				btnInstall.label = mModelHero.getBeastIds()[mModelBeast.pos]==null ? Tools.getMsgById('_beast_text15'):Tools.getMsgById('_beast_text40'); //"安装"/"更换"
			}else{
				btnInstall.label = Tools.getMsgById('_beast_text16'); //"卸载";
			}
			
		}

		private function setInfo1():void{
			//var info1:String = "<Font color='" + (ConfigColor.FONT_COLORS[mModelBeast.star+1]) + "'>"+ Tools.getMsgById('_equip26') + mModelBeast.getLvInfo(mModelBeast.lv)+"</Font>";			
			var info1:String = mModelBeast.getLvInfo(mModelBeast.lv);
			this.tHtml.innerHTML = '';//info1;
			// this.tHtml.style.wordWrap = false;
			// this.tHtml.width = this.tHtml.contextWidth;

			this.tAdd.text = info1;
			this.tAdd.width = this.tAdd.textField.textWidth;

			this.addNum.y = this.tAdd.y;
			
			this.addNum.fontSize = this.tAdd.fontSize;
			this.addNum.height = this.tAdd.height;

			this.addNum.text = '';
		}

		private function playAni1():void{
			var ani:Animation = EffectManager.loadAnimation('glow009','',1);
			ani.pos(this.tAdd.width + 24,8);
			ani.scaleX = ani.scaleY = 0.7;
			tHtml.addChild(ani);
			timer.once(200,this,function():void{
				//addNum.x = tHtml.x + tHtml.width + 46;
				addNum.x = tAdd.width + tAdd.x + 46;
				addNum.text = mModelBeast.getLvPower(mModelBeast.lv);
			});
			
			ani.once(Event.COMPLETE,this,function():void{
				setInfo1();
			});
		}

		private function playAni2():void{
			var arr:Array = [];
			var lockArr:Array = mModelBeast.getSuperData();
			for(var i:int=0;i<lockArr.length;i++){
				arr.push(lockArr[i][1][1]);
			}

			for(var j:int=0;j<arr.length;j++){
				if(mLockArr[j] == 0 && arr[j] == 1){
					var ani:Animation = EffectManager.loadAnimation('glow_arr_rarity_title','',1);
					ani.pos(150,4);
					ani.scaleY = 0.5;
					ani.scaleX = 0.8;
					this['tHtml'+(j+1)].addChild(ani);
				}
			}
			mLockArr = arr;
		}

		private function btnClick(obj:*):void{
			switch(obj){
				case this.btnLock:
					var s:String = mModelBeast.isLock() ? "beast_unlock" : "beast_lock";
					NetSocket.instance.send(s,{"beast_id":mModelBeast.id+""},Handler.create(this,function(np:NetPackage):void{
						ModelManager.instance.modelUser.updateData(np.receiveData);
						btnLock.skin = (mModelBeast.isLock()? "ui/btn_suo.png":"ui/btn_suo1.png" );
						ModelManager.instance.modelGame.event(ModelBeast.EVENT_BEAST_LIST_REFRESH);
						if(mModelBeast.isLock()){
							ViewManager.instance.showTipsTxt(Tools.getMsgById('_beast_tips7'));
						}
					}));
				break;

				case this.btn0:
					if(lvSlider.value-1 > lvSlider.min)
						lvSlider.value = lvSlider.value-1;
				break;

				case this.btn1:
						lvSlider.value = lvSlider.value+1;
				break;

				case this.btn2:
					if(mModelBeast.checkLv(true)){
						NetSocket.instance.send("beast_upgrade",{"beast_id":mModelBeast.id+"","lv":lvSlider.value},Handler.create(this,function(np:NetPackage):void{
							ModelManager.instance.modelUser.updateData(np.receiveData);
							mModelBeast.lv = ModelManager.instance.modelUser.beast[mModelBeast.id][3];
							ModelManager.instance.modelUser.event(ModelBeast.EVENT_BEAST_UPDATE);
							if(mModelHero) mModelHero.event(ModelHero.EVENT_HERO_BEAST_CHANGE);
							mUpToLv = mModelBeast.canUpToLv();
							mCostObj = {};
							if(mModelBeast.lv < mModelBeast.maxLv()){
								for(var i:int=mModelBeast.lv+1;i<=mModelBeast.maxLv();i++){
									var arr:Array = ModelManager.instance.modelProp.getRewardProp(mModelBeast.lvUpNeedObj(i));
									mCostObj[i]=arr;
								}
							}
							mBigCostObj = mModelBeast.lvUpNeedObj(mModelBeast.maxLv(),1);
							setUI();

							mItem.setMyData(mModelBeast.id+"");
							mItem.setLv(0);

							MusicManager.playSoundUI(MusicManager.SOUND_FORMATION_LV_UP);

							var ani1:Animation = EffectManager.loadAnimation('glow_arr_chose',"",1);
							ani1.pos(iconBg.width/2,iconBg.height/2);
							ani1.scaleX = 0.8;
							ani1.scaleY = 0.6;
							iconBg.addChild(ani1);

							var ani2:Animation = EffectManager.loadAnimation('beast_levelup',"",1);
							ani2.pos(tLv1.width/2,tLv1.height/2);
							tLv1.addChild(ani2);

							playAni1();
							playAni2();
						}));
					}
				break;

				case this.btnRes:
					if(mModelBeast.isLock()){
						ViewManager.instance.showTipsTxt(Tools.getMsgById('_beast_text20'));//'已锁定');
						return;
					}
					if(mModelBeast.hid!=""){
						ViewManager.instance.showTipsTxt(Tools.getMsgById('_beast_tips9'));//'已锁定');
						return;
					}
					var _this:* = this;
					ViewManager.instance.showAlert(Tools.getMsgById('_beast_text19'),function(index:int):void{
						if(index == 0){
							NetSocket.instance.send("beast_resolve",{"beast_id_list":[mModelBeast.id+""]},Handler.create(_this,function(np:NetPackage):void{
								ModelManager.instance.modelUser.updateData(np.receiveData);
								ModelManager.instance.modelUser.event(ModelBeast.EVENT_BEAST_UPDATE);
								closeSelf();
								ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
							}));
						}
					},null,Tools.getMsgById('_beast_tips8'));
				break;

				case this.btnInstall:
					if(!this.mModelHero.idle){
						this.mModelHero.busyHint();
						return;
					}
					var b:Boolean = mModelHero.getBeastIds()[mModelBeast.pos] == null;
					if(mModelBeast.hid == ""){
						NetSocket.instance.send("hero_install_beast",{"hid":mModelHero.id+"","beast_id":mModelBeast.id+""},Handler.create(this,function(np:NetPackage):void{
							ModelManager.instance.modelUser.updateData(np.receiveData);
							ModelManager.instance.modelUser.event(ModelBeast.EVENT_BEAST_UPDATE);
							ViewManager.instance.showTipsTxt(b ? Tools.getMsgById('_beast_text17') : Tools.getMsgById('_beast_text41'));//"安装成功");
							closeSelf();
						}));
					}else{
						NetSocket.instance.send("hero_uninstall_beast",{"hid":mModelHero.id+"","beast_index":mModelBeast.pos},Handler.create(this,function(np:NetPackage):void{
							ModelManager.instance.modelUser.updateData(np.receiveData);
							ModelManager.instance.modelUser.event(ModelBeast.EVENT_BEAST_UPDATE);
							btnInstall.label = Tools.getMsgById('_beast_text16');//"安装";
							ViewManager.instance.showTipsTxt(Tools.getMsgById('_beast_text18'));//"卸载成功");
							closeSelf();
						}));
					}
				break;
			}
		}

		public function sliderChange():void{
			if(lvSlider.value <= lvSlider.min){
				lvSlider.value = lvSlider.value+1;
				return;	
			}
			var lv:Number = lvSlider.value;
			//this.tLvNum.text = (lv - mModelBeast.lv)+"";
			var n:Number = lv - mModelBeast.lv;
			var arr:Array;
			
			arr = mCostObj[lv];
			if(mModelBeast.lv == mModelBeast.maxLv()){
				//this.tLvNum.text = "0";
				n = 0;
				arr = ModelManager.instance.modelProp.getRewardProp(mBigCostObj);
			}else{
				//if(mUpToLv == 0) this.tLvNum.text = "0";
				if(mUpToLv == 0) n = 0;
				if(mUpToLv == 0) arr = mCostObj[mModelBeast.lv];
			}
			this.btn2.label = Tools.getMsgById('_beast_text38',[n == 0 ? '' : n]);//'升x级';
			if(arr==null)
				arr = mCostObj[mModelBeast.lv+1];
			
			if(arr){
				comPay0.visible = true;
				
				if(arr[0]) comPay0.setData(AssetsManager.getAssetItemOrPayByID(arr[0][0]),
							arr[0][0].indexOf('item')!=-1 ? Tools.textSytle(ModelItem.getMyItemNum(arr[0][0]))+"/"+arr[0][1]:Tools.textSytle(arr[0][1]),
							ModelItem.getMyItemNum(arr[0][0])>=arr[0][1] ? -1 : 1);
				
				if(arr[1]) comPay1.setData(AssetsManager.getAssetItemOrPayByID(arr[1][0]),
							arr[1][0].indexOf('item')!=-1 ? Tools.textSytle(ModelItem.getMyItemNum(arr[1][0]))+"/"+arr[1][1]:Tools.textSytle(arr[1][1]),
							ModelItem.getMyItemNum(arr[1][0])>=arr[1][1] ? -1 : 1);
				
				if(arr[2]) comPay2.setData(AssetsManager.getAssetItemOrPayByID(arr[2][0]),
							arr[2][0].indexOf('item')!=-1 ? Tools.textSytle(ModelItem.getMyItemNum(arr[2][0]))+"/"+arr[2][1]:Tools.textSytle(arr[2][1]),
							ModelItem.getMyItemNum(arr[2][0])>=arr[2][1] ? -1 : 1);
				
				comPay1.visible = arr[1]!=null;
				comPay2.visible = arr[2]!=null;
				if(mModelBeast.lv == mModelBeast.maxLv()){
					if(arr[0]) comPay0.setData(AssetsManager.getAssetItemOrPayByID(arr[0][0]),'--');
					if(arr[1]) comPay1.setData(AssetsManager.getAssetItemOrPayByID(arr[1][0]),'--');
					if(arr[2]) comPay2.setData(AssetsManager.getAssetItemOrPayByID(arr[2][0]),'--');
				}				

				for(var i:int=0;i<3;i++){
					this["comPay"+i].off(Event.CLICK,this,comPayClick);
					this["comPay"+i].on(Event.CLICK,this,comPayClick,arr[i] ? [arr[i][0]] : [""]);
				}
			}else{
				comPay0.visible = comPay1.visible = comPay2.visible = false;
			}

		}

		private function comPayClick(id:String):void{
			if(id == "") return;
			ViewManager.instance.showItemTips(id);
		}

		override public function onRemoved():void{
			
		}
	}

}

