/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { AppStorageV2 } from '@kit.ArkUI';
import { SampleOrderInfo, OrderInfo, OrderState, Banner, BreakpointType } from 'commonlib';
import { RouterMap, RouterModule } from 'commonlib';
import { MyDataSource, Sample } from '../viewModel/CourseHomeModel';
import { UserInfo } from 'login_info';
import { TopicVM } from '../viewModel/TopicVM';
import { TopTabsBuilder } from '../components/TopTabsBuilder';

// 精选课程卡片组件
@ComponentV2
export struct CourseComponent {
  @Param @Require course: OrderInfo;
  @Param @Require isGoodCourse: boolean;

  build() {
    Column() {
      // 课程专家
      this.expertBuilder();
      // 课程详情
      this.courseDetailBuilder();
    }
    .borderRadius(16)
    .padding({ top: $r('app.float.vp_16'), bottom: $r('app.float.vp_16') })
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .height($r('app.float.vp_138'))
    .width('100%');
  }

  /**
   * 课程详情
   */
  @Builder
  courseDetailBuilder() {
    Column() {
      Row() {
        Text(this.course.content)
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium);
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ top: $r('app.float.vp_12'), bottom: $r('app.float.vp_12') });

      Row() {
        Column() {
          Text(`￥${this.course.price}`)
            .fontColor($r('sys.color.multi_color_08'))
            .fontSize($r('sys.float.Title_S'))
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Start)
            .width('100%');
          Text(`已有 ${this.course.buyNumbers}人 购买`)
            .fontColor($r('sys.color.font_tertiary'))
            .fontSize($r('sys.float.Body_S'))
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.Start)
            .width('100%');
        }
        .justifyContent(FlexAlign.Start)
        .width('50%');

        Column() {
          Row() {
            Button(this.course.orderState === 0 ? '查看详情' : '去学习')
              .fontColor($r('sys.color.font_on_primary'))
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .backgroundColor('#4B5CC4')
              .fontWeight(FontWeight.Bold);
          }.width('100%')
          .justifyContent(FlexAlign.End);
        }
        .width('50%')
        .onClick(() => {
          if (this.isGoodCourse) {
            // 跳转 精选好课详情页
            RouterModule.push({ url: RouterMap.GOOD_COURSE_DETAIL_PAGE, param: this.course });
          } else {
            // 跳转我的课程详情页
            RouterModule.push({ url: RouterMap.COURSE_INTRODUCTION_PAGE, param: this.course });
          }
        });
      }
      .height('auto')
      .width('100%');
    }
    .padding({ left: $r('app.float.vp_24'), right: $r('app.float.vp_24') })
    .width('100%');
  }

  /**
   * 课程专家
   */
  @Builder
  expertBuilder() {
    Row() {
      Image($r('app.media.ic_avatar'))
        .height($r('app.float.vp_24'))
        .width($r('app.float.vp_24'))
        .margin({ right: $r('app.float.vp_12') });
      Text('华为用户')
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Regular);
    }
    .padding({ left: $r('app.float.vp_12') })
    .height($r('app.float.vp_24'))
    .width('100%');
  }
}

@ComponentV2
export struct CourseHomePage {
  topicVM: TopicVM = TopicVM.instance;
  @Local isGoodCourse: boolean = true;
  @Local goodCourse: OrderInfo[] =
    [new OrderInfo('111', false, OrderState.WaitToPay, '20231010152332345', '一级建造师精华题库中级班', false, false),
      new OrderInfo('222', false, OrderState.WaitToPay, '20231010152332346', '一级建造师精华题库初级班', false, false),
      new OrderInfo('333', false, OrderState.WaitToPay, '20231010152332347', '一级建造师精华题库高级班', false, false)
    ];
  @Local myCourse: OrderInfo[] = [];
  data: MyDataSource = new MyDataSource([]);
  // 在AppStorageV2中创建一个key为Sample的键值对（如果存在，则返回AppStorageV2中的数据），并且和prop关联
  @Local prop: Sample = AppStorageV2.connect(Sample, () => new Sample())!;
  @Local propOrderInfo: SampleOrderInfo = AppStorageV2.connect(SampleOrderInfo, () => new SampleOrderInfo())!;
  @Local logoUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;

  @Monitor('isGoodCourse')
  onStrChange(monitor: IMonitor) {
    monitor.dirty.forEach((path: string) => {
      if (path === 'isGoodCourse') {
        // 获取订单购买保存的数据
        this.propOrderInfo = AppStorageV2.connect(SampleOrderInfo, () => new SampleOrderInfo())!;
        // 数据初始化  我的课程
        this.myCourse = this.propOrderInfo.orderInfos.filter((item: OrderInfo) => item.orderState === OrderState.Paid);
      }
    });
  }

  aboutToAppear(): void {
    // 数据初始化
    this.dataInitial();
  }

  dataInitial() {
    let list: string[] = [];
    list.push('app.media.ic_questionDetail_banner');
    list.push('app.media.ic_questionDetail_banner');
    list.push('app.media.ic_questionDetail_banner');
    list.push('app.media.ic_questionDetail_banner');
    this.data = new MyDataSource(list);
    // 获取存储在AppStorageV2中创建一个key为Sample的数据）
    this.prop = AppStorageV2.connect(Sample, 'Sample', () => new Sample())!;
    // 获取订单购买保存的数据
    this.propOrderInfo = AppStorageV2.connect(SampleOrderInfo, () => new SampleOrderInfo())!;
    // 数据初始化  我的课程
    this.myCourse = this.propOrderInfo.orderInfos.filter((item: OrderInfo) => item.orderState === OrderState.Paid);
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Column }) {
        // 课程首页 标题组件
        TopTabsBuilder({ title: '练习', type: this.prop.title });
        Scroll() {
          Column() {
            // 轮播图
            this.swiperBuilder();
            // 精选好课、我的课程 标题
            this.tabBuilder();
            // 精选好课、我的课程 列表
            this.courseListBuilder();
            Blank()
              .layoutWeight(1);
          }
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Center);
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .layoutWeight(1);
      }
      .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), })
      .backgroundColor($r('sys.color.background_secondary'));
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_primary'))
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }

  /**
   * 精选好课、我的课程 列表
   */
  @Builder
  courseListBuilder() {
    Grid() {
      ForEach(this.isGoodCourse ? this.goodCourse : this.myCourse, (item: OrderInfo) => {
        GridItem() {
          CourseComponent({ course: item, isGoodCourse: this.isGoodCourse })
            .margin({ bottom: 8 });
        };
      }, (item: OrderInfo, index: number) => item.orderNo + index);
    }
    .columnsTemplate('1fr '.repeat(new BreakpointType<number>({
      sm: 1,
      md: 2,
      lg: 3,
      xl: 3
    }).getValue(this.topicVM.breakPointModel.currentBreakpoint)))
    .columnsGap($r('app.float.vp_6'))
    .rowsGap($r('app.float.vp_6'))
    .borderRadius($r('app.float.vp_16'));

    // 更多精选按钮
    this.moreFeaturedBuilder();
    // 未购买  暂无我的课程
    this.noCourseBuilder();
  }

  /**
   * 更多精选按钮
   */
  @Builder
  moreFeaturedBuilder() {
    Row() {
      Row() {
        Text('更多精选')
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium);
        Image($r('app.media.icon_right')).width($r('app.float.vp_14')).height($r('app.float.vp_14'));
      }
      .padding({
        left: $r('app.float.vp_8'),
        right: $r('app.float.vp_8'),
        top: $r('app.float.vp_4'),
        bottom: $r('app.float.vp_4')
      })
      .width($r('app.float.vp_92'))
      .height($r('app.float.vp_30'))
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .borderRadius(14)
      .backgroundColor($r('sys.color.comp_background_tertiary'));
    }
    .width('100%')
    .margin({ top: $r('app.float.vp_4'), bottom: $r('app.float.vp_12') })
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .visibility(this.isGoodCourse ? Visibility.Visible : Visibility.None)
    .onClick(() => {
      // 跳转 更多精选好课
      RouterModule.push({ url: RouterMap.FEATURE_COURSE_PAGE });
    });
  }

  /**
   * 未购买  暂无我的课程
   */
  @Builder
  noCourseBuilder() {
    Column() {
      Text('暂无课程')
        .width('100%')
        .height('100%')
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center);
    }
    .width('100%')
    .height(200)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .visibility(!this.isGoodCourse && this.myCourse.length <= 0 ? Visibility.Visible : Visibility.None);
  }

  /**
   * 精选好课、我的课程 标题
   */
  @Builder
  tabBuilder() {
    Row() {
      Text('精选好课')
        .width('50%')
        .height('100%')
        .textAlign(TextAlign.Center)
        .backgroundColor(this.isGoodCourse ? $r('sys.color.comp_background_primary_contrary_secondary')
          : Color.Transparent)
        .opacity(this.isGoodCourse ? 1 : 0.7)
        .borderRadius(this.isGoodCourse ? 20 : 0)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          this.isGoodCourse = true;
        });
      Text('我的课程')
        .width('50%')
        .height('100%')
        .textAlign(TextAlign.Center)
        .backgroundColor(this.isGoodCourse ? Color.Transparent
          : $r('sys.color.comp_background_primary_contrary_secondary'))
        .opacity(this.isGoodCourse ? 0.7 : 1)
        .borderRadius(this.isGoodCourse ? 0 : 20)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_M'))
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          if (!this.logoUser.isLogin) {
            RouterModule.push({ url: RouterMap.LOGIN_PAGE, param: false });
            return;
          }
          this.isGoodCourse = false;
        });
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .width('70%')
    .height($r('app.float.vp_36'))
    .borderRadius(20)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .margin({ top: $r('app.float.vp_16'), bottom: $r('app.float.vp_16') });
  }

  /**
   * 轮播图
   */
  @Builder
  swiperBuilder() {
    Banner();
  }
}

@Builder
export function CourseHomePageBuilder() {
  CourseHomePage();
}
