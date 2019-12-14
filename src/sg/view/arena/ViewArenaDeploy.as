package sg.view.arena
{
	import laya.ui.Box;
	import laya.events.Event;
	import sg.utils.Tools;
	import sg.manager.ModelManager;
	import sg.manager.AssetsManager;
	import sg.model.ModelItem;
	import sg.model.ModelHero;
	import laya.maths.Point;
	import sg.cfg.ConfigClass;
	import sg.manager.ViewManager;
	import laya.maths.MathUtil;
	import ui.arena.arenaDeployUI;
	import sg.model.ModelArena;
	import sg.model.ModelUser;
	import sg.net.NetSocket;
	import laya.utils.Handler;
	import sg.net.NetPackage;
	import sg.fight.FightMain;

	/**
	 * ...
	 * @author
	 */
	public class ViewArenaDeploy  extends arenaDeployUI{

        private var mBox_me:Box;
        private var mBox_other:Box;
        private var mSelectItem:ItemArenaHero;
        private var mLen:Number = 0;//最大上阵部队数
        private var mIndex:int;//擂台的索引值
        private var mData:Object;//当前擂台数据
        private var mRightData:Object;//守擂者数据
		public function ViewArenaDeploy(){
			this.text0.text=Tools.getMsgById("_pk03");
            this.mBox_me = new Box();
            this.mBox_me.y = 150;
            this.mBox.addChild(this.mBox_me);
            //
            this.mBox_other = new Box();
            this.mBox_other.y = 150;
            this.mBox.addChild(this.mBox_other);

            this.mBox_me.left = this.mBox_other.right = 5;
            //
            this.mSelectItem = new ItemArenaHero();
            this.mSelectItem.mouseEnabled = false;
            this.mSelectItem.mouseThrough = true;
            this.mSelectItem.visible = false;
            this.mBox.addChild(this.mSelectItem);
            //
            this.on(Event.MOUSE_DOWN,this,this.onDown);
            this.on(Event.MOUSE_UP,this,this.onUp);
            
            this.btn.on(Event.CLICK, this, this.click_pk);
            this.btn.label = Tools.getMsgById("arena_text09");//"攻擂";
			//this.comTitle.setViewTitle(Tools.getMsgById("arena_text20"));//"攻擂队伍");
            

            this.text0.text = Tools.getMsgById("arena_text21");//"攻擂方";
            this.text1.text = Tools.getMsgById("arena_text22");//"守擂方";
            this.text2.text = Tools.getMsgById("arena_text23");//"当前擂台奖池";
            this.text3.text = "9999";
            this.text4.text = Tools.getMsgById("arena_text24");//"当前攻击加成";
            this.text5.text = "15%";

		}

		private function click_pk():void{
            var item:ItemArenaHero;
            var len:int = this.mBox_me.numChildren;
            var arr:Array = [];
            var hids:Array = [];
            for(var i:int = 0; i < len; i++)
            {
                item = this.mBox_me.getChildAt(i) as ItemArenaHero;
                if(item.mStatus == 1){
                    hids.push(item.mModel.id);
                }
            }
            if(hids.length==0){
                ViewManager.instance.showTipsTxt(Tools.getMsgById("arena_tips08"));//"至少上阵一位英雄");
                return;
            }
            var _this:* = this;
            var b1:Boolean = ModelArena.instance.arena ? ModelArena.instance.arena.arena_list[mIndex].user_list[1].length == 0 : false;
            ModelArena.instance.mJoinNum = -1;
            NetSocket.instance.send("join_pk_arena",{"arena_index":mIndex,"hids":hids},Handler.create(this,function(np:NetPackage):void{
                ModelManager.instance.modelUser.updateData(np.receiveData);
                //ViewManager.instance.showRewardPanel(np.receiveData.gift_dict);
                var b2:Boolean = true;
                if(np.receiveData.gift_dict && Tools.getDictLength(np.receiveData.gift_dict)!=0){
                    np.receiveData["act"] = 0;
                    ViewManager.instance.showView(["ViewArenaReward",ViewArenaReward],np.receiveData);
                    b2 = false;
                }
                closeSelf();
                if(b1 && b2){
                    ModelArena.instance.mJoinNum = mIndex;    
                }
                
            }));
		}

		 override public function initData():void{
            mIndex = this.currArg;
            mData = ModelArena.instance.arena.arena_list[mIndex];
            this.comTitle.setViewTitle(Tools.getMsgById(ModelArena.textArr[mData.type]));
            mLen = ModelArena.instance.fightNum();

            setData();
			this.setHerosForMe();
            this.setHerosForOther();

            this.info0.text =Tools.getMsgById("_pve_tips06",[mBox_me.numChildren,mLen]);// "己方部队("+mBox_me.numChildren+"/"+mLen+")";
            this.info1.text = mRightData ? Tools.getMsgById("_pve_tips07",[mBox_other.numChildren,mLen]):"";//"敌方部队("+mBox_other.numChildren+"/"+mLen+")" : "";


            this.mBox.height = 155 + 100*mLen + 85;
        }

        private function setData():void{
            this.text3.text = ModelArena.instance.getArenaItemNum(mIndex)+"";//mData.item_num;
            var nBuff:Number = ModelArena.instance.challengerBuff(mIndex);  
			this.text5.text  = nBuff==0 ? "0" : Math.round(nBuff*100)+"%";
            mRightData = mData.user_list[0];
            if(mRightData==null){
                this.name1.visible = this.country1.visible = this.head1.visible = false;
            }else{
                this.name1.visible = this.country1.visible = this.head1.visible = true;
                this.name1.text = mRightData.uname;
                this.country1.setCountryFlag(mRightData.country);
                this.head1.setHeroIcon(ModelUser.getUserHead(mRightData.head));
            }
            this.name0.text = ModelManager.instance.modelUser.uname;
            this.country0.setCountryFlag(ModelManager.instance.modelUser.country);
            this.head0.setHeroIcon(ModelUser.getUserHead(ModelManager.instance.modelUser.head));
            
        }

		private function setHerosForOther():void{
            var arr:Array = mRightData ? mRightData.troop : [];
            var len:int = arr.length;
            var item:ItemArenaHero;
            for(var i:int = 0; i < len; i++)
            {
                item = new ItemArenaHero(false);
                item.setDataOther(i,arr[i]);
                item.y = i*100;
                this.mBox_other.addChild(item);
            }
        }

        private function setHerosForMe():void{
            var n:Number = mLen;
            var arr:Array = ModelHero.getArenaHeroList(mData.type,n);
            var len:int = arr.length;

			var item:ItemArenaHero;
            for(var i:int = 0; i < len; i++)
            {
                item = new ItemArenaHero();
                item.offAll(Event.MOUSE_OVER);
                item.on(Event.MOUSE_OVER,this,this.onOver,[item]);
                item.offAll(Event.CLICK);
                item.on(Event.CLICK,this,this.click,[item]);
				item.setDataMe(i,arr[i]);
                item.y = i * 100;
                this.mBox_me.addChild(item);
            }
            meTips.text = this.mBox_me.numChildren == 0 ? Tools.getMsgById('arena_tips08') : "";
            
        }


		override public function onAdded():void{
            
        }

        override public function onRemoved():void{
            
            this.mBox_me.destroyChildren();
            //
            this.mBox_other.destroyChildren();
            //
            this.mSelectItem.visible = false;
        }

		private function click(item:ItemArenaHero):void{
            if(item.mStatus>=0){
                ViewManager.instance.showView(ConfigClass.VIEW_PK_TROOP,[this.mBox_me,item,mLen,mData.type+2]);
            }
        }

        private function onDown(evt:Event):void{
            if(evt.target is ItemArenaHero){
                var item:ItemArenaHero = evt.target as ItemArenaHero;
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

        private function onOver(item:ItemArenaHero):void{
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
            if(evt.target is ItemArenaHero){
                var item:ItemArenaHero = evt.target as ItemArenaHero;
                if(item.isMe && item.mStatus == 1){
                    if(item.mIndex!=this.mSelectItem.mIndex){
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
                        
                    }
                }
            }
            this.mSelectItem.mDropItem = null;
            this.mSelectItem.stopDrag();
            this.mSelectItem.visible = false;
        } 

		
	}

}