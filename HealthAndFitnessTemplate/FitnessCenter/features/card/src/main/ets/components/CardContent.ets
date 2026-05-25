import { CardInfo, ConsumeType, BreakpointNameEnum, BreakpointModel, GridSettingInfo } from 'external_interactions';
import { AppStorageV2, display } from '@kit.ArkUI';

@ComponentV2
export struct CardContent{
  @Param cardList : CardInfo[] = []
  scroller: Scroller = new Scroller()
  @Param @Once onChildClick : (id : string) => void = () => {}
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  @Computed
  get gridSetting() {
    // 获取当前屏幕旋转角度（0-3 分别对应 0°、90°、180°、270°）
    let rotation: number = display.getDefaultDisplaySync().rotation;
    const gridSettingInfo: GridSettingInfo  = {
      template: '1fr 1fr',
      colGap: 8,
      rowGap: 8,
    }
    if (BreakpointNameEnum.MD === this.breakPointModel.currentBreakpoint) {
      gridSettingInfo.template = '1fr 1fr 1fr 1fr'
      gridSettingInfo.colGap = 12
    }
    if ([BreakpointNameEnum.LG, BreakpointNameEnum.XL].includes((this.breakPointModel.currentBreakpoint))) {
      if (rotation === 1 || rotation === 3) {
        gridSettingInfo.template = '1fr 1fr 1fr 1fr 1fr 1fr'
        gridSettingInfo.colGap = 16
        gridSettingInfo.rowGap = 16
      }
    }
    return gridSettingInfo
  }

  @Builder
  cardGridBuilder(){
    Grid() {
      ForEach(this.cardList, (item: CardInfo) => {
        GridItem() {
          CardGrid({cardInfo :item,
            onBackClick :() =>{
              this.onChildClick && this.onChildClick(item.id)
            }
          })
        }
      }, (item: CardInfo) => JSON.stringify(item))
    }
    .width('100%')
    .columnsTemplate(this.gridSetting.template)
    .columnsGap(this.gridSetting.colGap)
    .rowsGap(this.gridSetting.rowGap)
  }

  build() {
    Column() {
      Row(){
        this.cardGridBuilder()
      }
    }
  }
}


@ComponentV2
export struct CardGrid {
  @Param cardInfo: CardInfo | undefined = undefined;
  @Param @Once onBackClick: () => void = () => {}
  build() {
    Column() {
       Stack(){
         if(this.cardInfo){
           Image($r(this.cardInfo.advImage))
             .width('100%')
             .height('80%')
             .borderRadius({ topLeft: 8, topRight: 8 })
             .aspectRatio(16 / 9)
           Column(){
             Text(this.cardInfo.name)
               .fontSize(10)
               .fontColor(Color.White)
               .fontWeight(FontWeight.Bold)
               .textOverflow({ overflow: TextOverflow.Ellipsis })
               .maxLines(1)
               .margin({bottom: 15})
             Text() {
               Span('¥' + this.cardInfo.price + '/')
                 .fontSize(14)
                 .fontColor(Color.White)
                 .fontWeight(FontWeight.Bold)
               Span(this.cardInfo.consumeType === ConsumeType.TIMES ? this.cardInfo.quota + '次' : '不限次')
                 .fontSize(10)
                 .fontColor(Color.White)
                 .fontWeight(FontWeight.Medium)
             }
           }
           .width('100%')
           .alignItems(HorizontalAlign.Start)
         }
       }
       .width('100%')
       .alignContent(Alignment.Center)
      Column() {
         if(this.cardInfo){
          Text(this.cardInfo.shortName)
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
         }
      }
      .alignItems(HorizontalAlign.Start)
      .shadow({
        radius: 2,
        color: '#ECECEC',
        offsetY: 5,
      })
      .width('100%')
      .backgroundColor(Color.White)
      .padding({ left: 8, top: 12, right: 8, bottom: 12 })
      .borderRadius({ bottomLeft: 8, bottomRight: 8 })
    }
    .onClick(() => {
      this.onBackClick()
    })
    .width('100%')
  }
}