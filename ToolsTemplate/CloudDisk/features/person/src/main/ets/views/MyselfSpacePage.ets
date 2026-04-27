import { Constants, FileInfo, UserInfo } from 'common';
import { OHPage } from 'oh_router';
import { BGTopView } from '../comp/BGTopView';
import { TopView } from '../comp/TopView';

@Builder
export function MyselfSpacePageBuilder(param : object) {
  MyselfSpacePage({userInfo : param as UserInfo})
}

/**
 * @usage: 用于展示个人空间页面。提供用户存储空间使用情况的可视化展示和VIP会员推广功能。
 * 关键数据结构包括pat（当前使用百分比，固定为10%）、imageAngle（圆环图标旋转角度）。
 * 页面展示总容量非会员20GB，会员40GB、已使用0MB的存储信息，以及VIP会员加入入口。
 * @layout: 页面采用Stack堆叠布局。底层是BGTopView背景视图（高度320vp，包含蓝色渐变背景和圆环进度图标240x240，
 * 显示使用百分比10%和"当前已使用"文字），顶层是TopView内容视图（包含HeaderView导航栏"个人空间"、
 * SpaceView空间信息卡片85vp高、VIPView会员推广卡片52vp高）。SpaceView显示"我的空间"标题、进度条（宽度15%、高度12vp、
 * 圆角6vp）、总容量和已使用容量文字。VIPView显示VIP图标40x40、推广文案和"立即加入"按钮（宽度80vp、高度26vp、圆角15vp）。
 * @constraints: 存储空间使用百分比固定为10%不可修改；总容量20GB和已使用65.2MB固定显示；
 * 背景渐变色（blue_sky到bg_color）和圆环图标ic_circle固定；进度条宽度15%和样式参数固定；
 * VIP会员卡片跳转到VipCenterPage不可修改。
 * @isGen: true
 * @fileType: page
 * @domain: 云存储
 * @zhName: 个人空间页面
 * @component: OHPage,HeaderView,BGTopView,TopView,SpaceView,VIPView
 * VIP推广文案可定制，按钮样式可调整（颜色、圆角、尺寸）。
 * @image: screenshot/Person/personalSpace.jpg
 */

@ComponentV2
struct MyselfSpacePage {
  @Param @Require userInfo :UserInfo

  @Builder
  render() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        BGTopView({userInfo : this.userInfo})
      }
      .backgroundColor($r('app.color.bg_color'))
      .justifyContent(FlexAlign.Start)
      .width(Constants.FULL_SIZE)
      .height(Constants.FULL_SIZE)

      TopView({userInfo : this.userInfo})
    }
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      }
    })

  }
}