xquery version "3.1";

module namespace api="http://teipublisher.com/api/hwgw/custom/index";

declare namespace tei="http://www.tei-c.org/ns/1.0";
import module namespace config="http://www.tei-c.org/tei-simple/config" at "../config.xqm";
import module namespace query="http://www.tei-c.org/tei-simple/query" at "../query.xql";
import module namespace pm-config="http://www.tei-c.org/tei-simple/pm-config" at "../pm-config.xql";

(: Chapter ordering for :register-occurrences :)
declare function api:chapter-ordering-key($identifier as xs:string) {
    let $parts :=
        for $p in tokenize($identifier, "-")
        let $filled := substring(concat("000000", $p), string-length($p)+1, 6)
        return $filled
    let $key := string-join($parts, "-")
    return $key
};


(: Occurrences for index entries :)
declare function api:occurrences($entryId) {
    let $facets :=  map { 
        "facets": map { 
            "direct-indexing": ($entryId)
        },
        "leading-wildcard": "no",
        "filter-rewrite": "yes"
    }
    let $query := ()
    let $entry := collection($config:data-root)//*[@xml:id=$entryId]
    let $volumes := ('s01', 's03', 's04')
    return
        <div>{
            if (exists(collection($config:data-root)//tei:div[ft:query(., $query, $facets)])) then
                <h2>Vorkommen</h2>
            else
                ()
        }
        {
            for $v in $volumes
            where (exists(collection($config:data-root || '/' || $v)//tei:div[ft:query(., $query, $facets)]))
            return
                <div>
                    <h3><a class="vol-title" href="./{$v}/index.html">{config:volume-title($v)}</a></h3>
                    <ul>{
                        for $d in collection($config:data-root || '/' || $v)/tei:TEI
                        order by $d/@n
                        let $chapters := $d//tei:div[ft:query(., $query, $facets)]
                        let $doc-title := $pm-config:web-transform($d//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@level='a' and @type='short'], map { "mode": "toc", "root": $d }, "woelfflin-base.odd")
                        let $doc-file := util:document-name($d)
                        where $chapters
                        return 
                            for $item in $chapters
                            let $noCommentMention := $item[ft:query(., $query, map {"facets": map { "direct-indexing-no-notes": ($entryId)}})]
                            let $commentMention := $item//tei:note[not(@place)][ft:query(., $query, $facets)] except $item//tei:div//tei:note
                            order by api:chapter-ordering-key($item/@xml:id)
                            return 
                                <li>
                                    <div>
                                        <span><a class="breadcrumb" href="./{$v}/{$doc-file}">{data($doc-title)}</a>
                                        {
                                            for $parentDiv in $item/ancestor-or-self::tei:div[tei:head]
                                            where (normalize-space($parentDiv/tei:head) != '')
                                            return
                                                <a class="breadcrumb" href="./{$v}/{$doc-file || "#" || $parentDiv/@xml:id}">
                                                {data($parentDiv/tei:head/@n)}
                                                </a>
                                                
                                                
                                        }
                                        </span>
                                        <span>
                                        {
                                         if ($noCommentMention and $commentMention) then
                                            " (und "
                                            else if ($commentMention) then " ("
                                            else ( )
                                            }
                                        {
                                                    if ($commentMention) then
                                            <ul class="anmerkungen-list">{
                                                    for $note in $commentMention
                                                    return <li class="anmerkungen">
                                                    <a href="./{$v}/{$doc-file || "?action=search&amp;id=" || $note/@xml:id || "&amp;view=div"}">
                                                    {data($note/@n)}
                                                    </a>
                                                    </li>
                                                }</ul> else ()
                                                }
                                                {
                                                if ($commentMention) then ")"
                                            else ( )
                                            }
                                        </span>
                                    </div>
                                </li>
                    }</ul>
                </div>
        }</div>
};



(: All objects created by the person of an index entry :)
declare function api:objects-per-person($entryId) {
    let $facets :=  map { 
        "facets": map { 
            "creator": ($entryId)
        },
        "leading-wildcard": "no",
        "filter-rewrite": "yes"
    }
    let $query := ()
    let $entries := doc($config:data-root || "/registers/objects.xml")//tei:object[ft:query(., $query, $facets)]

    return 
        if (count($entries) > 0) then
            <div>
                <h2>Werke</h2> 
                <ul class="obj-list">{
                    for $d in $entries
                    let $entryHtml := $pm-config:web-transform($d/tei:head, map { }, "woelfflin-base.odd")
                    let $target := $d/@xml:id
                    return <li><a href="#{$target}" class="hw-unmarked-link">{$entryHtml}</a></li>
                }</ul>
            </div>
        else
            ()
};

(: All works written by the person of an index entry :)
declare function api:bibl-per-person($entryId) {
    let $facets :=  map { 
        "facets": map { 
            "author": ($entryId)
        },
        "leading-wildcard": "no",
        "filter-rewrite": "yes"
    }
    let $query := ()
    let $entries := doc($config:data-root || "/registers/bibliography.xml")//tei:listBibl/tei:bibl[ft:query(., $query, $facets)]

    return 
        if (count($entries) > 0) then
            <div>
                <h2>Literarische Werke</h2>
                <ul class="obj-list">{
                    for $d in $entries
                    let $entryHtml := $pm-config:web-transform($d/tei:title[@type='short'], map { }, "woelfflin-base.odd")
                    let $target := $d/@xml:id
                    return <li><a href="#{$target}" class="hw-unmarked-link">{data($d/tei:title[@type='short'])}</a></li>
                }</ul>
            </div>
        else
            ()
};

(: Collected information of an index entry :)
declare function api:register-entry($request as map(*)) {
    let $entryId := normalize-space($request?parameters?entryId)
    let $entry := collection($config:data-root)//id($entryId)
    let $entryHtml := $pm-config:web-transform($entry, map { "mode": "entryview" }, "woelfflin-index.odd")
    
    return <div>
        <div class="text-section">
            { $entryHtml }
        </div>

        { if (local-name($entry)="person") then
        <div class="text-section">
            {api:objects-per-person($entryId)}
        </div> else ()
        }
        
        { if (local-name($entry)="person") then
        <div class="text-section">
            {api:bibl-per-person($entryId)}
        </div> else ()
        }

        <div class="text-section">
            {api:occurrences($entryId)}
        </div>
      </div>
};
