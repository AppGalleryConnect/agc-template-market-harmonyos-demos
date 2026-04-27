import { AvSection, NewsEnum } from 'lib_tv_apis'

/**
 * 服务卡片列表item模型
 */

export class FormItemModel {
  id: string = ''
  type: NewsEnum = NewsEnum.Television
  title: string = ''
  description: string = ''
  isFollow: boolean
  coverUrl: string = ''
  total: number = 0
  section: AvSection[] = []

  constructor(id?: string, title?: string, isFollow?: boolean, coverUrl?: string) {
    this.id = id ?? '';
    this.title = title ?? '';
    this.isFollow = isFollow ?? false
    this.coverUrl = coverUrl ?? ''
  }
}