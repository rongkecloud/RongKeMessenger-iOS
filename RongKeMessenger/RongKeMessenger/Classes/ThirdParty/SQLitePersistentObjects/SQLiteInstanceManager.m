//
//  SQLiteInstanceManager.m
// ----------------------------------------------------------------------
// Part of the SQLite Persistent Objects for Cocoa and Cocoa Touch
//
// Original Version: (c) 2008 Jeff LaMarche (jeff_Lamarche@mac.com)
// ----------------------------------------------------------------------
// This code may be used without restriction in any software, commercial,
// free, or otherwise. There are no attribution requirements, and no
// requirement that you distribute your changes, although bugfixes and 
// enhancements are welcome.
// 
// If you do choose to re-distribute the source code, you must retain the
// copyright notice and this license information. I also request that you
// place comments in to identify your changes.
//
// For information on how to use these classes, take a look at the 
// included Readme.txt file
// ----------------------------------------------------------------------


#import "SQLiteInstanceManager.h"
#import "SQLitePersistentObject.h"

static const void * const kDispatchQueueSpecificKey = &kDispatchQueueSpecificKey;

#pragma mark Private Method Declarations
@interface SQLiteInstanceManager (private)
- (NSString *)databaseFilepath;
@end

@interface SQLiteInstanceManager ()
{
    dispatch_queue_t dbOperationQueue;
    NSString *databaseFilepath;
    sqlite3 *database;
}

@end

@implementation SQLiteInstanceManager

@synthesize databaseFilepath;

#pragma mark -
#pragma mark Singleton Methods
+ (id)sharedManager 
{
    static dispatch_once_t dbConvertor;
    static SQLiteInstanceManager *shareManager;
    dispatch_once(&dbConvertor, ^{
        shareManager = [[SQLiteInstanceManager alloc] init];
    });
    return shareManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        dbOperationQueue = dispatch_queue_create("SQLitePeristentObject.DBOperationQueue", DISPATCH_QUEUE_SERIAL);
        
        dispatch_queue_set_specific(dbOperationQueue, kDispatchQueueSpecificKey, (__bridge void *)self, NULL);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}
- (NSUInteger)retainCount
{
	return UINT_MAX;  //denotes an object that cannot be released
}
- (oneway void)release
{
	// never release
}
- (id)autorelease
{
	return self;
}
#pragma mark -
#pragma mark Public Instance Methods

-(sqlite3 *)database
{
	static BOOL first = YES;
	
	if (first || database == NULL)
	{
		first = NO;
        if ([self databaseFilepath] == nil)
        {
            return NULL;
        }
        SQLITE_API int openDatabase = -1;
        
        if (SQLITE_VERSION_NUMBER >= 3005000)
        {
            openDatabase = sqlite3_open_v2([[self databaseFilepath] UTF8String], &database, SQLITE_OPEN_READWRITE|SQLITE_OPEN_CREATE, NULL);
        }
        else
        {
            openDatabase = sqlite3_open([[self databaseFilepath] UTF8String], &database);
        }
        
        
		if (openDatabase != SQLITE_OK)
		{
			// Even though the open failed, call close to properly clean up resources.
			NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
			sqlite3_close(database);
            database = NULL;
		}
		else
		{
			// Default to UTF-8 encoding
			[self executeUpdateSQL:@"PRAGMA encoding = \"UTF-8\""];
			
			// Turn on full auto-vacuuming to keep the size of the database down
			// This setting can be changed per database using the setAutoVacuum instance method
			[self executeUpdateSQL:@"PRAGMA auto_vacuum=1"];
            
            // Set cache size to zero. This will prevent performance slowdowns as the
            // database gets larger
            [self executeUpdateSQL:@"PRAGMA CACHE_SIZE=0"];
			
		}
	}
	return database;
}

- (void)closeDatabase
{
    // 关闭数据库之前，先把数据库相关的缓存清空  add by ivan 20160421
    [SQLitePersistentObject clearCache];
    
    if (database) {
        sqlite3_close(database);
        database = NULL;
    }
}

- (BOOL)tableExists:(NSString *)tableName
{
	BOOL ret = NO;
	// pragma table_info(i_c_project);
	NSString *query = [NSString stringWithFormat:@"pragma table_info(%@);", tableName];
	sqlite3_stmt *stmt;
	if (sqlite3_prepare_v2( database,  [query UTF8String], -1, &stmt, nil) == SQLITE_OK) {
		if (sqlite3_step(stmt) == SQLITE_ROW)
			ret = YES;
		sqlite3_finalize(stmt);
	}
	return ret;
}

- (void)setAutoVacuum:(SQLITE3AutoVacuum)mode
{
	NSString *updateSQL = [NSString stringWithFormat:@"PRAGMA auto_vacuum=%d", mode];
	[self executeUpdateSQL:updateSQL];
}
- (void)setCacheSize:(NSUInteger)pages
{
	NSString *updateSQL = [NSString stringWithFormat:@"PRAGMA cache_size=%lu", (unsigned long)pages];
	[self executeUpdateSQL:updateSQL];
}
- (void)setLockingMode:(SQLITE3LockingMode)mode
{
	NSString *updateSQL = [NSString stringWithFormat:@"PRAGMA locking_mode=%d", mode];
	[self executeUpdateSQL:updateSQL];
}
- (void)deleteDatabase
{
	NSString* path = [self databaseFilepath];
	NSFileManager* fm = [NSFileManager defaultManager];
	[fm removeItemAtPath:path error:NULL];
    
    // add by ivan 2014.11.11
    [self closeDatabase];
}
- (void)vacuum
{
	[self executeUpdateSQL:@"VACUUM"];
}
- (void)executeUpdateSQL:(NSString *) updateSQL
{
	char *errorMsg;
	if (sqlite3_exec([self database],[updateSQL UTF8String] , NULL, NULL, &errorMsg) != SQLITE_OK) {
		NSString *errorMessage = [NSString stringWithFormat:@"Failed to execute SQL '%@' with message '%s'.", updateSQL, errorMsg];
#pragma unused(errorMessage)		
		// NSAssert(0, errorMessage);
		sqlite3_free(errorMsg);
	}
}

- (void)dealloc
{
	[databaseFilepath release];
	[super dealloc];
}
#pragma mark -
#pragma mark Private Methods

- (NSString *)databaseFilepath
{
	if (databaseFilepath == nil)
	{
        return nil;  // add by ivan 2014.12.16 避免生成一个默认的数据库
	}
	return databaseFilepath;
}

#pragma mark -
#pragma mark DB OperationQueue methods

- (void)performUsingDBOperationQueue:(void(^)(void))block
{
    dispatch_retain(dbOperationQueue);
    dispatch_sync(dbOperationQueue, block);
    dispatch_release(dbOperationQueue);
}

@end
