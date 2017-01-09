//
//  URLContent.m
//  TRUEBOOK
//
//  Created by Narongsak Kongpan on 1/24/13.
//  Copyright (c) 2013 ebooks.in.th. All rights reserved.
//

#import "NKURLContent.h"

@implementation NKURLContent

@synthesize delegate = _delegate;
@synthesize timeout = _timeout;
@synthesize NSURLRequestCachePolicy = _NSURLRequestCachePolicy;
@synthesize _tag = __tag;

-(id)init{
	self = [super init];
	if(self){
		self.timeout = 30;
		self.NSURLRequestCachePolicy = NSURLRequestUseProtocolCachePolicy;
		isPlist = YES;
		isData = NO;
	}
	return self;
}

+(instancetype)newInstance{
    NKURLContent *theRequest = [[NKURLContent alloc] init];
    return theRequest;
}

-(void)getPlistByUrl:(NSString *)strUrl Tag:(NSString *)tag delegate:(id)delegate{
    self._tag = tag;
    self.delegate = delegate;
    [self getPlistByUrl:strUrl];
}

-(void)getPlistByInvocationDict:(NSDictionary*)args{
    self._tag = [args objectForKey:@"tag"];
    self.delegate = [args objectForKey:@"delegate"];
    [self getPlistByUrl:[args objectForKey:@"url"]];
}

-(NSOperation*)operationPlistByUrl:(NSString *)strUrl Tag:(NSString *)tag delegate:(id)delegate{
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:strUrl,@"url",tag,@"tag",delegate,@"delegate",nil];
    NSInvocationOperation* theOp = nil;
    theOp = [[NSInvocationOperation alloc] initWithTarget:self
                                                 selector:@selector(getPlistByInvocationDict:)
                                                   object:args];
    return theOp;
}

-(void)getPlistByUrl:(NSString*)strUrl Tag:(NSString*)tag delegate:(id)delegate withTimeout:(int)seconds{
	self.timeout = seconds;
	[self getPlistByUrl:strUrl Tag:tag delegate:delegate];
}

-(void)getContentByUrl:(NSString*)strUrl Tag:(NSString*)tag delegate:(id)delegate{
    self._tag = tag;
    self.delegate = delegate;
    [self getContentByUrl:strUrl];
}

-(void)getContentByUrl:(NSString*)strUrl Tag:(NSString*)tag delegate:(id)delegate withTimeout:(int)seconds{
	self.timeout = seconds;
	[self getContentByUrl:strUrl Tag:tag delegate:delegate];
}

-(void)getDataByUrl:(NSString *)strUrl Tag:(NSString *)tag delegate:(id)delegate{
    self._tag = tag;
    self.delegate = delegate;
    [self getDataByUrl:strUrl];
}

-(void)getDataByUrl:(NSString*)strUrl Tag:(NSString*)tag delegate:(id)delegate withTimeout:(int)seconds{
	self.timeout = seconds;
	[self getDataByUrl:strUrl Tag:tag delegate:delegate];
}

-(void)getPlistByUrl:(NSString*)strUrl{
	if(strUrl == nil){
		return;
	}
	NSLog(@"Request : %@",strUrl);

	isPlist = YES;
	@try {
		theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]
									  cachePolicy:self.NSURLRequestCachePolicy
								  timeoutInterval:self.timeout];
		theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:NO];
        [theConnection setDelegateQueue:[NSOperationQueue mainQueue]];
        [theConnection start];
		if (!theConnection) {
			[self throwErrorWithCode:-1];
		}else{
			receivedDatas = [NSMutableData data];
		}
	}
	@catch (NSException *exception) {
		[self throwErrorWithReason:exception];
	}
}

-(void)getDataByUrl:(NSString *)strUrl{
	if(strUrl == nil){
		return;
	}
	NSLog(@"Request : %@",strUrl);

	isData = YES;
	@try {
		theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString: strUrl]
												  cachePolicy:self.NSURLRequestCachePolicy
											  timeoutInterval:self.timeout];
		theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:NO];
        [theConnection setDelegateQueue:[NSOperationQueue mainQueue]];
        [theConnection start];
		if (!theConnection) {
			[self throwErrorWithCode:-1];
		}else{
			receivedDatas = [NSMutableData data];
		}
	}
	@catch (NSException *exception) {
		[self throwErrorWithReason:exception];
	}
}

-(void)getContentByUrl:(NSString*)strUrl{
	if(strUrl == nil){
		return;
	}
	NSLog(@"Request : %@",strUrl);

	isPlist = NO;
	@try {
		theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]
									  cachePolicy:self.NSURLRequestCachePolicy
								  timeoutInterval:self.timeout];
		theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:NO];
        [theConnection setDelegateQueue:[NSOperationQueue mainQueue]];
        [theConnection start];
		if (!theConnection) {
			[self throwErrorWithCode:-1];
		}else{
			receivedDatas = [NSMutableData data];
		}
	}
	@catch (NSException *exception) {
		[self throwErrorWithReason:exception];
	}
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[receivedDatas appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
	// Inform the user that the connection complete.
	NSData *receivedData = nil;
	NSString *returnValue  = nil;
	@try {
		receivedData = [NSData dataWithData:receivedDatas];
		if(isData){
            NSLog(@"NKURLConnectionWithCompleteData : %@",self._tag);
            if([self.delegate respondsToSelector:@selector(NKURLConnectionWithCompleteData:Tag:)]){
                [self.delegate NKURLConnectionWithCompleteData:receivedData Tag:self._tag];
            }
			return;
		}
		returnValue = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
		if(isPlist){
            NSLog(@"NKURLConnectionWithComplete : %@",self._tag);
            if([self.delegate respondsToSelector:@selector(NKURLConnectionWithComplete:Tag:)]){
                [self.delegate NKURLConnectionWithComplete:[returnValue propertyList] Tag:self._tag];
            }
		}else{
            NSLog(@"NKURLConnectionWithCompleteContent : %@",self._tag);
            if([self.delegate respondsToSelector:@selector(NKURLConnectionWithCompleteContent:Tag:)]){
                [self.delegate NKURLConnectionWithCompleteContent:returnValue Tag:self._tag];
            }else{
                [self throwErrorWithReason:[NSException exceptionWithName:NSGenericException
                                                                   reason:returnValue
                                                                 userInfo:nil]];
            }
		}
	}
	@catch (NSException *exception) {
		[self throwErrorWithReason:exception];
	}
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	NSLog(@"NKURLConnectionWithError : %ld Tag : %@",(long)[error code],self._tag);
    NSLog(@"Reason : %@",[error localizedDescription]);
	[self.delegate NKURLConnectionWithError:[error code]
                                     reason:[error localizedDescription]
                                        Tag:self._tag];
}

-(void)throwErrorWithCode:(int)code{
	NSLog(@"NKURLConnectionWithError : %i Tag : %@",code,self._tag);
}

-(void)throwErrorWithReason:(NSException*)exception{
	NSLog(@"NKURLConnectionWithError : %i Tag : %@ : %@",0,self._tag,[exception reason]);
	[self.delegate NKURLConnectionWithError:0
                                     reason:[exception reason]
                                        Tag:self._tag];
}

@end