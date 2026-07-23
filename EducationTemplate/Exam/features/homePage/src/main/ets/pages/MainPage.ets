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
import {
  PreferenceUtil,
  PreferConstant,
  GlobalContextUtils,
  Banner,
  BreakpointType
} from 'commonlib';
import { PracticeDataSource, PRACTICE_LIST_DATA, PracticeView } from '../model/PracticeMode';
import { CourseQuestions } from '../model/CourseQuestions';
import { RouterMap, RouterModule, CommonConstants } from 'commonlib';
import { Sample } from '../model/Course';
import { QuestionsRouterModel } from 'answer_questions';
import { TopicItemType } from 'answer_questions';
import { UserInfo } from 'login_info';
import { HomeVM } from '../viewmodels/HomeVM';
import { FinishStatus, MemberList, MemberParams,
  MemberSheetUtils,
  MemberStatusUtil, ProductsInfoOptions } from 'membership';
import { common } from '@kit.AbilityKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { TopTabsBuilder } from '../components/TopTabsBuilder';
import { iap } from '@kit.IAPKit';

@ComponentV2
export struct HomePage {
  homeVM: HomeVM = HomeVM.instance;
  private listData: PracticeView[] = PRACTICE_LIST_DATA;
  private dataSource: PracticeDataSource = new PracticeDataSource(this.listData);
  // 核心功能图标数组
  @Local functions: CourseCoreBar[] = [new CourseCoreBar($r('app.media.ic_practice_camera'), '搜题'),
    new CourseCoreBar($r('app.media.ic__practice_wrong_question')
      , '错题'), new CourseCoreBar($r('app.media.ic_practice_star'), '收藏'),
    new CourseCoreBar($r('app.media.ic_practice_notes'), '笔记')];
  // 核心功能图标数组
  @Local coursePractice: CourseQuestions[] =
    [new CourseQuestions('建筑工程经济', 120, 300), new CourseQuestions('建筑工程项目管理', 1024, 3411),
      new CourseQuestions('建筑工程项目管理', 1024, 3411)];
  // 在AppStorageV2中创建一个key为Sample的键值对（如果存在，则返回AppStorageV2中的数据），并且和prop关联
  @Local prop: Sample = AppStorageV2.connect(Sample, () => new Sample())!;
  @Local logoUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
  @Local lastPurchaseProductExpireTime: string = '';

  subscribeEvent = async (params: MemberParams): Promise<void> => {
    this.getUIContext().getPromptAction().showToast({ message: this.getSubscribeMsg(params) });
    if (params.type === iap.ProductType.NONRENEWABLE && params.status === FinishStatus.FINISHED) {
      this.queryExpireTime(params.productId, params.purchaseTime);
    }
  };
  ownedMemberEvent = async (list: MemberList): Promise<void> => {
    const isMembership = list.renewList.length > 0 || list.nonRenewList.length > 0;
    this.logoUser.isMembership = isMembership;
  };
  queryExpireTime = (productId: string, time?: number): Promise<string> => {
    // 请求开发者服务器获取非周期订阅商品到期时间（涉及商品id、购买次数）
    return new Promise((resolve, reject) => {
      this.lastPurchaseProductExpireTime = 'xxxx-xx-xx';
      resolve(this.lastPurchaseProductExpireTime)
    });
  };

  getSubscribeMsg(param: MemberParams) {
    let message = '';
    if (param.status === FinishStatus.FINISHED) {
      message = '会员订阅成功';
      this.logoUser.isMembership = true;
    } else if (param.status === FinishStatus.UNFINISHED) {
      message = `会员订阅失败，订阅错误码为${param.errCode}，错误原因为${param.errMsg}`;
    }
    return message;
  }

  productsInfo: ProductsInfoOptions = {
    isSheet: true,
    themeColor: '#E39331',
    // todo: 请先在resources目录下的base/element/color.json和dark/element/color.json文件中定义深浅模式下的不同渐变色值
    linearColors: [['#F8E6CE', 0.5], ['#E39331', 1.0]],
    btnFontColor: '#FFFFFF',
    // todo: 替换为您配置的商品ID及对应的权益
    productsInfo: [{
      type: iap?.ProductType.AUTORENEWABLE,
      productId: 'F0001',
      privileges: [
        {
          id: 'privilege_1',
          icon: $r('app.media.privilege'),
          title: '全真试卷无限使用',
          des: '直击考试真题',
        },
      ],
      privacyName: '连续包周服务协议',
      privacyContent: CommonConstants.MEMBERSHIP_CONTENT,
    },
      {
        type: iap?.ProductType.NONRENEWABLE,
        productId: 'F0002',
        privileges: [
          {
            id: 'privilege_1',
            icon: $r('app.media.privilege'),
            title: '全真试卷无限使用',
            des: '直击考试真题',
          },
        ],
      },],
    privacyContent: CommonConstants.PRIVACY_CONTENT,
    lastPurchaseProductExpireTime: '',
    subscribeCallBack: this.subscribeEvent,
    queryExpireTime: this.queryExpireTime,
    ownedMemberCallBack: this.ownedMemberEvent,
  };

  aboutToAppear(): void {
    // 获取存储在AppStorageV2中创建一个key为Sample的数据）
    this.prop = AppStorageV2.connect(Sample, 'Sample', () => new Sample())!;
  }

  queryMemberStatus() {
    if(this.logoUser.isLogin) {
      MemberStatusUtil.queryPurchase(this.getUIContext().getHostContext() as common.UIAbilityContext).then((res) => {
        let autoRenewPurchasedList = res.renewList;
        let nonAutoRenewPurchasedList = res.nonRenewList;

        if (autoRenewPurchasedList?.length || nonAutoRenewPurchasedList?.length) {
          this.logoUser.isMembership = true;
        } else {
          this.logoUser.isMembership = false;
          MemberSheetUtils.open(this.productsInfo, this.getUIContext());
        }
      }).catch((err: BusinessError) => {
        UtilLog.error(0xFF00, 'MemberShip',
          `Failed to query purchase record. Code is ${err.code}, message is ${err.message}`);
      });
    } else {
      this.logoUser.isMembership = false;
    }
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Column }) {
        TopTabsBuilder({ title: '练习', type: this.prop.title });
        Scroll() {
          Column({ space: 10 }) {
            // 轮播图
            this.swiperBuilder();
            // 功能栏
            this.functionBarBuilder();
            Column() {
              // 练习模式
              this.practiceModeBuilder();
              // 科目练习
              this.subjectPracticeBuilder();
            }
            .margin({ bottom: $r('app.float.vp_12') });

            Blank()
              .layoutWeight(1);
          }
          .justifyContent(FlexAlign.Center);
        }
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Vertical)
        .edgeEffect(EdgeEffect.Spring)
        .layoutWeight(1);
      };
    }
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('sys.color.background_secondary'))
    .width('100%')
    .height('100%');
  }

  /**
   * 科目练习
   */
  @Builder
  subjectPracticeBuilder() {
    Text('科目练习')
      .fontSize($r('sys.float.Subtitle_L'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_primary'))
      .width('100%')
      .textAlign(TextAlign.Start)
      .margin($r('app.float.vp_12'));

    if (!this.logoUser.isLogin) {
      Column() {
        Column() {
          Image($r('app.media.ic_noLogin'))
            .interpolation(ImageInterpolation.High)
            .objectFit(ImageFit.Fill)
            .width($r('app.float.vp_120'))
            .height($r('app.float.vp_120'))
            .clip(true);
          Text('登录后享受更多服务')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_tertiary'))
            .fontWeight(FontWeight.Regular);
        }
        .margin($r('app.float.vp_16'));
      }
      .width('100%')
      .justifyContent(FlexAlign.Center);
    } else {
      Grid() {
        ForEach(this.coursePractice, (item: CourseQuestions) => {
          GridItem() {
            CoursePracticeBuilder(item);
          };
        }, (item: CourseQuestions, index: number) => item.courseName + index);
      }
      .columnsTemplate('1fr '.repeat(new BreakpointType<number>({
        sm: 1,
        md: 2,
        lg: 3,
        xl: 3
      }).getValue(this.homeVM.breakPointModel.currentBreakpoint)))
      .columnsGap($r('app.float.vp_6'))
      .rowsGap($r('app.float.vp_6'))
      .borderRadius($r('app.float.vp_16'));
    }
  }

  /**
   * 练习模式
   */
  @Builder
  practiceModeBuilder() {
    Text('练习模式')
      .fontSize($r('sys.float.Subtitle_L'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_primary'))
      .width('100%')
      .textAlign(TextAlign.Start)
      .margin({ bottom: $r('app.float.vp_12') });
    Grid() {
      LazyForEach(this.dataSource, (practiceItem: PracticeView) => {
        GridItem() {
          ReusableFlowItem({ item: practiceItem });
        }
        .onClick(() => {
          if (!this.logoUser.isLogin) {
            RouterModule.push({ url: RouterMap.LOGIN_PAGE, param: false });
            return;
          }
          if (practiceItem.name === '每日一练') {
            RouterModule.push({ url: RouterMap.ANSWER_QUESTIONS_PAGE });
          } else if (practiceItem.name === '模拟考试') {
            RouterModule.push({ url: RouterMap.Mock_PAGE, param: 1 });
          } else if (practiceItem.name === '全真试卷') {
            if(this.logoUser.isMembership) {
              RouterModule.push({ url: RouterMap.Mock_PAGE, param: 2 });
            } else {
              this.queryMemberStatus();
            }
          } else {
            // 错题练习
            this.myWrongPracticeEvent();
          }
        });
      }, (practiceItem: PracticeView, index: number) => practiceItem.name + index);
    }
    .padding($r('app.float.vp_12'))
    .backgroundColor($r('sys.color.comp_background_primary'))
    .columnsTemplate('1fr '.repeat(new BreakpointType<number>({
      sm: 2,
      md: 4,
      lg: 4,
      xl: 4
    }).getValue(this.homeVM.breakPointModel.currentBreakpoint)))
    .columnsGap($r('app.float.vp_6'))
    .rowsGap($r('app.float.vp_6'))
    .borderRadius($r('app.float.vp_16'));
  }

  /**
   * 功能栏
   */
  @Builder
  functionBarBuilder() {
    Row({ space: 8 }) {
      ForEach(this.functions, (item: CourseCoreBar) => {
        CourseCoreBuilder(item);
      }, (item: CourseCoreBar, index: number) => item.description + index);
    }
    .height($r('app.float.vp_72'))
    .width('100%')
    .borderRadius($r('app.float.vp_16'))
    .backgroundColor($r('sys.color.comp_background_primary'))
    .justifyContent(FlexAlign.SpaceAround);
  }

  /**
   * 轮播图
   */
  @Builder
  swiperBuilder() {
    Banner();
  }

  // 错题练习点击事件
  myWrongPracticeEvent() {
    let arr: TopicItemType[] =
      PreferenceUtil.getInstance().get(PreferConstant.ERROR_RECORDS, []) as TopicItemType[];
    if (arr.length <= 0) {
      GlobalContextUtils.showToast({ message: '无错题数据' });
      return;
    }
    arr.sort((a, b) => b.jlStamp - a.jlStamp);
    let routerModel: QuestionsRouterModel = new QuestionsRouterModel();
    routerModel.sourceType = '错题练习';
    routerModel.datalist = arr;
    RouterModule.push({ url: RouterMap.ANSWER_QUESTIONS_PAGE, param: routerModel });
  }
}

@ComponentV2
struct ReusableFlowItem {
  @Param item: PracticeView = new PracticeView($r('app.media.ic_home'), '顺序练习', '1、3256');

  build() {
    Row() {
      Column() {
        Text(this.item.name)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .fontWeight(FontWeight.Regular)
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_primary'));
        Text(this.item.describe)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .fontSize($r('sys.float.Caption_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
          .margin({ top: $r('app.float.vp_2') });
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1);

      // 存在对应的jpg文件才会显示图片
      Image(this.item.imageUri)
        .interpolation(ImageInterpolation.High)
        .objectFit(ImageFit.Fill)
        .width('32vp')
        .height('32vp')
        .clip(true)
        .margin({ left: $r('app.float.vp_4'), right: $r('app.float.vp_4') });

      if(this.item.name === '全真试卷') {
        Text('VIP')
          .width(32)
          .height(16)
          .fontSize(10)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .borderRadius({
            topLeft: 2,
            topRight: 12,
            bottomRight: 2,
            bottomLeft: 12
          })
          .backgroundColor('#fff9a01e')
          .position({ x: '85%', y: 0 })
      }
    }
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .justifyContent(FlexAlign.SpaceBetween)
    .height($r('app.float.vp_56'))
    .width('100%')
    .padding({ left: $r('app.float.vp_12'), right: $r('app.float.vp_16') })
    .borderRadius($r('app.float.vp_12'));
  }
}

@Builder
export function HomePageBuilder() {
  HomePage();
}

// 核心功能组件builder
@Builder
export function CourseCoreBuilder(mainFunctionItem: CourseCoreBar) {
  Column() {
    Image(mainFunctionItem.showIcon)
      .height($r('app.float.vp_24'))
      .width($r('app.float.vp_24'))
      .margin({ bottom: $r('app.float.vp_2') });
    Text(mainFunctionItem.description)
      .fontSize($r('sys.float.Caption_M'));
  }
  .width(64)
  .height(48)
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
  .onClick(() => {
    let userInfo: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!;
    if (!userInfo.isLogin) {
      RouterModule.push({ url: RouterMap.LOGIN_PAGE, param: false });
      return;
    }
    if (mainFunctionItem.description === '搜题') {
      RouterModule.push({ url: RouterMap.SEARCH_INPUT_PAGE });
    } else if (mainFunctionItem.description === '笔记') {
      RouterModule.push({ url: RouterMap.MY_NOTE_PAGE });
    } else if (mainFunctionItem.description === '错题') {
      RouterModule.push({ url: RouterMap.MY_WRONG_PAGE });
    } else if (mainFunctionItem.description === '收藏') {
      RouterModule.push({ url: RouterMap.MY_COLLECTION_PAGE });
    }
  });
}

// 封装核心功能class
@ObservedV2
export class CourseCoreBar {
  @Trace showIcon: ResourceStr = '';
  @Trace description: string = '';

  constructor(showIcon: ResourceStr, description: string) {
    this.showIcon = showIcon;
    this.description = description;
  }
}

// 核心功能组件builder
@Builder
export function CoursePracticeBuilder(questions: CourseQuestions) {
  Column() {
    Row() {
      Row() {
        Text(questions.courseName)
          .fontSize($r('sys.float.Subtitle_S'))
          .fontWeight(FontWeight.Medium);
      };

      Row() {
        Text('章节练习')
          .fontSize($r('sys.float.Caption_L'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'));
        Image($r('app.media.icon_right'))
          .width($r('app.float.vp_16'))
          .height($r('app.float.vp_16'))
          .margin({ left: $r('app.float.vp_5') });
      }.layoutWeight(1)
      .justifyContent(FlexAlign.End)
      .onClick(() => {
        // 跳转章节练习页面
        RouterModule.push({ url: RouterMap.CHAPTER_PRACTICE_PAGE });
      });
    }
    .margin({ bottom: $r('app.float.vp_11') });

    Row() {
      Text('进度')
        .margin({ right: 8 })
        .fontSize($r('sys.float.Body_S'));
      Text() {
        Span(questions.completeNumber + '')
          .fontColor($r('sys.color.comp_background_emphasize'));
        Span(' / ' + questions.questionsNumber + '');
      }
      .fontSize($r('sys.float.Body_S'));
    }
    .width('100%')
    .margin({ bottom: $r('app.float.vp_10') });

    Row() {
      Progress({ value: questions.completeNumber, total: questions.questionsNumber, type: ProgressType.Linear })
        .color($r('sys.color.comp_background_emphasize'))
        .value(questions.completeNumber)
        .width($r('app.float.vp_266'));
    }
    .width('100%');
  }
  .borderRadius($r('app.float.vp_16'))
  .height($r('app.float.vp_82'))
  .width('100%')
  .padding({
    top: $r('app.float.vp_12'),
    bottom: $r('app.float.vp_10'),
    left: $r('app.float.vp_12'),
    right: $r('app.float.vp_12')
  })
  .backgroundColor($r('sys.color.background_primary'))
  .onClick(() => {
    RouterModule.push({ url: RouterMap.CHAPTER_PRACTICE_PAGE });
  });
}