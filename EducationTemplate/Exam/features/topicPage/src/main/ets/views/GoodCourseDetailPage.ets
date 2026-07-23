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

import { AppStorageV2, PromptAction } from '@kit.ArkUI';
import {
  OrderInfo,
  OrderState,
  SampleOrderInfo,
  SampleCollectInfo,
  TopTabsBuilder,
  GlobalContextUtils,
  Banner
} from 'commonlib';
import { RouterMap, RouterModule } from 'commonlib';
import { MyDataSource, GoodCourse } from '../viewModel/CourseHomeModel';
import { aggregatedPaymentService, CashierPicker, PaymentType } from 'aggregated_payment';
import { UserInfo } from 'login_info';
import { UtilLog } from '@hw-agconnect/util-log';
import { QQShareData, SharePicker } from 'aggregated_share';

const TAG = '[GoodCourseDetailPage]';

@ComponentV2
export struct GoodCourseDetailPage {
  data: MyDataSource = new MyDataSource([]);
  @Local goodCourse: GoodCourse =
    new GoodCourse('111', false, '一级建造师精华题库中级班', $r('app.media.ic_avatar'), '华为用户',
      '更新时间：2025-04-16',
      '课程简介：适合零基础学习人员使用，配置资料提供下载', '全部科目：13个科目', '有效期限：不限制');
  @Local prop: SampleOrderInfo = AppStorageV2.connect(SampleOrderInfo, () => new SampleOrderInfo())!;
  @Local propCollect: SampleCollectInfo = AppStorageV2.connect(SampleCollectInfo, () => new SampleCollectInfo())!;
  @Local logoUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
  @Local orderState: OrderState = OrderState.WaitToPay;
  courseName: string = '';
  uiContext: UIContext = this.getUIContext();
  promptAction: PromptAction = this.uiContext.getPromptAction();
  cashierPicker: CashierPicker = new CashierPicker(this.uiContext)
    .onRealPayment(async (type: PaymentType) => {
      // mock场景
      this.cashierPicker.close();

      if (type === PaymentType.WECHAT) {
        const isWeChatOpenSuccess: boolean =
          await aggregatedPaymentService.requestPaymentByWeChat(this.uiContext, {
            partnerId: '',
            prepayId: '',
            nonceStr: '',
            timeStamp: '',
            sign: ''
          });
        this.payFailed();
      } else if (type === PaymentType.ALIPAY) {
        // 以 Mock 数据测试时，不推荐 orderInfo 使用空字符串，会导致跳转行为仅仅是跳转，无法在支付宝中触发相关交互
        this.paySuccess();
        aggregatedPaymentService.requestPaymentByAliPay({ orderInfo: 'ORDER_INFO' }, RouterModule.stack);
      } else if (type === PaymentType.HUAWEI) {
        this.paySuccess();
        aggregatedPaymentService.requestPaymentByHuawei(this.uiContext, { orderStr: '' });
      }
    })
    .onWillDismiss(() => {
      this.cashierPicker.close();
    });

  aboutToAppear(): void {
    aggregatedPaymentService.registerPaymentCallback((type: PaymentType, isSuccess: boolean) => {
      UtilLog.info(type,isSuccess);
    });
    let list: string[] = [];
    list.push('app.media.ic_questionDetail_banner');
    list.push('app.media.ic_questionDetail_banner');
    list.push('app.media.ic_questionDetail_banner');
    list.push('app.media.ic_questionDetail_banner');
    list.push('app.media.ic_questionDetail_banner');
    this.data = new MyDataSource(list);
    // 获取科目名称
    let temp: OrderInfo | string | undefined = RouterModule.getNavParam({ url: RouterMap.GOOD_COURSE_DETAIL_PAGE });
    if (temp) {
      if (temp instanceof OrderInfo) {
        this.courseName = temp.content;
        this.goodCourse.id = temp.id;
        UtilLog.debug(TAG, 'prop111', JSON.stringify(this.prop.orderInfos[0]?.orderState ?? 0))
        if(this.prop.orderInfos.length) {
          const matchedOrder = this.prop.orderInfos.find((item) => item.id === this.goodCourse.id);
          this.orderState = matchedOrder ? matchedOrder.orderState : 0;
        }
      } else {
        this.courseName = temp;
      }
    }
    //匹配收藏课程 的ID 是否收藏
    this.propCollect.orderInfos.forEach((it: OrderInfo) => {
      if (it.id === this.goodCourse.id) {
        this.goodCourse.isCollect = true;
      }
    });
  }

  @Builder
  topBuilder() {
    Row() {
      Row() {
        Row() {
          Image($r('app.media.ic_back'))
            .width($r('app.float.vp_40'))
            .height($r('app.float.vp_40'))
            .borderRadius($r('app.float.vp_20'))
            .margin({ right: 10 })
            .onClick(() => {
              RouterModule.pop();
            });
        };
      }.justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center);

      Row() {
        Image($r('app.media.icon_search'))
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .margin({ right: $r('app.float.vp_10') });
        Image($r('app.media.ic_more')).width($r('app.float.vp_40')).height($r('app.float.vp_40'));
      }.justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center);
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .padding({ left: 16, right: 16 })
    .height(56)
    .backgroundColor($r('sys.color.comp_background_primary'));
  }

  @Builder
  swiperBuilder() {
    Banner();
  }

  @Builder
  subjectBuilder() {
    Column() {
      Text(this.courseName !== '' ? this.courseName : this.goodCourse.title)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: $r('app.float.vp_25') });
      Row() {
        Image(this.goodCourse.icon)
          .width($r('app.float.vp_40'))
          .height($r('app.float.vp_40'))
          .margin({ right: $r('app.float.vp_4') });
        Column() {
          Text(this.goodCourse.name).fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Subtitle_L'))
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: $r('app.float.vp_4') });
          Text(this.goodCourse.time).fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Body_S'))
            .fontWeight(FontWeight.Regular)
            .margin({ bottom: $r('app.float.vp_16') });
        }.alignItems(HorizontalAlign.Start);
      }.width('100%').justifyContent(FlexAlign.Start).alignItems(VerticalAlign.Top);

      Text(this.goodCourse.introduction)
        .fontColor($r('sys.color.font_secondary'))
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
        .width('100%')
        .fontSize($r('sys.float.Body_S'))
        .fontWeight(FontWeight.Regular)
        .margin({ top: $r('app.float.vp_12') });
      Text(this.goodCourse.allSubject)
        .fontColor($r('sys.color.font_secondary'))
        .width('100%')
        .fontSize($r('sys.float.Body_S'))
        .fontWeight(FontWeight.Regular)
        .margin({ top: $r('app.float.vp_2'), bottom: $r('app.float.vp_2') });
      Text(this.goodCourse.effectTime).fontColor($r('sys.color.font_secondary'))
        .width('100%')
        .fontSize($r('sys.float.Body_S'))
        .fontWeight(FontWeight.Regular);
    }
    .width('100%')
    .padding($r('app.float.vp_12'))
    .margin({ top: $r('app.float.vp_12') })
    .borderRadius($r('app.float.vp_16'))
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start);
  }

  @Builder
  selectBuilder() {
    Row() {
      Row() {
        Column() {
          Image($r('app.media.ic_share'))
            .width($r('app.float.vp_20'))
            .height($r('app.float.vp_20'))
            .margin({ bottom: $r('app.float.vp_2') });
          Text('分享')
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Caption_M'))
            .fontWeight(FontWeight.Medium);
        }
        .width($r('app.float.vp_30'))
        .height($r('app.float.vp_30'))
        .margin({ right: $r('app.float.vp_6') })
        .onClick(() => {
          const picker: SharePicker = new SharePicker({
            title: this.courseName !== '' ? this.courseName : this.goodCourse.title,
            subTitle: this.courseName !== '' ? this.courseName : this.goodCourse.title,
            coverUrl: this.goodCourse.icon,
            createTime: new Date().getTime(),
            thumbUrl: '', // 实际需要传入url(png)，例：https://agc-storage-drcn.platform.dbankcloud.cn/v0/template-thwjd/commonwidget%2Fexample960x720.png
            landingPageUrl: '', // 二维码生成,例：https://www.xxxxxx.com/exam?action=examList
          });

          picker.setSignQQShareDataCB((shareJson: string) => {
            const signData = new QQShareData();
            signData.shareJson = shareJson;
            signData.timestamp = Date.parse(new Date().toString()) / 1000;
            signData.nonce = 62695688; // 随机自然数
            signData.shareJsonSign = 'Hsvqs0IpjiN6DfFfhboGp+r3XzQ='; // 签名串，需要使用HMAC-SHA1 加密后，自己通过 Base64 编码得到
            return Promise.resolve(signData);
          })

          picker.show(this.getUIContext(), {
            autoClose: true,
          });
        });

        Column() {
          Image(this.goodCourse.isCollect ? $r('app.media.ic_star') : $r('app.media.icon_star'))
            .width($r('app.float.vp_20'))
            .height($r('app.float.vp_20'))
            .margin({ bottom: $r('app.float.vp_4') });
          Text('收藏')
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Caption_M'))
            .fontWeight(FontWeight.Medium);
        }
        .width($r('app.float.vp_30'))
        .height($r('app.float.vp_30'))
        .onClick(() => {
          if (!this.logoUser.isLogin) {
            RouterModule.push({ url: RouterMap.LOGIN_PAGE });
            return;
          }
          this.goodCourse.isCollect = !this.goodCourse.isCollect;
          // 如果未收藏 加入收藏
          if (this.goodCourse.isCollect) {
            let orderNo = '202506' + Date.now();
            let content = this.courseName;
            let orderInfo =
              new OrderInfo(this.goodCourse.id, this.goodCourse.isCollect, OrderState.All, orderNo, content,
                false, false);
            this.propCollect.orderInfos.unshift(orderInfo);
            GlobalContextUtils.showToast({ message: '收藏成功' });
          } else {
            this.propCollect.orderInfos = this.propCollect.orderInfos.filter((it: OrderInfo) => {
              return it.id !== this.goodCourse.id;
            });
            GlobalContextUtils.showToast({ message: '取消收藏' });
          }
        });
      }.justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center);
      Text(this.orderState === 0 ? '￥288 立即购买' : '去学习')//this.goodCourse.isPay
        .padding({
          left: $r('app.float.vp_20'),
          right: $r('app.float.vp_20'),
          top: $r('app.float.vp_8'),
          bottom: $r('app.float.vp_8')
        })
        .width('70%')
        .textAlign(TextAlign.Center)
        .borderRadius($r('app.float.vp_20'))
        .fontColor($r('sys.color.font_on_primary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .backgroundColor('rgb(232, 64, 38)')
        .onClick(() => {
          if(this.orderState !==0) {
            // 跳转我的课程详情页
            RouterModule.push({ url: RouterMap.COURSE_INTRODUCTION_PAGE });
          } else {
            if (this.logoUser.isLogin) {
              this.cashierPicker
                .reset()
                .setAmount(28800)
                .setTradeSummary('精华题库中级班')
                .open();
            } else {
              RouterModule.push({ url: RouterMap.LOGIN_PAGE });
            }
          }
        });
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .padding({
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16'),
      top: $r('app.float.vp_6'),
      bottom: $r('app.float.vp_6')
    })
    .width('100%')
    .height($r('app.float.vp_56'))
    .backgroundColor($r('sys.color.comp_background_primary'));
  }

  // 课程详情
  @Builder
  courseDetailsBuilder() {
    Row() {
      Text('课程详情')
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Medium);
    }.width('100%')
    .padding({ top: $r('app.float.vp_16'), bottom: $r('app.float.vp_16') })
    .justifyContent(FlexAlign.Center);

    // 课程详情图片
    Image($r('app.media.icon_courseDetail'))
      .interpolation(ImageInterpolation.High)
      .width('100%')
      .objectFit(ImageFit.Cover)
      .margin({ bottom: $r('app.float.vp_16') });
  }

  paySuccess() {
    let sampleOrderInfo = AppStorageV2.connect(SampleOrderInfo, () => new SampleOrderInfo())!;
    let orderNo = '202506' + Date.now();
    let content = this.courseName;
    let orderInfo =
      new OrderInfo(this.goodCourse.id, this.goodCourse.isCollect, OrderState.Paid, orderNo, content, false, true);
    sampleOrderInfo.orderInfos.unshift(orderInfo);
    GlobalContextUtils.showToast({ message: '支付成功' });
    RouterModule.pop();
  }

  payFailed() {
    let sampleOrderInfo = AppStorageV2.connect(SampleOrderInfo, () => new SampleOrderInfo())!;
    let orderNo = '202506' + Date.now();
    let content = this.courseName;
    let orderInfo =
      new OrderInfo(this.goodCourse.id, this.goodCourse.isCollect, OrderState.WaitToPay, orderNo, content, false, true);
    orderInfo.startTime =  Date.now()
    sampleOrderInfo.orderInfos.unshift(orderInfo);
    GlobalContextUtils.showToast({ message: '支付失败' });
    RouterModule.pop();
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Column }) {
        // 标题
        TopTabsBuilder({ bgColor: $r('sys.color.comp_background_primary'), showBackButton: true })
          .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), bottom: $r('app.float.vp_12') });
        // 滚动详情页
        Scroll() {
          Column() {
            // banner
            this.swiperBuilder();
            // 科目
            this.subjectBuilder();
            // 课程详情
            this.courseDetailsBuilder();
          }
          .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), top: $r('app.float.vp_12') })
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Start);
        }
        .backgroundColor($r('sys.color.background_secondary'))
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Vertical)
        .edgeEffect(EdgeEffect.Spring);

        // 收藏分享、支付
        this.selectBuilder();
      };
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.comp_background_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM]);
  }
}

@Builder
export function GoodCourseDetailBuilder() {
  GoodCourseDetailPage();
}