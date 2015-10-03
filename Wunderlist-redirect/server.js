var express = require('express');
var request = require('request');

var app = express();

const clientId = 'f7dff4e1225dc1459172';

app.get('/redirect', function(req, res){
    var code = req.query.code;
    console.log('Found code ' + code);
    if(code == undefined)   {
        console.log('Error: Query was ' + req.query);
        res.end('No code found!');
    }   else    {
        res.end('<html><head><script type="text/javascript">' +
            'window.location = "restock://' + code + '"' +
            '</script></head><body></body></html>');
    }

});

app.get('/listId', function (req, res) {

    console.log('GET /listId');

    var accesstoken = req.query.access_token;

    if(accesstoken == undefined)    {
        res.status(400).send('Query attribute "access_token" not set');
        console.log('No access token detected');
        return;
    }   else    {
        console.log('Got accesstoken' + accesstoken);
    }

    var getListsOptions = {url: 'http://a.wunderlist.com/api/v1/lists',
        headers: {
            'X-Access-Token': accesstoken,
            'X-Client-ID': clientId},
        json: true};

    request(getListsOptions, function (error, response, body) {
        var groceryListId;
        if (!error && response.statusCode == 200) {

            for(var i in body) {
                if (body[i].title == "Restock-Groceries") {
                    groceryListId = body[i].id;
                    console.log('Found list Restock-Groceries with id' + groceryListId);
                    break;
                }
            }

            if(groceryListId == undefined)    {
                console.log('No list Restock-Groceries found, adding it');
                // create a new list
                var postListOptions = {
                    url: 'https://a.wunderlist.com/api/v1/lists',
                    headers: {
                        'X-Access-Token': accesstoken,
                        'X-Client-ID': clientId,
                        'Content-Type': 'application/json'},
                    body: "{\"title\": \"Restock-Groceries\"}",
                    method: "POST"};
                request(postListOptions, function (err2, res2, body2) {
                    groceryListId = JSON.parse(body2).id;
                    console.log('Created new list with id %s', groceryListId);
                    if(err2)   console.log('Error creating list: ' + err2);
                });
            }

            var responseString = JSON.stringify({"id": groceryListId});
            res.send(responseString);
            console.log('Sending %s', responseString)
        }   else {
            res.status(500).send('Error communicating with the API (Status code ' + response.statusCode + '): ' + error);
            console.log('Error (Status ' + response.statusCode + '): ' + error);
        }
    });
    // {

});

app.listen(3001);







