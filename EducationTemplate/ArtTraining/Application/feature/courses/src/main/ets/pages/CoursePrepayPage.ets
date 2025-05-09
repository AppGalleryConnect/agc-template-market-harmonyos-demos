import { CourseInfo, CourseUtil } from 'commonlib';
import { CommonButton, CommonHeader, CommonLoading, ContainerColumn, ContainerRow } from 'componentlib';
import { PAYMENT_RADIO_GROUP, PAYMENT_RADIO_LIST } from '../constants/Constants';
import { UserInfoForOrderMap } from '../constants/Enums';
import { CoursePaymentMethod } from '../types/Index';
import { CoursePrepayVM } from '../viewmodels/CoursePrepayVM';

@Builder
export function coursePrepayPageBuilder() {
  CoursePrepayPage();
}

@ComponentV2
export struct CoursePrepayPage {
  vm: CoursePrepayVM = CoursePrepayVM.instance;

  build() {
    NavDestination() {
      CommonHeader({ title: '订单结算' });
      if (this.vm.isLoading) {
        CommonLoading();
      } else {
        Scroll() {
          Column() {
            if (this.vm.courseInfo) {
              // 课程卡片栏
              this.courseCardBuilder(this.vm.courseInfo);
              // 订单信息表单
              this.prepayFormBuilder();
            }
            Blank().layoutWeight(1);
          }
          .padding($r('app.string.padding_s'))
          .justifyContent(FlexAlign.Start);
        }
        .layoutWeight(1)
        .backgroundColor($r('app.color.system_color_background_auxiliary'));

        // 底部按钮
        this.bottomButtonBuilder();
      }
    }
    .hideTitleBar(true)
    .onReady(() => {
      this.vm.initCourseOrder();
    })
    .width($r('app.string.width_percent_full'))
    .height($r('app.string.height_percent_full'));

  }

  @Builder
  courseCardBuilder(courseInfo: CourseInfo) {
    ContainerRow() {
      Image(courseInfo.mainDiagram)
        .height(100)
        .aspectRatio(1)
        .borderRadius($r('app.string.border_radius_8'))
        .margin({ right: $r('app.string.margin_s') });
      Column() {
        Row() {
          Text(courseInfo.name).mainTextStyle();
          Blank();
          Text(`¥ ${courseInfo.price}`);
        }
        .width($r('app.string.width_percent_full'));

        Text(courseInfo.summary).descTextStyle()
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
        Text(`有效期： ${CourseUtil.getExpireLabel(courseInfo)}`).descTextStyle();
        Text(`规格： ${courseInfo.classHour}课时`).descTextStyle();
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);
    };
  }

  @Builder
  prepayFormBuilder() {
    ContainerRow() {
      Text('支付方式')
        .mainTextStyle()
        .width($r('app.string.width_percent_25'));
      Row() {
        ForEach(PAYMENT_RADIO_LIST, (item: CoursePaymentMethod) => {
          this.paymentMethodButton(item);
        }, (item: CoursePaymentMethod) => item.id.toString());
      };
    };

    ContainerColumn() {
      Row() {
        Row() {
          Text('学员').mainTextStyle();
          Text('*').requiredInputStyle();
        }
        .width($r('app.string.width_percent_15'));

        TextInput({ placeholder: '请输入学员姓名', text: this.vm.courseOrder.student })
          .type(InputType.Normal)
          .textInputStyle()
          .onChange((value) => {
            this.vm.courseOrder.student = value;
          })
          .layoutWeight(1);

        Image($r('app.media.ic_close_circle'))
          .closeIconStyle()
          .onClick(() => {
            this.vm.clearOrderInfo(UserInfoForOrderMap.NAME);
          });
      }
      .formItemStyle();

      Row() {
        Row() {
          Text('手机').mainTextStyle();
          Text('*').requiredInputStyle();
        }
        .width($r('app.string.width_percent_15'));

        TextInput({ placeholder: '请输入手机号码', text: this.vm.courseOrder.phone })
          .type(InputType.PhoneNumber)
          .textInputStyle()
          .onChange((value) => {
            this.vm.courseOrder.phone = value;
          })
          .layoutWeight(1);
        Image($r('app.media.ic_close_circle'))
          .closeIconStyle()
          .onClick(() => {
            this.vm.clearOrderInfo(UserInfoForOrderMap.PHONE);
          });
      }
      .formItemStyle();

      Column() {
        Text('留言')
          .mainTextStyle()
          .margin({ bottom: $r('app.string.margin_s') });
        TextArea({ placeholder: '选填，请输入留言~', text: this.vm.courseOrder.remark })
          .fontSize($r('app.string.font_size_14'))
          .padding($r('app.string.padding_s'))
          .maxLength(100)
          .showCounter(true)
          .height(100)
          .borderWidth(1)
          .borderRadius($r('app.string.border_radius_8'))
          .borderColor($r('app.color.system_color_background_grey_level2'))
          .backgroundColor($r('app.color.system_color_background_white'))
          .placeholderColor($r('app.color.font_color_level3'))
          .placeholderFont({ size: $r('app.string.font_size_14') })
          .onChange((value) => {
            this.vm.courseOrder.remark = value;
          });
      }
      .width($r('app.string.width_percent_full'))
      .alignItems(HorizontalAlign.Start);
    };
  }

  @Builder
  bottomButtonBuilder() {
    Row() {
      Text() {
        Span('合计: ')
          .fontSize($r('app.string.font_size_14'))
          .fontColor($r('app.color.font_color_level1'));
        Span('¥ ')
          .fontSize($r('app.string.font_size_12'))
          .fontColor($r('app.color.system_theme_color'));
        Span(this.vm.courseOrder.price.toString())
          .fontSize($r('app.string.font_size_18'))
          .fontColor($r('app.color.system_theme_color'));
      };

      CommonButton({
        title: '提交订单',
        handleClick: () => {
          this.vm.submitCourseOrder();
        },
      })
        .width($r('app.string.width_percent_half'));
    }
    .width('100%')
    .backgroundColor($r('app.color.system_color_background_white'))
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: $r('app.string.padding_l'),
      right: $r('app.string.padding_l'),
      top: $r('app.string.padding_l'),
    });
  }

  @Builder
  paymentMethodButton(item: CoursePaymentMethod) {
    Row() {
      Radio({
        value: item.value,
        group: PAYMENT_RADIO_GROUP,
        indicatorType: RadioIndicatorType.CUSTOM,
        indicatorBuilder: () => {
          this.indicatorBuilder();
        },
      })
        .checked(true)
        .radioStyle({
          checkedBackgroundColor: $r('app.color.system_theme_color'),
        })
        .height($r('app.integer.icon_size_16'))
        .width($r('app.integer.icon_size_16'))
        .onChange((isChecked: boolean) => {
          if (isChecked) {
            this.vm.switchPaymentMethod(item);
          }
        });
      Text(item.value).mainTextStyle();
    }
    .margin({ right: $r('app.string.margin_l') });
  }

  @Builder
  indicatorBuilder() {
    Image($r('app.media.ic_radio_selected'));
  }
}

@Extend(Row)
function formItemStyle() {
  .width($r('app.string.width_percent_full'))
  .justifyContent(FlexAlign.Start)
  .margin({
    bottom: $r('app.string.margin_l'),
  });
}

@Extend(Text)
function mainTextStyle() {
  .fontSize($r('app.string.font_size_14'))
  .fontColor($r('app.color.font_color_level1'));
}

@Extend(Text)
function descTextStyle() {
  .fontSize($r('app.string.font_size_12'))
  .fontColor($r('app.color.font_color_level2'))
  .lineHeight(20);
}

@Extend(Text)
function requiredInputStyle() {
  .fontColor($r('app.color.system_theme_color'))
  .fontSize($r('app.string.font_size_14'));
}

@Extend(TextInput)
function textInputStyle() {
  .fontSize($r('app.string.font_size_14'))
  .padding({ left: $r('app.string.padding_xxs') })
  .margin({ left: $r('app.string.margin_s') })
  .backgroundColor($r('app.color.system_color_background_white'))
  .placeholderColor($r('app.color.font_color_level3'))
  .placeholderFont({ size: $r('app.string.font_size_14') });
}

@Extend(Image)
function closeIconStyle() {
  .width($r('app.integer.icon_size_16'))
  .height($r('app.integer.icon_size_16'));

}