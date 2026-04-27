import { AlertDialog } from '@kit.ArkUI';
import { RouterMap, RouterModule } from '@agctemplate/router_module';
import { RouterTable } from '../common/TabConstants';
import { PreferenceUtil, PreferConstant } from '@agctemplate/utils';

const TAG = '[Index]'

@Entry
@ComponentV2
struct Index {
  @Provider('pathInfo') pathInfo: NavPathStack = RouterModule.stack
  @Provider('navId') navId: string = 'navId';
  // 弹框页
  dialogPages: string[] = [RouterMap.PRIVACY_USE_PAGE, RouterMap.LOGIN_PAGE, RouterMap.COMMENT_KEY_BOARD_PAGE]
  backPageDialogController?: CustomDialogController;
  content = ''
  leftButtonText = ''
  rightButtonText = ''

  backPageDialogOpen(content: string, leftButtonText: string, rightButtonText: string) {
    this.backPageDialogController = new CustomDialogController({
      builder: AlertDialog({
        primaryTitle: '温馨提示',
        content: content,
        secondaryButton: {
          value: rightButtonText,
          action: () => {
          }
        },
        primaryButton: {
          value: leftButtonText,
          fontColor: $r('sys.color.font_tertiary'),
          action: () => {
            RouterModule.pop()
          },
        },
      }),
    })
    this.backPageDialogController.open()
  }

  aboutToAppear() {
    //读取状态值，如果为空设置为true
    let isFirstLaunch =
      PreferenceUtil.getInstance(this.getUIContext().getHostContext()).get(PreferConstant.FIRSTLAUNCH, true) as boolean
    if (isFirstLaunch) {
      //隐私政策
      RouterModule.replace({ url: RouterMap.PRIVACY_AGREEMENT_PAGE })
      return;
    }
    RouterModule.replace({ url: RouterMap.MAIN_PAGE })
  }

  onBackPressed: Function = (): boolean => {
    return false;
  }

  @Builder
  pageMap(name: string) {
    RouterTable.getBuilder(name).builder()
  }

  build() {
    Column() {
      Navigation(RouterModule.stack) {
      }
      .hideNavBar(true)
      .hideToolBar(true)
      .hideTitleBar(true)
      .hideBackButton(true)
      .mode(NavigationMode.Stack)
      .navDestination(this.pageMap)
      .id(this.navId)
    }
  }
}