import { GenderType } from 'collect_personal_info'
import { GENDER_OPTIONS } from 'collect_personal_info/src/main/ets/common/Constant'

export function GenderStringToType(gender: string) {
  if (gender === GENDER_OPTIONS[0].label) {
    return GenderType.MALE
  } else if (gender === GENDER_OPTIONS[1].label) {
    return GenderType.FEMALE
  } else {
    return GenderType.CONFIDENTIALITY
  }
}

export function GenderTypeToString(type: number) {
  if (type === GenderType.MALE) {
    return GENDER_OPTIONS[0].label as string
  } else if (type === GenderType.FEMALE) {
    return GENDER_OPTIONS[1].label as  string
  } else {
    return '保密'
  }
}