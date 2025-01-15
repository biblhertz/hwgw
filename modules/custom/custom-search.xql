xquery version "3.1";

module namespace api="http://teipublisher.com/api/hwgw/custom/search";

declare namespace tei="http://www.tei-c.org/ns/1.0";
import module namespace config="http://www.tei-c.org/tei-simple/config" at "../config.xqm";
import module namespace query="http://www.tei-c.org/tei-simple/query" at "../query.xql";
import module namespace tpu="http://www.tei-c.org/tei-publisher/util" at "../lib/util.xql";
import module namespace nav="http://www.tei-c.org/tei-simple/navigation" at "../navigation.xql";
import module namespace kwic="http://exist-db.org/xquery/kwic" at "resource:org/exist/xquery/lib/kwic.xql";


(: Replacement of the search to enable sorting and different display :)
declare function api:search($request as map(*)) {
    (:If there is no query string, fill up the map with existing values:)
    if (empty($request?parameters?query))
    then
        api:show-hits($request, session:get-attribute($config:session-prefix || ".hits"), session:get-attribute($config:session-prefix || ".docs"))
    else
        (:Otherwise, perform the query.:)
        (: Here the actual query commences. This is split into two parts, the first for a Lucene query and the second for an ngram query. :)
        (:The query passed to a Luecene query in ft:query is an XML element <query> containing one or two <bool>. The <bool> contain the original query and the transliterated query, as indicated by the user in $query-scripts.:)
        let $hitsAll :=
        if ($request?parameters?sort = 0 and $request?parameters?query != '') then
            (
                (:If the $query-scope is narrow, query the elements immediately below the lowest div in tei:text and the four major element below tei:teiHeader.:)
                for $hit in query:query-default($request?parameters?field, $request?parameters?query, $request?parameters?doc, ())
                order by ft:score($hit) descending
                return $hit
            )
        else if ($request?parameters?sort = 0 and $request?parameters?query = '') then
            (
                (:If the $query-scope is narrow, query the elements immediately below the lowest div in tei:text and the four major element below tei:teiHeader.:)
                for $hit in query:query-default($request?parameters?field, $request?parameters?query, $request?parameters?doc, ())
                let $ordering := switch ($hit/name())
                    case 'bibl' return 
                        translate($hit/tei:title[@type='short'], "ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜäöü[]", "abcdefghijklmnopqrstuvwxyzaouaou")
                    case 'object' return 
                        translate($hit/tei:head[@type='main'], "ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜäöü«»", "abcdefghijklmnopqrstuvwxyzaouaou") 
                    case 'org' return 
                        translate($hit/tei:orgName[@type='main'], "ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜäöü", "abcdefghijklmnopqrstuvwxyzaouaou") 
                    case 'person' return 
                        translate($hit/tei:persName[@type='main'], "ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜäöü", "abcdefghijklmnopqrstuvwxyzaouaou") 
                    case 'place' return 
                        translate($hit/tei:placeName[@type='main'], "ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜäöü", "abcdefghijklmnopqrstuvwxyzaouaou") 
                    default return 
                        "◼︎"
                order by $ordering ascending
                return $hit
            )
        else if ($request?parameters?sort = 2) then
            (
                (:If the $query-scope is narrow, query the elements immediately below the lowest div in tei:text and the four major element below tei:teiHeader.:)
                for $hit in query:query-default($request?parameters?field, $request?parameters?query, $request?parameters?doc, ())
                order by $hit/string() ascending
                return $hit
            )
        else if ($request?parameters?sort = 1 and $request?parameters?query != '') then
            (
                (:If the $query-scope is narrow, query the elements immediately below the lowest div in tei:text and the four major element below tei:teiHeader.:)
                for $hit in query:query-default($request?parameters?field, $request?parameters?query, $request?parameters?doc, ())
                order by ft:score($hit) descending
                return $hit
            )
        else if ($request?parameters?sort = 1 and $request?parameters?query = '') then
            (
                (:If the $query-scope is narrow, query the elements immediately below the lowest div in tei:text and the four major element below tei:teiHeader.:)
                for $hit in query:query-default($request?parameters?field, $request?parameters?query, $request?parameters?doc, ())
                order by ft:facets($hit, 'occurrences', ())[1] descending
                return $hit
            )
        else
            (
            (:If the $query-scope is narrow, query the elements immediately below the lowest div in tei:text and the four major element below tei:teiHeader.:)
                for $hit in query:query-default($request?parameters?field, $request?parameters?query, $request?parameters?doc, ())
                order by $hit/string() ascending
                return $hit
            )
        let $hitCount := count($hitsAll)
        let $hits := if ($hitCount > 100000) then subsequence($hitsAll, 1, 100000) else $hitsAll
        (:Store the result in the session.:)
        let $store := (
            session:set-attribute($config:session-prefix || ".hits", $hitsAll),
            session:set-attribute($config:session-prefix || ".hitCount", $hitCount),
            session:set-attribute($config:session-prefix || ".query", $request?parameters?query),
            session:set-attribute($config:session-prefix || ".field", $request?parameters?field),
            session:set-attribute($config:session-prefix || ".docs", $request?parameters?doc)
        )
        return
            api:show-hits($request, $hits, $request?parameters?doc)
};

(: Dependency for :search :)
declare %private function api:show-hits($request as map(*), $hits as item()*, $docs as xs:string*) {
    response:set-header("pb-total", xs:string(count($hits))),
    response:set-header("pb-start", xs:string($request?parameters?start)),
    for $hit at $p in subsequence($hits, $request?parameters?start, $request?parameters?per-page)
    let $config := tpu:parse-pi(root($hit), $request?parameters?view)
    let $parent := query:get-parent-section($config, $hit)
    let $parent-id := config:get-identifier($parent)
    let $parent-id := if (exists($docs)) then replace($parent-id, "^.*?([^/]*)$", "$1") else $parent-id
    let $div := query:get-current($config, $parent)
    let $expanded := util:expand($hit, "add-exist-id=all")
    let $docId := config:get-identifier($div)
    return
        switch ($hit/name())
        case 'bibl' return 
            <div class="search-result">
                <div>
                    <div class="breadcrumbs">
                        <a class="breadcrumb" href="./">HWGW</a>
                        <a class="breadcrumb" href="register.xml#{$hit/@xml:id}">Index</a>
                        <a class="breadcrumb" href="register.xml#{$hit/@xml:id}">
                            <span class="hw-bibl">{$hit/tei:title[@type='short']/data()}</span>
                        </a>
                    </div>
                </div>
                <div class="short-info">
                    <p>{$hit/tei:bibl[@type="full"]/string()}</p>
                </div>
            </div>
        case 'object' return 
            <div class="search-result">
                <div>
                    <div class="breadcrumbs">
                        <a class="breadcrumb" href="./">HWGW</a>
                        <a class="breadcrumb" href="register.xml#{$hit/@xml:id}">Index</a>
                        <a class="breadcrumb" href="register.xml#{$hit/@xml:id}">
                            <span class="hw-object">{$hit/tei:head[@type='main']/data()}</span>
                        </a>
                    </div>    
                </div>
                <div class="short-info">
                    <p>{
                        if ($hit/tei:head[@type='hw']) then
                            (<span>HW: {$hit/tei:head[@type='hw']/string()}</span>, <br></br>)
                        else
                            <span></span>
                    }
                    {
                        if ($hit/tei:note/tei:persName[@role='author']) then
                            <span>{$hit/tei:note/tei:persName[@role='author']/string()}, </span>
                        else
                            <span></span>
                    }
                    {
                        if ($hit/tei:note/tei:date) then
                            <span>{$hit/tei:note/tei:date/string()}, </span>
                        else
                            <span></span>
                    }
                    {
                        if ($hit/tei:note/tei:placeName[@type='settlement']) then
                            <span>{$hit/tei:note/tei:placeName[@type='settlement']/string()}</span>
                        else
                            ''
                    }
                    {
                        if ($hit/tei:note/tei:placeName[@type='address']) then
                            (', ', <span>{$hit/tei:note/tei:placeName[@type='address']/string()}</span>)
                        else
                            ''
                    }
                    {
                        if ($hit/tei:note/tei:objectName and $hit/tei:note/tei:term) then
                            <span>{$hit/tei:note/tei:objectName/string()}</span>
                        else if ($hit/tei:note/tei:objectName) then
                            (', ', <span>{$hit/tei:note/tei:objectName/string()}</span>)
                        else
                            <span></span>
                    }.
                    </p>
                </div>
            </div>
        case 'org' return 
            <div class="search-result">
                <div>
                    <div class="breadcrumbs">
                        <a class="breadcrumb" href="./">HWGW</a>
                        <a class="breadcrumb" href="register.xml#{$hit/@xml:id}">Index</a>
                        <a class="breadcrumb" href="register.xml#{$hit/@xml:id}">
                            <span class="hw-organisation">{$hit/tei:orgName[@type='main']/data()}</span>
                        </a>
                    </div>
                </div>
                <div class="short-info">
                    <p>{$hit/tei:p/string()}</p>
                </div>
            </div>
        case 'person' return 
            <div class="search-result">
                <div>
                    <div class="breadcrumbs">
                        <a class="breadcrumb" href="./">HWGW</a>
                        <a class="breadcrumb" href="register.xml#{$hit/@xml:id}">Index</a>
                        <a class="breadcrumb" href="register.xml#{$hit/@xml:id}">
                            <span class="hw-person">{$hit/tei:persName[@type='main']/data()}</span>
                        </a>
                    </div>
                </div>
                <div class="short-info">
                    <p>{
                        if ($hit/tei:birth/text()) then 
                            data($hit/tei:birth/text()) 
                        else 
                            data($hit/tei:birth/@when)
                    } {
                        if ($hit/tei:birth or $hit/tei:death) then 
                            '–'
                        else 
                            ''
                    } {
                        if ($hit/tei:death/text()) then 
                            data($hit/tei:death/text()) 
                        else 
                            data($hit/tei:death/@when)
                    }{
                        if ($hit/tei:birth or $hit/tei:death) then 
                            '. ' 
                        else 
                            ''
                    } {
                        $hit/tei:note/string()
                    }</p>
                </div>
            </div>
        case 'place' return 
            <div class="search-result">
                <div>
                    <div class="breadcrumbs">
                        <a class="breadcrumb" href="./">HWGW</a>
                        <a class="breadcrumb" href="register.xml#{$hit/@xml:id}">Index</a>
                        <a class="breadcrumb" href="register.xml#{$hit/@xml:id}">
                            <span class="hw-place">{$hit/tei:placeName[@type='main']/data()}</span>
                        </a>
                    </div>
                </div>
                <div class="short-info">
                    <p>{$hit/tei:note/string()}</p>
                </div>
            </div>
        case 'note' return 
            <div class="search-result">
                <div>
                    <div class="breadcrumbs">
                    {query:get-breadcrumbs($config, $hit, $parent-id)}{if ($hit/@place='foot') then (" (Fn. ", data($hit/@n), ')') else (" (Anm. ", data($hit/@n), ')')}
                    </div>
                </div>
                <div class="matches">
                {
                    for $match in subsequence($expanded//exist:match, 1, 5)
                    let $matchId := $match/../@exist:id
                    let $docLink :=
                        if ($config?view = "page") then
                            (: first check if there's a pb in the expanded section before the match :)
                            let $pbBefore := $match/preceding::tei:pb[1]
                            return
                                if ($pbBefore) then
                                    $pbBefore/@exist:id
                                else
                                    (: no: locate the element containing the match in the source document :)
                                    let $contextNode := util:node-by-id($hit, $matchId)
                                    (: and get the pb preceding it :)
                                    let $page := $contextNode/preceding::tei:pb[1]
                                    return
                                        if ($page) then
                                            util:node-id($page)
                                        else
                                            util:node-id($div)
                        else
                            (: Check if the document has sections, otherwise don't pass root :)
                            if (nav:get-section-for-node($config, $div)) then util:node-id($div) else ()
                    let $config := <config width="60" table="no" link="{$docId}?{if ($docLink) then 'root=' || $docLink || '&amp;' else ()}action=search&amp;view={$config?view}&amp;odd={$config?odd}#{$matchId}"/>
                    return
                        kwic:get-summary($expanded, $match, $config)
                }
                </div>
            </div>
        default return 
            <div class="search-result">
                <div>
                    <div class="breadcrumbs">
                    {query:get-breadcrumbs($config, $hit, $parent-id)}
                    </div>
                </div>
                <div class="matches">
                {
                    for $match in subsequence($expanded//exist:match, 1, 5)
                    let $matchId := $match/../@exist:id
                    let $docLink :=
                        if ($config?view = "page") then
                            (: first check if there's a pb in the expanded section before the match :)
                            let $pbBefore := $match/preceding::tei:pb[1]
                            return
                                if ($pbBefore) then
                                    $pbBefore/@exist:id
                                else
                                    (: no: locate the element containing the match in the source document :)
                                    let $contextNode := util:node-by-id($hit, $matchId)
                                    (: and get the pb preceding it :)
                                    let $page := $contextNode/preceding::tei:pb[1]
                                    return
                                        if ($page) then
                                            util:node-id($page)
                                        else
                                            util:node-id($div)
                        else
                            (: Check if the document has sections, otherwise don't pass root :)
                            if (nav:get-section-for-node($config, $div)) then util:node-id($div) else ()
                    let $config := <config width="60" table="no" link="{$docId}?{if ($docLink) then 'root=' || $docLink || '&amp;' else ()}action=search&amp;view={$config?view}&amp;odd={$config?odd}#{$matchId}"/>
                    return
                        kwic:get-summary($expanded, $match, $config)
                }
                </div>
            </div>
};
