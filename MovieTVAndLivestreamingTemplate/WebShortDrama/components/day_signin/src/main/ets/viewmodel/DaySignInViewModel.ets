import { fromPlain, SignIn, SignInClass, toPlainObject } from '../model/DaySignInModel'
import { common } from '@kit.AbilityKit'
import StrConstants from '../constants/StrConstants'
import PreferencesManager from '../utils/PreferencesManager'
import { window } from '@kit.ArkUI'

export class DaySignInViewModel {
  signInList: SignInClass[] = []
  prefsManager: PreferencesManager
  windowStage: window.WindowStage = AppStorage.get('windowStage')!

  constructor(coinarray: number[]) {
    this.prefsManager = PreferencesManager.getInstance(this.windowStage.getMainWindowSync()
      .getUIContext()
      .getHostContext() as common.UIAbilityContext)
    coinarray.forEach((ca) => {
      this.signInList.push(new SignInClass(ca))
    })
  }

  async initPreferences() {
    await this.prefsManager.initPreferences(StrConstants.ONLINE_SETTING)
  }

  async getSignInInfo(): Promise<SignInClass[]> {
    return (await this.prefsManager.getData(StrConstants.SIGN_IN_LIST,
      this.signInList)).map((item) => fromPlain(item as SignIn))
  }

  getRightCount(signInList: SignInClass[]) {
    return signInList.filter(item => item.isClaim === true).length
  }

  async getCurrentDay() {
    const currentDate = new Date().toISOString().split('T')[0]
    const lastDate = await this.prefsManager.getData(StrConstants.LAST_SIGN_IN_DATE, '')
    let currentDay = 0
    if (!lastDate || lastDate === currentDate) {
      currentDay = await this.prefsManager.getData(StrConstants.CURRENT_DAY, 0)
    } else {
      currentDay =
        Math.min(await this.prefsManager.getData(StrConstants.CURRENT_DAY, 0) + 1, this.signInList.length - 1)
      await this.prefsManager.putData(StrConstants.CURRENT_DAY, currentDay)
    }
    await this.prefsManager.putData(StrConstants.LAST_SIGN_IN_DATE, currentDate)
    return currentDay
  }

  saveSignInList(signInList: SignInClass[]) {
    this.prefsManager.putData(StrConstants.SIGN_IN_LIST, signInList.map((item) => toPlainObject(item as SignIn)))
  }
}