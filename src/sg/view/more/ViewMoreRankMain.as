package sg.view.more
{
    import ui.more.more_rank_mainUI;
    import laya.utils.Handler;
    import sg.model.ModelRank;
    import sg.net.NetSocket;
    import sg.net.NetPackage;
    import sg.view.com.ItemBase;
    import sg.manager.ModelManager;
    import laya.events.Event;
    import sg.model.ModelUser;
    import sg.utils.Tools;
    import sg.cfg.ConfigServer;
    import sg.manager.AssetsManager;
    import sg.utils.SaveLocal;
    import laya.utils.Tween;
    import laya.utils.Ease;

    public class ViewMoreRankMain extends more_rank_mainUI
    {
        private var mTabData:Object;
        private var mListData:Array;        
        //private var myCom:*;
        private var curRankType:String;

        private var mListLen:Number;//排行榜长度
        private var mIsEyeable:Boolean;

		private var next_time_year:Number=0;

        public function ViewMoreRankMain()
        {
            this.list.scrollBar.visible=false;
            this.tab.selectHandler = new Handler(this,this.tab_select);
            this.tab.labels = Tools.getMsgById("_lht16");

            this.btnChange.on(Event.CLICK,this,changeClick);
        }
        override public function initData():void{ 
            var o:Object=SaveLocal.getValue(SaveLocal.KEY_LOCAL_RANK_TAB+ModelManager.instance.modelUser.mUID,true);
			if(o!=null){
				ModelRank.rankStatus = o;
			}

            this.title0.text=Tools.getMsgById("_more_rank06");
            this.title1.text=Tools.getMsgById("_more_rank07");
            this.setTitle(Tools.getMsgById("_country36"));
            //国士无双,绝世悍将,兵临城下,仗剑扶犁,与子同袍
            var str:String = "";
            var arr:Array = ModelRank.tabData;
            this.mTabData = [];
            //
            var len:int = arr.length;
            var obj:Object;
            var b:Boolean = false;
            for(var i:int = 0; i < len; i++)
            {
                b = false;
                obj = arr[i];
                // if(i==2){
                //     b = ModelGame.unlock(null,"country_task").visible;
                // }
                // else{
                    b = true;

                // }
                if(b){
                    this.mTabData.push(obj);
                    str+=obj.txt+",";
                }
            }
            //
            this.box_title.visible = false;
            this.tab.labels = str.substr(0,str.length-1);
            //
            this.tab.selectedIndex = this.currArg?this.currArg:0;

            this.imgFlag.skin=AssetsManager.getAssetsUI("icon_country"+(ModelManager.instance.modelUser.country+1)+".png");

            var dt:Array=Tools.deviationTime();
            var s:String = dt[0]+":";
            s+= dt[1]<=9 ? "0"+dt[1] : dt[1]; 
            this.tCountry.text=Tools.getMsgById("193014",[s]);

            
        }

        override public function onAdded():void{
            this.box_country.visible = this.box_time.visible =this.box_title.visible = this.btnChange.visible=false;
            mIsEyeable=SaveLocal.getValue(SaveLocal.KEY_SEE_RANK_WORLD+ModelManager.instance.modelUser,true)!=null;
            ModelManager.instance.modelUser.on(ModelUser.EVENT_IS_NEW_DAY,this,callBack);
            this.text0.text=Tools.getMsgById("_more_rank10");
            Tools.textLayout(this.text0,this.tTime,this.img2Time,this.box_time2);
            this.box_time2.centerX = 0;
            settimerLabel();
        }

        private function callBack():void{
            if(this.curRankType=="build_num"){
                this.tab.selectedIndex=-1;
                this.tab.selectedIndex=3;
            }
        }

        private function settimerLabel():void{
            next_time_year=Tools.getNextYearStamp();
            timerUpdate();
        }

        private function timerUpdate():void{
            this.tTime.text=Tools.getTimeStyle(next_time_year);
            next_time_year-=1000;
            if(next_time_year>0){
                timer.once(1000,this,timerUpdate); 
            }
            
        }

        private function changeClick():void{
            var n:Number=ModelRank.rankStatus[curRankType];
            ModelRank.rankStatus[curRankType]=n==0 ? 1 : 0;
            setUI();
        }


        private function tab_select(index:int):void
        {
            if(index>-1){
                this.box_title.visible = true;                
                //
                var obj:Object = this.mTabData[index];
                var type:int = obj.index;
                this.item_rank_user.visible = this.item_rank_kill.visible = false;
                NetSocket.instance.send("get_rank_by_type",{"rank_type":mTabData[index].type_key},Handler.create(this,function(np:NetPackage):void{                        
                    //trace("================",np.receiveData);
                    curRankType=mTabData[index].type_key;
                    mListData=[];
                    mListData=np.receiveData;
                    this.list.array = [];
                    switch(curRankType)
                    {
                        case "power"://个人战力(atk)
                            this.checkList(0,new Handler(this,this.list_render_0));
                            break;
                        case "hero_power"://英雄战力(hero_atk)
                            this.checkList(2,new Handler(this,this.list_render_2));
                            break; 
                        case "kill_num"://杀敌数(kill_num)
                            this.checkList(1,new Handler(this,this.list_render_3));
                            break; 
                        case "build_num"://建设值(build_num)
                            this.checkList(0,new Handler(this,this.list_render_0));
                            break;                                                                                      
                        default:
                            break;
                    }
			    }));
                //
                
            }
        }

        public function setBoxTitle():void{
            this.title1.text=Tools.getMsgById("_more_rank07");

            this.title2.text=(curRankType=="power") ? Tools.getMsgById("60000") : "";
            box_title.visible   = !(curRankType=="hero_power");
            box_country.visible = (curRankType=="kill_num");
            box_time.visible    = (curRankType=="build_num");

            if(curRankType=="power"){
                this.title3.text=Tools.getMsgById("_country41");//"战力";
                this.item_rank_user.visible=true;
                this.item_rank_kill.visible=false;
                box_title.y     = 50;
            }else if(curRankType=="kill_num"){ 
                this.title3.text=Tools.getMsgById("_country42");//"杀敌数";
                box_title.y     = box_country.y + box_country.height + 1;
                this.item_rank_user.visible=false;
                this.item_rank_kill.visible=true;
            }else if(curRankType=="build_num"){
                this.item_rank_user.visible=true;
                this.item_rank_kill.visible=false;
                this.title3.text=Tools.getMsgById("_country17");//建设
                box_title.y     = box_time.y + box_time.height + 1;
            }else if(curRankType=="hero_power"){
                box_title.y     = 50 - box_title.height;
                this.item_rank_user.visible=false;
                this.item_rank_kill.visible=false;
            }
            
            box_list.top        = (curRankType=="build_num") ? box_time.y + box_time.height + 1 : box_title.y + this.box_title.height + 1;
            box_list.bottom     = (curRankType=="hero_power") ? 2 : 88;
            this.list.top       = (curRankType=="build_num") ? box_time.height + 2 : 4; 

        }


        private function checkList(type:int,handle:Handler):void
        {
            setBoxTitle();
            var com:*;
            if(type==0){
                com=Item_Rank_User;
                //myCom=new Item_Rank_User();
            }else if(type==1){
                com=Item_Rank_Kill;
                //myCom=new Item_Rank_Kill();
            }else if(type==2){
                com=Item_Rank_Hero;
                //myCom=new Item_Rank_Hero();
            }
           

            if(this.list.renderHandler){
                this.list.renderHandler.clear();
            }
            this.list.itemRender = com;
            this.list.renderHandler = handle;

            setUI();
        }

        private function setUI():void{
            var _isMyCountry:Boolean=ModelRank.rankStatus[curRankType]==0;
            this.btnChange.label= !_isMyCountry ? Tools.getMsgById("_more_rank09") : Tools.getMsgById("_more_rank08");

            mListLen = _isMyCountry ? ConfigServer.system_simple.rank_worldlimit.rank_country[ModelManager.instance.modelUser.country] : ConfigServer.system_simple.rank_showworld[0];
            var arr:Array=[];

            var kill_num:Number=0;//每日击杀数
            var myWoIndex:int=-1;
            for(var k:int=0;k<mListData.length;k++){
                if(mListData[k].uid && mListData[k].uid+""== ModelManager.instance.modelUser.mUID){
                    if(curRankType=="kill_num"){
                        kill_num=mListData[k].kill_num;   
                    }
                    myWoIndex=k+1;
                    break;
                }
            }
            var _rank:Number=1;
            for(var j:int=0;j<mListData.length;j++){
                if(_isMyCountry){
                    if(mListData[j].country==ModelManager.instance.modelUser.country){
                        mListData[j].rank=_rank;
                        _rank++;
                        arr.push(mListData[j]);        
                    }
                }else{
                     mListData[j].rank=_rank;
                    _rank++;
                    arr.push(mListData[j]);
                }
                if(arr.length>=mListLen){
                    break;
                }
            }
            this.list.array = arr;
            list.scrollBar.value=0;
            this.callLater(listTween);            

            var myIndex:int=-1;
            for(var i:int=0;i<mListData.length;i++){
                if(mListData[i].uid){
                    if(mListData[i].uid+""== ModelManager.instance.modelUser.mUID){
                        if(mListData[i].rank <= mListLen){//小于这个数 才显示排名
                            myIndex=mListData[i].rank;
                        }
                        break;
                    }
                }
            }

            //if(this.box.getChildByName("me")){
            //    this.box.removeChild(this.box.getChildByName("me"));
            //}
                
            if(curRankType=="power" || curRankType=="kill_num" || curRankType=="build_num"){
                //this.myCom.name="me";
                //this.box.addChild(myCom);
                //this.myCom.centerX=0;
                //this.myCom.y=this.box_list.y + box_list.height + 4;
                var obj:Object={};
                obj["country"]     = ModelUser.getCountryID();
                obj["rank"]        = myIndex;
                obj["uname"]       = ModelManager.instance.modelUser.uname;
                obj["guild_name"]  = ModelManager.instance.modelGuild.name;
                //每日击杀数（数据通过接口返回）
                obj["kill_num"]    = kill_num;//ModelManager.instance.modelUser.total_records.kill_num+"";
                //年建设值
                obj["build_num"]   = ModelManager.instance.modelUser.year_build;//ModelManager.instance.modelUser.total_records.build_count+"";
                obj["building_lv"] = ModelManager.instance.modelUser.getLv();
                obj["power"]       = ModelManager.instance.modelUser.getPower();
                obj["head"]        = ModelManager.instance.modelUser.head;
                //this.myCom.setData(obj,curRankType);

                this.item_rank_kill.nameLabel.text = this.item_rank_user.nameLabel.text = obj.uname;
                this.item_rank_kill.nameLabel.color=this.item_rank_user.nameLabel.color="#10F010";

                item_rank_kill.comIndex.setRankIndex(obj.rank,Tools.getMsgById("_public101"),true);//未上榜
                item_rank_user.comIndex.setRankIndex(obj.rank,Tools.getMsgById("_public101"),true);//未上榜

                item_rank_user.comPower.visible=item_rank_user.boxLv.visible=(curRankType=="power");
                item_rank_user.numLabel.text=(curRankType=="power") ? "" : obj.build_num+"";
                item_rank_user.lvLabel.text = obj.building_lv + "";
			    item_rank_user.comPower.setNum(obj.power);     
                item_rank_user.comCountry.setCountryFlag(obj.country);

                item_rank_kill.numLabel.text=obj.kill_num+"";
                item_rank_kill.cHead.setHeroIcon(ModelUser.getUserHead(obj.head));          
                
            }
            if(curRankType=="kill_num"){
                this.btnChange.visible=false;
            }else{
                if(mIsEyeable || (ModelManager.instance.modelUser.getLv()>=ConfigServer.system_simple.rank_worldlimit.building_lv && myWoIndex!=-1 && myWoIndex<=ConfigServer.system_simple.rank_showworld[1])){
                    this.btnChange.visible=true;
                    if(mIsEyeable==false){
                        SaveLocal.save(SaveLocal.KEY_SEE_RANK_WORLD+ModelManager.instance.modelUser,{"o":1},true);
                    }
                }else{
                    this.btnChange.visible=false;
                }
            }
        
        }

        private function listTween():void{
            var item:*;
            for(var i:int=0;i<this.list.cells.length;i++){
                item = this.list.getCell(i);
                if(item){    
                    item.x=item.width;
                    Tween.to(item,{x:0},200,Ease.quadOut,null,100*i,true);               
                }else{
                    break;
                }
            }
        }

        private function list_render_0(item:Item_Rank_User,index:int):void
        {
            if(this.list.array[index]){
                item.setData(this.list.array[index],curRankType);
                item.off(Event.CLICK,this,this.itemClick);
                item.on(Event.CLICK,this,this.itemClick,[this.list.array[index].uid]);
            }
            
        }
        private function list_render_1(item:Item_Rank_Guild,index:int):void
        {
            if(this.list.array[index]){
                item.setData(this.list.array[index]);
            }
        }
        private function list_render_2(item:Item_Rank_Hero,index:int):void
        {
           if(this.list.array[index]){
                item.setData(this.list.array[index]);
                item.off(Event.CLICK,this,this.itemClick);
                item.on(Event.CLICK,this,this.itemClick,[this.list.array[index].uid]);
            }
            
        }

        private function list_render_3(item:Item_Rank_Kill,index:int):void{
            if(this.list.array[index]){
                item.setData(this.list.array[index]);
                item.off(Event.CLICK,this,this.itemClick);
                item.on(Event.CLICK,this,this.itemClick,[this.list.array[index].uid]);
            }
        }

        private function itemClick(id:*):void {
            ModelManager.instance.modelUser.selectUserInfo(id);
        }

        public override function onRemoved():void{
            ModelManager.instance.modelUser.off(ModelUser.EVENT_IS_NEW_DAY,this,callBack);
            Laya.timer.clear(this,timerUpdate); 
            this.tab.selectedIndex=-1;

            SaveLocal.save(SaveLocal.KEY_LOCAL_RANK_TAB+ModelManager.instance.modelUser.mUID,ModelRank.rankStatus,true);

        }
    }
}


import ui.more.item_rank_userUI;
import ui.more.item_rank_guildUI;
import ui.more.item_rank_heroUI;
import sg.model.ModelHero;
import sg.model.ModelSkill;
import sg.manager.ModelManager;
import ui.com.skillItemUI;
import laya.utils.Handler;
import sg.cfg.ConfigServer;
import sg.utils.Tools;
import ui.map.item_country_rankUI;
import ui.more.item_rank_killUI;
import sg.model.ModelUser;

/**
 * 
 */
class Item_Rank_User extends item_rank_userUI
{
    public function Item_Rank_User()
    {
        
    }

    public function setData(obj:Object,rank_type:String):void{
        this.comCountry.setCountryFlag(obj.country);
        this.comIndex.setRankIndex(obj.rank,Tools.getMsgById("_public101"),true);//未上榜
        this.nameLabel.text=obj.uname;
        this.nameLabel.color=(obj.uid+""==ModelManager.instance.modelUser.mUID)?"#10F010":"#FFFFFF";
        this.lvLabel.text="";
        this.numLabel.text = "";
        this.comPower.visible=this.boxLv.visible=false;
        if(rank_type=="power"){
            this.comPower.visible=this.boxLv.visible=true;
            this.lvLabel.text = obj.building_lv + "";
			this.comPower.setNum(obj.power);	
        }else if(rank_type=="kill_num" || rank_type=="build_num"){
            if(rank_type=="kill_num"){
                this.numLabel.text=obj.kill_num+"";
            }else{
                this.numLabel.text=obj.build_num+"";
            }

        }
        
    }
}

class Item_Rank_Kill extends item_rank_killUI
{
    public function Item_Rank_Kill(){

    }

     public function setData(obj:Object):void{
       
        this.nameLabel.text=obj.uname;
        this.numLabel.text=obj.kill_num+"";
        this.cHead.setHeroIcon(ModelUser.getUserHead(obj.head));
        this.comIndex.setRankIndex(obj.rank,Tools.getMsgById("_public101"),true);//未上榜
        this.nameLabel.color=(obj.uid+""==ModelManager.instance.modelUser.mUID)?"#10F010":"#FFFFFF";
    }
}


/**
 * 
 */
class Item_Rank_Guild extends item_rank_guildUI
{
    public function Item_Rank_Guild()
    {
        
    }

    public function setData(obj:Object):void{
        this.comCountry.setCountryFlag(obj.country);
        this.nameLabel.text=obj.guild_name;
        this.killLabel.text=obj.guild_kill+"";
        this.memberLabel.text=obj.user_count+"";
        this.comIndex.setRankIndex(obj.rank,Tools.getMsgById("_public101"),true);//未上榜
    }
}

/**
 * 
 */
class Item_Rank_Hero extends item_rank_heroUI{


    public var listData:Array;
    public function Item_Rank_Hero(){

    }

    public function setData(obj:Object):void{
        this.unameLabel.text=obj.uname;
        this.hnameLabel.text= ModelHero.getHeroName(obj.hid,(obj.hero_awaken && obj.hero_awaken==1));
        var key:String=obj.hid;
        key=obj.hero_awaken && obj.hero_awaken==1 ? key+"_1" : key;
        this.comHero.setHeroIcon(key,true,ModelHero.getHeroStarGradeColor(obj.hero_star));
        this.comStar.setHeroStar(obj.hero_star);
        this.comCountry.setCountryFlag(obj.country);
        this.comIndex.setRankIndex(obj.rank, Tools.getMsgById("_public101"), true);//未上榜
		this.heroLv.setNum(obj.hero_lv);
        //this.lvLabel.text = obj.hero_lv + "";
		this.comPower.setNum(obj.hero_power);
        //this.atkLabel.text=obj.hero_power+"";
        this.unameLabel.color=(obj.uid+""==ModelManager.instance.modelUser.mUID)?"#10F010":"#FFFFFF";
        this.listData=[];
        for(var s:String in obj.hero_skill){
            var skill:ModelSkill=new ModelSkill();// ModelManager.instance.modelGame.getModelSkill(s);
            skill.initData(s,ConfigServer.skill[s]);
            skill["slv"]=obj.hero_skill[s];
            listData.push(skill);
        }
        this.list.renderHandler=new Handler(this,this.listRender);
        this.list.scrollBar.visible=false;
        this.list.scrollBar.touchScrollEnable=false;
        this.list.array=listData;

        //trace("===================",obj.uid,listData);
    }

    public function listRender(item:skillItemUI,index:int):void{
        item.setSkillItem(listData[index],listData[index].slv);
    }
}