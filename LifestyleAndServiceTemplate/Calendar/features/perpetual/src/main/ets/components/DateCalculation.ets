import { NavigationTitle, ToggleChoose, ToggleItem } from 'common'
import { CalculationDate } from './CalculationDate'
import { CalculationInterval } from './CalculationInterval'

@Builder
export function DateCalculationBuilder() {
  DateCalculation()
}


@ComponentV2
export struct DateCalculation {
  @Local currentIndex: number = 0
  @Local toggleList: ToggleItem [] = [
    {
      name: '日期间隔',
      id: 'interval',
    },
    {
      name: '日期计算',
      id: 'calculation',
    }
  ]

  @Builder
  calculationOperation() {
    ToggleChoose({
      toggleList: this.toggleList,
      chooseChange: (index: number) => {
        this.currentIndex = index
      },
    })
  }

  build() {
    NavDestination() {
      NavigationTitle({
        title: '日期计算',
      })
      List() {
        ListItem() {
          this.calculationOperation()
        }

        ListItem() {
          Tabs({ index: this.currentIndex }) {
            TabContent() {
              CalculationInterval()
            }

            TabContent() {
              CalculationDate()
            }
          }
          .barHeight(0)
        }
      }
    }
    .hideTitleBar(true)
  }
}