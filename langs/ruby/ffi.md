# ffi
Ref: https://github.com/ffi/ffi

## Types
Ref: https://github.com/ffi/ffi/wiki/Types

## String and Memory Allocation
Rubyのstring pointerをC側でmutateする場合、C側の処理が完了するまでRuby stringは生存するようにケアする必要あり
Ref: https://github.com/ffi/ffi/wiki/Core-Concepts#memory-management

stringを戻り値にしたい場合、workaroundが必要
```ruby
module AugeasLib
  extend FFI::Library
  ffi_lib "libaugeas.so"
  attach_function :aug_get, [:pointer, :string, :pointer], :int
end

def get(path)
  ptr = FFI::MemoryPointer.new(:pointer, 1)
  AugeasLib.aug_get(@aug, path, ptr)
  strPtr = ptr.read_pointer()
  return strPtr.null? ? nil : strPtr.read_string().force_encoding('UTF-8') # returns UTF-8 encoded string
end
```
cf. https://github.com/ffi/ffi/wiki/Examples#single-string

## ffi で bridge 実装
Ref: https://kazegusuri.hateblo.jp/entry/2014/03/02/192729

requirements
* The libffi library and development headers - this is commonly in the libffi-dev or libffi-devel packages

Simpleな実装
* memory管理をRubyからCのFFIをたたくことでclient側から行う
```ruby
module FooLib
  extend FFI::Library
  ffi_lib "libfoo.so"

  class Foo < FFI::Struct
    layout(
      :name, :string,
      :ptr, :pointer,
    )
  end

  attach_function :func_a, [:int, :float, :ulong, :string], :double
  attach_function :create_foo, [], :pointer
  attach_function :use_foo, [:pointer, :int], :void
  attach_function :free_foo, [:pointer], :void
end
```

Memory管理freeな実装
* ManagedStruct
  * Structにhookを掛けられる
  * `self.releaase` はGC時に呼び出される
```ruby
class ManagedFoo < FFI::ManagedStruct
   layout(
     :name, :string,
     :ptr, :pointer,
   )
   def self.release(ptr)
     puts "release 0x#{ptr.address.to_s(16)}"
     FooLib::free_foo(ptr)
   end
 end
```

AutoPointer
* Pointerにhookを掛けられる
  * `initialize`, `self.release`
```ruby
class FooPointer < FFI::AutoPointer
  def self.release(ptr)
    puts "release 0x#{ptr.address.to_s(16)}"
    FooLib::free_foo(ptr)
  end

  def initialize
    ptr = FooLib.create_foo
    super ptr
    @foo = FooLib::Foo.new ptr
  end

  def use
    FooLib::use_foo @foo.pointer
  end

  def name
    @foo[:name]
  end

  def ptr
    @foo[:ptr]
  end
end
```
