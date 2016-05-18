#import "UITabBarItemWithBadge.h"

#define OFFSET 0.6f

@implementation UITabBarItemWithBadge

-(void) setCustomBadgeValue:(NSString *)value fontColor:(UIColor *)fontColor backgroundColor:(UIColor *)backgroundColor {
    UIView *v = (UIView *)[self performSelector:@selector(view)];

    [self setBadgeValue:value];

    for(UIView *sv in v.subviews) {
        NSString *str = NSStringFromClass([sv class]);
        NSLog(str);
        if([str isEqualToString:@"_UIBadgeView"]) {
            for(UIView *ssv in sv.subviews) {
                if(ssv.tag == 27) {
                    [ssv removeFromSuperview];
                }
            }

            UILabel *badge = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, sv.frame.size.width, sv.frame.size.height)];
            badge.adjustsFontSizeToFitWidth = true;
            badge.text = value;
            badge.textAlignment = NSTextAlignmentCenter;
            badge.textColor = fontColor;
            badge.backgroundColor = backgroundColor;
            badge.clipsToBounds = true;
            badge.tag = 27;

            badge.layer.cornerRadius = badge.frame.size.height/2;
            badge.layer.masksToBounds = YES;

            sv.layer.borderWidth = 1;
            sv.layer.borderColor = [backgroundColor CGColor];
            sv.layer.cornerRadius = sv.frame.size.height/2;
            sv.layer.masksToBounds = YES;

            [sv addSubview:badge];
            badge.tag = 27;
        }
    }
}

@end
