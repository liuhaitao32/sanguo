package sg.view.menu
{
	import sg.cfg.ConfigApp;
	import sg.map.utils.TestUtils;
    import ui.menu.userInfoNormalUI;
    import laya.utils.Handler;
    import laya.events.Event;
    import sg.manager.ViewManager;
    import sg.cfg.ConfigClass;
    import sg.manager.ModelManager;
    import sg.model.ModelHero;
    import laya.maths.MathUtil;
    import sg.model.ModelGuild;
    import sg.model.ModelUser;
    import sg.utils.Tools;
    import sg.model.ModelOffice;
    import sg.model.ModelOfficial;
    import sg.cfg.ConfigServer;
    import sg.model.ModelGame;
    import sg.net.NetSocket;
    import sg.net.NetPackage;

    public class UserInfoNormal extends userInfoNormalUI{
        private var mUser:Object;
        public function UserInfoNormal(){
            this.list.itemRender = ItemUserHero;
            this.list.renderHandler = new Handler(this,this.list_render);
            this.list.scrollBar.visible = false;
            this.bName.on(Event.CLICK,this,this.onClick,[0]);
            this.bHead.on(Event.CLICK,this,this.onClick,[1]);
            this.btnChat.on(Event.CLICK,this,this.onClick,[2]);
            //ModelManager.instance.modelUser.on(ModelUser.EVENT_USER_INFO_UPDATE,this,function():void{
                //if(mUser.id==ModelManager.instance.modelUser.mUID){
                //    this.cHead.setHeroIcon(ModelManager.instance.modelUser.head);//头像
               // }
            //});

            this.text2.text    = Tools.getMsgById("_public110");
            this.text3.text    = Tools.getMsgById("502018");
            this.text4.text    = Tools.getMsgById("lvup03_1_name");
            this.text5.text    = Tools.getMsgById("lvup09_2_name");
            this.text6.text    = Tools.getMsgById("lvup07_3_name");
            this.bName.label   = Tools.getMsgById("_public212");
            this.bHead.label   = Tools.getMsgById("_public213");
            this.btnChat.label = Tools.getMsgById("_country89");
        }
        public function setData(data:Object):void{
            ModelGame.unlock(this.btnChat,"chat_btn");
            this.mUser = data;
            var isMe:Boolean=(this.mUser.id == ModelManager.instance.modelUser.mUID);
            this.bName.visible=this.bHead.visible=isMe;
			this.imgFlag.visible=!isMe && this.mUser.country!=null;
			var nameStr:String = isMe ? ModelManager.instance.modelUser.uname : this.mUser.uname+"";
            var offical:Number=ModelOfficial.getOfficersByID(this.mUser.country,this.mUser.id);
            this.comOffcial.visible=(offical!=-100);
			if(offical!=-100) this.comOffcial.setOfficialIcon(offical, ModelOfficial.getInvade(this.mUser.country), this.mUser.country);
			if (TestUtils.isTestShow){
				nameStr += ' uid:'+this.mUser.id;
			}
            
            if(isMe) this.btnChat.visible = false;
			
            this.tName.text = nameStr;
            this.comOffcial.x=this.tName.x+this.tName.width+10;

            var cid:String=ModelOfficial.isCityMayor(this.mUser.id,this.mUser.country);
            this.tMayor.text = cid=="" ? "" : Tools.getMsgById(ConfigServer.city[cid].name)+Tools.getMsgById("_country13");

			this.comPower.setNum(this.mUser.power);			
            //this.tPower.text = this.mUser.power+"";
            this.imgFlag.skin=this.mUser.country ? "ui/icon_country"+(this.mUser.country+1)+".png" : "ui/icon_country1.png";
            this.tLv.text = this.mUser.building_lv;
            this.tOffice.text = ModelOffice.getOfficeName(this.mUser.office);
            this.tFarm.text = this.mUser.farm;
            this.tHistory.text = this.mUser.history;
            var headStr:*=isMe ? ModelManager.instance.modelUser.head : this.mUser.head;
            this.cHead.setHeroIcon(ModelUser.getUserHead(headStr));//头像
            //
            var arr:Array = [];
            var hero:Object;
            for(var key:String in this.mUser.hero)
            {
                hero = this.mUser.hero[key];
                hero["id"] = key;
                //var hmd:ModelHero = new ModelHero(true);            
                //hmd.setData(this.mUser.hero[key]);
                //hero["sortPower"]=hmd.getPower(hmd.getPrepare());
                arr.push(hero);
            }
            arr.sort(MathUtil.sortByKey("power",true,true));
            var arr2:Array=[];
            for(var i:int=0;i<arr.length;i++){
                arr2.push(arr[i]);
                if(arr2.length>=10){
                    break;
                }
            }
            this.list.array = arr2;

        }
        private function list_render(item:ItemUserHero,index:int):void{
            item.centerX = 0;
            item.setData(this.list.array[index]);
            item.on(Event.CLICK,this,this.itemClick,[index]);
        }

        private function itemClick(index:int):void{
			ViewManager.instance.showView(ConfigClass.VIEW_HERO_INFO,this.list.array[index]);
            //ViewManager.instance.showView(ConfigClass.VIEW_SHOP_HERO_TIPS,this.list.array[index]);
        }

        private function onClick(index:int):void{
            if(index==0){//改名
                ViewManager.instance.showView(ConfigClass.VIEW_CHANGE_NAME);
            }else if(index==1){//换头像
                ViewManager.instance.showView(ConfigClass.VIEW_CHANGE_HEAD);
            }else if(index == 2){
                var s:String = ModelGame.unlock(this.btnChat,"chat_btn").text;
                if(s!=""){
                    ViewManager.instance.showTipsTxt(s);
                }else{
                    NetSocket.instance.send("get_msg",{},Handler.create(this,function(np:NetPackage):void{
                        ModelManager.instance.modelUser.updateData(np.receiveData);
                        ModelManager.instance.modelUser.setChatData(ModelManager.instance.modelUser.msg.usr);	
                        ModelManager.instance.modelUser.event(ModelUser.EVENT_UPDATE_MAIL_CHAT_MAIN,ModelManager.instance.modelUser.msg.usr);
                        ModelManager.instance.modelChat.findUerCallBack(
                            {"receiveData":{"uid":this.mUser.id,
                                            "uname":this.mUser.uname,
                                            "country":this.mUser.country,
                                            "head":this.mUser.head,
                                            "lv":this.mUser.building_lv}},1);   
                    }));
                }
                
            }
        }
        override public function clear():void{
            this.list.destroy(true);
            this.mUser = null;
        }
        
    }   
}