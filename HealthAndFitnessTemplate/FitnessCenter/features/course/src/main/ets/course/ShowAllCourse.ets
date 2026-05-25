import { CourseDetailModel, MockService, SportType } from 'external_interactions';
import { TitleBar } from 'module_recharge/src/main/ets/components/TitleBar';
import { SearchFilterContent, Type } from 'module_search_filter';
import { CourseContent } from '../components/CourseContent';
import { ScreenPropStorage , AccountUpdate} from 'external_interactions'
import { AppStorageV2 } from '@kit.ArkUI';
@ComponentV2
export struct ShowAllCourse {
  @Local screenPropStorage : ScreenPropStorage = AppStorageV2.connect(ScreenPropStorage, 'ScreenPropStorage', () =>new ScreenPropStorage())!
  @Local topRectHeight: number = this.screenPropStorage.topRectHeight;
  @Local bottomRectHeight: number = this.screenPropStorage.bottomRectHeight;

  @Param @Once pathStack: NavPathStack = new NavPathStack();

  @Local showCourseList: CourseDetailModel[] = MockService.courseList;
  @Local courseList: CourseDetailModel[] = this.showCourseList
  sportTypeList: SportType[] = [{
    name: '全部',
    typeEnum: 0,
    icon: '',
    advImage: []
  }];
  courseNatureList: string[] = ['全部']
  @Param @Once list: string[] = []
  @Local sportSelectIndex: number = 0;
  @Local searchWord: string = ''
  @Local listLength: number = 0;
  aboutToAppear(): void {
    this.sportTypeList = this.sportTypeList.concat(MockService.sportTypeList)
    this.courseNatureList = this.courseNatureList.concat(MockService.courseNatureList)
    this.list = this.courseNatureList
  }
  @Monitor('screenPropStorage.topRectHeight', 'screenPropStorage.bottomRectHeight')
  onScreenPropStorage(mon: IMonitor) {
    this.topRectHeight = this.screenPropStorage.topRectHeight;
    this.bottomRectHeight = this.screenPropStorage.bottomRectHeight
  }
  private handleBack(nature: string, index: number, searchWord: string){
    this.showCourseList = MockService.getCourseListBySearchAndFilter(this.courseList, searchWord, index, nature)
    this.listLength = this.showCourseList?.length
  }
  build() {
    NavDestination() {
      TitleBar({ title: '课程列表', onBackClick:()=>{this.pathStack.pop()} })
        .margin({ left: 16, right: 16 })
      Scroll() {
        Column() {
          SearchFilterContent({
            placeHolder: '请输入课程信息',
            typeList: this.list,
            onContentChange: (nature: string, index: number, searchWord: string) => {
                this.handleBack(nature, index, searchWord)
            }
          })
          CourseContent({
            courseList: this.showCourseList,
            onBackClick: (id: string) => {
              this.pathStack.pushPath({name:'course/CourseDetail', param: MockService.courseIdMap.get(id)})
            }
          })
          Column() {
            Image($r('app.media.no_result'))
              .width(144)
              .height(144)
              .margin({ bottom: 12 })
            Text('未查询到课程信息')
              .fontSize(14)
              .fontWeight(FontWeight.Regular)
              .fontColor('#999999')
          }
          .height('50%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .visibility(
            this.listLength > 0 ? Visibility.None : Visibility.Visible
          )
        }
        .margin({ bottom: 50 })
      }
      .align(Alignment.Top)
      .layoutWeight(1)
      .margin({ left: 16, right: 16 })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .onReady((ctx: NavDestinationContext) => {
      this.pathStack = ctx.pathStack
      if (ctx.pathInfo.param) {
        this.showCourseList = ctx?.pathInfo?.param as CourseDetailModel[]
      } else {
        this.showCourseList = MockService.courseList
      }
      this.courseList = this.showCourseList
    })
    .hideTitleBar(true)
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight),
      bottom: this.getUIContext().px2vp(this.bottomRectHeight) })
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.main_background_color'))
    .onAppear(()=>this.handleBack('', 0, ''))
  }
}
