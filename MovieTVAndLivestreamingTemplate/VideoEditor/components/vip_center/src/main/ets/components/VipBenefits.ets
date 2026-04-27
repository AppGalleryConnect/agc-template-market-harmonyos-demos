import { BaseCell, getDataFromJSON } from 'base_apis';
import { Benefits } from '../model/Model';

@ComponentV2
export struct VipBenefits {
  @Local benefitsList: Benefits[] = []

  aboutToAppear(): void {
    this.benefitsList = getDataFromJSON<Benefits>('Vip_Benefits.json', this);
  }

  @Builder
  vipBenefits() {
    Grid() {
      ForEach(this.benefitsList, (item: Benefits, index: number) => {
        GridItem() {
          Column({ space: 5 }) {
            Row() {
              Image($r(item.icon)).width(24).height(24)
            }
            .padding(8)
            .borderRadius('50%')
            .backgroundColor('#FDF5E2')

            Text(item.title)
          }
        }
      },(item: Benefits) => JSON.stringify(item))
    }
    .maxCount(1)
    .margin({ top: 16 })
    .columnsTemplate('1fr 1fr 1fr 1fr')
  }

  build() {
    Column() {
      BaseCell({
        cellTitle: '会员权益',
        customBuilderParam: () => this.vipBenefits(),
      })
    }
  }
}