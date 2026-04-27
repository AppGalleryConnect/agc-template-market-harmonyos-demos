import { connection } from '@kit.NetworkKit';
import { getInstance } from '../common/CommonRoute';
import { ConnectionVo } from '../model/ConnectionVo';
import { TcpCallback } from '../model/TcpCallback';
import { TcpServer } from '../service/TcpServer';
import { common } from '@kit.AbilityKit';

@ComponentV2
struct ReceiverPage {
  @Local ipAddress: string = ''; // 本地ip地址
  @Local qrCodeData: string = ''; // 二维码数据
  @Local isConnected: boolean = AppStorage.get('isConnected') ?? false;
  @Local port: number = 0;
  context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext
  private tcpCallback: TcpCallback = {
    onPrepared: async (port?: number) => {
      if (port) {
        this.port = port
        const connectionInfo = {
          ip: this.ipAddress,
          port: this.port,
          type: 'tcp_connection',
          deviceName: '',
          img: '',
        } as ConnectionVo;
        this.qrCodeData = JSON.stringify(connectionInfo);
      }
    },
    onConnected: () => {
      this.isConnected = true
      getInstance().pushPathByName('FileReceiverPage', true)
    },
  } as TcpCallback

  async aboutToAppear(): Promise<void> {
    this.ipAddress = await this.getLocalIPAddress()
    this.generateQRCodeData()

    if (!this.isConnected) {
      TcpServer.context = this.context
      TcpServer.create(this.ipAddress, this.tcpCallback)
    }
  }

  // 获取本机IP地址
  async getLocalIPAddress(): Promise<string> {
    try {
      let netHandle = await connection.getDefaultNet();
      if (netHandle) {
        let connectionProperties: connection.ConnectionProperties = await connection.getConnectionProperties(netHandle);
        if (connectionProperties && connectionProperties.linkAddresses) {
          for (let address of connectionProperties.linkAddresses) {
            // 过滤IPv4地址
            if (address.address) {
              return address.address.address;
            }
          }
        }
      }
    } catch (error) {
      console.error('获取IP地址失败:', error);
    }
    return '';
  }

  // 生成包含IP和端口的二维码数据
  async generateQRCodeData() {
    const connectionInfo = {
      ip: this.ipAddress,
      port: this.port,
      type: 'tcp_connection',
    } as ConnectionVo;
    this.qrCodeData = JSON.stringify(connectionInfo);
  }

  build() {
    NavDestination() {
      Column() {
        Column({ space: 20 }) {
          // 服务端：显示二维码
          Column({ space: 10 }) {
            Column() {
              Text('使用旧手机的本机工具扫码连接')
                .fontSize($r('sys.float.Subtitle_L'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .margin({ bottom: 12 })
              Row() {
                Text('01.打开旧手机工具')
                  .fontSize($r('sys.float.Body_S'))
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_primary'))
                Text('>')
                  .fontSize($r('sys.float.Body_S'))
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_primary'))
                  .padding({ left: 12, right: 12 })
                Text('02.选择旧机扫码')
                  .fontSize($r('sys.float.Body_S'))
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.font_primary'))
              }
              .margin({ bottom: 12 })

              QRCode(this.qrCodeData)
                .color($r('sys.color.comp_foreground_primary'))
                .backgroundColor($r('sys.color.background_primary'))
                .width(204)
                .height(188)
                .aspectRatio(1)
                .margin({ bottom: 12 })
                .onClick(async () => {
                  this.ipAddress = await this.getLocalIPAddress(); // 获取本机IP地址
                  TcpServer.refresh(this.ipAddress);
                })

              Row() {
                Text('请确保两部设备连接同一WiFi或热点，且该网络未开启网络隔离等阻碍内网通信的安全设置')
                  .fontColor($r('sys.color.font_primary'))
                  .fontSize($r('sys.float.Body_M'))
                  .fontWeight(FontWeight.Regular)
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .padding({ left: 12, right: 12 })
            }
            .width('100%')
            .borderRadius(16)
            .padding({ top: 16, bottom: 16 })
            .backgroundColor(Color.White)
          }
        }
        .padding({ left: 16, right: 16 })
        .width('100%')
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Start)
      }
      .backgroundColor('#F0F3F5')
      .width('100%')
      .height('100%')
    }
    .title('扫码连接')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .backgroundColor($r('sys.color.background_secondary'))
  }
}

@Builder
export function ReceiverPageBuilder() {
  ReceiverPage();
}