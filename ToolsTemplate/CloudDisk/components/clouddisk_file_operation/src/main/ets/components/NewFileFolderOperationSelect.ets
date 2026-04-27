import { Constants, TCLogger } from 'common'
import { NewFileFolderOperationSelectVM } from '../viewmodel/NewFileFolderOperationSelectVM';
import { FileOperationUtil } from 'module_cloud_upload';


/**
 * @usage: 用于文件上传和新建文件夹的操作选择场景。提供照片、视频、文件、音频四种类型的上传入口，
 * 以及新建文件夹和VIP会员充值入口。关键数据结构：NormalFileType（文件类型，包含name名称、icon图标）、
 * FileOperationUtil（文件操作工具类）。包含if逻辑：根据FileOperationUtil.isInitSuccess判断是否需要初始化。
 * @layout: 垂直布局。顶部为标题行（左对齐"新建文件"标题、右对齐关闭按钮），第二行为新建文件夹按钮（左对齐），
 * 第三行为"上传文件"标题（左对齐），第四行为文件类型选择网格（4列横向排列，均分宽度，居中对齐），
 * 底部为VIP会员推广区域（渐变背景，左侧VIP图标和文字，右侧充值按钮）。
 * @constraints: fileTypes文件类型数组不能为空，selectFile回调函数必须正确处理文件选择，
 * jumpVip回调函数必须正确跳转VIP页面，FileOperationUtil必须正确初始化
 * @isGen: true
 * @fileType: component
 * @domain: 云存储
 * @zhName: 新建文件文件夹操作选择组件
 * @image: screenshot/screenshot02.jpg
 */
@ComponentV2
export struct NewFileFolderOperationSelect {
  private logTag: string = 'NewFileFolderOperationSelect'
  @Param @Require vm: NewFileFolderOperationSelectVM
  fileTypes: NormalFileType[] = [
    {
      name: '照片',
      icon: $r('app.media.icon_photo')
    },
    {
      name: '视频',
      icon: $r('app.media.icon_video')
    },
    {
      name: '文件',
      icon: $r('app.media.icon_file')
    },
    {
      name: '音频',
      icon: $r('app.media.icon_radio')
    }
  ]
  // 文件操作工具
  private fileOperationUtil: FileOperationUtil = new FileOperationUtil();
  // 本地的初始化成功标志
  @Local initSuccess: boolean = false
  // 选择文件
  @Param selectFile: (type: string) => void = (_type: string) => {
  }
  // 跳转vip充值页面
  @Param jumpVip: () => void = () => {
  }

  aboutToAppear(): void {
    if (!FileOperationUtil.isInitSuccess) {
      this.fileOperationUtil.init().then((res: boolean) => {
        this.initSuccess = res
        FileOperationUtil.isInitSuccess = true
        TCLogger.info(this.logTag, `Succeeded init Auth Login, result: ${JSON.stringify(res)}`);
      })
    }
  }

  // 云盘VIP会员
  @Builder
  buildCloudVip() {
    Row() {
      Row() {
        Image($r('app.media.img_vip')).size({ width: 42, height: 42 }).margin({ left: 20 })

        Column() {
          Text('云盘VIP会员').fontSize(14).fontColor('#FFD8BF').fontWeight(FontWeight.Medium).lineHeight(16)

          Text('提高传输速度')
            .fontSize(10)
            .fontColor('#E58A50')
            .fontWeight(FontWeight.Regular)
            .lineHeight(12)
            .margin({ top: 5 })
        }.alignItems(HorizontalAlign.Start).margin({ left: 14 }).layoutWeight(1)

        Row() {
          Text('会员充值').fontSize(12).fontColor('#221915').fontWeight(FontWeight.Medium).lineHeight(14)
        }
        .size({ width: 80, height: 26 })
        .borderRadius(15)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .margin({ right: 24 })
        .linearGradient({
          angle: 90, // 渐变角度（0点方向顺时针）
          colors: [
            ['#FEE6C2', 0.0], // 起始颜色及位置
            ['#FFBC93', 1.0]// 结束颜色及位置
          ]
        })
        .onClick(() => {
          this.jumpVip()
          this.vm.isShow = false
        })

      }
      .layoutWeight(1)
      .height('100%')
      .borderRadius(16)
      .alignItems(VerticalAlign.Center)
      .linearGradient({
        angle: 90, // 渐变角度（0点方向顺时针）
        colors: [
          ['#29211C', 0.0], // 起始颜色及位置
          ['#1D1310', 1.0]// 结束颜色及位置
        ]
      })

    }
    .width('100%').height(70).alignItems(VerticalAlign.Center).padding({ left: 16, right: 16, bottom: 16 })
  }

  // 不同类型文件操作
  @Builder
  differTypeFile() {
    Row() {
      ForEach(this.fileTypes, (item: NormalFileType) => {
        RelativeContainer() {
          Column() {
            Image(item.icon).size({ width: 40, height: 40 })

            Text(item.name)
              .fontSize(11)
              .fontColor($r('sys.color.mask_secondary'))
              .fontWeight(FontWeight.Regular)
              .lineHeight(13)
              .margin({ top: 4 })
          }
          .alignRules({
            middle: { align: HorizontalAlign.Center, anchor: '__container__' },
            center: { align: VerticalAlign.Center, anchor: '__container__' }
          })
        }
        .width(76)
        .height(77)
        .backgroundColor(Color.White)
        .borderRadius(16)
        .onClick(() => {
          this.selectFile(item.name)
        })
      }, (item: NormalFileType, idx: number) => JSON.stringify(item) + idx)
    }
    .width('100%')
    .height(77)
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ bottom: 16 })
  }

  // 上传文件
  @Builder
  buildUploadFile() {
    Row() {
      Text('上传文件').fontSize(14).fontColor(Color.Black).fontWeight(FontWeight.Medium).lineHeight(16)

    }
    .width('100%')
    .height(52)
    .alignItems(VerticalAlign.Center)
    .padding({ left: 24, right: 24 })
    .justifyContent(FlexAlign.Start)
  }

  // 新建文件夹
  @Builder
  buildNewfolder() {
    Row() {
      RelativeContainer() {
        Column() {
          Image($r('app.media.new_folder')).size({ width: 40, height: 40 })

          Text('新建文件夹')
            .fontSize(11)
            .fontColor($r('sys.color.mask_secondary'))
            .fontWeight(FontWeight.Regular)
            .lineHeight(13)
            .margin({ top: 4 })
        }.alignRules({
          middle: { align: HorizontalAlign.Center, anchor: '__container__' },
          center: { align: VerticalAlign.Center, anchor: '__container__' }
        })
      }
      .width(84)
      .height(81)
      .borderRadius(16)
      .backgroundColor(Color.White)
      .onClick(() => {
        this.vm.isShow = false
        this.vm.isShowInput = !this.vm.isShowInput
      })
    }.width('100%').height(81).alignItems(VerticalAlign.Center).padding({ left: 16, right: 16 })
  }

  // 标题和关闭按钮
  @Builder
  buildTitle() {
    Row() {
      Text('新建文件').fontSize(14).fontColor(Color.Black).fontWeight(FontWeight.Medium).lineHeight(16)

      Image($r('app.media.close')).size({ width: 20, height: 20 })
        .onClick(() => {
          this.vm.isShow = false
        })
    }
    .width('100%')
    .height(60)
    .alignItems(VerticalAlign.Center)
    .padding({ left: 24, right: 24 })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  build() {
    Column() {
      this.buildTitle()

      this.buildNewfolder()

      this.buildUploadFile()

      this.differTypeFile()

      this.buildCloudVip()
    }
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
    .padding({ bottom: 28 })
    .justifyContent(FlexAlign.Center)
  }
}

/**
 * 不同类型文件
 */
export interface NormalFileType {
  name: string,
  icon: ResourceStr
}
