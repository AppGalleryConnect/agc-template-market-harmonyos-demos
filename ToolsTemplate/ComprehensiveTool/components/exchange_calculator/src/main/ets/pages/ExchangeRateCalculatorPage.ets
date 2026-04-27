import { AppStorageV2 } from '@kit.ArkUI';
import { setPathStack } from '../common/Route';
import { CardItem } from '../components/CardItem';
import { StyleConstants } from '../constants/Styles';
import { AreaType, ICurrencyData } from '../model/Types';
import { ExchangeVM } from '../viewmodel/ExchangeVM';

@Builder
export function ExchangeRateCalculatorPageBuilder() {
  ExchangeRateCalculatorPage();
}

@ComponentV2
export struct ExchangeRateCalculatorPage {
  vm: ExchangeVM = ExchangeVM.instance;
  @Local avoidArea: AreaType = AppStorageV2.connect(AreaType, 'avoidArea', () => new AreaType())!;

  aboutToAppear(): void {
    this.vm.getExchangeInfo();
    this.vm.onKeyboardChange(this.getUIContext());
  }

  aboutToDisappear(): void {
    this.vm.offKeyboardChange(this.getUIContext());
  }

  @Builder
  list() {
    List({ space: StyleConstants.SPACE_8 }) {
      ForEach(this.vm.exchangeData, (data: ICurrencyData, index) => {
        CardItem({ index: index })
      }, (data: ICurrencyData) => JSON.stringify(data))
    }
    .scrollBar(BarState.Off)
    .layoutWeight(1);
  }

  build() {
    NavDestination() {
      Column({ space: StyleConstants.SPACE_16 }) {
        this.header();

        this.list();

        this.bottom();
      }
      .layoutWeight(1);
    }
    .title('汇率计算')
    .padding({ bottom: this.avoidArea.bottom })
    .backgroundColor($r('sys.color.background_secondary'))
    .onReady((ctx) => {
      setPathStack(ctx.pathStack);
    });
  }

  @Builder
  header() {
    Row() {
      Text('基准汇率').mainStyle();
      Blank().layoutWeight(1);
      Image($r('app.media.rate'))
        .fillColor(StyleConstants.Black_LEVEL2)
        .width(StyleConstants.IMAGE_14)
        .height(StyleConstants.IMAGE_14)
        .margin({ right: StyleConstants.SPACE_8 });
      Text('更新时间: ' + this.vm.updateTime).subStyle1();
    }
    .padding({ left: StyleConstants.SPACE_16, right: StyleConstants.SPACE_16 });
  }

  @Builder
  bottom() {
    Text('汇率有波动，仅供数据参考').subStyle2().margin({ bottom: StyleConstants.SPACE_12 });
  }
}

@Extend(Text)
function mainStyle() {
  .fontWeight(FontWeight.Medium)
  .fontSize($r('sys.float.Body_L'))
  .fontColor($r('sys.color.font_primary'));
}

@Extend(Text)
function subStyle1() {
  .fontWeight(FontWeight.Regular)
  .fontSize($r('sys.float.Caption_L'))
  .fontColor($r('sys.color.font_secondary'));
}

@Extend(Text)
function subStyle2() {
  .fontWeight(FontWeight.Regular)
  .fontSize($r('sys.float.Body_M'))
  .fontColor($r('sys.color.font_secondary'));
}