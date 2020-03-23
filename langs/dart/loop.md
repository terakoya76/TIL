# Loop N Times

https://stackoverflow.com/questions/37798397/create-a-list-from-0-to-n

List generate
```dart
var n = 10;
var a = List<int>
            .generate(n, (i) => i + 1)
            .map((i) => 'this is $i-th item')
            .toList();
```

custom generator
```dart
Iterable<int> get positiveIntegers sync* {
  int i = 0;
  while (true) yield i++;
}

var list = positiveIntegers
      .skip(1)   // don't use 0
      .take(10)  // take 10 numbers
      .toList(); // create a list
```
