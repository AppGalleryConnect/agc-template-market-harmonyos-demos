import { GlobalContext, RouterMap, RouterUtils, WindowModel } from 'lib_common';
import { HistoryButton } from '../../components/HistoryButton';
import { PageResultType } from './OfficeResultPage';
import { AppStorageV2 } from '@kit.ArkUI';
import { NavHeaderBar } from '../../widget/NavHeaderBar';

const SCHOOL_SECTION = ['不限', '本科', '硕士', '博士']
const NUMBERS = ['1000', '1500', '2000', '其他']
const SELECTED_LANGUAGE = ['中文', '英文'];

@Builder
export function PaperWritingPageBuilder() {
  PaperWritingPage()
}

@ComponentV2
export struct PaperWritingPage {
  @Local title: string = '';
  @Local major: string = '';
  @Local degree: string = '不限';
  @Local count: string = '1000';
  @Local language: string = '中文';
  @Local other: string = '';
  @Local isOtherNum: boolean = false;
  @Local otherCount: string = '';
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '论文写作'
        }) {
          HistoryButton({
            onEvent: () => {
              RouterUtils.pushPathByName(RouterMap.OFFICE_HISTORY_PAGE, '论文写作')
            }
          })
        }

        Scroll() {
          Column({ space: 16 }) {
            Column({ space: 12 }) {
              Text('论文题目')
                .fontSize($r('sys.float.Subtitle_L'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Bold)
              TextArea({ placeholder: '请输入标题', text: $$this.title })
                .placeholderColor($r('sys.color.font_secondary'))
                .placeholderFont({
                  size: $r('sys.float.Body_L'),
                  weight: FontWeight.Regular,
                })
                .fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Regular)
                .borderRadius(8)
                .padding({ left: 12 })
                .constraintSize({ minHeight: 58 })
            }.width('100%')
            .alignItems(HorizontalAlign.Start)

            Column({ space: 12 }) {
              Text('专业')
                .fontSize($r('sys.float.Subtitle_L'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Bold)
              TextArea({ placeholder: '请输入专业名称', text: $$this.major })
                .placeholderColor($r('sys.color.font_secondary'))
                .placeholderFont({
                  size: $r('sys.float.Body_L'),
                  weight: FontWeight.Regular,
                })
                .fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Regular)
                .borderRadius(8)
                .padding({ left: 12 })
                .constraintSize({ minHeight: 58 })
            }.width('100%')
            .alignItems(HorizontalAlign.Start)

            Column({ space: 16 }) {
              Text('学段')
                .fontSize($r('sys.float.Subtitle_L'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Bold)
              Row({ space: 8 }) {
                ForEach(SCHOOL_SECTION, (item: string) => {
                  Button() {
                    Text(item)
                      .fontSize($r('sys.float.Body_M'))
                      .fontWeight(FontWeight.Normal)
                      .fontColor(this.degree === item ? $r('sys.color.font_on_primary') :
                      $r('sys.color.font_primary'))
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .maxLines(1)
                  }
                  .width(72)
                  .height(28)
                  .borderRadius(14)
                  .padding({
                    top: 4,
                    bottom: 4,
                    right: 8,
                    left: 8
                  })
                  .backgroundColor(this.degree === item ? $r('sys.color.icon_emphasize') :
                  $r('sys.color.comp_background_tertiary'))
                  .onClick(() => {
                    this.degree = item;
                  })
                }, (item: string) => item)
              }
            }.width('100%')
            .alignItems(HorizontalAlign.Start)

            Column({ space: 16 }) {
              Text('字数')
                .fontSize($r('sys.float.Subtitle_L'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Bold)
              Row({ space: 8 }) {
                ForEach(NUMBERS, (item: string) => {
                  Button() {
                    Text(item)
                      .fontSize($r('sys.float.Body_M'))
                      .fontWeight(FontWeight.Normal)
                      .fontColor(this.count === item ? $r('sys.color.font_on_primary') :
                      $r('sys.color.font_primary'))
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .maxLines(1)
                  }
                  .width(72)
                  .height(28)
                  .borderRadius(14)
                  .padding({
                    top: 4,
                    bottom: 4,
                    right: 8,
                    left: 8
                  })
                  .backgroundColor(this.count === item ? $r('sys.color.icon_emphasize') :
                  $r('sys.color.comp_background_tertiary'))
                  .onClick(() => {
                    this.count = item;
                    if (item === '其他') {
                      this.isOtherNum = true;
                      return;
                    }
                    this.isOtherNum = false
                    this.otherCount = ''
                  })
                }, (item: string) => item)
              }

              if (this.isOtherNum) {
                TextInput({ placeholder: '请输入自定义字数  如：3000', text: $$this.otherCount })
                  .placeholderColor($r('sys.color.font_secondary'))
                  .placeholderFont({
                    size: $r('sys.float.Body_L'),
                    weight: FontWeight.Regular,
                  })
                  .fontSize($r('sys.float.Body_L'))
                  .fontColor($r('sys.color.font_primary'))
                  .fontWeight(FontWeight.Regular)
                  .borderRadius(8)
                  .padding({ left: 12 })
                  .type(InputType.Number)
                  .onEditChange((isEditing: boolean) => {
                    if (!isEditing) {
                      if (this.otherCount === '1000' || this.otherCount === '1500' || this.otherCount === '2000') {
                        this.count = this.otherCount
                        this.isOtherNum = false
                        this.otherCount = ''
                      }
                    }
                  })
              }
            }.width('100%')
            .alignItems(HorizontalAlign.Start)

            Column({ space: 16 }) {
              Text('选择语言')
                .fontSize($r('sys.float.Subtitle_L'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Bold)
              Row({ space: 8 }) {
                ForEach(SELECTED_LANGUAGE, (item: string) => {
                  Button() {
                    Text(item)
                      .fontSize($r('sys.float.Body_M'))
                      .fontWeight(FontWeight.Normal)
                      .fontColor(this.language === item ? $r('sys.color.font_on_primary') :
                      $r('sys.color.font_primary'))
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .maxLines(1)
                  }
                  .width(72)
                  .height(28)
                  .borderRadius(14)
                  .padding({
                    top: 4,
                    bottom: 4,
                    right: 8,
                    left: 8
                  })
                  .backgroundColor(this.language === item ? $r('sys.color.icon_emphasize') :
                  $r('sys.color.comp_background_tertiary'))
                  .onClick(() => {
                    this.language = item;
                  })
                }, (item: string) => item)
              }
            }.width('100%')
            .alignItems(HorizontalAlign.Start)

            Column({ space: 16 }) {
              Text('其他要求')
                .fontSize($r('sys.float.Subtitle_L'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Bold)
              TextArea({ placeholder: '请输入您的其他要求，若无可不填', text: $$this.other })
                .placeholderColor($r('sys.color.font_secondary'))
                .placeholderFont({
                  size: $r('sys.float.Body_L'),
                  weight: FontWeight.Regular,
                })
                .fontSize($r('sys.float.Body_L'))
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Regular)
                .borderRadius(8)
                .padding({ left: 12 })
                .constraintSize({ minHeight: 120 })
            }.width('100%')
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ bottom: 16 })
        }
        .edgeEffect(EdgeEffect.Spring)
        .align(Alignment.TopStart)
        .scrollBar(BarState.Off)
        .flexShrink(1)
        .flexGrow(1)
        .padding({ left: 16, right: 16, top: 8 })

        Column() {
          Button('开始生成')
            .width('100%')
            .height(40)
            .backgroundColor($r('sys.color.comp_background_emphasize'))
            .onClick(() => {
              if(!(this.title && this.major && (this.otherCount || this.count !== '其他'))){
                GlobalContext.getUIContext().getPromptAction().showToast({ message: '请检查题目、专业、字数是否为空！' });
                return;
              }
              let systemPrompt = '你是一个写作专家，需要根据用户的需求生成论文或总结，内容需要严谨';
              let userPrompt =
                `帮我生成一篇论文，论文的标题是${this.title}, 我当前的专业是${this.major}，当前是${this.degree}阶段。要求是字数不少于${this.otherCount ??
                this.count}，使用${this.language}，其他要求：${this.other}`
              RouterUtils.pushPathByName(RouterMap.OFFICE_RESULT_PAGE, {
                systemPrompt: systemPrompt,
                userPrompt: userPrompt,
                type: 'paper',
                pageTitle: '论文写作',
                title: this.title
              } as PageResultType)
            })
        }
        .margin({
          bottom: this.windowModel.windowBottomPadding + 12
        })
        .padding({ left: 16, right: 16, top: 8 })
      }
      .height('100%')
      .expandSafeArea([SafeAreaType.KEYBOARD])
    }
    .hideTitleBar(true)
  }
}

