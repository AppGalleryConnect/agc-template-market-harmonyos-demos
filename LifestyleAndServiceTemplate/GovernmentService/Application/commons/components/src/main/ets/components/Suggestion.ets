import { getPictureFromAlbum, Suggestion } from 'common'
import { PersistenceV2, promptAction } from '@kit.ArkUI'

@Component
export struct SuggestionPage {
  @State text: string = ''
  @State phoneNumber: string = ''
  @State imagePickerList: string[] = []
  @State phoneValidate: boolean = false
  @State descriptionValidate: boolean = false
  @Consume('pageInfos') pageInfos: NavPathStack
  @StorageLink('suggestionList') suggestionList: Suggestion[] =
    AppStorage.get('SuggestionList') ?? [];
  controller: TextAreaController = new TextAreaController()
  textInputController: TextInputController = new TextInputController()
  private imageListMaxLength: number = 4

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Column({ space: 20 }) {
            Column({ space: 12 }) {
              Row() {
                Text($r('app.string.suggestions_description'))
                  .fontSize(14)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_primary'))
                  .fontSize($r('sys.float.Body_M'))
                Text() {
                  Span(String(this.text.length))
                  Span('/100')
                }.fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.Body_M'))
              }.width('100%').justifyContent(FlexAlign.SpaceBetween)

              Column() {
                TextArea({
                  text: this.text,
                  placeholder: $r('app.string.suggestions_description_placeholder'),
                  controller: this.controller,
                })
                  .width('100%')
                  .height(112)
                  .fontColor($r('app.color.suggestions_area_fontColor'))
                  .backgroundColor($r('sys.color.background_primary'))
                  .borderRadius(12)
                  .maxLength(100)
                  .showCounter(true,
                    { thresholdPercentage: 100, highlightBorder: true })
                  .onChange((value: string) => {
                    this.text = value
                    this.descriptionValidate = (this.text === '')!
                  })
                if (this.descriptionValidate) {
                  Column() {
                    Text($r('app.string.suggestions_description_placeholder'))
                      .fontColor(Color.Red).fontSize($r('sys.float.Body_L')).fontWeight(FontWeight.Regular)
                  }
                  .margin({ top: 10 })
                }
              }.width('100%').alignItems(HorizontalAlign.Start)
            }

            Column({ space: 20 }) {
              Row() {
                Text($r('app.string.suggestions_image_upload')).fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_primary'))
                  .fontSize($r('sys.float.Body_M'))
                Text() {
                  Span(String(this.imagePickerList.length))
                  Span('/4')
                }.fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.Body_M'))
              }.width('100%').justifyContent(FlexAlign.SpaceBetween)

              Column() {
                Row({ space: 5 }) {
                  ForEach(this.imagePickerList, (item: string, index: number) => {
                    Column() {
                      Image(item)
                        .width(80)
                        .height(80)
                      Image($r('app.media.cancel')).width(16).height(16)
                        .position({ top: -5, right: 0 })
                        .onClick(() => {
                          this.imagePickerList.splice(index, 1)
                        })
                    }
                  }, (item: string) => item)
                  if (this.imagePickerList.length < this.imageListMaxLength) {
                    Column() {
                      Image($r('app.media.public_plus'))
                        .width(24)
                        .height(24)
                    }
                    .width(80)
                    .height(80)
                    .backgroundColor($r('app.color.about_bg'))
                    .justifyContent(FlexAlign.Center)
                    .borderRadius(10)
                    .onClick(() => {
                      getPictureFromAlbum().then((res: string) => {
                        if (res) {
                          this.imagePickerList.unshift(res)
                        }
                      })
                    })
                  }
                }.width('100%').justifyContent(FlexAlign.Start)
              }
              .width('100%')
              .padding(12)
              .backgroundColor($r('sys.color.background_primary'))
              .borderRadius(12)
            }

            Column({ space: 20 }) {
              Row() {
                Text($r('app.string.suggestions_contact'))
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_primary'))
                  .fontSize($r('sys.float.Body_M'))
                Text() {
                  Span(String(this.phoneNumber.length))
                  Span('/11')
                }.fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.Body_M'))
              }.width('100%').justifyContent(FlexAlign.SpaceBetween)

              Column() {
                TextInput({
                  text: this.phoneNumber,
                  placeholder: $r('app.string.suggestions_contact_placeholder'),
                  controller: this.textInputController,
                })
                  .maxLength(11)
                  .width('100%')
                  .height(40)
                  .backgroundColor($r('sys.color.background_primary'))
                  .onChange((value: string) => {
                    this.phoneNumber = value
                  })
                  .onBlur(() => {
                    if (!(/^[1][3456789][0-9]{9}$/
                      .test(this.phoneNumber)) && this.phoneNumber !== '') {
                      this.phoneValidate = true
                    } else {
                      this.phoneValidate = false
                    }
                  })
                if (this.phoneValidate) {
                  Column() {
                    Text($r('app.string.suggestions_problem_phone'))
                      .fontColor(Color.Red).fontSize($r('sys.float.Body_L')).fontWeight(FontWeight.Regular)
                  }
                  .margin({ top: 10 })
                }
              }
              .width('100%').alignItems(HorizontalAlign.Start)
            }
          }.padding(12)

          Button($r('app.string.suggestions_submit'))
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor('#4EA5FF')
            .padding(12)
            .width('50%')
            .margin({ top: 68 })
            .onClick(() => {
              if (this.phoneValidate) {
                return
              }
              if (this.text.length <= 0) {
                this.descriptionValidate = true
                return
              }
              this.suggestionList.push({
                title: this.text,
                date: new Date(),
                image: this.imagePickerList,
              })
              promptAction.showToast({ message: $r('app.string.suggestions_submit_success') })
              this.pageInfos.pop()
            })
        }
      }.scrollBar(BarState.Off)
    }
    .title('意见反馈')
    .padding({ top: Number(AppStorage.get('topRectHeight')) })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}