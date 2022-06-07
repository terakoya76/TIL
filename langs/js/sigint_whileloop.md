# SIGINT while loop

```javascript
process.on('SIGINT', function() {
  console.log("Caught interrupt signal");
  process.exit();
});

setInterval (function () {
  // do something
}, 0);
```
