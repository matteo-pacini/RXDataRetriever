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

#import "RXDataRetriever.h"

#import <AFNetworking/AFNetworking.h>

@interface RXDataRetriever()

@property (nonatomic,strong) AFHTTPSessionManager *httpSessionManager;

@property (nonatomic,assign) AFNetworkReachabilityStatus reachabilityStatus;

@end

@implementation RXDataRetriever

#pragma mark -
#pragma mark - Lifecycle

+(instancetype)instance
{
    static RXDataRetriever *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[RXDataRetriever alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //Default properties values
        self.reachabilityStatus = AFNetworkReachabilityStatusUnknown;
        self.errorResponseDomain = @"";
        self.errorResponseKeyPath = @"error";
    }
    return self;
}

#pragma mark -
#pragma mark - Getters / Setters

-(void)setBaseURL:(NSString *)baseURL
{
    NSCParameterAssert(baseURL);
    
    _baseURL = baseURL;
    
    [self setup];
}

-(void)setErrorResponseDomain:(NSString *)errorResponseDomain
{
    NSCParameterAssert(errorResponseDomain);
    
    _errorResponseDomain = errorResponseDomain;
}

-(void)setErrorResponseKeyPath:(NSString *)errorResponseKeyPath
{
    NSCParameterAssert(errorResponseKeyPath);
    
    _errorResponseKeyPath = errorResponseKeyPath;
}

#pragma mark -
#pragma mark - Setup

-(void)setup
{
    //Setting up AFHTTPSessionManager
    
    NSURL *backendURL = [NSURL URLWithString:self.baseURL];
    NSURLSessionConfiguration *sessionConfig =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    
    sessionConfig.allowsCellularAccess = YES;
    sessionConfig.discretionary = YES;
    
    self.httpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:backendURL
                                                       sessionConfiguration:sessionConfig];
    //Serializers
    
    self.httpSessionManager.requestSerializer =
    [AFJSONRequestSerializer serializerWithWritingOptions:0];
    
    self.httpSessionManager.responseSerializer =
    [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    
    @weakify(self)
    
    [self.httpSessionManager.reachabilityManager
             setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
                 @strongify(self);
                 
                 self.reachabilityStatus = status;
                 
    }];
        
}

#pragma mark -
#pragma mark - Reachability

-(RACSignal*)reachability
{
    return RACObserve(self, reachabilityStatus);
}

#pragma mark -
#pragma mark - HTTP Methods

-(RACSignal*)GET:(NSString*)path
           query:(NSDictionary*)arguments
{
    NSAssert(self.baseURL,@"self.baseURL is nil!");
    NSCParameterAssert(path);
    
    if (arguments && [arguments count])
    {
        path = [path stringByAppendingString:
                [self queryStringForArguments:arguments]];
    }
    
    NSLog(@"%@",path);
    
    @weakify(self);
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        @strongify(self);
        
        __block NSURLSessionDataTask *task =
        
        [self.httpSessionManager GET:path
                          parameters:nil
                             success:^(NSURLSessionDataTask *task, id responseObject) {
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)[task response];
            
            if (httpResponse.statusCode == 200) {
                
                [subscriber sendNext:responseObject];
                [subscriber sendCompleted];
                
            } else {
                
                NSString *error = [responseObject valueForKeyPath:self.errorResponseKeyPath];
                
                NSError *apiError =
                [NSError errorWithDomain:self.errorResponseDomain
                                    code:httpResponse.statusCode
                                userInfo:@{NSLocalizedDescriptionKey:error}];
            
                [subscriber sendError:apiError];
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            [subscriber sendError:error];
            
        }];
        
        return [RACDisposable disposableWithBlock:^{
            
            [task cancel];
            
        }];
        
    }];
    
}


-(RACSignal*)POST:(NSString*)path
             data:(id)data
{
    NSAssert(self.baseURL,@"self.baseURL is nil!");
    NSCParameterAssert(path);
    NSCParameterAssert(data);

    @weakify(self);
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        @strongify(self);
        
        __block NSURLSessionDataTask *task =
        
        [self.httpSessionManager POST:path
                           parameters:data
                              success:^(NSURLSessionDataTask *task, id responseObject) {
             
             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)[task response];
             
             if (httpResponse.statusCode == 200) {
                 
                 [subscriber sendNext:responseObject];
                 [subscriber sendCompleted];
                 
             } else {
                 
                 NSString *error = [responseObject valueForKeyPath:self.errorResponseKeyPath];
                 
                 NSError *apiError =
                 [NSError errorWithDomain:self.errorResponseDomain
                                     code:httpResponse.statusCode
                                 userInfo:@{NSLocalizedDescriptionKey:error}];
                 
                 [subscriber sendError:apiError];
             }
             
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             
             [subscriber sendError:error];
             
         }];
        
        return [RACDisposable disposableWithBlock:^{
            
            [task cancel];
            
        }];
        
    }];

}

-(RACSignal*)PUT:(NSString*)path
            data:(id)data
{
    NSAssert(self.baseURL,@"self.baseURL is nil!");
    NSCParameterAssert(path);
    NSCParameterAssert(data);
    
    @weakify(self);
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        @strongify(self);
        
        __block NSURLSessionDataTask *task =
        
        [self.httpSessionManager PUT:path
                           parameters:data
                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                  
                                  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)[task response];
                                  
                                  if (httpResponse.statusCode == 200) {
                                      
                                      [subscriber sendNext:responseObject];
                                      [subscriber sendCompleted];
                                      
                                  } else {
                                      
                                      NSString *error = [responseObject valueForKeyPath:self.errorResponseKeyPath];
                                      
                                      NSError *apiError =
                                      [NSError errorWithDomain:self.errorResponseDomain
                                                          code:httpResponse.statusCode
                                                      userInfo:@{NSLocalizedDescriptionKey:error}];
                                      
                                      [subscriber sendError:apiError];
                                  }
                                  
                              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  
                                  [subscriber sendError:error];
                                  
                              }];
        
        return [RACDisposable disposableWithBlock:^{
            
            [task cancel];
            
        }];
        
    }];
    
}

-(RACSignal*)PATCH:(NSString*)path
               ops:(NSArray*)patches
{
    NSAssert(self.baseURL,@"self.baseURL is nil!");
    NSAssert(path,@"Path can be nil!");
    NSAssert(patches,@"Patches can't be nil!");
    
    @weakify(self);
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        @strongify(self);
        
        __block NSURLSessionDataTask *task =
        
        [self.httpSessionManager PATCH:path
                            parameters:patches
                               success:^(NSURLSessionDataTask *task, id responseObject) {
             
             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)[task response];
             
             if (httpResponse.statusCode == 200) {
                 
                 [subscriber sendNext:responseObject];
                 [subscriber sendCompleted];
                 
             } else {
                 
                 NSString *error = [responseObject valueForKeyPath:self.errorResponseKeyPath];
                 
                 NSError *apiError =
                 [NSError errorWithDomain:self.errorResponseDomain
                                     code:httpResponse.statusCode
                                 userInfo:@{NSLocalizedDescriptionKey:error}];
                 
                 [subscriber sendError:apiError];
             }
             
         } failure:^(NSURLSessionDataTask *task, NSError *error) {
             
             [subscriber sendError:error];
             
         }];
        
        return [RACDisposable disposableWithBlock:^{
            
            [task cancel];
            
        }];
        
    }];

}

-(RACSignal*)DELETE:(NSString*)path
{
    NSAssert(self.baseURL,@"self.baseURL is nil!");
    NSAssert(path,@"Path can be nil!");
    
    @weakify(self);
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        @strongify(self);
        
        __block NSURLSessionDataTask *task =
        
        [self.httpSessionManager DELETE:path
                            parameters:nil
                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                   
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)[task response];
                                   
            if (httpResponse.statusCode == 200) {
                                       
                [subscriber sendNext:responseObject];
                [subscriber sendCompleted];
                                       
            } else {
                                       
                NSString *error = [responseObject valueForKeyPath:self.errorResponseKeyPath];
                
                NSError *apiError =
                [NSError errorWithDomain:self.errorResponseDomain
                                    code:httpResponse.statusCode
                                userInfo:@{NSLocalizedDescriptionKey:error}];
                                       
                    [subscriber sendError:apiError];
            }
                                   
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   
            [subscriber sendError:error];
                                   
        }];
        
        return [RACDisposable disposableWithBlock:^{
            
            [task cancel];
            
        }];
        
    }];
}


#pragma mark -
#pragma mark - Invalidate

-(RACSignal*)invalidateSessionCancelingTasks:(BOOL)cancelPendingTasks
{
    @weakify(self)
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        @strongify(self)
        
        [self.httpSessionManager invalidateSessionCancelingTasks:cancelPendingTasks];
        
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
           
            
        }];
        
    }];
    
}

#pragma mark -
#pragma mark - Utilities

-(NSString*)queryStringForArguments:(NSDictionary*)arguments
{
    __block NSString *queryString = @"?";
    
    __block NSInteger entriesCount = [arguments count];
    __block NSInteger count = 0;
    
    @weakify(self);
        
    [arguments enumerateKeysAndObjectsUsingBlock:^(NSString* key, id obj, BOOL *stop) {
        
        @strongify(self);
        
        count++;
        
        NSString *arg = [NSString stringWithFormat:@"%@=%@%@",
                         key,
                         [self urlEncode:obj],
                         (count == entriesCount?@"":@"&")];
        
        queryString = [queryString stringByAppendingString:arg];
        
    }];
    
    return queryString;
}

-(NSString*)urlEncode:(NSString*)str
{
    NSString *charactersToEscape = @"!*'();:@&=+$,/?%#[]\" ";
    
    NSCharacterSet *allowedCharacters =
    [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape]
                                         invertedSet];
    
    return  [str stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
}

@end
