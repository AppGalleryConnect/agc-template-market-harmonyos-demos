import { PersonalInfoView } from 'collect_personal_info'
import { CommonHeader } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router'
import { EditPersonalVM } from '../viewmodel/EditPersonalVM';

@Builder
export function EditPersonalCenterBuilder() {
  EditPersonalCenter();
}

/**
 * @usage: 个人信息页 支持展示用户基本信息（头像、昵称、性别、出生日期、手机号码、邮箱、签名等）
 * @layout: 页面采用纵向排列布局，从上到下依次是标题为"个人信息"的CommonHeader组件和PersonalInfoView个人信息视图组件，
 * 整体左对齐且顶部对齐，背景色为系统次要背景色
 * @constraints: 组件使用OHPage全屏布局且启用安全区域内边距，CommonHeader的返回按钮触发页面返回操作，
 * PersonalInfoView的list数据由vm.list提供且themeColor固定为'#564AF7'紫色主题不可修改
 * @isGen: true
 * @fileType: page
 * @domain: 社交交友
 * @zhName: 个人信息页
 * @subPage:
 * @component: PersonalInfoView
 * @image: screenshot/person/person_info.png
 */

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
          themeColor: '#564AF7',
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

