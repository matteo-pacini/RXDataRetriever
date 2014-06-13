#RXDataRetriever

RXDataRetriever is a Reactive JSON RESTful client.

It depends on *ReactiveCocoa* and *AFNetworking*

#Integration

Add this into your Podfile:

    pod 'RXDataRetriever', '~> 0.1'

Import the class in your prefix:

    #import <RXDataRetriever/RXDataRetriever.h>

#Methods

- GET
- POST
- PUT
- PATCH
- DELETE

**GET** supports query arguments. If you don't need those, just pass *nil*.

    [[RXDataRetriever instance] GET:@"/doge" query:@{"such":"networking","much":"reactive"}]

...produces this URL:

    @"/doge?such=networking&much=reactive"

Query values will be URL-encoded if needed.

##Signatures

    -(RACSignal*)GET:(NSString*)path
           query:(NSDictionary*)arguments;
    
    -(RACSignal*)POST:(NSString*)path
             data:(id)data;
    
    -(RACSignal*)PUT:(NSString*)path
            data:(id)data;
    
    -(RACSignal*)PATCH:(NSString*)path
               ops:(NSArray*)patches;
    
    -(RACSignal*)DELETE:(NSString*)path;
    
    -(RACSignal*)reachability;
    
    -(RACSignal*)invalidateSessionCancelingTasks:(BOOL)cancelPendingTasks;

#Examples

##Retrieve a GitHub user

Configure the client first.

**errorResponseDomain** will be used to create NSError objects (if an error occurs).

**errorResponseKeyPath** tells the object where it should look to get an error message.

e.g. If your server replies with this JSON after a 500:
 
    {
        "error": {
            "code"    : 500,
            "message" : "blablabla"
        }
    }
 
 ...you should set **errorResponseKeyPath** to @"error.message"!
 
 GitHub API uses @"message" keypath.

    [RXDataRetriever instance].baseURL = @"https://api.github.com"
    [RXDataRetriever instance].errorResponseDomain = @"api.github.com"
    [RXDataRetriever instance].errorResponseKeyPath = @"message"

Retrieving the user name

    [[[[RXDataRetriever instance] GET:@"/users/Zi0P4tch0" query:nil]
        map:^id(id value) {
        
            return value[@"name"];
        
        }] subscribeNext:^(NSString* name) {
        
            NSLog(@"Name is: \"%@\"", name);
        
        }];

Mapping is useful (you could map the json response using Core Data or Mantle!)

#Swift

Swift won't be supported until both ReactiveCocoa and AFNetworking will be 100% working on it.

#To Do / Contribute

- Support headers (which includes authentication)


Fork the repo and send a pull request!

#License

    Copyright (c) 2014 Matteo Pacini
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.

