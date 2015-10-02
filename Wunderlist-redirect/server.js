var express = require('express');

var app = express();

app.get('/redirect', function(req, res){
    var code = req.query.code;
    console.log('Found code ' + code);
    if(code == undefined)   {
        console.log('Error: Query was ' + req.query);
    }
    res.end('<html><head><script type="text/javascript">' +
        'window.location = "restock://' + code + '"' +
        '</script></head><body></body></html>');
});

app.listen(3001);







