import { FileBaseSelectListView } from 'cloud_file_base';
import { OperationItemView } from 'cloud_operation_item';
import { PrivatespacePageViewModel } from '../viewmodel/PrivatespacePageViewModel';

/**
 * @usage: 隐私空间页面：展示隐私空间下文件，结合底部操作项进行操作。
 * @layout: 顶部导航栏 + 文件选择列表视图 + 底部操作栏（绑定Sheet弹出）。
 * @constraints: 隐私空间文案固定，文件展示样式
 * @isGen: false
 * @fileType: component
 * @domain: 云存储
 * @zhName: 云盘隐私空间页面
 * @subPage:
 * @component: FileBaseSelectListView,OperationItemView
 * @image: screenshots/multileval.jpg
 */
@ComponentV2
struct PrivatespacePage {
  private navPathStack: NavPathStack = new NavPathStack();
  @Require @Param vm: PrivatespacePageViewModel

  aboutToAppear(): void {
    this.vm.initializationResponses()
  }

  build() {
    NavDestination() {
      Column() {
        this.buildHeader()

        FileBaseSelectListView({ vm: this.vm, selectRowBgColor: '#F1F3F5' })
          .width('100%')
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .bindSheet($$this.vm.isShow, this.privatespaceOperationView(),
        {
          showClose: false,
          height: 40 + 48,
          enableOutsideInteractive: true,
          maskColor: Color.Transparent,
          radius: { topLeft: 0, topRight: 0 },
          preferType: SheetType.BOTTOM
        })
    }
    .hideTitleBar(true)
    .mode(NavDestinationMode.STANDARD)
    .padding(this.vm.contentPadding)
    .onReady((ctx: NavDestinationContext) => {
      this.navPathStack = ctx.pathStack
    })
  }

  @Builder
  buildHeader() {
    Row() {
      Image($r('app.media.privatespace_back'))
        .width(40)
        .height(40)
        .onClick(() => {
          this.navPathStack.pop()
        })

      Text($r('app.string.cloud_privatespace'))
        .margin({left: 8, right: 8})
        .layoutWeight(1)
        .fontSize(20)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .height(58)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  privatespaceOperationView() {
    OperationItemView({ vm: this.vm.operationVM })
  }
}

@Builder
export function PrivatespacePageBuilder(param: Object) {
  PrivatespacePage({ vm: param as PrivatespacePageViewModel })
}
