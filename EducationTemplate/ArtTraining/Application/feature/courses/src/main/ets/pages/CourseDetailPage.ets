import { CourseUtil } from 'commonlib';
import { CommonButton, CommonHeader, CommonLoading, ContainerColumn, ContainerRow } from 'componentlib';
import { CourseDetailVM } from '../viewmodels/CourseDetaiVM';

@Builder
export function courseDetailPageBuilder() {
  CourseDetailPage();
}

@ComponentV2
export struct CourseDetailPage {
  vm: CourseDetailVM = CourseDetailVM.instance;

  aboutToAppear(): void {
    this.vm.getCourseDetail();
  }

  build() {
    NavDestination() {
      CommonHeader({ title: this.vm.courseInfo?.name ?? '' });
      Scroll() {
        Column() {
          if (this.vm.isLoading) {
            CommonLoading();
          } else {
            if (this.vm.courseInfo) {
              // 顶部卡片
              this.topBannerBuilder();
              //课程详情
              this.courseDetailBuilder();

              Blank().layoutWeight(1)
            }
          }
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Start);
      }
      .scrollBar(BarState.Off)
      .width($r('app.string.width_percent_full'))
      .backgroundColor($r('app.color.system_color_background_auxiliary'))
      .layoutWeight(1);

      // 底部按钮
      this.bottomButtonBuilder();
    }
    .hideTitleBar(true)
    .onShown(() => {
      this.vm.getCourseDetail();
    });

  }

  @Builder
  topBannerBuilder() {
    if (this.vm.courseInfo) {
      Column() {
        Image(this.vm.courseInfo.mainDiagram)
          .width($r('app.string.width_percent_full'));
        Column() {
          Text(this.vm.courseInfo.name)
            .fontSize($r('app.string.font_size_16'))
            .fontColor($r('app.color.font_color_level1'))
            .margin({ bottom: $r('app.string.margin_s') });

          Text(this.vm.courseInfo.summary)
            .fontSize($r('app.string.font_size_12'))
            .fontColor($r('app.color.font_color_level2'))
            .margin({ bottom: $r('app.string.margin_s') });

          Row() {
            Text() {
              Span('¥ ')
                .fontSize($r('app.string.font_size_12'));
              Span(this.vm.courseInfo.price.toString())
                .fontSize($r('app.string.font_size_16'));
            }
            .fontColor($r('app.color.system_theme_color'))
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1);
          };
        }
        .alignItems(HorizontalAlign.Start)
        .backgroundColor($r('app.color.system_color_background_white'))
        .padding({
          left: $r('app.string.padding_l'),
          right: $r('app.string.padding_l'),
          top: $r('app.string.padding_m'),
          bottom: $r('app.string.padding_m'),
        })
        .width($r('app.string.width_percent_full'));
      }
      .width($r('app.string.width_percent_full'));
    }
  }

  @Builder
  courseDetailBuilder() {
    Column() {
      ContainerRow() {
        Text('时效')
          .fontSize($r('app.string.font_size_14'))
          .fontColor($r('app.color.font_color_level2'))
          .margin({ right: $r('app.string.margin_l') });
        Text(CourseUtil.getExpireLabel(this.vm.courseInfo))
          .fontSize($r('app.string.font_size_14'))
          .fontColor($r('app.color.font_color_level1'));
      };

      ContainerColumn({
        title: '详情',
      }) {
        Text(this.vm.courseInfo?.detail)
          .lineHeight(18)
          .fontSize($r('app.string.font_size_12'))
          .fontColor($r('app.color.font_color_level2'));
      };
    }
    .padding($r('app.string.padding_l'));

  }

  @Builder
  bottomButtonBuilder() {
    Flex() {
      Column() {
        Image($r('app.media.ic_home'))
          .width($r('app.integer.icon_size_24'))
          .height($r('app.integer.icon_size_24'))
          .fillColor($r('app.color.icon_color_level2'))
          .margin({ bottom: $r('app.string.margin_xs') });
        Text('首页')
          .fontSize($r('app.string.font_size_10'))
          .fontColor($r('app.color.font_color_level2'));
      }
      .width(40)
      .onClick(() => {
        this.vm.backToHome();
      });

      CommonButton({
        title: '立即购买',
        handleClick: () => {
          this.vm.jumpToPrepayPage();
        },
      });
    }
    .height('auto')
    .padding($r('app.string.padding_l'));
  }
}