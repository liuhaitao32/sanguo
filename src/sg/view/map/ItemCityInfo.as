package sg.view.map
{
	import sg.utils.Tools;
    import ui.map.itemCityInfoUI;

    public class ItemCityInfo extends itemCityInfoUI{
        public function ItemCityInfo(){

        }
        public function setUI(data:Array, country:int):void{
			var uName:String = data[1];
			if (uName.charAt(0) == '$'){
				//特殊NPC，使用配置文字（可自动补充国家串）
				uName = uName.substr(1);
				if (Tools.hasMsgById(uName)){
					uName = Tools.getMsgById(uName, [Tools.getMsgById('country_' + country)]);
				}
			}
			this.tName.text = uName;


            this.tNum.text = data[2];
			var allNum:int = data[3];
			if (allNum >= 0){
				this.tAll.text = allNum.toString();
				this.tName.color = '#FFFFFF';
			}
			else{
				//护国军
				this.tAll.text = '???';
				this.tName.color = '#ffd556';
			}
        }
    }   
}