
@ComponentV2
export struct CarKeyboard {
  @Local focusIndex:number = 10;
  @Param keyboardHeight:number = 260;
  @Param licenseElement:string[] = [];
  @Event changeLicense: (index:number, element:string) => void = (index:number, element: string) => {};
  controller: TextInputController = new TextInputController();

  commonKeys: string[] =
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0','Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'O', 'P','港','A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', '澳','Z', 'X', 'C', 'V', 'B', 'N', 'M', '学','警']

  provincesKeyBoard: string[] =
    ['京', '皖', '津', '渝', '沪', '冀', '晋', '辽', '吉','黑', '苏', '浙', '闽', '赣', '鲁', '豫', '鄂', '湘','粤', '琼', '川', '贵', '云', '陕', '甘', '青','蒙', '桂', '宁', '新', '藏',]
  @Builder
  areaKeyboard() {
    Column() {
      Row() {
        Text('收起')
          .height(30)
          .onClick(() => {
            this.focusIndex = 10;
            this.controller.stopEditing()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .margin({
        bottom:8
      })

      Grid() {
        ForEach(this.provincesKeyBoard, (item: string) => {
          GridItem() {
            Text(item)
              .fontSize(18)
              .fontWeight(600)
              .textAlign(TextAlign.Center)
              .width('100%')
              .height('100%')
              .onClick(() => {
                  this.changeLicense(this.focusIndex, item);
                  if (this.focusIndex < 7) {
                    this.focusIndex ++
                  }
              });
          }
          .backgroundColor(Color.White)
          .borderRadius(8)
        })

        GridItem() {}
        .columnStart(5)
        .columnEnd(7)
        .backgroundColor('#dee0e5')

        GridItem() {
          Text('删除')
          .fontSize(18)
          .fontWeight(600)
          .textAlign(TextAlign.Center)
          .height('100%')
            .width('100%')
          .onClick(() => {
            this.changeLicense(this.focusIndex, '');
            if (this.focusIndex > 0) {
              this.focusIndex--;
            }
          })
        }
        .columnStart(8)
        .columnEnd(9)
        .backgroundColor('#bcc0c6')
        .borderRadius(8)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr 1fr')
      .rowsGap(5)
      .columnsGap(2)
    }
    .backgroundColor('#dee0e5')
    .height(this.keyboardHeight)
    .padding({
      top:8,
      left:2,
      right:2,
      bottom: 80
    })
  }

  @Builder
  commonKeyboard() {
    Column() {
      Row() {
        Text('完成')
          .height(30)
          .onClick(() => {
            this.focusIndex = 10;
            this.controller.stopEditing()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .margin({
        bottom:8
      })

      Grid() {
        ForEach(this.commonKeys, (item: string) => {
          GridItem() {
            Text(item)
              .fontSize(18)
              .fontWeight(600)
              .textAlign(TextAlign.Center)
              .width('100%')
              .height('100%')
              .borderRadius(3)
              .onClick(() => {
                this.changeLicense(this.focusIndex, item);
                if (this.focusIndex < 7) {
                  this.focusIndex ++
                }
              });
          }
          .backgroundColor(Color.White)
          .borderRadius(8)
        })
        GridItem() {
          Text('删')
            .fontSize(18)
            .fontWeight(600)
            .textAlign(TextAlign.Center)
            .height('100%')
            .width('100%')
            .borderRadius(3)
            .onClick(() => {
              const code = this.licenseElement[this.focusIndex];
              this.changeLicense(this.focusIndex, '');
              if (this.focusIndex > 0 && code === '') {
                this.focusIndex--;
              }
            })
        }
        .backgroundColor('#bcc0c6')
        .borderRadius(8)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr 1fr')
      .rowsGap(5)
      .columnsGap(2)
    }
    .backgroundColor('#dee0e5')
    .height(this.keyboardHeight)
    .padding({
      top:8,
      left:2,
      right:2,
      bottom: 80
    })
  }

  @Builder
  customBoardBuilder() {
    if (this.focusIndex === 0) {
      this.areaKeyboard()
    } else {
      this.commonKeyboard()
    }
  }

  @Styles
  carCodeStyle() {
    .height(40)
    .borderRadius(4)
    .layoutWeight(1)
    .backgroundColor('#F1F3F5')
  }

  build() {
    Column() {
      Row({space:8}) {
        ForEach(Array(2).fill(''), (item: string | number, index: number) => {
          Column() {
            Text(this.licenseElement[index])
          }
          .carCodeStyle()
          .key(item.toString())
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .border({ width: '2px', color: '#F1F3F5', style: BorderStyle.Solid })
          .borderColor(this.focusIndex === index? Color.Red:'#F1F3F5')
          .onClick(() => {
            this.focusIndex = index;
            focusControl.requestFocus('keyBoardInput')
          })
        })

        Column() {

        }
        .width(4)
        .height(4)
        .borderRadius('50%')
        .backgroundColor(Color.Black)

        ForEach(Array(5).fill(''), (item: string | number, index: number) => {
          Column() {
            Text(this.licenseElement[index+2])
          }
          .carCodeStyle()
          .key(item.toString())
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .border({ width: '2px', color: '#F1F3F5', style: BorderStyle.Solid })
          .borderColor(this.focusIndex === index+2? Color.Red:'#F1F3F5')
            .onClick(() => {
              this.focusIndex = index + 2;
              focusControl.requestFocus('keyBoardInput')
            })
        })

        Column() {
          Text(this.licenseElement[7] !== '' && this.licenseElement[7] !== undefined? this.licenseElement[7]:'+')
            .fontColor('#64bb5c')
        }
        .height(40)
        .borderRadius(4)
        .layoutWeight(1)
        .backgroundColor('#eef8ed')
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .border({ width: '2px', color: '#64bb5c', style: BorderStyle.Dashed })
        .borderStyle(this.focusIndex === 7? BorderStyle.Solid:BorderStyle.Dashed)
        .onClick(() => {
          this.focusIndex = 7;
          focusControl.requestFocus('keyBoardInput')
        })
      }
      .width('100%')

      TextInput({controller: this.controller})
        .opacity(0)
        .padding(0)
        .id('keyBoardInput')
        .height(0)
        .customKeyboard(this.customBoardBuilder())
    }
    .defaultFocus(false)
  }
}