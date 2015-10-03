var express = require('express');
var request = require('request');

var app = express();

app.get('/redirect', function(req, res){
    var code = req.query.code;
    console.log('Found code ' + code);
    if(code == undefined)   {
        console.log('Error: Query was ' + req.query);
        res.end('No code found!');
    }   else    {
        //// Get the access token
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

app.get('/listId', function (req, res) {
var accesstoken = req.query.access_token;

if(accesstoken == undefined)    {
    res.end('No access token detected');
    console.log('No access token detected');
    return;
}   else    {
    console.log('got accesstoken' + accesstoken);
}
request({url: 'http://a.wunderlist.com/api/v1/lists', headers: {
    'X-Access-Token': accesstoken,
    'X-Client-ID': 'f7dff4e1225dc1459172'}, json: true}, function (error, response, body) {
        var groceryListId;
        if (!error && response.statusCode == 200) {
            var array = response.body
            for(var i in array) {
                console.log(array[i].title);
                if (array[i].title == "Restock-Groceries") {
                    groceryListId = array[i].id;
                    console.log('Found id ' + groceryListId);
                    break;
                }
            }
            if(groceryListId == undefined)    {
                console.log('No list Restock-Groceries found, adding it')
                // create a new list
                request({url: 'http://a.wunderlist.com/api/v1/lists', headers: {
                    'X-Access-Token': accesstoken,
                    'X-Client-ID': 'f7dff4e1225dc1459172'}, json: true, body: {"title": "Restock-Groceries"}}, function (err2, res2, body2) {
                    groceryListId = res2.body.id;
                    console.log('Created new list with id %s', res2.body.id);
                    if(groceryListId == undefined)  console.log(res2.body);
                    if(err2)   console.log('Error creating list: ' + err2);
                })
            }


            res.end(JSON.stringify({id: groceryListId}));
        }   else {
            console.log('Error (Status ' + response.statusCode + '): ' + error);
        }
    });
    // {

});

app.listen(3001);







