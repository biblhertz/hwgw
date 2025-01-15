xquery version "3.1";

(:~
 : This is the place to import your own XQuery modules for either:
 :
 : 1. custom API request handling functions
 : 2. custom templating functions to be called from one of the HTML templates
 :)
module namespace api="http://teipublisher.com/api/custom";

declare namespace tei="http://www.tei-c.org/ns/1.0";

(: Add your own module imports here :)
import module namespace rutil="http://e-editiones.org/roaster/util";
import module namespace errors = "http://e-editiones.org/roaster/errors";
import module namespace app="teipublisher.com/app" at "app.xql";

import module namespace csearch="http://teipublisher.com/api/hwgw/custom/search" at "custom/custom-search.xql";
import module namespace cindex="http://teipublisher.com/api/hwgw/custom/index" at "custom/custom-index.xql";

(:~
 : Keep this. This function does the actual lookup in the imported modules.
 :)
declare function api:lookup($name as xs:string, $arity as xs:integer) {
    try {
        function-lookup(xs:QName($name), $arity)
    } catch * {
        ()
    }
};
