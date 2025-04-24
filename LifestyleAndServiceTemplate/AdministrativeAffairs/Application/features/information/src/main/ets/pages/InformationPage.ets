import { CloudFunction, CloudFunctionInformationResult, commonToast, Constants, InformationTabsInfo } from 'common';
import { ServiceTitle } from 'components';
import { CustomTabBar } from '../components/CustomTabBar';
import { InformationsList } from '../components/InformationsList';

@ComponentV2
export struct InformationPage {
  @Local informationTabsInfo: InformationTabsInfo[] = []
  @Local currentIndex: number = 0

  async aboutToAppear() {
    commonToast.show({
      type: 'loading',
    })
    let resp = await CloudFunction.getInformaticaList(0, '')
    if ((resp as CloudFunctionInformationResult).result.ret.code === 0) {
      let result: InformationTabsInfo[] =
        (resp as CloudFunctionInformationResult).result.result as InformationTabsInfo[]
      this.informationTabsInfo = result
    }
    commonToast.hide()
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      ServiceTitle({
        title: $r('app.string.information_title'),
      })
      Column() {
        CustomTabBar({
          informationTabsInfo: this.informationTabsInfo,
          currentIndex: this.currentIndex,
          fontSize:Constants.FONT_SIZE_SMALL,
          currentIndexChange: (value: number) => {
            this.currentIndex = value
          },
        })
        if (this.informationTabsInfo.length) {
          InformationsList({
            informationTabsInfo: this.informationTabsInfo,
            currentIndex: this.currentIndex,
          })
        }
      }
      .height(Constants.FULL_PERCENT_HEIGHT)
      .padding({ top: Number(AppStorage.get('topRectHeight')) + Constants.SAFE_AREA_SIXTY })
    }
  }
}