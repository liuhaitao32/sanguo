package sg.model
{
    import sg.cfg.ConfigServer;
    import sg.utils.Tools;
    import ui.inside.pubHeroItemUI;
    import sg.manager.ModelManager;
    import sg.utils.StringUtil;

    public class ModelOfficeRight extends ModelBase{
        public var name:String;
        public var office_lv:Number;
        public var para:Array;
        public var front:String;
        public var material:Array;
        public var id:String;
        public var info:String;
        public var effect_info:String;
        public function ModelOfficeRight(ids:String){
            this.id = ids;
            for(var key:String in getCfgRightById(ids))
            {
                if(this.hasOwnProperty(key)){
                    this[key] = getCfgRightById(ids)[key];
                }
            }
        }
        public function getName():String{
            return Tools.getMsgById(this.name);
        }        
        public function getFront():String{
            if(Tools.isNullString(this.front)){
                return "";
            }
            else{
                return this.front;
            }
        }
        public function getOfficeLv():int{
            return parseInt(this.id.charAt(0));
        }
        public function getMaterial():Array{
            var len:int = material.length;
            var arr:Array = [];
            for(var i:int = 0; i < len; i++)
            {
                if(material[i]>0){
                    arr.push({
                        id:ModelBuiding.material_type[i],
                        num:material[i],
                        ok:ModelBuiding.getMaterialEnough(ModelBuiding.material_type[i],material[i])
                    });
                }
            }
            return arr;
        }
        public function getInfo():String{//效果详细说明
            if(!Tools.isNullString(this.effect_info)){
                return  Tools.getMsgById(this.effect_info);
            }
            var arr:Array = getFuncs(this.id);
            var len:int = arr.length;
            var msgKey:String;
            var re:String = "";
            var par:Array;
            for(var i:int = 0; i < len; i++)
            {
                par = null;
                msgKey = arr[i];
                if(this.para){
                    par = this.para.concat();
                    if(par[0] is Number){
                        if(par[0]<1){
                            par[0] = StringUtil.numToPercentStr(par[0]);
                        }
                    }
                }
                re +=Tools.getMsgById(msgKey,par);
                if(i<len-1){
                    re+="\n";
                }
            }
            return re;
        }
        public function isMine():Boolean{
            return isOpen(this.id);
        }
        public static function isOpen(key:String):Boolean{
            return ModelManager.instance.modelUser.office_right.indexOf(key)>-1;
        }
        public static function getCfgRight():Object{
            return ConfigServer.office.right;
        }
        public static function getCfgRightById(id:String):Object{
            return getCfgRight()[id];
        }
        public static function getFuncs(id:String):Array{
            var funcArr:Array;
            var arr:Array = [];
            for(var key:String in ConfigServer.office.righttype)
            {
                funcArr = ConfigServer.office.righttype[key];
                if(funcArr.indexOf(id)>-1){
                    arr.push(key);
                }
            } 
            return arr;
        }
    }   
}