//
//  ViewController.m
//  CASqliteDemo
//
//  Created by Charles on 15/11/21.
//  Copyright © 2015年 Charles. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>

@interface ViewController () {
    sqlite3 *db;
}

@property (weak, nonatomic) IBOutlet UILabel *errorMessage;

@property (weak, nonatomic) IBOutlet UITextView *resultTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 1.获取沙盒路径
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *sqliteFilePath = [documentPath stringByAppendingPathComponent:@"peopleuserinfo.sqlite"];
    
    // 2.创建, 打开数据库, 如果数据库文件不存在会自动创建
    if (sqlite3_open([sqliteFilePath UTF8String], &db) == !SQLITE_OK) {
        NSLog(@"打开数据库失败");
        self.errorMessage.text = @"打开数据库失败";
        
        sqlite3_close(db);
    } else {
        NSLog(@"打开数据库成功");
        self.errorMessage.text = @"打开数据库成功";
        
        // 2.1 create table
        NSString *sql = @"CREATE TABLE IF NOT EXISTS PEOPLEUSERINFO (ID INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER, gender TEXT);";
        [self execSql:sql];
    }
}

// 执行数据库操作
- (void)execSql:(NSString *)sql {
    
    char *err;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(db);
        NSLog(@"数据库操作数据失败");
        
        self.errorMessage.text = @"数据库操作数据失败";
    }
}

/**
 *  插入数据
 */
- (IBAction)insertData:(id)sender {
    
    NSArray *names = @[@"Amy", @"Bob", @"Candy", @"Dove", @"Erin",
                       @"Franky", @"God", @"Holy", @"Ivy", @"Jack",
                       @"Kelly", @"Lily", @"Moon", @"Nina", @"Oliver",
                       @"Peter", @"Queen", @"Rose", @"Steve", @"Tom",
                       @"Union", @"Victor", @"Wall", @"Xanthe", @"Yoyo",
                       @"Zack"];
    for (NSString *name in names) {
        int age = arc4random() % 20 + 20;
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO PEOPLEUSERINFO ('name', 'age', 'gender') VALUES ('%@', %d, '%@')", name, age, (age % 2) == 0 ? @"Male" : @"Female"];
        [self execSql:sql];
    }
}

/**
 *  删除数据
 */
- (IBAction)deleteData:(id)sender {
    
    NSString *sql = @"DELETE FROM PEOPLEUSERINFO where age=19";
    
    // stmt存放结果
    sqlite3_stmt *stmt = NULL;
    
    if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
        NSLog(@"删除数据失败");
        self.errorMessage.text = @"删除数据失败";
    } else {
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            int sid = sqlite3_column_int(stmt, 0);
            const unsigned char *sname = sqlite3_column_text(stmt, 1);
            int sage = sqlite3_column_int(stmt, 2);
            const unsigned char *sgender = sqlite3_column_text(stmt, 3);
            
            NSLog(@"sid:%d name:%s age:%d gender:%s 删除成功", sid, sname, sage, sgender);
        }
        
        NSLog(@"删除成功");
        self.errorMessage.text = @"删除成功";
    }
}

/**
 *  更新数据
 */
- (IBAction)updateData:(id)sender {
    
    NSString *sql = @"UPDATE PEOPLEUSERINFO set name = 'Charles', age = 23, gender = 'Male';";
    
    sqlite3_stmt *stmt = NULL;
    
    if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
        NSLog(@"更新数据失败");
        self.errorMessage.text = @"更新数据失败";
    } else {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            int sid = sqlite3_column_int(stmt, 0);
            const unsigned char *sname = sqlite3_column_text(stmt, 1);
            int sage = sqlite3_column_int(stmt, 2);
            const unsigned char *sgender = sqlite3_column_text(stmt, 3);
            
            NSLog(@"sid:%d name:%s age:%d gender:%s", sid, sname, sage, sgender);
        }
        
        NSLog(@"更新成功");
        self.errorMessage.text = @"更新成功";
    }
}

/**
 *  查询数据
 */
- (IBAction)queryData:(id)sender {
    
    NSString *sql = @"SELECT * FROM PEOPLEUSERINFO order by age asc, name asc;";
    
    sqlite3_stmt *stmt = NULL;
    
    if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
        NSLog(@"查询数据失败");
        self.errorMessage.text = @"查询数据失败";
    } else {
        
        NSMutableString *result = [[NSMutableString alloc] init];
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            int sid = sqlite3_column_int(stmt, 0);
            const unsigned char *sname = sqlite3_column_text(stmt, 1);
            int sage = sqlite3_column_int(stmt, 2);
            const unsigned char *sgender = sqlite3_column_text(stmt, 3);
            
            [result appendString:[NSString stringWithFormat:@"id:%d name:%s age:%d gender:%s\n", sid, sname, sage, sgender]];
            NSLog(@"%@", result);
        }
        
        NSLog(@"查询成功");
        self.errorMessage.text = @"查询成功";
        
        self.resultTextView.text = result;
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
