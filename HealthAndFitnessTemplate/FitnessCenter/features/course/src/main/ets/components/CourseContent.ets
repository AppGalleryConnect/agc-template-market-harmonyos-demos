import { CourseDetailModel, BreakpointNameEnum, BreakpointModel, GridSettingInfo } from 'external_interactions'
import { AppStorageV2, display } from '@kit.ArkUI';

@ComponentV2
export struct CourseContent{
  @Param courseList : CourseDetailModel[] = []
  @Param @Once onBackClick : (msg : string) => void = () => {};
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
  courseBuilder(){
    Grid() {
      ForEach(this.courseList, (item: CourseDetailModel) => {
        GridItem() {
          CourseGrid({courseDetail : item, onBackClick:(id : string)=>{
            this.onBackClick && this.onBackClick(id)
          }})
        }
      }, (item: CourseDetailModel) => JSON.stringify(item))
    }
    .width('100%')
    .columnsTemplate(this.gridSetting.template)
    .columnsGap(this.gridSetting.colGap)
    .rowsGap(this.gridSetting.rowGap)
  }

  build() {
    Column(){
      Row(){
        this.courseBuilder()
      }
    }
  }
}

@ComponentV2
export struct CourseGrid{
  @Param courseDetail: CourseDetailModel | undefined = undefined;
  @Param @Once onBackClick : (msg : string) => void = () => {};
  build() {
    if(this.courseDetail){
      Column() {
        Image($r(this.courseDetail.advImage))
          .width('100%')
          .height('70%')
          .borderRadius({ topLeft: 8, topRight: 8 })
          .aspectRatio(16 / 9)
        Column() {
          Text(this.courseDetail.courseName)
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom:4 })
          Text('¥' + this.courseDetail.price)
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
        }
        .justifyContent(FlexAlign.SpaceEvenly)
        .alignItems(HorizontalAlign.Start)
        .shadow({
          radius: 2,
          color:'#ECECEC',
          offsetY: 5,
        })
        .width('100%')
        .backgroundColor('#fff')
        .padding({left: 8, top: 12, right: 8, bottom: 12})
        .borderRadius({bottomLeft: 8, bottomRight: 8})
      }
      .width('100%')
      .borderRadius({ topLeft: 8, topRight: 8 })
      .onClick(() => {
        if(this.courseDetail){
          this.onBackClick && this.onBackClick(this.courseDetail.id)
        }
      })
    }
  }
}