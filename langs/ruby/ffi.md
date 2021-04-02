## ffi
Ref: https://github.com/ffi/ffi

### Types
Ref: https://github.com/ffi/ffi/wiki/Types

### String and Memory Allocation
ruby の string pointer を C 側で mutate する場合、C 側の処理が完了するまで ruby string は生存するようにケアする必要あり
Ref: https://github.com/ffi/ffi/wiki/Core-Concepts#memory-management

string を返り値にしたい場合、workaround が必要
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

### ffi で bridge 実装
Ref: http://kazegusuri.hateblo.jp/entry/2014/03/02/192729

requirements
* The libffi library and development headers - this is commonly in the libffi-dev or libffi-devel packages

Simple な実装
* memory 管理を ruby から C の FFI を叩くことで client 側から行う
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

Memory 管理 free な実装
* ManagedStruct
  * Struct に hook を掛けられる
  * `self.releaase` は GC 時に呼び出される
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
* Pointer に hook を掛けられる
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
