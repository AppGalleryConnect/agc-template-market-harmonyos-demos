import { Logger, PreferencesUtil } from 'commonlib';
import { SetFontSizeUtil } from '../utils/SetFontSizeUtil';
import { MainPageVM } from '../viewModels/MainPageVM';

class NewsData{
  title:string=''
  content:string=''
  image?: Resource
  comment:string=''
  good:boolean=false
  collect:boolean=false
  share:number=0
}

@Builder
export function setFontSizeBuilder() {
  SetFontSize();
}

@ComponentV2
export struct SetFontSize {
  vm: MainPageVM = MainPageVM.instance;
  @Local message: string = 'Hello World';
  @Local time: string = '2小时前'
  @Local newsData: NewsData = new NewsData();
  private arr: number[] = [0, 1, 2];
  private initSize: number = 14;


  aboutToAppear() {
    PreferencesUtil.getChangeFontSize().then((value:number) => {
      this.vm.changeFontSize = value;
      let setZSize: number = this.initSize + value;
      this.vm.fontSizeText = SetFontSizeUtil.getTextByFontSize(setZSize);
      Logger.info('setfontsize', 'Get the value of changeFontSize: ' + this.vm.changeFontSize);
    });
  }

  @Builder
  Title() {
    Row() {
      Row() {
        Image($r('app.media.chevron_backward')).width(9).height(16)
          .margin({ left: 30, top: 48, bottom: 18})
          .onClick(() => {
          })
      }.justifyContent(FlexAlign.Start)
      .width('10%')
    }
    .width('100%')
    .backgroundColor('#E84026')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder
  Comment() {
    Column() {
      Row() {
        Text(this.newsData.comment||'这篇文章写得好，点赞！')
      }.width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom:10 })

      Row(){
        Text('【新闻】').margin({left:4}).fontSize(15).fontWeight(FontWeight.Medium)
        Text(this.newsData.title||'新闻标题').fontSize(15).fontWeight(FontWeight.Medium)
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .margin({bottom:16})

      Row(){
        Text(this.time).fontSize(12).fontWeight(FontWeight.Regular).fontColor(Color.Gray)
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .margin({bottom:16})

      Divider().strokeWidth(1)
    }
    .margin({ left: 16,top:16,right:16 })
  }

  @Builder
  Comments() {
    List() {
      ListItem() {
        this.Comment()
      }
    }
  }

  build() {
    NavDestination(){
      Column() {
          List() {
            ForEach(this.arr, (item: number) => {
              ListItem() {
                Row(){
                  Column(){
                    Row() {
                      Image($r('app.media.new'))
                        .width(40)
                        .height(16)
                        .objectFit(ImageFit.ScaleDown)
                      Text('特朗普将封禁DeepSeek？外交部给出回应')
                        .fontSize(`${16 + this.vm.changeFontSize}`)
                        .fontColor('#000000')
                        .layoutWeight(1)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .fontWeight(500)
                    }
                    .alignItems(VerticalAlign.Center)
                    .height(20)
                    .width('100%')
                    .margin({ top: 10 })

                    Row() {
                      Text('习惯了城市生活的我们，或许去海边进行一趟旅行，可以缓解疲劳的心情')
                        .fontSize(`${14 + this.vm.changeFontSize}`)
                        .lineHeight(`${18 + this.vm.changeFontSize}`)
                        .fontColor('#000000')
                        .width('100%')
                        .maxLines(2)
                        .margin({ top: 10 })
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                    .layoutWeight(1)
                    .alignItems(VerticalAlign.Top)

                    Text('2025年3月10日')
                      .fontSize(`${10 + this.vm.changeFontSize}`)
                      .fontColor('#FF989898')
                      .height(14)
                      .textAlign(TextAlign.Start)
                      .maxLines(2)
                      .margin({
                        top: 10,
                        bottom: 10
                      })
                      .textOverflow({ overflow: TextOverflow.None })
                  }
                  .margin({ right: 12 })
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  Image($rawfile('news1.jpg'))
                    .height(110)
                    .width(110)
                    .borderRadius(8)
                    .margin({
                      top: 12,
                      bottom: 12
                    })
                }
                .padding({
                  left: 12,
                  right: 12
                })
                .height(130)
              }
            }, (item: string) => JSON.stringify(item))
          }
          .layoutWeight(1)
        Text(this.vm.fontSizeText)
          .fontSize(14)
          .fontColor('#182431')
        Row() {
          Text('A')
            .fontColor('#182431')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.End)
            .width('12.5%')
            .padding({ right: 9 })

          Slider({
            value: this.initSize + this.vm.changeFontSize,
            min: 12,
            max: 20,
            step: 2,
            style: SliderStyle.InSet
          })
            .showSteps(true)
            .width('75%')
            .onChange(async (value: number)=> {
              this.vm.fontSizeText = SetFontSizeUtil.getTextByFontSize(value);
              this.vm.changeFontSize = value - this.initSize;
              PreferencesUtil.saveChangeFontSize(this.vm.changeFontSize);
            })
          Text('A')
            .fontColor('#182431')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .width('12.5%')
            .padding({ left: 8 })
        }
      }
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius(24)
      .width('93.3%')
      .padding({ top: 16, bottom: 21 })
      .margin({
        left: '3.3%',
        right: '3.3%',
        top: '1%',
        bottom: '6.2%'
      })
    }
    .title('字体设置')
  }
}

