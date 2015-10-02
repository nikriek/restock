var express = require('express');

var app = express();

app.get('/redirect', function(req, res){
    var code = req.query.code;
    console.log('Found code ' + code);
    if(code == undefined)   {
        console.log('Error: Query was ' + req.query);
        res.code(500).end('No code found!');
    }   else    {
        //// Get the access token
        //var request = require('request');
        //request({url: 'http://www.wunderlist.com/oauth/access_token', form:{client_id:'f7dff4e1225dc1459172',
        //        client_secret:'73868615a4151c7445be60745a3cb35a3c6b5c138879f1da74d187aaf07e',
        //        code: code}},
        //    function (error, response, body) {
        //        if (!error && response.statusCode == 200) {
        //            var token = response.body.access_token;
        //            res.end({access_token: token});
        //        }   else {
        //            console.log('Error requesting the access token (Status ' + response.statusCode + '): ' + error);
        //            res.write('error');
        //        }
        //    });
        res.end('<html><head><script type="text/javascript">' +
            'window.location = "restock://' + code + '"' +
            '</script></head><body></body></html>');
    }

});

app.listen(3001);







