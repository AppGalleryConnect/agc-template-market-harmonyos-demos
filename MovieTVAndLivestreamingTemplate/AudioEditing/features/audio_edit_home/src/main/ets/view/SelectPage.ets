/**
 * @usage: 音频选择页面,用户从音频编辑首页点击音频剪辑、合成、调节等功能后跳转到此页面选择音频文件。
 * 提供音乐库浏览和音频文件选择功能,支持单选模式(用于剪辑/调节)和多选模式(用于合成)。
 * 支持搜索音频功能,可快速定位目标音频文件。
 * @layout: 页面采用NavDestination导航容器包裹Column垂直布局,顶部为SelectHeader搜索头部组件,
 * 中间为MusicLibraryComponent音乐库组件(占满剩余空间),展示本地音频文件列表。
 * 页面背景色为深色主题(#0A0D1E)。
 * @constraints: 需要读取本地音频文件权限。单选模式下点击音频直接跳转到对应的编辑页面,
 * 多选模式下需要选择至少一个音频才能进入下一步。
 * @domain: 音频编辑
 * @zhName: 音频选择页面
 * @isGen: true
 * @fileType: page
 * @subPage: SearchViewPage,AudioEditPage,AudioSynthesisPage,AudioAdjustPage
 * @component: SelectHeader,MusicLibraryComponent
 * @image: 
 */
import { phoneRouterControl } from 'oh_router';
import { PersistenceV2, Type } from '@kit.ArkUI';
import { MusicListViewController, SelectHeader } from 'common_view';
import { BarVM, RouterMap, TValueType } from 'common';
import { MusicViewModel } from 'common_view/src/main/ets/viewModel/MusicViewModel';
import { LISTMODE } from 'common_view/src/main/ets/components/MusicItem';
import { SearchViewPageBuilder } from './SearchViewPage';

import { MusicLibraryComponent } from '../components/MusicLibraryComponent';

phoneRouterControl.registerPageBuilder('SelectPage', wrapBuilder(SelectPageBuilder))

const TAG = 'SelectPage'

@Builder
export function SelectPageBuilder(params: TValueType) {
  SelectPage({ pageParams: params })
}

PersistenceV2.notifyOnError((key: string, reason: string, msg: string) => {
});

@ComponentV2
export struct SelectPage {
  @Param pageParams: TValueType = null;
  musicListViewController = new MusicListViewController()
  headTitle: string = '音频剪辑'
  pageType: string = ''
  @Local listMode: LISTMODE = 'click' //列表操作模式，默认单选模式
  @Local selectedMusicList: MusicViewModel[] = [] //选中的音频列表，用于合成功能
  //搜索按钮点击事件回调
  searchOnclick: () => void = () => {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.SEARCH_VIEW_PAGE,
      builder: wrapBuilder(SearchViewPageBuilder),
      param: {
        'pageType': this.pageType,
        'listMode': this.listMode
      } as Record<string, string>
    })
  }

  aboutToAppear(): void {
    this.pageType = (this.pageParams as Record<string, string>)?.pageType
    this.headTitle =
      (this.pageParams as Record<string, string>)?.headTitle ? (this.pageParams as Record<string, string>)?.headTitle :
        '音频剪辑'
    this.listMode = (this.pageParams as Record<string, string>)?.listMode as LISTMODE ?
      (this.pageParams as Record<string, string>)?.listMode as LISTMODE : 'click'
  }

  jumpPage(pageName: string, builder: WrappedBuilder<[Object]>,
    param?: Record<string, string | number | MusicViewModel | MusicViewModel[]>) {
    phoneRouterControl.jumpPage({
      pageName,
      builder,
      param
    })
  }

  build() {
    NavDestination() {
      Column() {
        SelectHeader({
          title: this.headTitle,
          searchOnclick: this.searchOnclick
        })
        MusicLibraryComponent({
          pageType: this.pageType,
          listMode: this.listMode,
          musicListViewController: this.musicListViewController,
          changeSelected: (res: MusicViewModel[]) => {
            this.selectedMusicList = res
          }
        }).layoutWeight(1)

      }
      .backgroundColor('#0A0D1E')
      .padding({
        top: BarVM.instance.staBarH
      })
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
  }
}