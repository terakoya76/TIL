# Learn Lua in Y minutes

Ref: https://learnxinyminutes.com/docs/lua/

## Example
playground
* https://www.lua.org/cgi-bin/demo

fib
```lua
function fib(n)
  if n < 2 then return 1 end
  return fib(n - 2) + fib(n - 1)
end
```

fizbuzz
```lua
for i = 1,100,1 do
  if i%15 == 0 then
    print('Fizz Buzz')
  elseif i%3 == 0 then
    print('Fizz')
  elseif i%5 == 0 then
    print('Buzz')
  else
    print(i)
  end
end
```
