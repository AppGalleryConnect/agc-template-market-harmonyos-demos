import formProvider from '@ohos.app.form.formProvider';
import sendableColorSpaceManager from '@ohos.graphics.sendableColorSpaceManager';

const PROGRESS:string[] = ['科目一','科目二','科目三','科目四']

@Entry
@Component
struct WidgetCard {
  /*
   * The title.
   */
  readonly title: string = 'Hello World';
  /*
   * The action type.
   */
  readonly actionType: string = 'router';
  /*
   * The ability name.
   */
  readonly abilityName: string = 'EntryAbility';
  /*
   * The message.
   */
  readonly message: string = 'add detail';
  /*
   * The width percentage setting.
   */
  readonly fullWidthPercent: string = '100%';
  /*
   * The height percentage setting.
   */
  readonly fullHeightPercent: string = '100%';
  @LocalStorageProp('index') @Watch('indexChange') index:number = 0;
  @State currentProgress:string = PROGRESS[this.index];

  indexChange() {
    this.currentProgress = PROGRESS[this.index];
  }

  build() {
    Column({space:12}) {
     Row() {
       Image($r('app.media.app_icon'))
         .width(20)
         .height(20)
         .margin({right:8})
         .borderRadius(4)
Text('驾考')
          .fontSize('12vp')
          .fontColor($r('app.color.item_title_font'))
          .fontWeight(400)     }
     .width(this.fullWidthPercent)
      .justifyContent(FlexAlign.Start)
     Row() {
Text(`当前进度-${this.currentProgress}`)
          .fontFamily('HarmonyHeiTi')
          .fontColor($r('app.color.item_title_font'))
          .fontSize('14vp')
          .fontWeight(500)
          .lineHeight('19vp')     }
     .width(this.fullWidthPercent)
     Row() {
       Column() {
         Image($r('app.media.card_exam'))
           .width(32)
           .height(32)
           .margin({bottom:4})
Text('模拟考试')
            .fontFamily('HarmonyHeiTi')
            .fontColor($r('app.color.item_title_font'))
            .fontSize('12vp')
            .fontWeight(500)
            .lineHeight('16vp')       }
       .width('50%')
       .alignItems(HorizontalAlign.Center)
       .onClick(() => {
         postCardAction(this, {
           action: this.actionType,
           abilityName: this.abilityName,
           params: {
             message: 'practiceView'
           }
         });
       })
       Column() {
         Image($r('app.media.card_pratice'))
           .width(32)
           .height(32)
           .margin({bottom:4})
Text('顺序练习')
            .fontFamily('HarmonyHeiTi')
            .fontColor($r('app.color.item_title_font'))
            .fontSize('12vp')
            .fontWeight(500)
            .lineHeight('16vp')       }
       .width('50%')
       .alignItems(HorizontalAlign.Center)
       .onClick(() => {
         postCardAction(this, {
           action: this.actionType,
           abilityName: this.abilityName,
           params: {
             message: 'orderPractice'
           }
         });
       })
     }
     .width(this.fullWidthPercent)
    }
    .padding(12)
    .width(this.fullWidthPercent)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .onClick(() => {
      postCardAction(this, {
        action: this.actionType,
        abilityName: this.abilityName,
        params: {
          message: this.message
        }
      });
    })
  }
}