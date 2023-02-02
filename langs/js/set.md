# set
cf. https://zenn.dev/nananaoto/articles/3c49bcf18017b472b9ff

Union
```javascript
// const A = [1, 2, 4, 5, 7];
// const B = [2, 3, 5, 6, 8];
[...A, ...B].reduce((cur, acc) => {
    return [...cur, ...(cur.includes(acc) ? [] : [acc])], [] as number[]
})

// const A = [
//   { id: 1, x: 1 },
//   { id: 2, x: 1 },
//   { id: 4, x: 1 },
//   { id: 5, x: 1 },
//   { id: 7, x: 1 },
// ];
// const B = [
//   { id: 2, x: 1 },
//   { id: 3, x: 1 },
//   { id: 5, x: 1 },
//   { id: 6, x: 1 },
//   { id: 8, x: 1 },
// ];
[...A, ...B].reduce((acc, cur) => {
    return [...acc, ...(acc.some((item) => {
        return item.id === cur.id ? [] : [cur]
    }))], [] as { id: number; x: number }[]
})
```

Intersection
```javascript
// const A = [1, 2, 4, 5, 7];
// const B = [2, 3, 5, 6, 8];
A.filter((valA) => B.includes(valA))

// const A = [
//   { id: 1, x: 1 },
//   { id: 2, x: 1 },
//   { id: 4, x: 1 },
//   { id: 5, x: 1 },
//   { id: 7, x: 1 },
// ];
// const B = [
//   { id: 2, x: 1 },
//   { id: 3, x: 1 },
//   { id: 5, x: 1 },
//   { id: 6, x: 1 },
//   { id: 8, x: 1 },
// ];
A.filter((valA) => B.some((valB) => valB.id === valA.id))
```

Difference
```javascript
// const A = [1, 2, 4, 5, 7];
// const B = [2, 3, 5, 6, 8];
A.filter((val) => !B.includes(val))

// const A = [
//   { id: 1, x: 1 },
//   { id: 2, x: 1 },
//   { id: 4, x: 1 },
//   { id: 5, x: 1 },
//   { id: 7, x: 1 },
// ];
// const B = [
//   { id: 2, x: 1 },
//   { id: 3, x: 1 },
//   { id: 5, x: 1 },
//   { id: 6, x: 1 },
//   { id: 8, x: 1 },
// ];
A.filter((valA) => !B.some((valB) => valA.id === valB.id))
```

XOR
```javascript
// const A = [1, 2, 4, 5, 7];
// const B = [2, 3, 5, 6, 8];
[...A, ...B].filter((val, _, arr) => arr.filter((v) => v === val).length === 1)

// const A = [
//   { id: 1, x: 1 },
//   { id: 2, x: 1 },
//   { id: 4, x: 1 },
//   { id: 5, x: 1 },
//   { id: 7, x: 1 },
// ];
// const B = [
//   { id: 2, x: 1 },
//   { id: 3, x: 1 },
//   { id: 5, x: 1 },
//   { id: 6, x: 1 },
//   { id: 8, x: 1 },
// ];
[...A, ...B].filter((val, _, arr) => arr.filter((v) => v.id === val.id).length === 1)
```


