package coconut.vdom.macros;

#if macro
import coconut.ui.macros.*;
import tink.domspec.Macro.tags;
import haxe.macro.Context;
import haxe.macro.Expr;
import tink.hxx.*;

using tink.MacroApi;

class Setup {
  
  static var registered = false;

  static function addTags() {
    var ret = Context.getBuildFields();
    for (name in tags.keys()) {
      var tag = tags[name];
      ret.push({
        name: name,
        pos: tag.pos,
        access: [AStatic, APublic, AInline],
        kind: FFun({
          var et = tag.dom.toComplex();
          var args = [
            {
              name: 'hxxMeta',
              type: macro : { 
                @:optional var key(default, never):coconut.diffing.Key;
                @:optional var ref(default, never):coconut.ui.Ref<$et>;
              },
              opt: false
            },
            {
              name: 'attr',
              type: [
                tag.attr, 
                macro : tink.domspec.Events<$et>,
                macro : { 
                  @:hxxCustomAttributes(~/^(data-|aria-)/)
                  @:optional var attributes(default, never):Dynamic<xdom.html.Dataset.DatasetValue>; 
                },
              ].intersect().sure(),
              opt: false
            }
          ];
          var callArgs = [macro $v{name}, macro hxxMeta.ref, macro hxxMeta.key, macro attr];
          if (tag.kind != VOID) {
            args.push({
              name: 'children',
              type: macro : coconut.ui.Children,
              opt: true
            });
            callArgs.push(macro children);
          }
          {
            args: args,
            expr: macro return h($a{callArgs}),
            ret: macro : coconut.ui.RenderResult
          }
        })
      });
    }
    return ret;
  }

  static function all() 
    HXX.defaults.whenever(Tag.extractAllFrom(macro coconut.vdom.Html));
  
}
#end