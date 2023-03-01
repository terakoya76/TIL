# Good Performance Rails Code
Ref: https://shopify.engineering/write-fast-code-ruby-rails

`ActiveRecord`
* use pluck aggressively
* dont believe query cache too much
  * query cache is in-memory and short-lived
* avoid querying unindexed columns


`ActiveSupport::Cache::Store`
Ref: https://railsguides.jp/caching_with_rails.html#activesupport-cache-store
* cache everything

Throttle abusing API
* https://github.com/rack/rack-attack
* https://github.com/dryruby/rack-throttle

`ActiveJob::Base`
Ref: https://railsguides.jp/active_job_basics.html

Fast Ruby Code
* stop meta-programming
* allocate-less
  * stop mutating global state
  * mutate local state
* fewer custom layers
