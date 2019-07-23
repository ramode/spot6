var FUNC_ERROR_TEXT="Expected a function",NAN=NaN,symbolTag="[object Symbol]",reTrim=/^\s+|\s+$/g,reIsBadHex=/^[-+]0x[0-9a-f]+$/i,reIsBinary=/^0b[01]+$/i,reIsOctal=/^0o[0-7]+$/i,freeParseInt=parseInt,freeGlobal="object"==typeof global&&global&&global.Object===Object&&global,freeSelf="object"==typeof self&&self&&self.Object===Object&&self,root=freeGlobal||freeSelf||Function("return this")(),objectProto=Object.prototype,objectToString=objectProto.toString,nativeMax=Math.max,nativeMin=Math.min,now=function(){return root.Date.now()};function debounce(n,r,e){var o,i,a,f,u,c,l=0,b=!1,s=!1,t=!0;if("function"!=typeof n)throw new TypeError(FUNC_ERROR_TEXT);function v(e){var t=o,r=i;return o=i=void 0,l=e,f=n.apply(r,t)}function m(e){var t=e-c;return void 0===c||r<=t||t<0||s&&a<=e-l}function j(){var e=now();if(m(e))return y(e);u=setTimeout(j,function(e){var t=r-(e-c);return s?nativeMin(t,a-(e-l)):t}(e))}function y(e){return u=void 0,t&&o?v(e):(o=i=void 0,f)}function p(){var e=now(),t=m(e);if(o=arguments,i=this,c=e,t){if(void 0===u)return function(e){return l=e,u=setTimeout(j,r),b?v(e):f}(c);if(s)return u=setTimeout(j,r),v(c)}return void 0===u&&(u=setTimeout(j,r)),f}return r=toNumber(r)||0,isObject(e)&&(b=!!e.leading,a=(s="maxWait"in e)?nativeMax(toNumber(e.maxWait)||0,r):a,t="trailing"in e?!!e.trailing:t),p.cancel=function(){void 0!==u&&clearTimeout(u),o=c=i=u=void(l=0)},p.flush=function(){return void 0===u?f:y(now())},p}function isObject(e){var t=typeof e;return!!e&&("object"==t||"function"==t)}function isObjectLike(e){return!!e&&"object"==typeof e}function isSymbol(e){return"symbol"==typeof e||isObjectLike(e)&&objectToString.call(e)==symbolTag}function toNumber(e){if("number"==typeof e)return e;if(isSymbol(e))return NAN;if(isObject(e)){var t="function"==typeof e.valueOf?e.valueOf():e;e=isObject(t)?t+"":t}if("string"!=typeof e)return 0===e?e:+e;e=e.replace(reTrim,"");var r=reIsBinary.test(e);return r||reIsOctal.test(e)?freeParseInt(e.slice(2),r?2:8):reIsBadHex.test(e)?NAN:+e}
