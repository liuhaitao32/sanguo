package sg.model
{
    import sg.manager.ModelManager;
    import sg.cfg.ConfigServer;
    import sg.utils.Tools;
    import laya.maths.MathUtil;
    import sg.utils.SaveLocal;
    /**
     * 官职,爵位,爵位特权
     */
    public class ModelOffice extends ModelBase{
        public var name:String;
        public var upaward:Object;
        public var condition:Object;
        public var id:String;
        //
        public function ModelOffice(ids:String):void{
            if(Tools.isNullString(ids)){
                return;
            }
            this.initData(ids);
        }
        public function initData(ids:String):void{
            this.id = ids;//等级 == id
            for(var key:String in getCfgOfficeById(ids))
            {
                if(this.hasOwnProperty(key)){
                    this[key] = getCfgOfficeById(ids)[key];
                }
            }
        }
        public function getLv():int{
            return parseInt(this.id);
        }
        public function getName():String{
            return getOfficeName(this.id);
        }
        public static function getBuildingMaxLv(lv:int):Number{
            if(ConfigServer.office.officelv_building.hasOwnProperty(lv)){
                return ConfigServer.office.officelv_building[lv];
            }
            else{
                return 0;
            }
        }
        /**
         * 当前爵位的 升级条件 整理
         * id = ,ok = 是否OK,value = ,index = 排序
         */    
        public function getConditionArr(olv:Number=0,checkMerge:Boolean = true):Array{
            var arr:Array = [];
            var obj:Object;
            var re:Array;
            for(var key:String in this.condition)
            {
                if(key=="merge_times"){//合服条件 不显示
                    if(checkMerge){
                        obj = {id:key,ok:ModelManager.instance.modelUser.mergeNum >= this.condition[key],info:"",pre:1,value:0,index:0,n1:0,n2:0};  
                        arr.push(obj);
                    }       
                }else{
                    re = checkCondition(key,this.condition[key],(olv+1)+"");
                    obj = {id:key,ok:re[0],info:re[1],pre:re[2],value:this.condition[key],index:0,n1:re[3],n2:re[4]};  
                    arr.push(obj);
                }

                //office_gtask这个值会被重置回0  但是UI上面会显示不正确  所以这里重新赋值
  
                
            }
            arr.sort(MathUtil.sortByKey("index"));
            return arr;
        }

        /**
         * 爵位是否可升级
         */
        public function isCanLvUp():Boolean{
            if(this.condition){
                if(this.condition.hasOwnProperty("merge_times")){
                    return ModelManager.instance.modelUser.mergeNum>=this.condition["merge_times"];
                }
                return true;
            }
            return false;
        }

        /**
         * 本地红点数据 登录时设置一次
         */
        public static function setLocalRedPoint():Object{
            var o:Object=SaveLocal.getValue(SaveLocal.KEY_SEE_OFFICE_MAIN+ModelManager.instance.modelUser.mUID,true);
            var b:Boolean=false;
            if(o==null) o={};
            if(o==null) b=true;
            var arr:Array = ModelOffice.getOfficeAll();
            for(var i:int=0;i<arr.length;i++){
                var omd:ModelOffice=arr[i];
                if(omd.isCanLvUp()){
                    if(!o.hasOwnProperty(omd.id)){
                        o[omd.id]=false;
                        b=true;
                    }
                }
            }
            if(b)
                SaveLocal.save(SaveLocal.KEY_SEE_OFFICE_MAIN+ModelManager.instance.modelUser.mUID,o,true);
            
            //trace("===========",o);
            return o;
        }

        /**
         * 检查本地红点数据
         */
        public static function checkLocalRedPoint():Boolean{
            var o:Object=SaveLocal.getValue(SaveLocal.KEY_SEE_OFFICE_MAIN+ModelManager.instance.modelUser.mUID,true);
            if(o==null) return true;//一般来说不会等于null
            if(o){
                for(var s:String in o){
                    if(o[s]==false)
                        return true;
                }
            }
            return false;
        }


        /**
         * 爵位升级的 条件 判断
         */
        public static function checkCondition(type:String,value:*,olv:String):Array{           
            var b:Boolean = false;
            var okNum:Number = 0;
            var info:String = "";
            var officecon:String = "officecon_";
            var per:Number = 0;
            var maxNum:* = value;
            var lvInt:int = parseInt(olv);
            var curLv:int = ModelManager.instance.modelUser.office;
            if(type == "merit"){//#累计功勋
                okNum = ModelManager.instance.modelUser.total_records.merit;
                info = Tools.getMsgById(officecon+"merit",[value]);
                if(okNum >= value){
                    b = true;
                }
                per = okNum/value;
            }else if(type=="office_right"){//#开启2个特权
                okNum = ModelManager.instance.modelUser.office_right.length;
                info = Tools.getMsgById(officecon+"right",[value]);
                if(okNum >= value){
                    b = true;
                }
                per = okNum/value;
            }else if(type=="hero"){//#获得4个英雄 0为不限英雄品质
                var num:Number = 0;
                var starVal:Number = value[0];
                var hmd0:ModelHero;
                //
                info = Tools.getMsgById(officecon+"hero",[starVal<0?Tools.getMsgById("_office8"):ModelHero.getHeroStarColorName(starVal),value[1]]);//"任意"
                //
                for(var key0:String in ModelManager.instance.modelUser.hero){
                    hmd0 = ModelManager.instance.modelGame.getModelHero(key0);
                    if(hmd0.getStar()>=starVal){
                        num+=1;
                    }
                    if(num>=value[1]){
                        b = true;
                        break;
                    }
                }
                okNum = num;
                maxNum=value[1];
                per = okNum/value[1];
            }else if(type=="army"){//#训练500个士兵
                info = Tools.getMsgById(officecon+"army",[value]);
                okNum = ModelManager.instance.modelUser.total_records.army_0+ModelManager.instance.modelUser.total_records.army_1+ModelManager.instance.modelUser.total_records.army_2+ModelManager.instance.modelUser.total_records.army_3;
                if(okNum>=value){
                    b = true;
                }
                per = okNum/value;
            }else if(type=="finish_gtask"){//#完成20个政务
                info = Tools.getMsgById(officecon+"finish_gtask",[value]);
                okNum = ModelManager.instance.modelUser.total_records.finish_gtask;
                if(okNum>=value){
                    b = true;
                }
                per = okNum/value;
            }else if(type=="building"){//#building002等级达到2级
                var bid:String = value[0];
                var blv:Number = value[1];
                var bmd:ModelBuiding = ModelManager.instance.modelInside.getBuildingModel(bid);
                okNum = bmd.lv;
                info = Tools.getMsgById(officecon+"building",[bmd.getName(),blv]);
                if(bmd.lv>=blv){
                    b = true;
                }
                maxNum=value[1];
                per = okNum/blv;
            }else if(type=="skill_lv"){//#【技能等级，技能数量，英雄数量】麾下4个英雄各有2个10级以上技能  英雄数量为0则合并所有英雄的技能数量
                var hnum:Number = 0;
                var snum:Number = 0;
                var hnumMax:Number = value[2];
                var hmd:ModelHero;
                var smd:ModelSkill;
                for(var key:String in ModelManager.instance.modelUser.hero)
                {
                    hmd = ModelManager.instance.modelGame.getModelHero(key);
                    if(hnumMax>0){
                        snum = 0;
                    }
                    for(var key2:String in hmd.getMySkills()){
                        smd = ModelManager.instance.modelGame.getModelSkill(key2);
                        if(hnumMax>0){
                            if(smd.getLv(hmd)>=value[0]){
                                snum+=1;
                            }                            
                            if(snum>=value[1]){
                                hnum+=1;
                                break;
                            }
                        }
                        else{
                            if(smd.getLv(hmd)>=value[0]){
                                snum+=1;
                            }  
                            if(snum>=value[1]){
                                b = true;
                                break;
                            }                          
                        }
                    }
                    if(hnum>=hnumMax && hnumMax>0){
                        b = true;
                        break;
                    }
                    else if(hnumMax<=0){
                        if(snum>=value[1]){
                            b = true;
                            break;
                        } 
                    }
                }
                info = Tools.getMsgById(officecon+"skill_lv",[value[0],value[1],(hnumMax>0)?value[2]:(hnumMax==1)?Tools.getMsgById("_office8"):""]);
                okNum = (hnumMax>0)?hnum:snum;
                maxNum=(hnumMax>0)?value[2]:value[1];
                per = (hnumMax>0)?(okNum/value[2]):(okNum/value[1]);
            }else if(type=="resolve"){//#累计问道50次
                okNum = ModelManager.instance.modelUser.total_records.resolve;
                info = Tools.getMsgById(officecon+"resolve",[value]);
                if(okNum >= value){//
                    b = true;
                }
                per = okNum/value;
            }else if(type=="build_count"){
                okNum = ModelManager.instance.modelUser.total_records.build_count;
                info = Tools.getMsgById(officecon+"build_count",[value]);
                if(okNum >= value){//
                    b = true;
                }
                per = okNum/value;
            }else if(type=="hello"){//#拜访次数10次（大地图行为
                okNum = ModelManager.instance.modelUser.total_records.visit_num;
                info = Tools.getMsgById(officecon+"hello",[value]);
                if(okNum>=value){//
                    b = true;
                }
                per = okNum/value;
            }else if(type=="make_equip"){//#制作5个宝物
                okNum = ModelManager.instance.modelUser.total_records.make_equip;
                info = Tools.getMsgById(officecon+"make_equip",[value]);
                if(okNum>=value){//
                    b = true;
                }                
                per = okNum/value;
            }else if(type=="tax"){//#征税次数5次
                info = Tools.getMsgById(officecon+"tax",[value]);
                okNum = ModelManager.instance.modelUser.total_records.estate_1;
                if(okNum>=value){//
                    b = true;
                }             
                per = okNum/value;
            }else if(type=="office_gtask"){//#达到某个官职等级之后完成政务的次数
                info = Tools.getMsgById(officecon+"office_gtask",[getCfgOfficeById((lvInt-1)+"") ? Tools.getMsgById(getCfgOfficeById((lvInt-1)+"").name):"",value]);
                okNum = curLv==lvInt-1 ? ModelManager.instance.modelUser.total_records.office_gtask : (curLv>lvInt-1 ? value : 0);
                if(curLv>=lvInt-1 && okNum>=value){//
                    //还有政务
                    b = true;
                }
                per = okNum/value;
            }else if(type=="office_credit"){//上一个爵位之后累积的战功                
                info = Tools.getMsgById(officecon+"office_credit",[getCfgOfficeById((lvInt-1)+"") ? Tools.getMsgById(getCfgOfficeById((lvInt-1)+"").name):"",value]);
                okNum = curLv==lvInt-1 ? ModelManager.instance.modelUser.records.office_credit : (curLv>lvInt-1 ? value : 0);
                //okNum = ModelManager.instance.modelUser.records.office_credit ? ModelManager.instance.modelUser.records.office_credit : 0;
                if(okNum>=value){
                    b=true;
                }
                per = okNum/value;
            }
            return [b,info,per,okNum,maxNum];
        }
        /**
         * 爵位 当前 等级的配置
         */
        public static function getCfgOfficeById(id:String):Object{
            return ConfigServer.office.office_lv[id];
        }
        public static function getOfficeName(id:*):String{
            var cfg:Object = getCfgOfficeById(id+"");
            if(cfg){
                return Tools.getMsgById(cfg.name);
            }
            return Tools.getMsgById("officelv0");
        }        
        /**
         * 获得 爵位下的 特权 model
         */
        public static function getRightByLv(id:String):Array{
            var fid:String = "";
            var arr:Array = [];
            var ormd:ModelOfficeRight;
            for(var key:String in ModelOfficeRight.getCfgRight())
            {
                fid = key.substring(0,key.length-2);
                if(fid == id && ModelOfficeRight.getFuncs(key).length>0){
                    ormd = new ModelOfficeRight(key);
                    arr.push(ormd);
                }
            }
            return arr;
        }
        /**
         * 获取所有 爵位 model
         */
        public static function getOfficeAll():Array{
            var arr:Array = [];
            var obj:Object;
            var omd:ModelOffice;
            for(var key:String in ConfigServer.office.office_lv)
            {
                omd = new ModelOffice(key);
                arr.push(omd);
            }
            arr.sort(MathUtil.sortByKey("id"));
            return arr;
        }

        public static function getAddstarCheck():String{
            var arr:Array = ModelOffice.getRightType(ModelOffice.addstar);
            var len:int = arr.length;
            var rid:String = "";
            for(var i:int = 0;i < len;i++){
                if(!ModelOfficeRight.isOpen(arr[i])){
                    rid = arr[i];
                    break;
                }
            }
            if(rid!=""){
                var rmd:ModelOfficeRight = new ModelOfficeRight(rid);
                var fid:String = rid.substring(0,rid.length-2);
                return getOfficeName(fid)+rmd.getName();
            }
            return "";
        }

        /**
         * 星级突破需要的特权id
         */
        public static function getAddstarID():String{
            var arr:Array = ModelOffice.getRightType(ModelOffice.addstar);
            var len:int = arr.length;
            var rid:String = "";
            for(var i:int = 0;i < len;i++){
                if(!ModelOfficeRight.isOpen(arr[i])){
                    rid = arr[i];
                    break;
                }
            }
            
            return rid;
        }


        /**
         * --------------------------------------------------------------
         * --------------------------------------------------------------
         * --------------------------------------------------------------
         * --------------------------------------------------------------
         * --------------------------------------------------------------
         * --------------------------------------------------------------
         */
        public static const buildtime:String       = "buildtime";      //建筑秒杀时间@
        public static const addtroop:String        = "addtroop";       //增加编队上限@
        public static const runaway:String         = "runaway";        //在国战中，未出战的部队可撤军
        public static const mexp_compensate:String = "mexp_compensate";//死亡士兵战功补偿,相同类型之间，大的覆盖小的
        public static const addhero:String         = "addhero";        //#酒馆中增加英雄
        public static const mayor:String           = "mayor";          //是否可以被任命为太守
        public static const addstar:String         = "addstar";        //增加星级突破的等级上限@
        public static const buildworker:String     = "buildworker";    //增加封地的建筑队列@
        public static const homegold:String        = "homegold";       //#封地钱产量增加 1+%@
        public static const homefood:String        = "homefood";       //#封地粮产量增加 1+%@
        public static const homewood:String        = "homewood";       //#封地木产量增加 1+%@
        public static const homeiron:String        = "homeiron";       //#封地铁产量增加 1+%@
        public static const baggagefree:String     = "baggagefree";    //#辎重免费购买次数@
        public static const indcount:String        = "indcount";       //#可占领产业数量增加
        public static const addmerit:String        = "addmerit";       //#政务的功勋奖励增加 1+%
        public static const gtaskcount:String      = "gtaskcount";     //#政务次数增加
        public static const shoppos:String         = "shoppos";        //商店位置开放
        public static const break_right:String     = "break";          //国战中突破至下一个城池
        public static const highbox:String         = "highbox";        //#酒馆中额外赠送抽将
        public static const arrogance:String       = "arrogance";      //傲气值不增加的规则
        public static const traincost:String       = "traincost";      //减少练兵资源 1-%@
        public static const visitherocount:String  = "visitherocount"; //拜访增加英雄数量
        public static const syield:String          = "syield";         //已占领的产业被动收益
        public static const sectionspeed:String    = "sectionspeed";   //科技研发速度 1-%
        public static const visittime:String       = "visittime";      //拜访时间缩短量
        public static const estatetime:String      = "estatetime";     //狩猎时间缩短量
        public static const killmexp:String        = "killmexp";       //击杀士兵战功增加量 1+%

        public static const flycatch:String        = "flycatch";       //全范围切磋
        public static const flyestate:String       = "flyestate";      //全范围占领产业
        public static const flygtask:String        = "flygtask";       //全范围做政务

        public static const autotrain:String       = "autotrain";       //自动补兵
        /**
         * 建筑秒杀时间,免费秒 分钟
         */
        public static function func_buildtime():Number{
            return func_addNum(buildtime);
        }
        /**
         * 增加 编队 上限 +
         */
        public static function func_addtroop():Number{
            return func_addNum(addtroop);
        }
        /**
         * 在国战中，未出战的部队可撤军
         */
        public static function func_runaway():Boolean{
            return func_addNum(runaway,true)>0;
        } 
        /**
         * 死亡士兵战功补偿,相同类型之间，大的覆盖小的
         */
        public static function func_mexp_compensate():Number{
            return func_addNum(mexp_compensate,false,true);
        }
        /**
         * 酒馆中增加英雄
         */
        public static function func_addhero(key:String):Number{
            var arr:Array = getRightType(addhero);
            var n:Number=0;
            for(var i:int=0;i<arr.length;i++){
                var rid:String=arr[i];
                if(ModelOfficeRight.isOpen(rid)){
                    var para:Array = ModelOfficeRight.getCfgRightById(rid).para;
                    if(para[0]==key){
                        n+=para[1];    
                    }
                }
            }
            return n;//func_addNum(addhero,true);
        }
        /**
         * 酒馆中额外赠送抽将
         */
        public static function func_highbox(key:String):Number{
            var arr:Array = getRightType(highbox);
            var n:Number=0;
            for(var i:int=0;i<arr.length;i++){
                var rid:String=arr[i];
                if(ModelOfficeRight.isOpen(rid)){
                    var para:Array = ModelOfficeRight.getCfgRightById(rid).para;
                    if(para[0]==key){
                        n+=para[2];    
                    }
                }
            }
            return n;// func_addNum(highbox,true);
        } 
        /**
         * 是否可以被任命为太守
         */
        public static function func_mayor():Boolean{
            return func_addNum(mayor,true)>0;
        }
        /**
         * 增加星级突破的等级上限,和一起
         */
        public static function func_addstar():Number{
            return func_addNum(addstar);
        }    
        /**
         * 建筑升级上限
         */
        public static function func_buildworkerNum():Number{
            return func_addNum(buildworker);
        }  
        public static function func_buildworkerInfo():String{
            var arr:Array = getRightType(buildworker);
            var len:int = arr.length;
            var rid:String;
            var para:Object;
            var str:String="";
            var oid:String = "";
            for(var i:int = 0; i < len; i++)
            {
                rid = arr[i];
                //
                // if(ModelOfficeRight.isOpen(rid)){
                //     para = ModelOfficeRight.getCfgRightById(rid).para;
                //     m +=para[0];
                // }
                oid = rid.substring(0,rid.length-2);
                
                str += Tools.getMsgById(getCfgOfficeById(oid).name)+Tools.getMsgById(ModelOfficeRight.getCfgRightById(rid).name);
            }
            return str;             
        }  
        /**
         * 封地钱产量增加 = 1+n%
         */
        public static function func_homegold():Number{
            return func_addNum(homegold);
        } 
        /**
         * 封地粮产量增加 = 1+n%
         */
        public static function func_homefood():Number{
            return func_addNum(homefood);
        }  
        /**
         * 封地木产量增加 = 1+n%
         */
        public static function func_homewood():Number{
            return func_addNum(homewood);
        } 
        /**
         * 封地铁产量增加 = 1+n%
         */
        public static function func_homeiron():Number{
            return func_addNum(homeiron);
        }   
        /**
         * 辎重免费购买次数 
         */
        public static function func_baggagefree():Number{
            return func_addNum(baggagefree);
        }  
        /**
         * 可占领产业数量增加
         */
        public static function func_indcount():Number{
            return func_addNum(indcount);
        } 
        /**
         * 政务的功勋奖励增加
         */
        public static function func_addmerit():Number{
            return func_addNum(addmerit);
        }     
        /**
         * 政务次数增加
         */
        public static function func_gtaskcount():Number{
            return func_addNum(gtaskcount);
        } 
        /**
         * 商店位置开放
         */
        public static function func_shoppos():Object{
            return func_isGetkey(shoppos);
        } 
        /**
         * 国战中突破至下一个城池
         */
        public static function func_break():Boolean{
            return func_addNum(break_right,true)>0;
        }
  
        /**
         * 傲气值不增加的规则
         */       
        public static function func_arrogance():Boolean{
            return func_addNum(arrogance,true)>0;
        } 
        /**
         * 减少练兵资源 1-%
         */
        public static function func_traincost():Number{
            return func_addNum(traincost);
        } 
        /**
         * 拜访增加英雄数量
         */
        public static function func_visitherocount():Number{
            return func_addNum(visitherocount);
        }  
        /**
         * 已占领的产业收益 1+%
         */
        public static function func_syield():Number{
            return func_addNum(syield);
        }
        /**
         * 科技研发速度 1-%
         */ 
        public static function func_sectionspeed():Number{
            return func_addNum(sectionspeed);
        } 
        /**
         * 拜访时间缩短量 ms
         */ 
        public static function func_visittime():Number{
            return func_addNum(visittime);
        }     
        /**
         * 狩猎时间缩短量 ms
         */ 
        public static function func_estatetime(type:String):Number{
            return func_addNum(estatetime,false,false,type);
        }  
        /**
         * 击杀士兵战功增加量 1+%
         */ 
        public static function func_killmexp():Number{
            return func_addNum(killmexp);
        }  
        /**
         * 
         */ 
        public static function func_flycatch():Boolean{
            return func_addNum(flycatch,true)>0;
        }  
        /**
         * 
         */ 
        public static function func_flyestate():Boolean{
            return func_addNum(flyestate,true)>0;
        }  
        /**
         * 
         */ 
        public static function func_flygtask():Boolean{
            return func_addNum(flygtask,true)>0;
        } 

        /**
         * 
         */ 
        public static function func_autotrain():Boolean{
            return func_addNum(autotrain,true)>0;
        } 

        /**
         * 爵位、特权 功能 增加数值的
         */           
        public static function func_addNum(type:String,onlyBool:Boolean = false,max:Boolean = false,ts:String=""):Number{
            var arr:Array = getRightType(type);
            var len:int = arr.length;
            var rid:String;
            var para:Object;
            var m:Number = 0;
            for(var i:int = 0; i < len; i++)
            {
                rid = arr[i];//每个特权id
                //
                if(ModelOfficeRight.isOpen(rid)){// 检测特权 是否 开通
                    if(max){
                        para = ModelOfficeRight.getCfgRightById(rid).para;
                        m = Math.max(para[0],m);//最大模式
                    }
                    else{
                        if(onlyBool){
                            m += 1;//存在模式
                        }
                        else{
                            para = ModelOfficeRight.getCfgRightById(rid).para;//计数模式
                            if(para.length>1){
                                if(para[0]==ts){
                                    m +=para[1];    
                                }
                            }else{
                                m +=para[0];
                            }
                        }
                    }
                }
            }
            return m;            
        }
        public static function func_isGetkey(type:String):Object{
            var arr:Array = getRightType(type);
            var len:int = arr.length;
            var rid:String;
            var para:Object;
            var re:Object = {};
            for(var i:int = 0; i < len; i++)
            {
                rid = arr[i];//每个特权id
                para = ModelOfficeRight.getCfgRightById(rid).para;
                var o:Object={};
                o["panelID"]="office";
                o["secondMenu"]=rid,
                re[para[0]] =[para[1],rid,o];//

                //
                if(ModelOfficeRight.isOpen(rid)){// 检测特权 是否 开通
                    if(re.hasOwnProperty(para[0])){
                        delete re[para[0]];
                    }
                }
            }
            return re;
        }
        public static function getRightType(key:String):Array{
            return ConfigServer.office.righttype[key];
        }
		/**
		 * 检查 爵位 是否有升级的
		 */
		public static function checkOfficeCanUp():Boolean{
            var b:Boolean = true;
            if(ModelGame.unlock(null,"more_office").stop){
                return false;
            }
            //
			var curr:int = (ModelManager.instance.modelUser.office>0)?(ModelManager.instance.modelUser.office-1):0;
			var arr:Array = ModelOffice.getOfficeAll();
			var omd:ModelOffice = arr[curr];
            var isHad:Boolean = ModelManager.instance.modelUser.office>= Number(omd.id);
            if(isHad){
                if(curr<(arr.length-1)){
                    curr+=1;
                    omd = arr[curr];
                }
            }
            //
			var checkArr:Array = omd.getConditionArr();
            //
			if(checkArr.length>0){
				var len:int = checkArr.length;
				for(var i:int = 0;i < len;i++){
					if(!checkArr[i].ok){
						b = false;
						break;
					}
				}
			}
            else{
                if(!omd.condition){
                    b = false;
                }
            }
			return b;
		}  
        public static function checkOfficeWill(onlyRight:Boolean = false):Boolean{
            var rights:Object = ConfigServer.office.right;
            var righttype:Object = ConfigServer.office.righttype;
            var right:Object;
            var lv:Number = ModelManager.instance.modelUser.office;
            var num:Number = 0;
            var numOK:Number = 0; 
            var key:String;      
            
            /*
            for(key in rights)
            {
                right = rights[key];
                if(right.office_lv<=lv){
                    if(checkOfficeWillRight(right,key)){
                        return true;
                    }
                }
            }*/
            //以前是遍历所有的特权  改为 遍历righttype里面有的特权id
            for(var s:String in righttype){
                var arr:Array=righttype[s];
                for(var i:int=0;i<arr.length;i++){
                    key=arr[i];
                    right = rights[key];
                    if(right.office_lv<=lv){
                        if(checkOfficeWillRight(right,key)){
                            return true;
                        }
                    }
                }
            }

            if(onlyRight){
                return false;
            }
            var cfg:Object = ConfigServer.office.office_lv[lv+1];
            while(ConfigServer.office.office_lv[lv+1])
            {
                cfg = ConfigServer.office.office_lv[lv+1];
                num = 0;
                numOK = 0;
                if(cfg.condition){
                    for(key in cfg.condition)
                    {
                        num+=1;
                        if(checkCondition(key,cfg.condition[key],(lv+1)+"")[0]){
                            numOK+=1;
                        }
                    }
                    if(num==numOK){
                        return true;
                    }
                } else {
					return false;//敬请期待没有红点。
				}
                lv+=1;
            }
            return false;
        }  
        public static function checkOfficeOpenWill(omd:ModelOffice,olv:int):Boolean{
            var fid:Number = Number(omd.id);
            if(fid>ModelManager.instance.modelUser.office){
                var arr:Array = omd.condition?omd.getConditionArr(olv):[];
                var len:int = arr.length;
                var num:Number = 0;                 
                for(var i:int = 0; i < len; i++)
                {
                    if(arr[i].ok){
                        num+=1;
                    }
                }
                if(num>0 && num == len){
                    return true;
                }
            }
            return false;

        }
        public static function checkOfficeWillRight(right:Object,oid:*):Boolean{
            if(right.material){
                var num:Number = 0;
                var numOK:Number = 0;             
                var len:int = right.material.length;
                var arr:Array = [];
                var fid:Number = Number(oid.substring(0,oid.length-2));
                if(fid>ModelManager.instance.modelUser.office){
                    return false;
                }
                num = 0;
                numOK = 0;
                for(var i:int = 0; i < len; i++)
                {
                    if(right.material[i]>0){
                        num+=1;
                        if(ModelBuiding.getMaterialEnough(ModelBuiding.material_type[i],right.material[i]) 
                            && ModelManager.instance.modelUser.office_right.indexOf(oid)<0 
                            && (!right.front  || (right.front && ModelManager.instance.modelUser.office_right.indexOf(right.front)>-1)))
                        {
                            numOK+=1;
                        }
                    }
                }  
                if(num == numOK){
                    return true;
                }    
            }  
            return false;      
        }    
    }   
}