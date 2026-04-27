/**
 * @usage: 用于备份状态展示和控制场景。显示备份进度、备份时间、备份状态，提供开始、暂停、查看相册等操作。
 * 关键数据结构：backupProgress（备份进度0-100）、backupDateTime（备份日期时间字符串）、
 * backupStatus（备份状态，0-暂停、1-备份中、2-已完成）。包含if逻辑：根据backupStatus显示不同的界面
 * （状态2显示"已成功备份"和"查看相册"按钮，状态0/1显示"备份中"和进度百分比及开始/暂停按钮）。
 * @layout: 白色圆角卡片布局。顶部为"备份详情"标题（左对齐），中间为备份信息行（左侧环形进度条和成功图标，
 * 中间备份文字和时间，右侧查看相册按钮或开始/暂停按钮）。所有元素垂直居中对齐。
 * @constraints: backupProgress备份进度必须在0-100之间，backupDateTime备份时间不能为空，
 * backupStatus备份状态只能为0/1/2，pickAvatarFromAlbum回调函数必须正确跳转相册，
 * beginProgress和pauseProgress回调函数必须正确控制备份，onValueChange回调函数必须正确更新状态
 * @isGen: true
 * @fileType: component
 * @domain: 云存储,
 * @zhName: 备份状态组件
 * @subPage:
 * @image: screenshot/backup/backup_component.jpg
 */
@ComponentV2
export struct BackStatus {
  @Require @Param backupProgress: number
  @Require @Param backupDateTime: string
  @Require @Param backupStatus: number
  @Event pickAvatarFromAlbum: () => void = () => {
  }
  @Event beginProgress: () => void = () => {
  }
  @Event pauseProgress: () => void = () => {
  }
  @Event onValueChange: (data: number) => void = () => {
  }

  build() {
    Column() {
      Row() {
        Text('备份详情').fontSize(12).fontColor('rgba(0, 0, 0, 0.8)').fontWeight(500)
      }.layoutWeight(1).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Start).width('100%')

      Row() {
        Stack({ alignContent: Alignment.Center }) {
          Progress({ value: this.backupProgress, type: ProgressType.Ring })
            .width(30)
            .color('#2FAFFF')
            .style({ strokeWidth: 2 })
          Image($r('app.media.ic_backup_success')).width(16).height(16)
        }

        if (this.backupStatus === 2) {
          Column() {
            Text('已成功备份相册3项').fontSize(14).fontColor('#000000')
            Text(`最近备份日期：${this.backupDateTime}`).fontSize(12).fontColor('rgba(0, 0, 0, 0.4)')
              .margin({top: 2})
          }.layoutWeight(1).alignItems(HorizontalAlign.Start).margin({ left: 9 })

          Text('查看相册').fontSize(11).fontColor('#2FAFFF')
            .onClick(() => {
              this.pickAvatarFromAlbum()
            })
        } else {
          Text('备份中').fontSize(14).fontColor('#000000').margin({ left: 8 })
          Text(`${this.backupProgress}%`)
            .fontSize(14)
            .fontColor('rgba(0, 0, 0, 0.4)')
            .margin({ left: 4 })
            .layoutWeight(1)
          Row() {
            Image(this.backupStatus === 1 ? $r('app.media.ic_stop') :
            $r('app.media.ic_start'))
              .width(14)
              .height(14)
              .margin({ right: 4 })
            Text(this.backupStatus === 1 ? '暂停备份' : '开始备份')
              .fontSize(11)
              .fontColor('rgba(0, 0, 0, 0.7)')
          }.onClick(() => {
            if (this.backupStatus === 0) {
              this.onValueChange(1)
              this.beginProgress()
            } else {
              this.onValueChange(0)
              this.pauseProgress()
            }

          })
        }

      }.height(56)

    }
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .height(90)
    .padding({ left: 12, right: 12 })
    .margin({ top: 12 })
  }
}