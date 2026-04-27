import { TimeUtil } from 'common'
import { PersistenceV2 } from '@kit.ArkUI'

@ObservedV2
export class CueWordsItem {
  @Trace id: string = ''
  @Trace title: string = ''
  @Trace content: string = ''
  @Trace time: string = ''
  __ob_id: string = ''
  __ob_title: string = ''
  __ob_content: string = ''
  __ob_time: string = ''

  constructor(id: string, title: string, content: string, time: string) {
    this.id = id
    this.content = content
    this.title = title
    this.time = time
  }

  init() {
    this.id = Date.now().toString()
    this.setTime()
  }

  setTime() {
    this.time = TimeUtil.formatDate(Date.now(), TimeUtil.PATTERN_DATE_TIME_HYPHEN)
  }
}

@ObservedV2
export class CueWordsList {
  @Trace data: CueWordsItem[] = []
  @Trace persistenceCueWords: PersistenceCueWords =
    PersistenceV2.connect(PersistenceCueWords, () => new PersistenceCueWords())!

  constructor(cueWordsList?: CueWordsItem[]) {
    this.data = cueWordsList ?? []
  }

  saveToPersistence() {
    this.persistenceCueWords.content = JSON.stringify(this.data)
  }

  init(data: CueWordsItem[]) {
    this.data = data
    this.saveToPersistence()
  }

  add(data: CueWordsItem) {
    this.data?.push(data)
    this.saveToPersistence()
  }

  delete(id: string) {
    this.data = this.data?.filter(item => item.id !== id)
    this.saveToPersistence()
  }

  deleteIds(ids: string[]) {
    ids.forEach(id => {
      this.delete(id)
    })
    this.saveToPersistence()
  }

  sort() {
    this.data?.sort((a, b) => TimeUtil.parseDate(b.time, TimeUtil.PATTERN_DATE_TIME_HYPHEN) -
    TimeUtil.parseDate(a.time, TimeUtil.PATTERN_DATE_TIME_HYPHEN))
    this.saveToPersistence()
  }

  clear() {
    this.data = []
    this.saveToPersistence()
  }
}

@ObservedV2
export class PersistenceCueWords {
  @Trace content: string = ''
}