/**
 * @usage: 个人信息编辑页面，展示和编辑用户的个人资料信息
 * @layout: 页面整体采用垂直布局（Column），顶部是通用头部组件，下方是个人信息表单组件
 * @constraints: 使用PersonalInfoView组件展示个人信息表单
 * @isGen: true
 * @fileType: page
 * @zhName: 个人信息
 * @domain: 旅游
 * @image: screenshots/person/PersonalCenter.jpg
 * @component: CommonHeader,PersonalInfoView
 */
import { PersonalInfoView } from 'collect_personal_info'
import { CommonHeader } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router'
import { EditPersonalVM } from '../viewmodel/EditPersonalVM';

@Builder
export function EditPersonalCenterBuilder() {
  EditPersonalCenter();
}

@ComponentV2
export struct EditPersonalCenter {
  vm: EditPersonalVM = new EditPersonalVM();

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      isFullScreen: true,
      useSafePadding: true,
    })
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      CommonHeader({
        title: '个人信息',
        onReturnClick: () => {
          phoneRouterControl.popPage();
        },
      })
      Column() {
        PersonalInfoView({
          list: this.vm.list,
          themeColor: $r('sys.color.multi_color_07'),
        })
      }
      .width('100%')
      .height('100%')
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
  }
}

