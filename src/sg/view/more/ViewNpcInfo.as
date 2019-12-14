package sg.view.more
{
    import ui.more.npc_infoUI;
    import ui.more.item_npc_infoUI;
    import laya.utils.Handler;
    import sg.model.ModelTask;
    import sg.model.ModelClimb;
    import sg.cfg.ConfigServer;
    import sg.utils.Tools;
    import sg.model.ModelUser;
    import sg.model.ModelHero;
    import sg.model.ModelOfficial;
    import laya.events.Event;
    import sg.boundFor.GotoManager;
    import sg.manager.AssetsManager;
    import laya.maths.MathUtil;
    import sg.manager.ModelManager;
    import sg.model.ModelGame;
    import sg.manager.EffectManager;
    import sg.model.ModelBlessHero;

    public class ViewNpcInfo extends npc_infoUI
    {
        private var mListData0:Array;
        private var mListData1:Array;
        private var mListData2:Array;
        private var mListData3:Array;
        private var mTabStrArr:Array = ["",Tools.getMsgById("501020"),Tools.getMsgById("501021"),Tools.getMsgById("501026"),Tools.getMsgById("501028")];
        private var mIndex:int;
        public function ViewNpcInfo()
        {
            this.list.scrollBar.hide = true;
            this.list.itemRender = item_npc_infoUI;
            this.list.renderHandler = new Handler(this,this.list_render);
            //
            //this.iTitle.text = Tools.getMsgById("_lht15");
            this.comTitle.setViewTitle(Tools.getMsgById("501019"));
            //斥候情报、国令状态、护国军
            
            this.tab.selectHandler=new Handler(this,tabChange);
        }
        override public function initData():void{
            if(ModelUser.getCountryArmyAriseTime()==null){
                ModelTask.country_army_arr = [];
                ModelTask.country_army_num = 0;
            }
            ModelTask.npcInfoStatus = 0;
            //
            var arr1:Array = ModelTask.npcInfo_thief_arr;
            var arr2:Array = ModelTask.fire_city_arr;
            ModelTask.updateBuffsAndMayor();
            var arr3:Array = ModelTask.buffs_mayor_arr;
            var arr4:Array = ModelTask.country_army_arr;
            mListData0 = arr1.concat(arr2);
            mListData0.sort(MathUtil.sortByKey("layer",false,false));

            mListData1 = arr3;
            mListData1.sort(MathUtil.sortByKey("layer",false,false));
                        
            mListData2 = arr4;

            ModelTask.checkBlessHero();
            mListData3 = ModelTask.bless_hero_arr;
            //trace("==============",mListData0);
            //trace("==============",mListData1);
            //trace("==============",mListData2);
            var cfg:Object = ConfigServer.npc_info;
            var a:Array = [];
            for(var s:String in cfg){
                if(a.indexOf(cfg[s].label)==-1){
                    a.push(cfg[s].label);
                }
            }
            a.sort(function(a:*,b:*):Number{
				return MathUtil.sortNumSmallFirst(a,b);
			});
            var str:String = "";
            for(var i:int=0;i<a.length;i++){
                str+=mTabStrArr[a[i]];
                str+=i==a.length-1 ? "":",";
            }
            this.tab.labels=str;

            mIndex = this.currArg ? this.currArg : 0;
            this.tab.selectedIndex=mIndex < a.length ? mIndex : 0;
            
        }

        private function tabRedPoint():void{
            var b1:Boolean = ModelTask.fire_num>0;        //点火城市个数
			var b2:Boolean = ModelTask.thief_num>0;       //黄巾军
			var b3:Boolean = ModelTask.buffs_num>0;       //各种令的个数
            var b4:Boolean = ModelTask.country_army_num>0;//护国军数
            ModelGame.redCheckOnce(tab.items[0],b1 || b2);
            tab.items[1]!=null && ModelGame.redCheckOnce(tab.items[1],b3);
            tab.items[2]!=null && ModelGame.redCheckOnce(tab.items[2],b4);

            var b5:Boolean = ModelTask.bless_hero_num>0;; //福将挑战次数
            tab.items[3]!=null && ModelGame.redCheckOnce(tab.items[3],b5);
        }

        private function tabChange():void{
            this.info.text="";
            if(this.tab.selectedIndex==0){
                ModelTask.thief_num=ModelTask.fire_num=0;
                this.list.array=mListData0;
                this.info.text=this.list.array.length==0 ? Tools.getMsgById("_public202") : "";
            }else if(this.tab.selectedIndex==1){
                ModelTask.buffs_num=0;
                this.list.array=mListData1;
                this.info.text=this.list.array.length==0 ? Tools.getMsgById("_public219") : "";
            }else if(this.tab.selectedIndex==2){
                ModelTask.country_army_num=0;
                this.list.array=mListData2;
                this.info.text=this.list.array.length==0 ? Tools.getMsgById("_public238") : "";
            }else if(this.tab.selectedIndex==3){
                this.list.array=mListData3;
                this.info.text=this.list.array.length==0 ? Tools.getMsgById("_public242") : "";
            }
            ModelManager.instance.modelGame.event(ModelGame.EVENT_CHECK_NPC_INFO);
            this.list.scrollBar.value=0;
            tabRedPoint();
        }

        private function list_render(item:item_npc_infoUI,index:int):void
        {
            var data:Object = this.list.array[index];
            var cfg:Object = ConfigServer.npc_info[data.type];
            item.btnGo.label = Tools.getMsgById("501022");
            item.tInfo.style.color = "#cee0ff";
            item.tInfo.style.wordWrap = true;
            item.tInfo.style.leading = 6;
            item.tInfo.style.fontSize = 18;
            item.tInfo.style.align = "left";      
            item.tDiff.text = "";//Tools.getMsgById(["alien_easy", "alien_normal", "alien_trouble"][cfg.difficult-1]);
            var cid:String = data.id ? data.id : "";
            /*
            if(data.type == "pk_npc"){
                cid = this.checkPk(item,data);
            }
            else{
                cid = this.checkThief(item,data);
            }*/
            item.heroIcon.visible = false;
            
            var time:Number=0;
            var city:String=cid=="" ? "" : ModelOfficial.getCityName(cid);
            var enemy:String="";
            item.tTime.visible = item.img1.visible = item.img2.visible = true;
            item.btnGo.y=item.tTime.y+item.tTime.height+8;
            item.btnGo.label=Tools.getMsgById("501022");
            var std:Date;
            var now:Number=ConfigServer.getServerTimer();
            if(this.tab.selectedIndex==0){
                if(data.type=="thief_one" || data.type=="thief_two"  || data.type=="thief_three"){
                    var thief:Object = data.data;
                    var hmd:ModelHero = new ModelHero(true);
                    hmd.setData({hid:thief.hid});            
                    var stms:Number = thief.start_time*Tools.oneMillis;
                    var lms:Number = 0;
                    if(data.type=="thief_three") lms = ConfigServer.country_pvp[data.type].speed*Tools.oneMillis;
                    else lms = ConfigServer.attack_city_npc[data.type].speed*Tools.oneMillis;
                    var fightMs:Number = stms+lms;
                    //std = new Date(fightMs);
                    //time=(std.getHours()*60 + std.getMinutes())+"";
                    time=Math.ceil((fightMs - now)/Tools.oneMinuteMilli);
                    enemy=hmd.getName();
                }else if(data.type == "fire"){
                    item.tTime.visible=false;
                    item.btnGo.y=(item.height-item.btnGo.height)/2;
                    enemy=Tools.getMsgById("country_"+ data.data);
                }
                item.tName.text = Tools.getMsgById(cfg.title,["",city]);
                item.tInfo.innerHTML = Tools.getMsgById(cfg.info,["",city,enemy]);
            }else if(this.tab.selectedIndex==1){
                var n1:Number=Tools.getTimeStamp(data.data[2]);
                var n2:Number=ConfigServer.country[data.type].time*Tools.oneMinuteMilli;
                var n3:Number=n2 - (now - n1);
                time=n3<0 ? 0 : Math.ceil(n3/Tools.oneMinuteMilli);
                item.tName.text = Tools.getMsgById(cfg.title,["",city]);
                item.tInfo.innerHTML = Tools.getMsgById(cfg.info,["",city,enemy]);
            }else if(this.tab.selectedIndex==2){
                item.tTime.visible=false;
                item.btnGo.y=(item.height-item.btnGo.height)/2;
                item.tName.text = Tools.getMsgById(cfg.title);
                var ot:Object = ModelUser.getCountryArmyAriseTime()
                var a:Array = ot ? ot[cid] : [0,0];
                var s1:String = a[0]+":"+(a[1]<10 ? "0"+a[1] : a[1]);
                var s2:String = a[2] ? Tools.getMsgById(a[2]==1 ? "_public239" : "_public240") : "";
                item.tInfo.innerHTML = Tools.getMsgById(cfg.info,[s2 + s1,city,enemy]);
            }else if(this.tab.selectedIndex==3){
                time = 0;
                item.tTime.visible = item.img1.visible = item.img2.visible = false;
                item.btnGo.y = (item.height-item.btnGo.height)/2;
                item.heroIcon.visible = true;
                item.heroIcon.setHeroIcon(data.data[1]);
                item.tName.text = Tools.getMsgById("501028");
                item.tInfo.innerHTML = Tools.getMsgById(cfg.info,[ModelHero.getHeroName(data.data[1]),ModelOfficial.getCityName(data.data[0])]);
                item.btnGo.label =Tools.getMsgById("501030");
            }

            if(item.img0.visible) item.img0.skin = AssetsManager.getAssetsUI(cfg.flag);
            if(item.img1.visible) item.img1.skin = AssetsManager.getAssetsUI(cfg.icon);

            EffectManager.changeSprColor(item.img2,cfg.color?cfg.color:0);
            item.img1.centerX=0;
            item.img1.centerY=0;

            item.tTime.text=time<=0 ? "" : Tools.getMsgById("501023",[time]);
            item.btnGo.visible=cid!="";
            item.btnGo.off(Event.CLICK,this,this.click);
            item.btnGo.on(Event.CLICK,this,this.click,[cid]);
        }
        private function click(cid:String):void
        {
            if(cid==""){
                // trace("error error error");
                return;
            }
            if(Number(cid)>=0){
                GotoManager.boundFor({type:1,cityID:cid});
            }
            
        }
        /*
        private function checkPk(item:item_npc_infoUI,data:Object):String
        {
            var nmd:ModelClimb = data.data;
            var type:String = data.type;
            var cfg:Object = ConfigServer.npc_info[type];
            var cityData:Array = ModelClimb.alien_city(data.id+"");
            var hero:String = ModelClimb.pk_npc_get_hero_icon(ModelUser.getCountryID(),cityData[0]);
            var hmd:ModelHero = new ModelHero(true);
            hmd.setData({hid:hero});
            var cid:String = data.id+"";
            var diffArr:Array = ModelClimb.alien_country_diff(cid);
            item.tDiff.text = Tools.getMsgById(ModelClimb.pk_npc_diff_name[cityData[0]]);
            if(nmd.pk_npc_award){
                // item.box2.visible = true;
                item.tInfo.innerHTML = Tools.getMsgById(cfg.info2,[Tools.getMsgById(diffArr[0]),ModelOfficial.getCityName(cid)]);
            }
            else{
                // item.box1.visible = true;
                item.tInfo.innerHTML = Tools.getMsgById(cfg.info1,[Tools.getMsgById(diffArr[0]),ModelOfficial.getCityName(cid)]);
            }
            return cid;
        }

        private function checkThief(item:item_npc_infoUI,data:Object):String
        {
            var type:String = data.type;
            var cfg:Object = ConfigServer.npc_info[type];
            var thiefCfg:Object = ConfigServer.attack_city_npc[type];
            var thief:Object = data.data;
            var hmd:ModelHero = new ModelHero(true);
            hmd.setData({hid:thief.hid});            
            var stms:Number = thief.start_time*Tools.oneMillis;
            var lms:Number = thiefCfg.speed*Tools.oneMillis;
            
            var fightMs:Number = stms+lms;
            var std:Date = new Date(fightMs);
            var now:Number = ConfigServer.getServerTimer();
            var cid:String = data.id+"";
            if(now>=stms && now<fightMs){
                item.tInfo.innerHTML = Tools.getMsgById(cfg.info1,[std.getHours()+Tools.getMsgById("_public108")+std.getMinutes()+Tools.getMsgById("_public109"),ModelOfficial.getCityName(cid)]);
            }
            else{    
                item.tInfo.innerHTML = Tools.getMsgById(cfg.info2,[ModelOfficial.getCityName(cid),hmd.getName()]);
            }
            return cid;
        }*/

        override public function onRemoved():void{
            this.tab.selectedIndex=-1;
        }
    }
}