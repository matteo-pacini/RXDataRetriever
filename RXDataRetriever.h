/////////////////////////////////////////////////////////////////////////////////////
//                                                                                 //
//  The MIT License (MIT)                                                          //
//                                                                                 //
//  Copyright (c) 2014 Matteo Pacini                                               //
//                                                                                 //
//  Permission is hereby granted, free of charge, to any person obtaining a copy   //
//  of this software and associated documentation files (the "Software"), to deal  //
//  in the Software without restriction, including without limitation the rights   //
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      //
//  copies of the Software, and to permit persons to whom the Software is          //
//  furnished to do so, subject to the following conditions:                       //
//                                                                                 //
//  The above copyright notice and this permission notice shall be included in     //
//  all copies or substantial portions of the Software.                            //
//                                                                                 //
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     //
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       //
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    //
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         //
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  //
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN      //
//  THE SOFTWARE.                                                                  //
//                                                                                 //
/////////////////////////////////////////////////////////////////////////////////////

/*
    Reactive JSON RESTful client.
    Based on ReactiveCocoa and AFNetworking 2.x.
 
    Author: Matteo Pacini <ispeakprogramming@gmail.com>
    Github: https://www.github.com/Zi0P4tch0
    Twitter: @Zi0P4tch0
*/
@interface RXDataRetriever : NSObject

//You need to set this before making requests!
@property (nonatomic, strong) NSString *baseURL;
//Defaults to @"", you should change this.
@property (nonatomic, strong) NSString *errorResponseDomain;
/*
 
 Defaults to @"error".
 e.g. If your server replies with this JSON after a 500:
 
 {
    "error": {
        "code"    : 500,
        "message" : "blablabla"
    }
 }
 
 ...you should set errorResponseKeyPath to @"error.message"!
 
 */
@property (nonatomic, strong) NSString *errorResponseKeyPath;

+(instancetype)instance;

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

@end
