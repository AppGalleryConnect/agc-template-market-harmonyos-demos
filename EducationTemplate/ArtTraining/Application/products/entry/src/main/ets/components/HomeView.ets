import { CourseTypeMap } from 'commonlib';
import { CommonBanner, ContainerRow, CourseList, StoreMap } from 'componentlib';
import { MAIN_SERVICE_LIST } from '../constants/Constants';
import { StoreInfoTypeMap } from '../constants/Enums';
import { MainServiceItem } from '../types/Types';
import { HomeVM } from '../viewmodels/HomeVM';

@ComponentV2
export struct HomeView {
  vm: HomeVM = HomeVM.instance;

  aboutToAppear(): void {
    this.vm.initHomePage();
  }

  build() {
    Scroll() {
      Column() {
        // 顶部轮播
        CommonBanner({
          coverRatio: 3 / 2,
          covers: this.vm.banners,
        });
        // 核心服务
        this.mainServiceBuilder();
        // 直播课程
        this.onlineCoursesBuilder();
        // 热门课程
        this.popularCoursesBuilder();
        // 线下门店
        this.offlineStoreBuilder();
      }
      .layoutWeight(1);
    }
    .height($r('app.string.height_percent_full'))
    .width($r('app.string.width_percent_full'))
    .backgroundColor($r('app.color.system_color_background_auxiliary'))
    .padding({ bottom: $r('app.string.padding_l') })
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Off)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
  }

  @Builder
  mainServiceBuilder() {
    Column() {
      ContainerRow() {
        ForEach(MAIN_SERVICE_LIST, (item: MainServiceItem) => {
          Column() {
            Image(item.icon)
              .width(50)
              .height(50)
              .margin({ bottom: $r('app.string.margin_xs') });
            Text(item.label)
              .fontColor($r('app.color.font_color_level2'))
              .fontSize($r('app.string.font_size_12'));
          }
          .width($r('app.string.width_percent_25'))
          .onClick(() => {
            this.vm.jumpToMainService(item.type);
          });
        }, (item: MainServiceItem) => item.label);
      };
    }
    .padding({ left: $r('app.string.padding_l'), right: $r('app.string.padding_l') })
    .margin({ top: $r('app.string.margin_l') });
  }

  @Builder
  onlineCoursesBuilder() {
    this.titleBarBuilder('直播课程', true, CourseTypeMap.ONLINE);
    CourseList({
      coursesList: this.vm.onlineList,
      showTag: false,
      isVertical: false,
      handleClick: (course) => {
        this.vm.handleClickCourseCard(course);
      },
    });

  }

  @Builder
  popularCoursesBuilder() {
    this.titleBarBuilder('热门课程');
    Column() {
      CourseList({
        coursesList: this.vm.offlineList,
        handleClick: (course) => {
          this.vm.handleClickCourseCard(course);
        },
      });
    }
    .padding({ left: $r('app.string.padding_l'), right: $r('app.string.padding_l') });
  }

  @Builder
  offlineStoreBuilder() {
    this.titleBarBuilder('线下门店', false);
    if (this.vm.storeInfo) {
      Column() {
        Row() {
          StoreMap({
            storeInfo: this.vm.storeInfo,
          });
        }
        .borderRadius($r('app.string.border_radius_16'))
        .clip(true);

        Row() {
          Column() {
            Text(this.vm.storeInfo.shopName)
              .fontColor($r('app.color.font_color_level1'))
              .fontSize($r('app.string.font_size_14'))
              .fontWeight(500)
              .margin({ bottom: $r('app.string.margin_s') });
            this.shopInfoItemBuilder($r('app.media.ic_location'), this.vm.storeInfo.address, StoreInfoTypeMap.LOCATION);
            this.shopInfoItemBuilder($r('app.media.ic_tel'), this.vm.storeInfo.phoneNumber, StoreInfoTypeMap.PHONE);
            this.shopInfoItemBuilder($r('app.media.ic_mail'), this.vm.storeInfo.email, StoreInfoTypeMap.EMAIL, false);

          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start);
        }
        .alignItems(VerticalAlign.Top)
        .width($r('app.string.width_percent_full'))
        .margin({ top: $r('app.string.margin_l') })
        .padding($r('app.string.padding_l'))
        .backgroundColor($r('app.color.system_color_background_white'))
        .borderRadius($r('app.string.border_radius_16'));
      }
      .padding({ left: $r('app.string.padding_l'), right: $r('app.string.padding_l') });
    }
  }

  @Builder
  titleBarBuilder(title: string, showMore: boolean = true, type: CourseTypeMap = CourseTypeMap.ALL) {
    Row() {
      Text(title)
        .fontColor($r('app.color.font_color_level1'))
        .fontSize($r('app.string.font_size_18'))
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1);
      if (showMore) {
        Row() {
          Text('更多')
            .fontColor($r('app.color.font_color_level2'))
            .fontSize($r('app.string.font_size_12'));
          Image($r('app.media.ic_arrow_right'))
            .width($r('app.integer.icon_size_16'))
            .fillColor($r('app.color.font_color_level2'));
        }
        .onClick(() => {
          this.vm.jumpToCourseCenter(type);
        });
      }
    }
    .width($r('app.string.width_percent_full'))
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: $r('app.string.padding_l'),
      right: $r('app.string.padding_l'),
    })
    .margin({
      top: $r('app.string.margin_m'),
      bottom: $r('app.string.margin_s'),
    });
  }

  @Builder
  shopInfoItemBuilder(icon: ResourceStr, content: string, type: StoreInfoTypeMap, showMore: boolean = true) {
    Row() {
      Image(icon)
        .width(12)
        .height(12)
        .fillColor($r('app.color.icon_color_level2'))
        .margin({ right: $r('app.string.margin_xs') });
      Text(content)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontSize($r('app.string.font_size_12'))
        .fontColor($r('app.color.font_color_level2'))
        .layoutWeight(1);
      if (showMore) {
        Image($r('app.media.ic_arrow_right'))
          .width(12)
          .height(12)
          .onClick(() => {
            this.vm.handleClickStoreInfo(type);
          });
      }

    }
    .margin({
      top: $r('app.string.margin_s'),
      bottom: $r('app.string.margin_s'),
    });
  }
}