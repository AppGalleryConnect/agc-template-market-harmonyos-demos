import { ExpressList } from '../components/ExpressList'
import { SearchButton } from '../components/SearchButton'
import { StateBar } from '../components/StateBar'
import { Title } from '../components/Title'
import { QueryPageVM } from '../viewModels/QueryPageVM'
import { emitter } from '@kit.BasicServicesKit'
import { Logger } from 'module_base'

@Entry
@ComponentV2
export struct OrderPage {
  vm: QueryPageVM = QueryPageVM.instance

  aboutToAppear(): void {
    try {
      emitter.on('order', (data) => {
        if (data.data) {
          this.vm.reFresh()
        }
      });
    } catch (e) {
      Logger.error(JSON.stringify(e))
    }

    try {
      emitter.on('index', (data) => {
        if (data.data) {
          if (this.vm.userInfoModel.isLogin) {
            this.vm.reFresh()
          } else {
            this.vm.logout()
          }
        }
      })
    } catch (e) {
      Logger.error(JSON.stringify(e))
    }

    try {
      emitter.on('login', (data) => {
        if (data.data) {
          this.vm.reFresh()
        }
      })
    } catch (e) {
      Logger.error(JSON.stringify(e))
    }

    this.vm.init()
  }

  build() {
    NavDestination() {
      Column() {
        Title()
        Column() {
          SearchButton()
          StateBar()
          ExpressList()
        }
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1)
    }
    .backgroundColor('#F1F3F5')
  }
}