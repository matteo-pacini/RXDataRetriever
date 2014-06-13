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

*GET* supports query arguments. If you don't need those, just pass *nil*.

    [[RXDataRetriever instance] GET:@"/doge" query:@{"such":"networking","much","reactive"}]

...produces this URL:

    @"/doge?such=networking&much=reactive"

Query values will be URL-encoded if needed.

#Example

##Retrieve a GitHub user

Configure the client first.

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

#Swift

Swift won't be supported until ReactiveCocoa and AFNetworking will be 100% working on it.


#Contribute

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

