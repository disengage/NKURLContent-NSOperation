//
//  URLContent.h
//  TRUEBOOK
//
//  Created by Narongsak Kongpan on 1/24/13.
//  Copyright (c) 2013 ebooks.in.th. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NKURLContent_Protocol <NSObject>
@required
-(void)NKURLConnectionWithError:(NSInteger)errorCode reason:(NSString*)reason Tag:(NSString*)tag;
@optional
-(void)NKURLConnectionWithComplete:(NSMutableArray*)muArray Tag:(NSString*)tag;
-(void)NKURLConnectionWithCompleteContent:(NSString*)content Tag:(NSString *)tag;
-(void)NKURLConnectionWithCompleteData:(NSData*)data Tag:(NSString *)tag;
@end

@interface NKURLContent : NSOperation <NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
	NSURLRequest *theRequest;
	NSURLConnection *theConnection;
	NSMutableData *receivedDatas;
	
	bool isPlist;
	bool isData;
}

@property (nonatomic,retain) id<NKURLContent_Protocol> delegate;
@property int timeout;
@property NSURLRequestCachePolicy NSURLRequestCachePolicy;
@property (nonatomic,strong) NSString *_tag;

+(instancetype)newInstance;

-(void)getPlistByUrl:(NSString*)strUrl Tag:(NSString*)tag delegate:(id)delegate;
-(void)getContentByUrl:(NSString*)strUrl Tag:(NSString*)tag delegate:(id)delegate;
-(void)getDataByUrl:(NSString*)strUrl Tag:(NSString*)tag delegate:(id)delegate;

-(void)getPlistByUrl:(NSString*)strUrl Tag:(NSString*)tag delegate:(id)delegate withTimeout:(int)seconds;
-(void)getContentByUrl:(NSString*)strUrl Tag:(NSString*)tag delegate:(id)delegate withTimeout:(int)seconds;
-(void)getDataByUrl:(NSString*)strUrl Tag:(NSString*)tag delegate:(id)delegate withTimeout:(int)seconds;

-(NSOperation*)operationPlistByUrl:(NSString *)strUrl Tag:(NSString *)tag delegate:(id)delegate;
@end