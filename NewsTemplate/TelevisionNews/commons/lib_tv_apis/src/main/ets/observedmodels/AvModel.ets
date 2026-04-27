import { AvResponse } from '../response/AvResponse'

@ObservedV2
export class AvModel implements AvResponse {
  @Trace id: string = ''
  title: string = ''
  description: string = ''
  @Trace isFollow: boolean = false
  coverUrl: string = ''
  total: number = 0
  @Trace section: AvSection[] = []

  constructor(av?: AvModel) {
    this.id = av?.id ?? ''
    this.title = av?.title ?? ''
    this.description = av?.description ?? ''
    this.isFollow = av?.isFollow ?? false
    this.coverUrl = av?.coverUrl ?? ''
    this.total = av?.total ?? 0
    this.section = av?.section.map(item => new AvSection(item)) ?? []
  }
}

@ObservedV2
export class AvSection {
  @Trace id: string = ''
  @Trace title: string = ''
  @Trace duration: number = 0
  @Trace updateTime: string = ''
  @Trace sectionUrl: string = ''
  @Trace coverUrl: string = ''

  constructor(broadcastSection?: AvSection) {
    if (broadcastSection) {
      this.id = broadcastSection.id
      this.title = broadcastSection.title
      this.duration = broadcastSection.duration
      this.updateTime = broadcastSection.updateTime
      this.sectionUrl = broadcastSection.sectionUrl
      this.coverUrl = broadcastSection.coverUrl
    }
  }
}
