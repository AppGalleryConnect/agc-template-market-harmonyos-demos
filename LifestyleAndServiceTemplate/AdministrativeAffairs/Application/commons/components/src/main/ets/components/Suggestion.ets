import { Constants, getPictureFromAlbum, SuggestionList } from 'common'
import { PersistenceV2, promptAction } from '@kit.ArkUI'

@ComponentV2
export struct SuggestionPage {
  @Local text: string = ''
  @Local phoneNumber: string = ''
  @Local imagePickerList: string[] = []
  @Local phoneValidate: boolean = false
  @Local descriptionValidate: boolean = false
  @Consumer('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  @Local suggestionList: SuggestionList = PersistenceV2.connect(SuggestionList, () => new SuggestionList())!;
  controller: TextAreaController = new TextAreaController()
  textInputController: TextInputController = new TextInputController()
  private imageListMaxLength: number = 4

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Column({ space: 20 }) {
            Column({ space: Constants.CONTAINER_SPACE_TWENTY }) {
              Row() {
                Text($r('app.string.suggestions_description'))
                  .fontSize(Constants.FONT_SIZE_SMALL)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_primary'))
                  .fontSize($r('sys.float.Body_M'))
                Text() {
                  Span(String(this.text.length))
                  Span('/100')
                }.fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('sys.float.Body_M'))
              }.width(Constants.FULL_PERCENT_WIDTH).justifyContent(FlexAlign.SpaceBetween)

              Column() {
                TextArea({
                  text: this.text,
                  placeholder: $r('app.string.suggestions_description_placeholder'),
                  controller: this.controller,
                })
                  .width(Constants.FULL_PERCENT_WIDTH)
                  .height($r('app.float.suggestion_textArea_width'))
                  .fontColor($r('app.color.suggestions_area_fontColor'))
                  .backgroundColor($r('sys.color.background_primary'))
                  .borderRadius(Constants.RADIUS_TWELVE)
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
                  .margin({ top: $r('app.float.common_margin_ten') })
                }
              }.width(Constants.FULL_PERCENT_WIDTH).alignItems(HorizontalAlign.Start)
            }

            Column({ space: Constants.CONTAINER_SPACE_TWENTY }) {
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
              }.width(Constants.FULL_PERCENT_WIDTH).justifyContent(FlexAlign.SpaceBetween)

              Column() {
                Row({ space: Constants.CONTAINER_SPACE_FIVE }) {
                  ForEach(this.imagePickerList, (item: string, index: number) => {
                    Column() {
                      Image(item)
                        .width($r('app.float.suggestion_upload_size'))
                        .height($r('app.float.suggestion_upload_size'))
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
                        .width($r('app.float.suggestion_plus_size'))
                        .height($r('app.float.suggestion_plus_size'))
                    }
                    .width($r('app.float.suggestion_upload_size'))
                    .height($r('app.float.suggestion_upload_size'))
                    .backgroundColor($r('app.color.about_bg'))
                    .justifyContent(FlexAlign.Center)
                    .borderRadius(Constants.CONTAINER_SPACE_TEN)
                    .onClick(() => {
                      getPictureFromAlbum().then((res: string) => {
                        if (res) {
                          this.imagePickerList.unshift(res)
                        }
                      })
                    })
                  }
                }.width(Constants.FULL_PERCENT_WIDTH).justifyContent(FlexAlign.Start)
              }
              .width(Constants.FULL_PERCENT_WIDTH)
              .padding($r('app.float.about_padding'))
              .backgroundColor($r('sys.color.background_primary'))
              .borderRadius(Constants.RADIUS_TWELVE)
            }

            Column({ space: Constants.CONTAINER_SPACE_TWENTY }) {
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
              }.width(Constants.FULL_PERCENT_WIDTH).justifyContent(FlexAlign.SpaceBetween)

              Column() {
                TextInput({
                  text: this.phoneNumber,
                  placeholder: $r('app.string.suggestions_contact_placeholder'),
                  controller: this.textInputController,
                })
                  .maxLength(11)
                  .width(Constants.FULL_PERCENT_WIDTH)
                  .height($r('app.float.suggestion_textInput_size'))
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
                  .margin({ top: $r('app.float.common_margin_ten') })
                }
              }
              .width(Constants.FULL_PERCENT_WIDTH).alignItems(HorizontalAlign.Start)
            }
          }.padding($r('app.float.about_padding'))

          Button($r('app.string.suggestions_submit'))
            .fontColor(Color.White)
            .backgroundColor('#4EA5FF')
            .padding($r('app.float.about_padding'))
            .width(Constants.HALF_PERCENT_WIDTH)
            .margin({ top: $r('app.float.about_margin') })
            .onClick(() => {
              if (this.phoneValidate) {
                return
              }
              if (this.text.length <= 0) {
                this.descriptionValidate = true
                return
              }
              this.suggestionList.suggestionList.push({
                title: this.text,
                date: new Date(),
                image: this.imagePickerList,
              })
              PersistenceV2.save(SuggestionList);
              promptAction.showToast({ message: $r('app.string.suggestions_submit_success') })
              this.pageInfos.pop()
            })
        }
      }.scrollBar(BarState.Off)
    }
    .title('意见建议')
    .padding({ top: Number(AppStorage.get('topRectHeight')) })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}