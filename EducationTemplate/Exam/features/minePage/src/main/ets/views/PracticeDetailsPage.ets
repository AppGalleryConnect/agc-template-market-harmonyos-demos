import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { PracticeModel, PracticeRecordModel, RouterModule, TopBar, PRACTICE_RECORD_DATA, Logger,
  SystemBarOperation } from 'commonlib';
import dayjs from 'dayjs';
import { MainArea } from '../components/MainArea';

@Builder
export function PracticeDetailsBuilder() {
  PracticeDetailsPage();
}

@Entry
@ComponentV2
struct PracticeDetailsPage {
    private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Left | PanDirection.Right });
    @Provider('offset') offsetX: number | undefined = undefined;
    @Local practiceRecordModels: PracticeRecordModel[] = [];
    practiceModels: PracticeModel[] = [];
    // 默认时间降序
    @Local descOrder: boolean = true;

  aboutToAppear(): void {
    SystemBarOperation.setWindowSystemBarProp({
      statusBarColor: '#ffffff',
    })
    // 练习记录测试数据
    this.practiceModels = PRACTICE_RECORD_DATA;
    this.initData();
  }

     /**
      * 初始化数据
      */
    initData() {
      for (let index = 0; index < 30; index++) {
        let record: PracticeRecordModel = new PracticeRecordModel();
        let date: string = dayjs('2025/5/29').subtract(index, 'day').format('YYYY-MM-DD');
        let practiceDuration: number = 0;
        let rightCount: number = 0;
        let topicCount: number = 0;
        let practiceCount: number = 0;
        let onDayPracticeModels: PracticeModel[] = [];
        this.practiceModels.forEach((item: PracticeModel) => {
          if (date === item.date) {
            practiceDuration += item.practiceDuration;
            rightCount += item.rightCount;
            topicCount += item.topicCount;
            practiceCount++;
            onDayPracticeModels.push(item);
          }
        });
        record.date = date;
        let h = Math.floor(practiceDuration / 3600) < 10 ? '0' + Math.floor(practiceDuration / 3600) :
          Math.floor(practiceDuration / 3600);
        let m = Math.floor(practiceDuration % 3600 / 60) < 10 ? '0' + Math.floor(practiceDuration % 3600 / 60) :
          Math.floor(practiceDuration % 3600 / 60);
        let s = (practiceDuration % 60) < 10 ? '0' + (practiceDuration % 60) : (practiceDuration % 60);
        if (practiceCount > 0) {
          record.practiceDuration = h + ':' + m + ':' + s;
          record.practiceCount = practiceCount.toString();
          record.correctRate = (rightCount / topicCount * 100).toFixed(2) + '%';
          record.practiceModels = onDayPracticeModels;
          record.wrongCount = (topicCount - rightCount).toString();
          record.totalCount = topicCount.toString();
        }
        this.practiceRecordModels.push(record);
      }
    }

    /**
     * 顶部
     */
    @Builder
    topBuilder() {
      Row() {
        // 练习明细
        TopBar({
          onClickBack: () => {
            RouterModule.pop();
          },
          title: $r('app.string.practice_details')
        });
      }
      .width('100%')
      .height($r('app.float.vp_56'))
      .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') });
    }

    @Builder
    timeBuilder() {
      Row() {
        Row() {
          Text($r('app.string.time'))
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_on_primary'))
            .fontWeight(FontWeight.Medium)
            .margin({ left: $r('app.float.vp_8') });
          Image($r('app.media.arrow_bottom_filled'))
            .width($r('app.float.vp_20'))
            .height($r('app.float.vp_20'))
            .rotate({ angle: this.descOrder ? 0 : 180 });
        }
        .width($r('app.float.vp_58'))
        .height($r('app.float.vp_28'))
        .backgroundColor($r('app.color.time_btn'))
        .borderRadius(8)
        .onClick(() => {
          this.descOrder = !this.descOrder;
          if (this.descOrder) {
            this.practiceRecordModels.sort((a, b) => dayjs(b.date).valueOf() - dayjs(a.date).valueOf());
          } else {
            this.practiceRecordModels.sort((a, b) => dayjs(a.date).valueOf() - dayjs(b.date).valueOf());
          }
        });

        Text($r('app.string.recent_30_days_practice'))
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_secondary'));
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: $r('app.float.vp_12'), bottom: $r('app.float.vp_12') })
      .padding({left: 16, right: 16})
    }

    build() {
        Column() {
          // 顶部
          this.topBuilder();
          Divider().color($r('sys.color.comp_divider'));
          // 时间
          this.timeBuilder();
          Column() {
            // 明细表
            MainArea({ practiceRecordModels: this.practiceRecordModels });
          }
          .layoutWeight(1)
          .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
            .gesture(
              // 用于触发拖动手势事件，滑动的最小距离为5vp时拖动手势识别成功。
              PanGesture(this.panOption).onActionStart((event?: GestureEvent) => {
                this.offsetX = event?.offsetX;
                Logger.info('gesture11: PanGesture start' + event?.offsetX);
              })
            )
        }
        .width('100%')
        .height('100%')
        .backgroundColor($r('sys.color.comp_background_primary'))
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}


@Extend(Text)
function textStyles() {
  .width($r('app.float.vp_70'))
  .textAlign(TextAlign.Center)
  .fontSize($r('sys.float.Caption_L'))
  .fontWeight(FontWeight.Regular)
  .fontColor($r('sys.color.font_secondary'));
}

@Extend(Text)
function titleStyles() {
  .width($r('app.float.vp_70'))
  .textAlign(TextAlign.Center)
  .fontSize(14)
  .fontWeight(FontWeight.Regular)
  .fontColor('rgba(0, 0, 0, 0.9)')
  .height(40)
}