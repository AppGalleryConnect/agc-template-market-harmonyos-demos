import { NavPageInfo } from '../interface/RouterPageInfo'
import { RouterPopInfo } from '../interface/RouterPopInfo'
import { TCLogger } from 'common'

const TAG = 'PhoneRouterManager: '

/**
 * 手机Product的路由管理器
 * 如果平板、手表、PC可再创建一共Manager，或者写一个base，多个Manager继承base
 */
export class PhoneRouterManager {
  // 路由栈名称，所有页面信息集合
  navPageInfoMap: Map<string, NavPageInfo[]> = new Map<string, NavPageInfo[]>()
  // 路由栈名称，路由信息
  navPathStackMap: Map<string, NavPathStack> = new Map()
  // 所有注册进路由表的builder信息
  routerBuilderMap: Map<string, WrappedBuilder<[object]>> = new Map()
  // 默认路由栈名称
  defaultRouteName: string = 'PhoneAppMainRouter'

  /**
   * 跳转页面
   * @param page 页面信息
   */
  public async jumpPage(page: NavPageInfo): Promise<void> {
    if (this.checkPageInfo(page)) {
      this.getRouter(page.routerName).pushPathByName(page.pageName, page.param, page.onPop);
      // 记录页面
      let navPageInfoList: NavPageInfo[] = this.getNavPageInfoList()
      navPageInfoList.push(page)
      TCLogger.info(TAG + `jumpPage history pageInfo length = ${navPageInfoList.length}`)
      TCLogger.info(TAG + `jumpPage page list info= ${JSON.stringify(this.getNavPageInfoList())}`)
    }
  }

  /**
   * 将当前页面栈栈顶退出
   * 如果页面的builder还未注册，则跳转失败
   * @param page 页面信息
   */
  public replacePage(page: NavPageInfo): void {
    if (this.checkPageInfo(page)) {
      this.getRouter(page.routerName).replacePathByName(page.pageName, page.param);
      TCLogger.info(TAG + `jumpPage page list info= ${JSON.stringify(this.getNavPageInfoList())}`)
    }
  }

  /**
   * 页面出栈, 默认最近的栈出栈
   * @param page 页面信息
   */
  public popPage(page?: RouterPopInfo): void {
    if (page?.popData) {
      // 出栈并返回消息
      this.getRouter(page?.routerName ?? this.defaultRouteName).pop(page?.popData)
    } else {
      // 出栈
      this.getRouter(page?.routerName ?? this.defaultRouteName).pop()
    }
    let navPageInfoList: NavPageInfo[] = this.getNavPageInfoList()
    TCLogger.info(TAG + `popPage current pageInfo length = ${navPageInfoList.length}`)
    navPageInfoList.pop()
    TCLogger.info(TAG + `popPage new pageInfo length = ${navPageInfoList.length}`)
    TCLogger.info(TAG + `popPage new pageInfo list info = ${JSON.stringify(this.getNavPageInfoList())}`)
  }

  /**
   * 出指定页面名称的路由栈
   * @param page 页面信息
   * @param isBack 是否执行页面返回，默认true
   */
  public popPageName(page?: RouterPopInfo, isBack: boolean = true): void {
    let navPageInfoList: NavPageInfo[] = this.getNavPageInfoList()
    TCLogger.info(TAG + `popPageName current pageInfo length = ${navPageInfoList.length}`)
    for (let index = 0; index < navPageInfoList.length; index++) {
      const pageInfo = navPageInfoList[index];
      if (pageInfo.pageName === page?.pageName) {
        TCLogger.info(TAG + `popPageName find matched pageName = ${page?.pageName} and pop this page`)
        if (isBack) {
          // 出栈
          this.getRouter(page?.routerName ?? this.defaultRouteName).removeByName(page?.pageName)
        }
        navPageInfoList.splice(index, 1)
        break
      }
    }
    TCLogger.info(TAG + `popPageName Remaining pageInfoList = ${JSON.stringify(navPageInfoList)}`)
  }

  /**
   * 路由出最近的一个栈，不执行页面返回，只内存出栈
   * 使用常见：A har包跳转B har包后，但是B har包不依赖phoneRouterControl，在B har结束路由时，需删除A的路由栈
   */
  popLastPage() {
    let navPageInfoList: NavPageInfo[] = this.getNavPageInfoList()
    TCLogger.info(TAG + `popLastPage current pageInfo length = ${navPageInfoList.length}`)
    navPageInfoList.pop()
    TCLogger.info(TAG + `popLastPage new pageInfo length = ${navPageInfoList.length}`)
    TCLogger.info(TAG + `popLastPage new pageInfo list info = ${JSON.stringify(this.getNavPageInfoList())}`)
  }

  /**
   * 一次结束多个页面栈
   * @param pageNumber 需要出几个栈(包括当前页)
   * @param isBack 是否执行页面返回，默认true
   */
  public popMulPage(pageNumber: number, isBack: boolean = true): void {
    let navPageInfoList: NavPageInfo[] = this.getNavPageInfoList()
    TCLogger.info(TAG + `popMulPage current pageInfo length = ${navPageInfoList.length}`)
    if (pageNumber > navPageInfoList.length) {
      TCLogger.warn(TAG + `popMulPage pageNumber more than pageList length, do nothing`)
      return
    }
    const newNavPageInfoList = [...navPageInfoList].reverse();
    TCLogger.info(TAG + `popMulPage newNavPageInfoList = ${JSON.stringify(newNavPageInfoList)}`)
    for (let index = 0; index < pageNumber; index++) {
      if (isBack) {
        const page = newNavPageInfoList[index];
        TCLogger.info(TAG + `popMulPage pop page name = ${page.pageName}`)
        // 出栈
        this.getRouter(page?.routerName ?? this.defaultRouteName).pop()
      }
      navPageInfoList.pop()
    }
    TCLogger.info(TAG + `popMulPage new pageInfo length = ${navPageInfoList.length}`)
    TCLogger.info(TAG + `popMulPage new pageInfo list info = ${JSON.stringify(this.getNavPageInfoList())}`)
  }

  /**
   * 创建路由栈
   * @param navPathStack 路由栈
   * @param routerName 路由栈名称
   */
  public createRouter(router: NavPathStack, routerName: string = this.defaultRouteName): void {
    TCLogger.info(TAG + 'createRouter')
    this.navPathStackMap.set(routerName, router)
    this.navPageInfoMap.set(routerName, [])
  }

  /**
   * 通过路由栈名称获取路由栈
   * @param routerName 路由栈名称
   * @returns 路由栈
   */
  public getRouter(routerName: string = this.defaultRouteName): NavPathStack {
    return this.navPathStackMap.get(routerName) as NavPathStack
  }

  /**
   * 记录页面名称与页面builder
   * @param pageName 页面的名称
   * @param builder 自定义view或者page页面
   */
  public registerPageBuilder(pageName: string, builder: WrappedBuilder<[Object]>): void {
    TCLogger.info(TAG + `registerPageBuilder pageName : ${pageName}`)
    this.routerBuilderMap.set(pageName, builder)
  }

  /**
   * 获取页面名称对应的页面view
   * @param pageName 页面的名称
   * @returns 页面view
   */
  public getPageBuilder(pageName: string): WrappedBuilder<[Object]> {
    const builder = this.routerBuilderMap.get(pageName)
    if (!builder) {
      TCLogger.info(`getPageBuilder 页面未注册:${pageName}`)
    }
    return builder as WrappedBuilder<[Object]>
  }

  /**
   * 判断页面信息是否存在，如果不存在，则注册页面信息
   * @param page 页面信息
   * @returns true: 页面存在
   */
  protected checkPageInfo(page: NavPageInfo): boolean {
    let builder = this.routerBuilderMap.get(page.pageName)
    if (!builder) {
      if (page.builder) {
        this.registerPageBuilder(page.pageName, page.builder)
      } else {
        TCLogger.info(`checkPageInfo page not registered : ${page.pageName}`)
        return false
      }
    }
    return true
  }

  /**
   * 获取路由栈中的所有页面信息
   * @param routerName 路由栈名称
   * @returns 路由栈中的所有页面信息
   */
  public getNavPageInfoList(): NavPageInfo[] {
    const navPageInfoList = this.navPageInfoMap.get(this.defaultRouteName)
    if (!navPageInfoList) {
      this.navPageInfoMap.set(this.defaultRouteName, [])
    }
    return navPageInfoList || []
  }
}

export const phoneRouterControl = new PhoneRouterManager()