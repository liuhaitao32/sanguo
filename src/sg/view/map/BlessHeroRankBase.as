package sg.view.map
{
    import ui.map.bless_rank_baseUI;
    import sg.utils.Tools;

    public class BlessHeroRankBase extends bless_rank_baseUI
    {
        public function BlessHeroRankBase()
        {
        }
        
        override public function set dataSource(source:*):void {
            if (!source)    return;
            var uid:String = source[0];
            var hurt:int = source[1][0];
            var time:int = Math.floor(source[1][1] * Tools.oneMillis);
            var name:String = source[2][1];
            var country:int = source[2][3];
            var rank:int = source[3] + 1;
            this.setData(uid, name, country, rank, time, hurt);
        }

        public function setData(uid:String, name:String, country:int, rank:int, time:int, hurt:int):void {
            icon_country.setCountryFlag(country);
            item_rank.setRankIndex(rank, '', true);
            txt_name.text = name;
            Tools.textFitFontSize(txt_name);
            txt_hurt.text = String(hurt);
            txt_time.text = Tools.dateFormat(time, 1).substring(11, 16);
            if (time === 0) {
                txt_time.text = '--:--'.split('').join(' ');
            }
        }
    }
}