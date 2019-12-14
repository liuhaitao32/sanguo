package sg.utils
{
    import sg.cfg.ConfigColor;
    import sg.cfg.ConfigServer;
    import sg.model.ModelEstate;
    import sg.model.ModelHero;

    public class FunMsgByValue
    {
        public function FunMsgByValue()
        {
            
        }
        public static const MSG_HERO_STAR_COLOR:String = "hero_star_color:";
        public static const MSG_HERO_STAR_COLOR_RIGHT:String = "hero_star_color_right:";
		public static const MSG_SHOP_NAME:String = "shop_name:";
		public static const MSG_CFG_NAME:String = "cfg_name:";
		public static const MSG_PERCENT:String = "percent:";
		public static const MSG_ESTATE:String = "estate:";
		public static const MSG_EQUIP_LV:String = "equip_lv:";//宝物等级->颜色
		public static const MSG_HERO_RARITY:String = "hero_rarity:";//英雄品质
		
		public static function msg_replace_func(str:String,i:int,v:*):String{
			var reStr:String = "";
			var ret:RegExp
			if(str.indexOf("{"+MSG_HERO_STAR_COLOR+i+"}")>-1){
				reStr = "\\{"+MSG_HERO_STAR_COLOR+i+"\\}";
				ret = new RegExp(reStr,"g");
				return str.replace(ret,Tools.getColorInfo(Math.floor(v/6)+2));
			}
			else if(str.indexOf("{"+MSG_PERCENT+i+"}")>-1){
				reStr = "\\{"+MSG_PERCENT+i+"\\}";
				ret = new RegExp(reStr,"g");				
				return str.replace(ret,StringUtil.numberToPercent(v));
			}	
			else if(str.indexOf("{"+MSG_ESTATE+i+"}")>-1){
				reStr = "\\{"+MSG_ESTATE+i+"\\}";
				ret = new RegExp(reStr,"g");				
				return str.replace(ret,ModelEstate.getEstateName(v));
			}					
			else if(str.indexOf("{"+MSG_HERO_STAR_COLOR_RIGHT+i+"}")>-1){
				reStr = "\\{"+MSG_HERO_STAR_COLOR_RIGHT+i+"\\}";
				ret = new RegExp(reStr,"g");					
				return str.replace(ret,Tools.getColorInfo(Math.floor((v+ConfigServer.system_simple.star_limit_init)/6)+2));
			}			
			else if(str.indexOf("{"+MSG_SHOP_NAME+i+"}")>-1){
				reStr = "\\{"+MSG_SHOP_NAME+i+"\\}";
				ret = new RegExp(reStr,"g");		
				return str.replace(ret,Tools.getMsgById(v));
			}else if(str.indexOf("{"+MSG_EQUIP_LV+i+"}")>-1){
				reStr = "\\{"+MSG_EQUIP_LV+i+"\\}";
				ret = new RegExp(reStr,"g");
				return str.replace(ret,Tools.getColorInfo(v));
			}else if(str.indexOf("{"+MSG_HERO_RARITY+i+"}")>-1){
				reStr = "\\{"+MSG_HERO_RARITY+i+"\\}";
				ret = new RegExp(reStr,"g");
				return str.replace(ret,ModelHero.rarity_name[v]);
			}			
			else{
				if(v is String){
					if(v.indexOf("hero_box")>-1){
						reStr = "\\{" + i + "\\}";
						ret = new RegExp(reStr,"g");							
						return str.replace(ret, Tools.getMsgById(v));
					}
				}
				reStr = "\\{" + i + "\\}";
				ret = new RegExp(reStr,"g");				
				return str.replace(ret, v);
			}
			return str;
		}
    }
}