(:
 :
 :  Copyright (C) 2017 Wolfgang Meier
 :
 :  This program is free software: you can redistribute it and/or modify
 :  it under the terms of the GNU General Public License as published by
 :  the Free Software Foundation, either version 3 of the License, or
 :  (at your option) any later version.
 :
 :  This program is distributed in the hope that it will be useful,
 :  but WITHOUT ANY WARRANTY; without even the implied warranty of
 :  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 :  GNU General Public License for more details.
 :
 :  You should have received a copy of the GNU General Public License
 :  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 :)
xquery version "3.1";

module namespace teis="http://www.tei-c.org/tei-simple/query/tei";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";
import module namespace nav="http://www.tei-c.org/tei-simple/navigation/tei" at "navigation-tei.xql";
import module namespace query="http://www.tei-c.org/tei-simple/query" at "query.xql";

import module namespace pm-config="http://www.tei-c.org/tei-simple/pm-config" at "../pm-config.xql";

declare function teis:query-default($fields as xs:string+, $query as xs:string, $target-texts as xs:string*,
    $sortBy as xs:string*) {
    if(string($query)) then
        for $field in $fields
        return
            switch ($field)
                case "head" return
                    if (exists($target-texts)) then
                        for $text in $target-texts
                        return
                            $config:data-root ! doc(. || "/" || $text)//tei:head[ft:query(., $query, query:options($sortBy))]
                    else
                        collection($config:data-root)//tei:head[ft:query(., $query, query:options($sortBy))]
        (:  :
                case "index" return
                        collection($config:data-root)//tei:listBibl/tei:bibl[ft:query(., $query, query:options($sortBy))] |
                        collection($config:data-root)//tei:listObject/tei:object[ft:query(., $query, query:options($sortBy))] |
                        collection($config:data-root)//tei:listPerson/tei:person[ft:query(., $query, query:options($sortBy))] |
                        collection($config:data-root)//tei:listOrg/tei:org[ft:query(., $query, query:options($sortBy))] |
                        collection($config:data-root)//tei:listPlace/tei:place[ft:query(., $query, query:options($sortBy))]
                case "text" return
                        collection($config:data-root)//tei:div[ft:query(., $query, query:options($sortBy))][not(starts-with(@xml:id, 'index-'))] |
                        collection($config:data-root)//tei:text[ft:query(., $query, query:options($sortBy))] |
                        collection($config:data-root)//tei:note[ft:query(., $query, query:options($sortBy))][@xml:id] |
                        collection($config:data-root)//tei:floatingText[ft:query(., $query, query:options($sortBy))] 
                    :)
                default return
                    if (exists($target-texts)) then
                        for $text in $target-texts
                        return
                            $config:data-root ! doc(. || "/" || $text)//tei:div[ft:query(., $query, query:options($sortBy))] |
                            $config:data-root ! doc(. || "/" || $text)//tei:text[ft:query(., $query, query:options($sortBy))] |
                            $config:data-root ! doc(. || "/" || $text)//tei:note[ft:query(., $query, query:options($sortBy))] |
                            $config:data-root ! doc(. || "/" || $text)//tei:floatingText[ft:query(., $query, query:options($sortBy))]
                    else
                        collection($config:data-root)//tei:div[ft:query(., $query, query:options($sortBy))][not(starts-with(@xml:id, 'index-'))] |
                        collection($config:data-root)//tei:text[ft:query(., $query, query:options($sortBy))] |
                        collection($config:data-root)//tei:note[ft:query(., $query, query:options($sortBy))][@xml:id] |
                        collection($config:data-root)//tei:floatingText[ft:query(., $query, query:options($sortBy))] |
                        collection($config:data-root)//tei:listBibl/tei:bibl[ft:query(., $query, query:options($sortBy))] |
                        collection($config:data-root)//tei:listObject/tei:object[ft:query(., $query, query:options($sortBy))] |
                        collection($config:data-root)//tei:listPerson/tei:person[ft:query(., $query, query:options($sortBy))] |
                        collection($config:data-root)//tei:listOrg/tei:org[ft:query(., $query, query:options($sortBy))] |
                        collection($config:data-root)//tei:listPlace/tei:place[ft:query(., $query, query:options($sortBy))]
    else (
        collection($config:data-root)//tei:listBibl/tei:bibl[ft:query(., (), query:options($sortBy))] |
        collection($config:data-root)//tei:listObject/tei:object[ft:query(., (), query:options($sortBy))] |
        collection($config:data-root)//tei:listPerson/tei:person[ft:query(., (), query:options($sortBy))] |
        collection($config:data-root)//tei:listOrg/tei:org[ft:query(., (), query:options($sortBy))] |
        collection($config:data-root)//tei:listPlace/tei:place[ft:query(., (), query:options($sortBy))] |
        
        collection($config:data-root)//tei:div[ft:query(., (), query:options($sortBy))][not(starts-with(@xml:id, 'index-'))] |
        collection($config:data-root)//tei:text[ft:query(., (), query:options($sortBy))] |
        collection($config:data-root)//tei:note[ft:query(., (), query:options($sortBy))][@xml:id] |
        collection($config:data-root)//tei:floatingText[ft:query(., (), query:options($sortBy))] 
    )
};

declare function teis:query-metadata($path as xs:string?, $field as xs:string?, $query as xs:string?, $sort as xs:string) {
    let $queryExpr := 
        if ($field = "file" or empty($query) or $query = '') then 
            "file:*" 
        else
            ($field, "text")[1] || ":" || $query
    let $options := query:options($sort, ($field, "text")[1])
    let $result :=
        $config:data-default ! (
            collection(. || "/" || $path)//tei:text[ft:query(., $queryExpr, $options)]
        )
    return
        query:sort($result, $sort)
};

declare function teis:autocomplete($doc as xs:string?, $fields as xs:string+, $q as xs:string) {
    let $lower-case-q := lower-case($q)
    for $field in $fields
    return
        switch ($field)
            case "author" return
                collection($config:data-root)/ft:index-keys-for-field("author", $lower-case-q,
                    function($key, $count) {
                        $key
                    }, 30)
            case "file" return
                collection($config:data-root)/ft:index-keys-for-field("file", $lower-case-q,
                    function($key, $count) {
                        $key
                    }, 30)
            case "text" return
                if ($doc) then (
                    doc($config:data-root || "/" || $doc)/util:index-keys-by-qname(xs:QName("tei:div"), $lower-case-q,
                        function($key, $count) {
                            $key
                        }, 30, "lucene-index"),
                    doc($config:data-root || "/" || $doc)/util:index-keys-by-qname(xs:QName("tei:text"), $lower-case-q,
                        function($key, $count) {
                            $key
                        }, 30, "lucene-index")
                ) else (
                    collection($config:data-root)/util:index-keys-by-qname(xs:QName("tei:div"), $lower-case-q,
                        function($key, $count) {
                            $key
                        }, 30, "lucene-index"),
                    collection($config:data-root)/util:index-keys-by-qname(xs:QName("tei:text"), $lower-case-q,
                        function($key, $count) {
                            $key
                        }, 30, "lucene-index")
                )
            case "head" return
                if ($doc) then
                    doc($config:data-root || "/" || $doc)/util:index-keys-by-qname(xs:QName("tei:head"), $lower-case-q,
                        function($key, $count) {
                            $key
                        }, 30, "lucene-index")
                else
                    collection($config:data-root)/util:index-keys-by-qname(xs:QName("tei:head"), $lower-case-q,
                        function($key, $count) {
                            $key
                        }, 30, "lucene-index")
            default return
                collection($config:data-root)/ft:index-keys-for-field("title", $lower-case-q,
                    function($key, $count) {
                        $key
                    }, 30)
};

declare function teis:get-parent-section($node as node()) {
    ($node/self::tei:text, $node/ancestor-or-self::tei:div[1], $node)[1]
};

declare function teis:get-breadcrumbs($config as map(*), $hit as node(), $parent-id as xs:string) {
    let $work := root($hit)/*
    let $doc-title := data($work//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@level='a' and @type='short'])
    let $v := if (data($work//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type='volume']/@n) ) then
        data($work//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type='volume']/@n)
        else ''
    let $volume-title := config:volume-title($v)

    return
        (
            <a class="breadcrumb" href="./">HWGW</a>,
            <a class="breadcrumb" href="./{$v}/index.html">{$volume-title}</a>,
            <a class="breadcrumb" href="./{$parent-id}">{$doc-title}</a>,
            (
                for $parentDiv in $hit/ancestor-or-self::tei:div[tei:head]
                let $id := util:node-id(
                    if ($config?view = "page") then ($parentDiv/preceding::tei:pb[1], $parentDiv)[1] else $parentDiv
                )
                return
                    (: <a class="breadcrumb" href="{$parent-id || "?action=search&amp;root=" || $id || "&amp;view=" || $config?view || "&amp;odd=" || $config?odd}">
                    {$pm-config:web-transform($parentDiv/tei:head, map { "mode": "toc", "root": $parentDiv }, "woelfflin-base.odd")}
                    </a> :)
                    <a class="breadcrumb" href="{$parent-id || "?action=search&amp;root=" || $id || "&amp;view=" || $config?view}">
                    {data($parentDiv/tei:head/@n)}
                    </a>
            )
        )
};

(:~
 : Expand the given element and highlight query matches by re-running the query
 : on it.
 :)
declare function teis:expand($data as node()) {
    let $query := session:get-attribute($config:session-prefix || ".search")
    let $field := session:get-attribute($config:session-prefix || ".field")
    let $div :=
        if ($data instance of element(tei:pb)) then
            let $nextPage := $data/following::tei:pb[1]
            return
                if ($nextPage) then
                    if ($field = "text") then
                        (
                            ($data/ancestor::tei:div intersect $nextPage/ancestor::tei:div)[last()],
                            $data/ancestor::tei:text
                        )[1]
                    else
                        $data/ancestor::tei:text
                else
                    (: if there's only one pb in the document, it's whole
                      text part should be returned :)
                    if (count($data/ancestor::tei:text//tei:pb) = 1) then
                        ($data/ancestor::tei:text)
                    else
                      ($data/ancestor::tei:div, $data/ancestor::tei:text)[1]
        else
            $data
    let $result := teis:query-default-view($div, $query, $field)
    let $expanded :=
        if (exists($result)) then
            util:expand($result, "add-exist-id=all")
        else
            $div
    return
        if ($data instance of element(tei:pb)) then
            $expanded//tei:pb[@exist:id = util:node-id($data)]
        else
            $expanded
};


declare %private function teis:query-default-view($context as element()*, $query as xs:string, $fields as xs:string+) {
    for $field in $fields
    return
        switch ($field)
            case "head" return
                $context[./descendant-or-self::tei:head[ft:query(., $query, $query:QUERY_OPTIONS)]]
            default return
                $context[./descendant-or-self::tei:div[ft:query(., $query, $query:QUERY_OPTIONS)]] |
                $context[./descendant-or-self::tei:text[ft:query(., $query, $query:QUERY_OPTIONS)]] |
                $context[./descendant-or-self::tei:note[ft:query(., $query, $query:QUERY_OPTIONS)]] |
                $context[./descendant-or-self::tei:floatingText[ft:query(., $query, $query:QUERY_OPTIONS)]]
};

declare function teis:get-current($config as map(*), $div as node()?) {
    if (empty($div)) then
        ()
    else
        if ($div instance of element(tei:teiHeader)) then
            $div
        else
            (nav:filler($config, $div), $div)[1]
};
