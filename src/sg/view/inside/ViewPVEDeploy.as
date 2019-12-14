package sg.view.inside
{
	import ui.fight.pkDeployUI;
	import laya.ui.Box;
	import sg.view.fight.ItemPKhero;
	import laya.events.Event;
	import sg.utils.Tools;
	import sg.manager.ModelManager;
	import sg.model.ModelItem;
	import sg.model.ModelHero;
	import laya.maths.Point;
	import sg.net.NetSocket;
	import sg.net.NetPackage;
	import sg.manager.ViewManager;
	import sg.cfg.ConfigClass;
	import sg.cfg.ConfigServer;
	import laya.utils.Handler;
	import sg.model.ModelUser;
	import sg.fight.FightMain;
	import sg.utils.SaveLocal;

	/**
	 * ...
	 * @author
	 */
	public class ViewPVEDeploy extends pkDeployUI{

        
		private var config_pve:Object={};
        private var battlId:String="";

		//private var mData:Object;
        private var mBox_me:Box;
        private var mBox_other:Box;
        private var mSelectItem:ItemPKhero;
        //private var mTempTroop:Array;
        //private var mTempMyData:Object;
        private var mTroopNum:int = -1;

        private var me_len:Number=0;
        private var other_len:Number=0;
        private var mIsCanRepeat:Boolean=false;
        private var mfirstHid:String="";
        private var mOtherHid:String="";
        private var mUpHids:Array;
		private var skip_fight:Boolean;
		
		public function ViewPVEDeploy(){
			this.mBox_me = new Box();
            this.mBox_me.y = 100;
            this.mBox.addChild(this.mBox_me);
            //
            this.mBox_other = new Box();
            this.mBox_other.y = 100;
            this.mBox.addChild(this.mBox_other);
            //
            this.mSelectItem = new ItemPKhero();
            this.mSelectItem.mouseEnabled = false;
            this.mSelectItem.mouseThrough = true;
            this.mSelectItem.visible = false;
            this.mBox.addChild(this.mSelectItem);
            //
            this.on(Event.MOUSE_DOWN,this,this.onDown);
            this.on(Event.MOUSE_UP,this,this.onUp);
            // this.mSelectItem.on(Event.DRAG_MOVE,this,this.onDrag);
            this.btn.on(Event.CLICK, this, this.click_pk);
            this.btn.label = Tools.getMsgById("_lht65");
		}
		



        //private function ws_sr_pk_user(re:NetPackage):void{
		//	var receiveData:* = re.receiveData;	
			//
			//ViewManager.instance.showFightScenes(FightMain.startBattle(receiveData, this, this.outFight, [receiveData]).fightLayer);
        //}

		override public function initData():void{
            this.btnClear.visible=false;
            //this.mData = this.currArg[0];

            //this.mTempMyData = this.currArg[1];
            //this.mTempTroop = Tools.isNullObj(this.mTempMyData)?[]:this.mTempMyData.troop;
            config_pve = ConfigServer.pve;
            battlId = this.currArg[0];
            mIsCanRepeat=this.currArg[1];
            //
            //this.tTitle.text = Tools.getMsgById(battlId);
            this.comTitle.setViewTitle(Tools.getMsgById(battlId));
            //this.tName.text = "己方部队("+me_len+"/"+other_len+")";//ModelManager.instance.modelUser.uname;/////////////////
            //this.tOther.text = "敌方部队("+other_len+"/"+other_len+")";//this.mData.uname;//////////////////
            this.tName.color=this.tOther.color="#98c3d9";

            //
            //var award:Array = ModelManager.instance.modelClimb.getPKawardByOnec();
            //this.award.setData(ModelItem.getItemIcon(award[0]),0,"",award[1]);
            this.boxReward.visible=false;
            //
            //
            this.setHerosForMe();
            this.setHerosForOther();

            this.tName.text = Tools.getMsgById("_building32",[me_len+"/"+other_len]);//"己方部队("+me_len+"/"+other_len+")";
            this.tOther.text = Tools.getMsgById("_building33",[other_len+"/"+other_len]);//"敌方部队("+other_len+"/"+other_len+")";
        }

	    override public function onRemoved():void{
            this.mBox_me.destroyChildren();
            this.mBox_me.removeChildren();
            //
            this.mBox_other.destroyChildren();
            this.mBox_other.removeChildren();
            //
            this.mSelectItem.visible = false;
        }

		 private function setHerosForOther():void{
            var arr:Array = config_pve.battle[battlId].enemy; //this.mData.troop as Array;
            var item:ItemPKhero;
            other_len=arr.length;
            for(var i:int = 0; i < other_len; i++)
            {
                item = new ItemPKhero(false);
                //if(i<arr.length){
                   item.setDataOther(i,arr[i]);            
                //}                
                //else{
                    //item.setDataOther(i,null);
                //}
                item.y = i*100;
                if(i==0){
                    mOtherHid=arr[i].hid;
                }
                this.mBox_other.addChild(item);
            }
            this.mBox_other.right = 8;
        }

	    private function setHerosForMe():void{
            var arr:Array = [];
            var hmd:ModelHero;
                       

            var fNum:Number=0;
            var eNum:Number=config_pve.battle[battlId].enemy.length;
			if(config_pve.battle[battlId].hasOwnProperty("friend")){
				fNum=config_pve.battle[battlId].friend.length;
               
			}
            
			var a:Array=getLocalData();// ModelManager.instance.modelUser.getMyHeroArr(true);
			for(var j:int=0;j<a.length;j++){
				if(j<eNum-fNum){
					var hero:ModelHero=ModelManager.instance.modelGame.getModelHero(a[j]);
					arr.push(hero);
				}
			}

        	if(config_pve.battle[battlId].hasOwnProperty("friend")){
                var f:Array=config_pve.battle[battlId].friend;
				for(var k:int=0;k<f.length;k++){
					hmd=new ModelHero(true);
					hmd.setData(f[k]);
					hmd["is_help"]=true;
					arr.push(hmd);
				}
			}
            me_len=arr.length;
            var item:ItemPKhero;
            this.mTroopNum = 0;
            for(var i:Number = 0; i < arr.length; i++)
            {
                item = new ItemPKhero();
                item.on(Event.MOUSE_OVER,this,this.onOver,[item]);
                item.on(Event.CLICK,this,this.click,[item]);
                item.mouseEnabled=true;
                if(i<arr.length){
                    this.mTroopNum+=1;
                    item.setDataMe(i,arr[i]);
                    item.imgHelp.visible=(arr[i].is_help);
                    item.setIsFriend(arr[i].is_help);
                    item.mouseEnabled=!(arr[i].is_help);
                }
                else{
                    item.setDataMe(i,null);
                }
                item.y = i * 100;
                this.mBox_me.addChild(item);
            }
            this.mBox_me.x = 8;

        }

		 private function click(item:ItemPKhero):void{
            if(item.mStatus>=0){
                ViewManager.instance.showView(ConfigClass.VIEW_PK_TROOP,[this.mBox_me,item,this.mTroopNum,1]);
            }
        }
        private var isDrag:Boolean = false;
        private function onDown(evt:Event):void{
            if(evt.target is ItemPKhero){
                var item:ItemPKhero = evt.target as ItemPKhero;
				if(!item.isMe){
                    return;
                }
                var point:Point = this.mBox_me.toParentPoint(new Point(item.x,item.y));
                if(item.mStatus!=1){
                    return;
                }
                this.mSelectItem.x = point.x;
                this.mSelectItem.y = point.y;
                this.mSelectItem.setDataMe(item.mIndex,item.mModel);
                this.mSelectItem.visible = true;
                this.mSelectItem.mDropItem = item;
                this.mSelectItem.startDrag();
                //
            }
        }
        private function onOver(item:ItemPKhero):void{
            if(item.mStatus!=1){
                return;
            }
            if(item.mIndex!=this.mSelectItem.mIndex){
                // 不一样
            }
            else{
                // 一样
            }
        }
        private function onUp(evt:Event):void{
            if(evt.target is ItemPKhero){
                var item:ItemPKhero = evt.target as ItemPKhero;
                if(item.isMe && item.mStatus == 1){
                    if(item.mIndex!=this.mSelectItem.mIndex){
                        //不一样up
                        var dInde:int = item.mIndex;
                        var dModel:ModelHero = item.mModel;
                        if(this.mSelectItem.mDropItem){
                            item.setDataMe(dInde,this.mSelectItem.mModel);
                        }
                        if(this.mSelectItem.mDropItem){
                            this.mSelectItem.mDropItem.setDataMe(this.mSelectItem.mIndex,dModel);
                        }
                    }
                    else{
                        //一样up
                    }
                }
            }
            this.mSelectItem.mDropItem = null;
            this.mSelectItem.stopDrag();
            this.mSelectItem.visible = false;
        }  

        private function click_pk():void{

            if(me_len!=other_len){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("_building34"));//队伍数不足，无法开战
                return;
            }
            
            getHids();
            var talks:Array=config_pve.battle[battlId].talks;
            if(!mIsCanRepeat && talks){
                mfirstHid=mUpHids[0];
                talks=talks.concat();
                for(var i:int=0;i<talks.length;i++){
                    var a:Array=talks[i];
                    if(a[0]+""=="1"){
                        if(i%2!=0){
                            a[0]=mOtherHid;
                        }else{
                            a[0]=mfirstHid;
                        }
                    }
                }
                ViewManager.instance.showHeroTalk(talks,function():void{
                     sendMsg();
                });
            }else{
                sendMsg();
            }
			
        }

        public function sendMsg():void{
			var sendData:Object={};
			sendData["battle_id"]=this.currArg[0];
			sendData["repeat"]=0;
            sendData["hids"]=mUpHids;
            NetSocket.instance.send("pve_combat",sendData,Handler.create(this,startCallBack));
            setLocalData(mUpHids);
        }

        public function getHids():void{
            var item:ItemPKhero;
            var len:int = this.mBox_me.numChildren;
            var arr:Array = [];
            mUpHids = [];
            var num1:Number=config_pve.battle[battlId].enemy.length;
            var num2:Number=config_pve.battle[battlId].friend?config_pve.battle[battlId].friend.length:0;
            for(var i:int = 0; i < len; i++)
            {
                item = this.mBox_me.getChildAt(i) as ItemPKhero;
                if(item.mStatus == 1){
                    // arr.push({hid:item.mModel.id,index:item.mIndex});
                    if(i<num1-num2){
                        mUpHids.push(item.mModel.id);
                    }
                }
            }            
        }

        private function startCallBack(np:NetPackage):void{
            ViewManager.instance.closePanel();            
            var receiveData:* = np.receiveData;
			var canSkip:Boolean = !config_pve.battle[battlId].battle_type;
			if (receiveData.pk_result && receiveData.pk_result.winner != 0){
				canSkip = false;
			}
            this.skip_fight = FightMain.startBattle(receiveData, this, this.outFight, [receiveData], canSkip, ConfigServer.world.skip_pve_rate)?false:true;
        }

        private function outFight(receiveData:*):void{
			if (this.skip_fight){
				//跳过了战斗，显示奖励
				ViewManager.instance.showRewardPanel(receiveData.gift_dict);
			}
			ModelManager.instance.modelUser.updateData(receiveData);
			if (receiveData.pk_result && receiveData.pk_result.winner != 0){
				//败北或平局都是输
			}
			else{
				//这里闪黑屏
				ModelManager.instance.modelUser.event(ModelUser.EVENT_PVE_UPDATE,mIsCanRepeat);
			}
			this.closeSelf();
		}


        public function getLocalData():Array{
            var modelUser:ModelUser = ModelManager.instance.modelUser;
            var o:Object=SaveLocal.getValue(SaveLocal.KEY_PVE_HERO + modelUser.mUID,true);
            var arr:Array=[];
            var a:Array = modelUser.getMyHeroArr(true,"",null,true);
            if(Tools.isNullString(o)){
                for(var i:int=0;i<5;i++){
                    if(a[i]){
                        arr.push(a[i].id);
                    }else{
                        break;
                    }
                }
            }else{
                var aa:Array=o["hero"];
                for(var j:int=0;j<aa.length;j++){
                    if(aa[j]){
                        var heros:Object = modelUser.hero;
                        var b1:Boolean=heros.hasOwnProperty(aa[j]);//英雄列表里没有这个英雄
                        var b2:Boolean = Boolean(modelUser.getCommander(aa[j])); // 是副将
                        if(!b1 || b2){
                            if(aa.indexOf(aa[j])!=-1){
                                aa.splice(aa.indexOf(aa[j]),1);
                                // trace("pve do not find ",aa[j]);
                            }
                        }
                    }
                    
                }
                if(aa.length>=5){
                    arr=aa;
                }else{
                    var n:Number=0;
                    while(aa.length<=5){
                        if(a[n] && aa.indexOf(a[n].id)==-1){
                            aa.push(a[n].id);
                        }
                        n+=1;
                        if(!a[n]){
                            break;
                        }
                    }
                    arr=aa;
                }
            }
            //trace("================",arr);
            return arr;
        }

        public function setLocalData(arr:Array):void{
            var o:Object={"hero":arr};
            SaveLocal.save(SaveLocal.KEY_PVE_HERO+ModelManager.instance.modelUser.mUID,o,true);
            
        }
	}

	

}