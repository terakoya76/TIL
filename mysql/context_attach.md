# arproxy により SQL に context を埋め込む
* https://github.com/cookpad/arproxy

### How to embed
```ruby
class ContextAttacher < Arproxy::Base
  def execute(sql, name = nil)
    ctx = Context.current
    sql = "#{sql} /* ctx=#{ctx.display_name} */" unless ctx.empty?
    super(sql, name)
  end
end
```

## How to extract
```ruby
ctx_re = %r{/\* ctx=(.*) \*/\z}
matched = sql.match(ctx_re)
matched.nil? ? '' : matched[1]
```
