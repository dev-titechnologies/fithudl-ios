//
//  Created by Dmitry Ivanenko on 14.04.14.
//  Copyright (c) 2014 Dmitry Ivanenko. All rights reserved.
//

#import <UIKit/UIKit.h>


extern const CGFloat kDIDatepickerHeight;

@interface DIDatepicker : UIControl <UICollectionViewDataSource, UICollectionViewDelegate>

// data
@property (strong, nonatomic) NSArray *dates;
@property (strong, nonatomic, readonly) NSDate *selectedDate;
@property (strong, nonatomic, readonly) NSDate *prevDate;

// UI
@property (strong, nonatomic) UIColor *bottomLineColor;
@property (strong, nonatomic) UIColor *selectedDateBottomLineColor;

// methods
-(void) filDatesWithMonth:(NSString*) month year:(NSString*) year;
- (void)fillDatesFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (void)fillDatesFromDate:(NSDate *)fromDate numberOfDays:(NSInteger)nextDatesCount;
- (void)fillCurrentWeek;
- (void)fillCurrentMonth;
- (void)fillCurrentYear;
- (void)selectDate:(NSDate *)date;
- (void)selectDateAtIndex:(NSUInteger)index;

@end
