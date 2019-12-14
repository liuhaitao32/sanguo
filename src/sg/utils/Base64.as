package sg.utils {
    import laya.utils.Browser;

	/**
	 * base64编码解码类
	 * @author Thor
	 */
    public class Base64 {
        private static var _base64:Object = null;
		public static function get instance():Object {
            if (_base64 === null) {
                __JS__('!function(e,t){"object"==typeof exports&&"undefined"!=typeof module?module.exports=t(e):"function"==typeof define&&define.amd?define(t):t(e)}("undefined"!=typeof self?self:"undefined"!=typeof window?window:"undefined"!=typeof global?global:this,function(t){"use strict";function n(e){if(e.length<2)return(t=e.charCodeAt(0))<128?e:t<2048?p(192|t>>>6)+p(128|63&t):p(224|t>>>12&15)+p(128|t>>>6&63)+p(128|63&t);var t=65536+1024*(e.charCodeAt(0)-55296)+(e.charCodeAt(1)-56320);return p(240|t>>>18&7)+p(128|t>>>12&63)+p(128|t>>>6&63)+p(128|63&t)}function r(e){return e.replace(s,n)}function o(e){var t=[0,2,1][e.length%3],n=e.charCodeAt(0)<<16|(1<e.length?e.charCodeAt(1):0)<<8|(2<e.length?e.charCodeAt(2):0);return[h.charAt(n>>>18),h.charAt(n>>>12&63),2<=t?"=":h.charAt(n>>>6&63),1<=t?"=":h.charAt(63&n)].join("")}function u(e,t){return t?A(String(e)).replace(/[+\/]/g,function(e){return"+"==e?"-":"_"}).replace(/=/g,""):A(String(e))}function a(e){switch(e.length){case 4:var t=((7&e.charCodeAt(0))<<18|(63&e.charCodeAt(1))<<12|(63&e.charCodeAt(2))<<6|63&e.charCodeAt(3))-65536;return p(55296+(t>>>10))+p(56320+(1023&t));case 3:return p((15&e.charCodeAt(0))<<12|(63&e.charCodeAt(1))<<6|63&e.charCodeAt(2));default:return p((31&e.charCodeAt(0))<<6|63&e.charCodeAt(1))}}function c(e){return e.replace(b,a)}function i(e){var t=e.length,n=t%4,r=(0<t?l[e.charAt(0)]<<18:0)|(1<t?l[e.charAt(1)]<<12:0)|(2<t?l[e.charAt(2)]<<6:0)|(3<t?l[e.charAt(3)]:0),o=[p(r>>>16),p(r>>>8&255),p(255&r)];return o.length-=[0,0,2,1][n],o.join("")}function e(e){return B(String(e).replace(/[-_]/g,function(e){return"-"==e?"+":"/"}).replace(/[^A-Za-z0-9\+\/]/g,""))}var f,d=(t=t||{}).Base64,h="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",l=function(e){for(var t={},n=0,r=e.length;n<r;n++)t[e.charAt(n)]=n;return t}(h),p=String.fromCharCode,s=/[\uD800-\uDBFF][\uDC00-\uDFFFF]|[^\x00-\x7F]/g,g=t.btoa?function(e){return t.btoa(e)}:function(e){return e.replace(/[\s\S]{1,3}/g,o)},A=function(e){return g(r(e))},b=new RegExp(["[À-ß][-¿]","[à-ï][-¿]{2}","[ð-÷][-¿]{3}"].join("|"),"g"),C=t.atob?function(e){return t.atob(e)}:function(e){return e.replace(/\S{1,4}/g,i)},B=function(e){return c(C(e))};if(t.Base64={VERSION:"2.5.1",atob:function(e){return C(String(e).replace(/[^A-Za-z0-9\+\/]/g,""))},btoa:g,fromBase64:e,toBase64:u,utob:r,encode:u,encodeURI:function(e){return u(e,!0)},btou:c,decode:e,noConflict:function(){var e=t.Base64;return t.Base64=d,e},__buffer__:f},"function"==typeof Object.defineProperty){var y=function(e){return{value:e,enumerable:!1,writable:!0,configurable:!0}};t.Base64.extendString=function(){Object.defineProperty(String.prototype,"fromBase64",y(function(){return e(this)})),Object.defineProperty(String.prototype,"toBase64",y(function(e){return u(this,e)})),Object.defineProperty(String.prototype,"toBase64URI",y(function(){return u(this,!0)}))}}return t.Meteor&&(Base64=t.Base64),"undefined"!=typeof module&&module.exports?module.exports.Base64=t.Base64:"function"==typeof define&&define.amd&&define([],function(){return t.Base64}),{Base64:t.Base64}});');
                _base64 = Browser.window.Base64;
            }
			return _base64;
		}

        /**
         * base64编码
         */
        public static function encode(s:String):String {
            return instance.encode(s);
        }

        /**
         * base64解码
         */
        public static function decode(base64:String):String {
            return instance.decode(base64);
        }
    }
}