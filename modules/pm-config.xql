
xquery version "3.1";

module namespace pm-config="http://www.tei-c.org/tei-simple/pm-config";

import module namespace pm-woelfflin-base-web="http://www.tei-c.org/pm/models/woelfflin-base/web/module" at "../transform/woelfflin-base-web-module.xql";
import module namespace pm-woelfflin-base-print="http://www.tei-c.org/pm/models/woelfflin-base/print/module" at "../transform/woelfflin-base-print-module.xql";
import module namespace pm-woelfflin-base-latex="http://www.tei-c.org/pm/models/woelfflin-base/latex/module" at "../transform/woelfflin-base-latex-module.xql";
import module namespace pm-woelfflin-base-epub="http://www.tei-c.org/pm/models/woelfflin-base/epub/module" at "../transform/woelfflin-base-epub-module.xql";
import module namespace pm-woelfflin-base-fo="http://www.tei-c.org/pm/models/woelfflin-base/fo/module" at "../transform/woelfflin-base-fo-module.xql";
import module namespace pm-woelfflin-meta-web="http://www.tei-c.org/pm/models/woelfflin-meta/web/module" at "../transform/woelfflin-meta-web-module.xql";
import module namespace pm-annotations-web="http://www.tei-c.org/pm/models/annotations/web/module" at "../transform/annotations-web-module.xql";
import module namespace pm-woelfflin-apparatus-web="http://www.tei-c.org/pm/models/woelfflin-apparatus/web/module" at "../transform/woelfflin-apparatus-web-module.xql";
import module namespace pm-woelfflin-introduction-comments-web="http://www.tei-c.org/pm/models/woelfflin-introduction-comments/web/module" at "../transform/woelfflin-introduction-comments-web-module.xql";
import module namespace pm-woelfflin-index-web="http://www.tei-c.org/pm/models/woelfflin-index/web/module" at "../transform/woelfflin-index-web-module.xql";
import module namespace pm-woelfflin-books-comments-web="http://www.tei-c.org/pm/models/woelfflin-books-comments/web/module" at "../transform/woelfflin-books-comments-web-module.xql";
import module namespace pm-woelfflin-introduction-web="http://www.tei-c.org/pm/models/woelfflin-introduction/web/module" at "../transform/woelfflin-introduction-web-module.xql";
import module namespace pm-woelfflin-index-entry-list-web="http://www.tei-c.org/pm/models/woelfflin-index-entry-list/web/module" at "../transform/woelfflin-index-entry-list-web-module.xql";
import module namespace pm-woelfflin-books-web="http://www.tei-c.org/pm/models/woelfflin-books/web/module" at "../transform/woelfflin-books-web-module.xql";
import module namespace pm-docx-tei="http://www.tei-c.org/pm/models/docx/tei/module" at "../transform/docx-tei-module.xql";
import module namespace pm-woelfflin-apparatus-comments-web="http://www.tei-c.org/pm/models/woelfflin-apparatus-comments/web/module" at "../transform/woelfflin-apparatus-comments-web-module.xql";

declare variable $pm-config:web-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "woelfflin-base.odd" return pm-woelfflin-base-web:transform($xml, $parameters)
case "woelfflin-meta.odd" return pm-woelfflin-meta-web:transform($xml, $parameters)
case "annotations.odd" return pm-annotations-web:transform($xml, $parameters)
case "woelfflin-apparatus.odd" return pm-woelfflin-apparatus-web:transform($xml, $parameters)
case "woelfflin-introduction-comments.odd" return pm-woelfflin-introduction-comments-web:transform($xml, $parameters)
case "woelfflin-index.odd" return pm-woelfflin-index-web:transform($xml, $parameters)
case "woelfflin-books-comments.odd" return pm-woelfflin-books-comments-web:transform($xml, $parameters)
case "woelfflin-introduction.odd" return pm-woelfflin-introduction-web:transform($xml, $parameters)
case "woelfflin-index-entry-list.odd" return pm-woelfflin-index-entry-list-web:transform($xml, $parameters)
case "woelfflin-books.odd" return pm-woelfflin-books-web:transform($xml, $parameters)
case "woelfflin-apparatus-comments.odd" return pm-woelfflin-apparatus-comments-web:transform($xml, $parameters)
    default return pm-woelfflin-books-web:transform($xml, $parameters)
            
    
};
            


declare variable $pm-config:print-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "woelfflin-base.odd" return pm-woelfflin-base-print:transform($xml, $parameters)
    default return error(QName("http://www.tei-c.org/tei-simple/pm-config", "error"), "No default ODD found for output mode print")
            
    
};
            


declare variable $pm-config:latex-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "woelfflin-base.odd" return pm-woelfflin-base-latex:transform($xml, $parameters)
    default return error(QName("http://www.tei-c.org/tei-simple/pm-config", "error"), "No default ODD found for output mode latex")
            
    
};
            


declare variable $pm-config:epub-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "woelfflin-base.odd" return pm-woelfflin-base-epub:transform($xml, $parameters)
    default return error(QName("http://www.tei-c.org/tei-simple/pm-config", "error"), "No default ODD found for output mode epub")
            
    
};
            


declare variable $pm-config:fo-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "woelfflin-base.odd" return pm-woelfflin-base-fo:transform($xml, $parameters)
    default return error(QName("http://www.tei-c.org/tei-simple/pm-config", "error"), "No default ODD found for output mode fo")
            
    
};
            


declare variable $pm-config:tei-transform := function($xml as node()*, $parameters as map(*)?, $odd as xs:string?) {
    switch ($odd)
    case "docx.odd" return pm-docx-tei:transform($xml, $parameters)
    default return error(QName("http://www.tei-c.org/tei-simple/pm-config", "error"), "No default ODD found for output mode tei")
            
    
};
            
    