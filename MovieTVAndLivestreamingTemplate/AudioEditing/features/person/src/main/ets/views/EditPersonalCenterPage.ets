/**
 * @usage: 编辑个人信息页面,用户从个人中心页点击个人信息入口后跳转到此页面编辑个人资料。
 * 提供用户头像、昵称、姓名、性别等个人信息的编辑功能。支持修改头像、昵称、姓名、性别等个人信息字段。
 * 修改后的信息会同步更新到个人中心页面。
 * @layout: 页面采用OHPage容器包裹Column垂直布局,顶部为CommonHeader导航头部,
 * 中间为PersonalInfoView个人信息表单组件,展示头像、昵称、姓名、性别等信息项。
 * 每个信息项可点击进入编辑状态。
 * @constraints: 需要登录后才能访问。修改头像需要相册访问权限或相机权限。
 * 昵称和姓名有长度限制,性别仅支持男/女选择。
 * @domain: 音频编辑
 * @zhName: 编辑个人信息页面
 * @isGen: true
 * @fileType: page
 * @subPage: 
 * @component: CommonHeader,PersonalInfoView
 * @image: screenshots/person/personInfo.jpg
 */
import { PersonalInfoView } from 'collect_personal_info'
import { CommonHeader } from 'audio_common';
import { OHPage, phoneRouterControl } from 'oh_router'
import { EditPersonalVM } from '../viewmodel/EditPersonalVM';
import { BarVM } from 'common';

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
    .padding({
      top: BarVM.instance.staBarH,
      left: 16,
      right: 16
    })
  }
}

