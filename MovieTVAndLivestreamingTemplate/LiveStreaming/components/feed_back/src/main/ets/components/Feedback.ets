/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License')
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

import { FeedbackItemType } from '../model/FeedbackRecordModel'
import { fileSelect, getDateStringWithTimeStamp } from '../utils/FileSelect'

@ComponentV2
export struct Feedback {
  text?: ResourceStr
  //传入问题描述的最大字数
  @Param des: number = 100
  //传入问题截图需要的最大数量
  @Param num: number = 5
  //问题描述输入文本
  @Local desText: string = ''
  //监听电话号码输入的长度
  @Local phoneLength: number = 0
  //获取选择图片后的url数组
  @Local stageImageUris: Array<string> = []
  @Local imageUris: Array<string> = []
  @Local phoneValue: string = ''
  @Local feedList: FeedbackItemType = {
    description: '',
    stageImageUris: [],
    phone: '',
    time: ''
  }
  @Event butOnClick: (feedList: FeedbackItemType) => void

  build() {
    Column() {
      Column({ space: 24 }) {
        // 问题描述
        this.feedDes()
        // 问题截图
        this.feedPic()
        // 联系方式
        this.feedPhone()
      }

      Blank()
      // 提交按钮
      this.submitButton()
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height('100%')
    .padding({
      left: 16,
      right: 16,
      top: 8,
      bottom: 12
    })
    .backgroundColor($r('sys.color.comp_background_gray'))
  }

  // 选择图像
  async selectImage() {
    if (this.feedList.stageImageUris.length >= this.num) {
      this.getUIContext().getPromptAction().showToast({ message: `最多上传${this.num}张图片`, duration: 2000 })
      return
    }
    let remainingSlots = this.num - this.feedList.stageImageUris.length
    if (remainingSlots > 0) {
      let uris = await fileSelect(this.getUIContext(),this.stageImageUris, remainingSlots)
      this.imageUris.push(...uris)
      this.feedList.stageImageUris = this.imageUris
    }
  }

  // 提交按钮
  @Builder
  submitButton() {
    Button('提交反馈')
      .borderRadius(20)
      .fontColor($r('sys.color.font_on_primary'))
      .backgroundColor('#EE5D1A')
      .fontSize($r('sys.float.Body_L'))
      .fontWeight(FontWeight.Medium)
      .width('100%')
      .height(40)
      .padding({ top: 12, bottom: 12 })
      .onClick(async () => {
        if (this.feedList.description.length > 0) {
          if (this.phoneLength === 0 || this.phoneLength === 11) {
            //获取当前时间
            this.feedList.time = getDateStringWithTimeStamp()
            this.butOnClick(this.feedList)
          } else {
            this.getUIContext().getPromptAction().showToast({ message: '请输入11位正确的电话号码', duration: 2000 })
          }
        } else {
          this.getUIContext().getPromptAction().showToast({ message: '请填写问题描述', duration: 2000 })
        }
      })
  }

  // 问题描述
  @Builder
  feedDes() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      TextArea({ text: this.desText, placeholder: '请详细描述您的问题（必填）' })
        .caretColor('#EE5D1A')
        .selectedBackgroundColor('#EE5D1A')
        .placeholderFont({ size: 16, weight: 400 })
        .placeholderColor($r('sys.color.font_tertiary'))
        .size({ width: '100%', height: 151 })
        .maxLength(this.des)
        .backgroundColor($r('sys.color.comp_background_primary'))
        .onChange((value: string) => {
          this.desText = value
          this.feedList.description = this.desText
        })
        .padding(12)

      Text(`${this.desText.length}/${this.des}`)
        .fontSize(12)
        .fontColor(this.desText.length === 100 ? $r('sys.color.warning') :
        $r('sys.color.font_secondary'))
        .translate({ x: -12, y: -12 })
    }
    .size({ width: '100%', height: 151 })
  }

  // 问题截图
  @Builder
  feedPic() {
    Column() {
      Text('上传图片')
        .fontSize(14)
        .fontWeight(400)
        .fontColor($r('sys.color.font_secondary'))
        .margin({ bottom: 12 })

      GridRow({
        columns: {
          sm: 3, // 在sm断点时为3列
          md: 5, // 在md断点时为5列
        },
        gutter: {
          x: 8, // 列间距
          y: 8, // 行间距
        },
      }) {
        // 添加图片选择按钮
        GridCol() {
          Row() {
            SymbolGlyph($r('sys.symbol.plus'))
              .fontSize(22)
              .fontColor([$r('sys.color.icon_secondary')])
          }
          .height(104)
          .aspectRatio(1)
          .borderRadius(16)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.selectImage()
          })
        }

        ForEach(this.imageUris, (item: string, index: number) => {
          GridCol() {
            Stack({ alignContent: Alignment.TopEnd }) {
              Image(item ? item : $r('app.media.close_btn'))
                .width(104)
                .aspectRatio(1)
                .objectFit(ImageFit.Cover)
                .borderRadius(16)
              Image($r('app.media.close_btn'))
                .width(22)
                .aspectRatio(1)
                .margin({ right: 9, top: 9 })
                .onClick(() => {
                  this.imageUris.splice(index, 1)
                  this.feedList.stageImageUris.splice(index, 1)
                })
            }
          }
        }, (item: string, index: number) => item + index)
      }
      .width('100%')
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height(this.imageUris.length < 3 ? 135 : 247)
  }

  // 联系方式
  @Builder
  feedPhone() {
    Column() {
      Text('请留下您的联系方式')
        .fontSize(14)
        .fontWeight(400)
        .fontColor($r('sys.color.font_secondary'))
        .margin({ bottom: 12 })

      TextInput({ placeholder: '手机号码（选填）', text: this.text })
        .caretColor('#EE5D1A')
        .backgroundColor(Color.Transparent)
        .padding(0)
        .type(InputType.PhoneNumber)
        .maxLength(11)
        .placeholderFont({ size: $r('sys.float.Body_L'), weight: 400 })
        .onChange((value: string) => {
          this.phoneLength = value.length
          this.phoneValue = value
        })
        .size({ width: '100%', height: 48 })
        .onBlur(() => {
          if (this.phoneLength === 11 || this.phoneLength === 0) {
            this.feedList.phone = this.phoneValue
          } else {
            this.getUIContext().getPromptAction().showToast({ message: '请输入11位正确的电话号码', duration: 2000 })
          }
        })
        .onWillInsert((info: InsertValue) => {
          // 在将要输入时调用的回调。在返回true时，表示正常插入，返回false时，表示不插入。
          if (info.insertValue.startsWith(' ')) {
            return false
          } else {
            return true
          }
        })
      Divider().width('100%').height(0.5).color($r('sys.color.comp_divider'))
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }
}

@Builder
export function FeedbackBuilder() {
  Feedback()
}
