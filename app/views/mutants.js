jade=function(e){function t(e){return e!=null}return Array.isArray||(Array.isArray=function(e){return"[object Array]"==Object.prototype.toString.call(e)}),Object.keys||(Object.keys=function(e){var t=[];for(var n in e)e.hasOwnProperty(n)&&t.push(n);return t}),e.merge=function(n,r){var i=n["class"],s=r["class"];if(i||s)i=i||[],s=s||[],Array.isArray(i)||(i=[i]),Array.isArray(s)||(s=[s]),i=i.filter(t),s=s.filter(t),n["class"]=i.concat(s).join(" ");for(var o in r)o!="class"&&(n[o]=r[o]);return n},e.attrs=function(n,r){var i=[],s=n.terse;delete n.terse;var o=Object.keys(n),u=o.length;if(u){i.push("");for(var a=0;a<u;++a){var f=o[a],l=n[f];"boolean"==typeof l||null==l?l&&(s?i.push(f):i.push(f+'="'+f+'"')):0==f.indexOf("data")&&"string"!=typeof l?i.push(f+"='"+JSON.stringify(l)+"'"):"class"==f&&Array.isArray(l)?i.push(f+'="'+e.escape(l.join(" "))+'"'):r&&r[f]?i.push(f+'="'+e.escape(l)+'"'):i.push(f+'="'+l+'"')}}return i.join(" ")},e.escape=function(t){return String(t).replace(/&(?!(\w+|\#\d+);)/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;")},e.rethrow=function(t,n,r){if(!n)throw t;var i=3,s=require("fs").readFileSync(n,"utf8"),o=s.split("\n"),u=Math.max(r-i,0),a=Math.min(o.length,r+i),i=o.slice(u,a).map(function(e,t){var n=t+u+1;return(n==r?"  > ":"    ")+n+"| "+e}).join("\n");throw t.path=n,t.message=(n||"Jade")+":"+r+"\n"+i+"\n\n"+t.message,t},e}({}),jade.templates={},jade.render=function(e,t,n){var r=jade.templates[t](n);e.innerHTML=r},jade.templates.homepage=function(locals,attrs,escape,rethrow,merge){attrs=attrs||jade.attrs,escape=escape||jade.escape,rethrow=rethrow||jade.rethrow,merge=merge||jade.merge;var buf=[];with(locals||{}){var interp,forum_mixin=function(e,t){var n=this.block,r=this.attributes||{},i=this.escaped||{};buf.push("<img"),buf.push(attrs({id:"forum_bg_"+e.id+"",src:""+cache_url+"/images/bg_"+e.id+".jpg","class":"bg initial"},{"class":!0,id:!0,src:!0})),buf.push("/><div"),buf.push(attrs({id:"forum_"+e.id+"","class":"forum "+(""+(e.classes||"")+" "+(t%2?"odd":"even")+"")},{"class":!0,id:!0})),buf.push("><a"),buf.push(attrs({name:"forum_"+e.id+""},{name:!0})),buf.push('></a><div class="header"><div class="description"><a'),buf.push(attrs({href:e.uri,"class":"mutant"},{href:!0})),buf.push(">");var s=e.description;buf.push(escape(null==s?"":s)),buf.push('</a></div></div><div class="container">'),e.posts&&(function(){if("number"==typeof e.posts.length)for(var t=0,n=e.posts.length;t<n;t++){var r=e.posts[t];post_mixin(e,r,t)}else for(var t in e.posts){var r=e.posts[t];post_mixin(e,r,t)}}.call(this),buf.push("<div"),buf.push(attrs({"data-scroll-to":"#forum_"+e.id+"",title:"Scroll top of "+e.title+"!","class":"up scroll-to"},{"class":!0,"data-scroll-to":!0,title:!0})),buf.push("></div>")),buf.push("</div></div>")},post_mixin=function(e,t,n){var r=this.block,i=this.attributes||{},s=this.escaped||{};buf.push("<div"),buf.push(attrs({id:"post_"+t.id+"","class":"post "+("col"+Math.ceil(Math.random()*2)+"")},{"class":!0,id:!0})),buf.push("><a"),buf.push(attrs({href:t.uri,"class":"mutant"},{href:!0})),buf.push('><h5 class="title">');var o=t.title;buf.push(null==o?"":o),buf.push('<span class="date">'+escape((interp=t.date)==null?"":interp)+'</span></h5></a><p class="body">');var o=t.body;buf.push(null==o?"":o),buf.push("</p>"),t.posts&&function(){if("number"==typeof t.posts.length)for(var e=0,n=t.posts.length;e<n;e++){var r=t.posts[e];subpost_mixin(r,e)}else for(var e in t.posts){var r=t.posts[e];subpost_mixin(r,e)}}.call(this),buf.push('<div class="comment"><div class="photo"><img'),buf.push(attrs({src:""+cache_url+"/images/profile.jpg"},{src:!0})),buf.push('/></div><input type="text" placeholder="Say it ..." class="msg"/></div></div>')},subpost_mixin=function(e,t){var n=this.block,r=this.attributes||{},i=this.escaped||{};buf.push("<div"),buf.push(attrs({id:"subpost_"+e.id+"","class":"subpost "+(t%2?"odd":"even")},{"class":!0,id:!0})),buf.push('><div class="photo"><img'),buf.push(attrs({src:""+cache_url+"/images/profile.jpg"},{src:!0})),buf.push('/></div><p class="body">');var s=e.body;buf.push(null==s?"":s),buf.push('</p><div class="signature"><span class="username">- '+escape((interp=e.user_name)==null?"":interp)+'</span><span class="date">');var s=e.date;buf.push(escape(null==s?"":s)),buf.push("</span></div></div>")};forums?function(){if("number"==typeof forums.length)for(var e=0,t=forums.length;e<t;e++){var n=forums[e];forum_mixin(n,e)}else for(var e in forums){var n=forums[e];forum_mixin(n,e)}}.call(this):buf.push("<p>Create a forum first<i>!</i></p>")}return buf.join("")},jade.templates.nav=function(locals,attrs,escape,rethrow,merge){attrs=attrs||jade.attrs,escape=escape||jade.escape,rethrow=rethrow||jade.rethrow,merge=merge||jade.merge;var buf=[];with(locals||{}){var interp,forum_mixin=function(e,t){var n=this.block,r=this.attributes||{},i=this.escaped||{};buf.push('<h3 class="title">Forums</h3>'),e.forums&&(buf.push("<ul"),buf.push(attrs({"class":"forum "+(""+(e.classes||"")+" forum-"+activeForumId+"")},{"class":!0})),buf.push(">"),function(){if("number"==typeof e.forums.length)for(var t=0,n=e.forums.length;t<n;t++){var r=e.forums[t];subforum_mixin(e,r,t)}else for(var t in e.forums){var r=e.forums[t];subforum_mixin(e,r,t)}}.call(this),buf.push("</ul>"))},subforum_mixin=function(e,t,n){var r=this.block,i=this.attributes||{},s=this.escaped||{};buf.push("<li><a"),buf.push(attrs({href:t.uri,"class":"mutant title"},{href:!0})),buf.push(">");var o=t.title;buf.push(escape(null==o?"":o)),buf.push("</a></li>")},thread_mixin=function(e){var t=this.block,n=this.attributes||{},r=this.escaped||{};buf.push('<li class="thread"><h4 class="title"><a'),buf.push(attrs({href:e.uri,"class":"mutant"},{href:!0})),buf.push(">");var i=e.title;buf.push(escape(null==i?"":i)),buf.push('</a></h4><div class="user-name">');var i=e.user_name;buf.push(escape(null==i?"":i)),buf.push('</div><div class="post-count">');var i=e.post_count;buf.push(escape(null==i?"":i)),buf.push('</div><div class="views">');var i=e.views;buf.push(escape(null==i?"":i)),buf.push("</div><div"),buf.push(attrs({"data-time":e.created_iso,"class":"created"},{"data-time":!0})),buf.push(">");var i=e.created_human;buf.push(escape(null==i?"":i)),buf.push("</div></li>")};buf.push('<div id="handle" title="Toggle" class="handle">&lt;</div><div class="create"><a class="button onclick-add-post-dialog">Create Thread</a></div><ul class="threads">'),function(){if("number"==typeof topThreads.length)for(var e=0,t=topThreads.length;e<t;e++){var n=topThreads[e];thread_mixin(n)}else for(var e in topThreads){var n=topThreads[e];thread_mixin(n)}}.call(this),buf.push("</ul>")}return buf.join("")},jade.templates.posts=function(locals,attrs,escape,rethrow,merge){attrs=attrs||jade.attrs,escape=escape||jade.escape,rethrow=rethrow||jade.rethrow,merge=merge||jade.merge;var buf=[];with(locals||{}){var interp,breadcrumb_mixin=function(e){var t=this.block,n=this.attributes||{},r=this.escaped||{},i="",s=e.uri.split("/"),s=s.splice(1,s.length-2);(function(){if("number"==typeof s.length)for(var e=0,t=s.length;e<t;e++){var n=s[e];if(n!="t"){buf.push("<span>/</span><a"),buf.push(attrs({href:""+i+""+n+"","class":"mutant"},{href:!0})),buf.push(">");var r=n.replace("-"," ");buf.push(escape(null==r?"":r)),buf.push("</a>")}i=i+n+"/"}else for(var e in s){var n=s[e];if(n!="t"){buf.push("<span>/</span><a"),buf.push(attrs({href:""+i+""+n+"","class":"mutant"},{href:!0})),buf.push(">");var r=n.replace("-"," ");buf.push(escape(null==r?"":r)),buf.push("</a>")}i=i+n+"/"}}).call(this),buf.push("<span>/</span><em>");var o=e.title;buf.push(escape(null==o?"":o)),buf.push("</em>")},subpost_mixin=function(e,t){var n=this.block,r=this.attributes||{},i=this.escaped||{};buf.push("<div"),buf.push(attrs({id:"subpost_"+e.id+"","data-post-id":""+e.id+"","class":"subpost "+(t%2?"odd":"even")},{"class":!0,id:!0,"data-post-id":!0})),buf.push(">");if(e.title){buf.push('<h4 class="title">');var s=e.title;buf.push(escape(null==s?"":s)),buf.push("</h4>")}buf.push('<div class="user">');var s=e.user_name;buf.push(escape(null==s?"":s)),buf.push('</div><div class="date">');var s=e.created_human;buf.push(escape(null==s?"":s)),buf.push("</div>");if(e.body){buf.push('<p class="body">');var s=e.body;buf.push(null==s?"":s),buf.push("</p>")}buf.push('<div class="actions"><a class="onclick-append-reply-ui">Reply</a>|<a'),buf.push(attrs({href:""+e.uri.replace(/\/\d+$/,"")+"/edit/"+e.id+"","class":"mutant"},{href:!0})),buf.push(">Edit</a> <a"),buf.push(attrs({href:e.uri},{href:!0})),buf.push('>Permalink</a></div><div class="reply"></div></div>'),e.posts&&e.posts.length&&(buf.push('<div class="children">'),function(){if("number"==typeof e.posts.length)for(var t=0,n=e.posts.length;t<n;t++){var r=e.posts[t];subpost_mixin(r,t)}else for(var t in e.posts){var r=e.posts[t];subpost_mixin(r,t)}}.call(this),buf.push("</div>"))};if(typeof subPost!="undefined"){buf.push('<div class="forum"><div'),buf.push(attrs({id:"post_"+subPost.id+"","data-post-id":""+subPost.id+"","class":"post"},{id:!0,"data-post-id":!0})),buf.push(">");if(subPost.title){buf.push('<h3 class="title">');var __val__=subPost.title;buf.push(escape(null==__val__?"":__val__)),buf.push("</h3>")}buf.push('<div class="user">');var __val__=subPost.user_name;buf.push(escape(null==__val__?"":__val__)),buf.push('</div><div class="date">');var __val__=subPost.created_human;buf.push(escape(null==__val__?"":__val__)),buf.push('</div><div class="breadcrumb">'),breadcrumb_mixin(subPost),buf.push("</div>");if(subPost.body){buf.push('<subPost class="body">');var __val__=subPost.body;buf.push(null==__val__?"":__val__),buf.push("</subPost>")}buf.push('<div class="actions"><a class="onclick-append-reply-ui">Reply</a> <a'),buf.push(attrs({href:subPost.uri},{href:!0})),buf.push('>Permalink</a></div><div class="reply"></div></div>'),subPost.posts&&subPost.posts.length&&function(){if("number"==typeof subPost.posts.length)for(var e=0,t=subPost.posts.length;e<t;e++){var n=subPost.posts[e];subpost_mixin(n,0)}else for(var e in subPost.posts){var n=subPost.posts[e];subpost_mixin(n,0)}}.call(this),buf.push("</div>")}}return buf.join("")},jade.templates.post_edit=function(locals,attrs,escape,rethrow,merge){attrs=attrs||jade.attrs,escape=escape||jade.escape,rethrow=rethrow||jade.rethrow,merge=merge||jade.merge;var buf=[];with(locals||{}){var interp,post_edit_mixin=function(e){var t=this.block,n=this.attributes||{},r=this.escaped||{};buf.push("<div"),buf.push(attrs({id:"post_edit_"+e.id+"","class":"post-edit"},{id:!0})),buf.push('><form id="add-post-form" action="/resources/posts" method="post"></form><label for="post_title">Title</label><input id="post_title" type="text" class="title"/><textarea class="body">');var i=e.body;buf.push(escape(null==i?"":i)),buf.push("</textarea><input"),buf.push(attrs({type:"hidden",name:"forum_id",value:e.id},{type:!0,name:!0,value:!0})),buf.push("/><input"),buf.push(attrs({type:"hidden",name:"csrf",value:e.csrf},{type:!0,name:!0,value:!0})),buf.push('/><input type="submit" value="Save" class="button"/><button class="cancel">Cancel</button><div class="preview"></div></div>')};typeof post!="undefined"&&post_edit_mixin(post)}return buf.join("")}