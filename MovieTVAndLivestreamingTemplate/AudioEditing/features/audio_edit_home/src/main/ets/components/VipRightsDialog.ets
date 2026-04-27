/**
 * @usage: VIP权益提示弹窗组件,当用户使用需要VIP权限的功能时弹出,引导用户充值或升级会员。
 * 支持两种类型:充值提示(charge)和升级提示(upgrade)。根据type参数显示不同的标题和文案。
 * @layout: 采用Column垂直布局,顶部为标题文字,中间为提示内容文字,底部为Row横向排列的取消和确认按钮。
 * 弹窗带圆角和深色背景。
 * @constraints: 必须提供type、onCancel和onConfirm参数。type仅支持'charge'和'upgrade'两种值。
 * @domain: 音频编辑
 * @zhName: VIP权益弹窗
 * @fileType: component
 * @image: 
 */
@ComponentV2
export struct VipRightsDialog {
  @Param @Require type: 'charge' | 'upgrade';
  @Param @Require onCancel: () => void;
  @Param @Require onConfirm: () => void;

  build() {
    Column() {
      Text(this.type === 'charge' ? '使用次数' : '功能升级')
        .fontSize(18)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 24, bottom: 16 })

      Text(this.type === 'charge'
        ? '普通用户暂不支持提取音频功能，请您充值VIP，享受更多权益'
        : '超级VIP会员可享受终身免费权益，是否需要权益？')
        .fontSize(15)
        .fontColor('rgba(255,255,255,0.8)')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 32, left: 24, right: 24 })
        .lineHeight(24)

      Row() {
        Text('取消')
          .textAlign(TextAlign.Center)
          .borderRadius(30)
          .width(120)
          .height(40)
          .backgroundColor('transparent')
          .border({ width: 1, color: '#01FCEA' })
          .fontColor('#01FCEA')
          .onClick(() => this.onCancel())

        Text(this.type === 'charge' ? '充值' : '升级')
          .width(120)
          .textAlign(TextAlign.Center)
          .borderRadius(30)
          .height(40)
          .backgroundColor('#01FCEA')
          .fontColor('#0A0D1E')
          .onClick(() => this.onConfirm())
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ bottom: 24 })
    }
    .width(300)
    .backgroundColor('#202E3E')
    .borderRadius(16)
  }
}
