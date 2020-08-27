自动更新对象的缓存，每个对象可有多个不同的缓存，对象更新，对应的缓存则失效

该 gem 依赖 `Rails`

# 使用说明

示例代码

```ruby
class Page < ActiveRecord::Base
  def calculate_something
    cache('calculate_something') do
      # do something
    end
  end
end

page = Page.create
# rails 缓存会生成一个 Page/1/calculate_something 这样的缓存键（model名/对象id/传入的namespace）
page.calculate_something # 会进入block中做相应的计算
page.calculate_something # 直接读取缓存，不会进行block里面的计算
page.save
page.calculate_something # 会进入block中做相应的计算
page.touch
page.calculate_something # 会进入block中做相应的计算
page.update_columns(status: 1)
page.calculate_something # 直接读取缓存，不会进行block里面的计算(如果跳过了rails的回调话，则不能更新缓存)
```

并且支持 `Rails.cache.fetch` 里面所支持的参数， 详细请查看rails相关文档