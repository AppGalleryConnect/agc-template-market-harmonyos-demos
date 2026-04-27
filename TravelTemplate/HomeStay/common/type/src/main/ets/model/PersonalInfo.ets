@ObservedV2
export class PersonalInfo {
  @Trace id: number = 0;
  @Trace uid: string = '';
  @Trace openId: string = '';
  @Trace nickName: string = '';
  @Trace gender: number = 0;
  @Trace birthday: string = '1970-01-01';
  @Trace phone: string = '';
  @Trace avatar: ResourceStr = '';
}