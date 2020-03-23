# embedded
implementing interface by embedded
```go
type UserInterface interface {
    Name() string
    Age() int64
}

type User struct {
    firstName string
    lastName string
    age int64
}

func (u *User) Name() string {
    return u.firstName + u.lastName
}

func (u * User) Age() int64 {
    return u.age
}
```

struct on struct
```go
// dummyUser implement UserInterface
type dummyUser struct {
    User
}

// override some behavior
func (u *dummyUser) Age() int64 {
    return 10
}

du := &dummyUser{}
du.Age()
=> 10
```

interface on struct
```go
// dummyUser implement UserInterface
type dummyUser struct {
    UserInterface
}

// 実際には実装はないので Interface method を呼び出しても panic する
du := &dummyUser{}
du.Age()
=> panic
```

interface on interface
```go
// 複数の Interface を embed して積集合的な interface を定義するのに使う
type dummyUserInterface {
    UserInterface
}
```
