@ObservedV2
export class RemarksModel {
  @Trace title = ''
  @Trace choosen = false

  constructor(
    title: string,
    choosen: boolean,
  ) {
    this.title = title
    this.choosen = choosen
  }
}